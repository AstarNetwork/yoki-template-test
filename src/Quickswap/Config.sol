// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Config {
    uint256 public maxSupply = 100000; // 0 for unlimited
    string public baseURI = "ipfs://bafybeiegxej6xgtvxqnec66dv6j4xiupsq4f56kfgcqdmifxxebr4m4nf4/";
    uint256 public maxMintPerUser = 0; // 0 for unlimited
    uint256 public mintPrice = 1400000000000000 wei; // 0 for free
}