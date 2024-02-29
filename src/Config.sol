// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Config {
    uint256 public maxSupply = 10000;
    string public baseURI = "ipfs://example.com/";

    function setSupply(uint256 newNumber) public {
        maxSupply = newNumber;
    }
}
