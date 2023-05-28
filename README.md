# Anoymous Transfers Protocol in Noir

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
nargo proof main
nargo verify main
```

Run tests:

```
yarn hardhat test
```
