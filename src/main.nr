use dep::std::hash;

global N = 4;

fn main(
  secret: Field,
  nullifier: Field, 
  nullifier_hash: pub Field,
  // public contract inputs
  recipient: pub Field,
  fee: pub Field,
  relayer: pub Field,
  // Merkle membership proof
  root: pub Field, 
  index: Field,
  merkle_path: [Field; N],
) -> pub [Field; 3] {
    constrain nullifier_hash == hash::pedersen([nullifier])[1];

    // Compute input note commitment
    let commitment = hash::pedersen([nullifier, secret])[1];

    // Check that the input note commitment is in the root
    constrain root == compute_merkle_root(commitment, index, merkle_path);
    
    // Cannot have unused variables, return public contract inputs
    [recipient, fee, relayer]
}

// Returns the root of the Merkle tree from the provided leaf and its Merkle path, using MiMC hash
fn compute_merkle_root(leaf: Field, index: Field, merkle_path: [Field]) -> Field {
    let index_bits = index.to_le_bits(N as u32);
    let mut current = leaf;
    for i in 0..N {
        let path_bit = index_bits[i] as bool;
        let (hash_left, hash_right) = if path_bit {
            (merkle_path[i], current)
        } else {
            (current, merkle_path[i])
        };
        current = hash::mimc_bn254([hash_left, hash_right]);
    };
    current
}
