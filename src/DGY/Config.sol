// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Config {
    uint256 public maxSupply = 8888; // 0 for unlimited
    string public baseURI = "ipfs://example.com/";
    uint256 public maxMintPerUser = 8; // 0 for unlimited
    uint256 public mintPrice = 0; // 0 for free
}