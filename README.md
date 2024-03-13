## Template tests for contracts participating in Yoki Origins

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

## Usage for Yoki contracts:
### Requirements
All contracts participating in Yoki Origins should use this template to ensure that they are compatible with the Yoki Origins ecosystem.

Main requirements used for this template:
- [ ] ER721, ERC721A or ERC1155
- [ ] Minting function is format: `mint(address, uint256)` 
- [ ] Allowed minting is only for MINTER_ROLE 
- [ ] Existance of `tokenUri()` for ERC721
- [ ] Existance of `uri()` for ERC1155
- [ ] Variables `name` and `symbol` are set in contract

### How to use template tests
1. Install Foundry (follow the instructions in the Foundry [documentation](https://book.getfoundry.sh/getting-started/installation))
2. Clone this repository
3. Run `forge test` to make sure your environment is properly set up
4. Create a new forlder with your contract name & date
5. Add a `Config.sol` with your metadata configs
6. Add a `TestMe.sol` with your contract code and rename your contract `TestMe`
7. Create a new file in test folder with your contract name & date
8. Copy the code from BaseTemplate and adapt the constructor and _callMint()
9. Run `forge test -vvv` to ensure that your contract is compatible with Yoki Origins

### Some useful commands:

#### Build

```shell
$ forge build
```

#### Test
Test with verbose output
```shell
$ forge test -vvv
```

#### Format

```shell
$ forge fmt
```

#### Gas Snapshots

```shell
$ forge snapshot
```

#### Help

```shell
$ forge --help
```
