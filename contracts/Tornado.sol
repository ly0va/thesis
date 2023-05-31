// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./MerkleTreeWithHistory.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IVerifier {
  function verifyProof(bytes memory _proof, uint256[5] memory _input) external returns (bool);
  // function verify(bytes calldata _proof) external returns (bool);
}

contract Tornado is MerkleTreeWithHistory, ReentrancyGuard {
  IVerifier public immutable verifier;
  uint256 public denomination;

  mapping(bytes32 => bool) public nullifierHashes;
  // we store all commitments just to prevent accidental deposits with the same commitment
  mapping(bytes32 => bool) public commitments;

  event Deposit(bytes32 indexed commitment, uint32 leafIndex, uint256 timestamp);
  event Withdrawal(address to, bytes32 nullifierHash, address indexed relayer, uint256 fee);
  event FlashLoan(address indexed initiator, address indexed target, uint256 amount);

  /**
    @dev The constructor
    @param _verifier the address of SNARK verifier for this contract
    @param _hasher the address of MiMC hash contract
    @param _denomination transfer amount for each deposit
    @param _merkleTreeHeight the height of deposits' Merkle Tree
  */
  constructor(
    IVerifier _verifier,
    IHasher _hasher,
    uint256 _denomination,
    uint32 _merkleTreeHeight
  ) MerkleTreeWithHistory(_merkleTreeHeight, _hasher) {
    require(_denomination > 0, "denomination should be greater than 0");
    verifier = _verifier;
    denomination = _denomination;
  }

  /**
    @dev Deposit funds into the contract. The caller must send (for ETH) or approve (for ERC20) value equal to or `denomination` of this instance.
    @param _commitment the note commitment, which is PedersenHash(nullifier + secret)
  */
  function deposit(bytes32 _commitment) external payable nonReentrant {
    require(!commitments[_commitment], "Commitments cannot repeat");
    require(msg.value == denomination, "Incorrect ETH amount");

    uint32 insertedIndex = _insert(_commitment);
    commitments[_commitment] = true;

    emit Deposit(_commitment, insertedIndex, block.timestamp);
  }

  /**
    @dev Withdraw a deposit from the contract. `proof` is a zkSNARK proof data, and input is an array of circuit public inputs
    `input` array consists of:
      - merkle root of all deposits in the contract
      - hash of unique deposit nullifier to prevent double spends
      - the recipient of funds
      - optional fee that goes to the transaction sender (usually a relay)
  */
  function withdraw(
    bytes calldata _proof,
    bytes32 _root,
    bytes32 _nullifierHash,
    address payable _recipient,
    address payable _relayer,
    uint256 _fee
  ) external payable nonReentrant {
    require(msg.value == 0, "Message value is supposed to be zero for ETH instance");
    require(_fee <= denomination, "Fee exceeds transfer value");
    require(!nullifierHashes[_nullifierHash], "The note has been already spent");
    require(isKnownRoot(_root), "Cannot find your merkle root"); // Make sure to use a recent one
    require(
      verifier.verifyProof(
        _proof,
        [uint256(_root), uint256(_nullifierHash), uint256(_recipient), uint256(_relayer), _fee]
      ),
      "Invalid withdraw proof"
    );

    nullifierHashes[_nullifierHash] = true;

    (bool success, ) = _recipient.call{ value: denomination - _fee }("");
    require(success, "payment to _recipient did not go through");
    if (_fee > 0) {
      (success, ) = _relayer.call{ value: _fee }("");
      require(success, "payment to _relayer did not go through");
    }

    emit Withdrawal(_recipient, _nullifierHash, _relayer, _fee);
  }

  /** @dev whether a note is already spent */
  function isSpent(bytes32 _nullifierHash) public view returns (bool) {
    return nullifierHashes[_nullifierHash];
  }

  /**
   * @dev Executes a Flash Loan - borrow as much money as you want, but return it by the end of the tx.
   * @param target the contract address to call
   * @param amount the amount to borrow
   * @param data the calldata to call the target contract with
   */
  function flashLoan(address target, uint256 amount, bytes calldata data) external nonReentrant {
    uint256 balance = address(this).balance;

    // execute the call
    (bool success, ) = target.call{ value: amount }(data);
    require(success, "target call failed");

    // 1% premium
    require(address(this).balance >= balance + amount / 100, "flash loan did not repay");
    emit FlashLoan(msg.sender, target, amount);
  }
}
