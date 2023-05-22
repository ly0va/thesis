// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IHasher {
  function MiMCpe7(uint256 in_x, uint256 in_k) external pure returns (uint256);
}

contract MerkleTreeWithHistory {
  uint256 public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
  uint256 public constant ZERO_VALUE = 16681341018512387888314998799321041707041291844067824936040154362796666763581; // = keccak256("lyova") % FIELD_SIZE
  IHasher public immutable hasher;

  uint32 public levels;

  // filledSubtrees and roots could be bytes32[size], but using mappings makes it cheaper because
  // it removes index range check on every interaction
  mapping(uint256 => bytes32) public filledSubtrees;
  mapping(uint256 => bytes32) public roots;
  uint32 public constant ROOT_HISTORY_SIZE = 30;
  uint32 public currentRootIndex = 0;
  uint32 public nextIndex = 0;

  constructor(uint32 _levels, IHasher _hasher) {
    require(_levels > 0, "_levels should be greater than zero");
    require(_levels < 32, "_levels should be less than 32");
    levels = _levels;
    hasher = _hasher;

    for (uint32 i = 0; i < _levels; i++) {
      filledSubtrees[i] = zeros(i);
    }

    roots[0] = zeros(_levels);
  }

  /**
    @dev Hash 2 tree leaves, returns MiMC(_left, _right)
  */
  function hashLeftRight(
    IHasher _hasher,
    bytes32 _left,
    bytes32 _right
  ) public pure returns (bytes32) {
    require(uint256(_left) < FIELD_SIZE, "_left should be inside the field");
    require(uint256(_right) < FIELD_SIZE, "_right should be inside the field");

    uint256 hash = _hasher.MiMCpe7(uint256(_left), 0);
    uint256 R = addmod(uint256(_left), hash, FIELD_SIZE);

    hash = _hasher.MiMCpe7(uint256(_right), R);
    R = addmod(R, uint256(_right), FIELD_SIZE);
    R = addmod(R, hash, FIELD_SIZE);
    return bytes32(R);
  }

  function _insert(bytes32 _leaf) internal returns (uint32 index) {
    uint32 _nextIndex = nextIndex;
    require(_nextIndex != (1 << levels), "Merkle tree is full. No more leaves can be added");
    uint32 currentIndex = _nextIndex;
    bytes32 currentLevelHash = _leaf;
    bytes32 left;
    bytes32 right;

    for (uint32 i = 0; i < levels; i++) {
      if (currentIndex % 2 == 0) {
        left = currentLevelHash;
        right = zeros(i);
        filledSubtrees[i] = currentLevelHash;
      } else {
        left = filledSubtrees[i];
        right = currentLevelHash;
      }
      currentLevelHash = hashLeftRight(hasher, left, right);
      currentIndex /= 2;
    }

    uint32 newRootIndex = (currentRootIndex + 1) % ROOT_HISTORY_SIZE;
    currentRootIndex = newRootIndex;
    roots[newRootIndex] = currentLevelHash;
    nextIndex = _nextIndex + 1;
    return _nextIndex;
  }

  /**
    @dev Whether the root is present in the root history
  */
  function isKnownRoot(bytes32 _root) public view returns (bool) {
    if (_root == 0) {
      return false;
    }
    uint32 _currentRootIndex = currentRootIndex;
    uint32 i = _currentRootIndex;
    do {
      if (_root == roots[i]) {
        return true;
      }
      if (i == 0) {
        i = ROOT_HISTORY_SIZE;
      }
      i--;
    } while (i != _currentRootIndex);
    return false;
  }

  /**
    @dev Returns the last root
  */
  function getLastRoot() public view returns (bytes32) {
    return roots[currentRootIndex];
  }

  /// @dev provides Zero (Empty) elements for a MiMC MerkleTree. Up to 32 levels
  function zeros(uint256 i) public pure returns (bytes32) {
    if (i == 0) return bytes32(0x24e14def1367f8cfff22a672effa2fc4a25d7fae33bcacd02e3dda355e7bb93d);
    if (i == 1) return bytes32(0x0298da57ac1f509f79ce0e39c8437041edbc720023f8417c382a02e9bafa80db);
    if (i == 2) return bytes32(0x0d1649579cbc0b28b6ffaa13ff11cabab4c491d19901f561b3b6754618f91f0f);
    if (i == 3) return bytes32(0x08b3424b4cde797d221d349217b1460500765686f6f568022eb0de66acf8e8c8);
    if (i == 4) return bytes32(0x2a9e576261e6642824c48a62a157451e18860cfd3f0cbd0bc897a65d14697b57);
    if (i == 5) return bytes32(0x20c8c71174cd88344ab1f6a8fc6f8fb1ca4171ea011a35251da2b51e6de22f87);
    if (i == 6) return bytes32(0x1e24eb1cbee5d6b4ecca6796e78311c5f163dffb57dc6f400230327c2ab214ee);
    if (i == 7) return bytes32(0x14224f6a47d497d514976440b681f2535d6fff3f49ca8805d121e79173e8b6a9);
    if (i == 8) return bytes32(0x0755987d3b9fbc479d270ee2d011b11824c7904993b8b90f52637c92ae4686d1);
    if (i == 9) return bytes32(0x25e32d5ff82ed7d79064ca4c42dfb9938ba168c0b3fcadcc6199d3423b385abb);
    if (i == 10) return bytes32(0x117d475c0cef8756dca42f9f8d87bb819f9ae06ee54b869ae6fbecda509a9d49);
    if (i == 11) return bytes32(0x10422796cfa47b9c91fd491fb2311d495b9761255afa4ba3852ac5601ce61d56);
    if (i == 12) return bytes32(0x16994ccfa75a1837e28765f686a4a825f6e7409139f1dd1eb45c743be11c4b97);
    if (i == 13) return bytes32(0x0febeef998188bb004a1f496f808596de996de2862df1261754bb33f72a8d766);
    if (i == 14) return bytes32(0x1c2ea33b380ef2caa77c25ae4b34313b29084cfb76fee0cb96ac2693eeb214b3);
    if (i == 15) return bytes32(0x1fb242870ac2dfea756c5c8ac638b5702aa41c99402c749ff0deb09ce9e4505c);
    if (i == 16) return bytes32(0x16161d0def54f18e052cf9827ad8da770c266303c3e66b3025fe72b8ff75b72a);
    if (i == 17) return bytes32(0x2215f3c0ca0ba5d0d274d0ca0bb29ad5796ffe16113649d178804537ad5d3f49);
    if (i == 18) return bytes32(0x2caabe3e0fb0540ba92fc1b9519896162df0b0f58efc3a220c6c5dd06a3fd5d1);
    if (i == 19) return bytes32(0x1c30e4cca571ffaa42d0303c60b4f1fb24e9e64da0c5d720f65acc7cf3a18e71);
    if (i == 20) return bytes32(0x028cc04c444f0c0789fad6867ad12649147099832ea4a0df8b8b0d07bcdcf40e);
    if (i == 21) return bytes32(0x20c7099c0069fd438659ef52ebe57e6ea079a7c5aeb64a85887a41a18fb4b90d);
    if (i == 22) return bytes32(0x2e7ca27854d9a8c00d1b03a9b895247d9064abe50ed15105cd005225ced62c31);
    if (i == 23) return bytes32(0x1fd08033cff95cae9403ded591ed8dbe36e81b1206086e66ba22f399c8b4c8ee);
    if (i == 24) return bytes32(0x15787310feda7fdaf40526b2fbd390eb27733aa20592ee9bda4625ba425d23aa);
    if (i == 25) return bytes32(0x2f1b5feef13c75a37542e9a96d702e48ad8944c0bac048f7c78b8aa562480cfb);
    if (i == 26) return bytes32(0x1ba82d816f1fc2d6e4360fcbb357a2ee58ec23cc25521304d07ac08ab5b26a6c);
    if (i == 27) return bytes32(0x2932dc65eddb84dde0a872a75d04870e50eba0d5a7a1f1b38609155c99b77e5f);
    if (i == 28) return bytes32(0x1afea70d7071f058db508c44a6fc74758cce9814af18fadf3c3de59bb04f4a9f);
    if (i == 29) return bytes32(0x061d0c40aab89d427bfecb0bd24bd930bd75e09cde56c94eb948f0b03b3f9aaa);
    if (i == 30) return bytes32(0x0d2d070b761041895b2f84182d7fe18297f489ae9654278667d83d083b8be04f);
    if (i == 31) return bytes32(0x11269aa11b12f05320806b9b27e26dda262059b9f9bc46e6b43e9a12d9a91be1);
    revert("Index out of bounds");
  }
}
