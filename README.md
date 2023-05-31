# Anonymous Transfers Protocol in Noir

Install:

```
git clone https://github.com/ly0va/thesis
cd thesis
yarn install
```

Generate Verifier and compile contracts:

```
yarn hardhat verifier
yarn hardhat compile
```

Generate and verify ZKP with Noir:

```
cd circuits
nargo prove main
nargo verify main
```

Compile `thesis.pdf`:

```
typst compile typ/thesis.typ
```

Run tests:

```
yarn hardhat test
```

Expected output:

```
  Hasher
    ✔ should deploy MiMC7 hasher (334ms)

  Private Transfer
    ✔ should deploy the Tornado contract (76ms)
    ✔ should make a deposit (389ms)
    ✔ should perform a withdrawal (510ms)

  Merkle Tree
    ✔ should deploy the Merkle Tree contract (161ms)
    ✔ should test empty hashes (441ms)
    ✔ should test root value


  7 passing (3s)
```


