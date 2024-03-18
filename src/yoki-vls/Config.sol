// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Config {
    uint256 public maxSupply = 30000; // 0 for unlimited
    string public baseURI = "https://gateway.irys.xyz/hvxDR2qlC27-iqN8wo9DaWA_PZ4tbjaZWXhTumE4pVk/";
    uint256 public maxMintPerUser = 0; // 0 for unlimited
    uint256 public mintPrice = 0; // 0 for free
}
