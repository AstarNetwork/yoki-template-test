// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Config {
    uint256 public maxSupply = 100000; // 0 for unlimited
    string public baseURI = "ipfs://example.com/";
    uint256 public maxMintPerUser = 1; // 0 for unlimited
    uint256 public mintPrice = 0; // 0 for free
}
