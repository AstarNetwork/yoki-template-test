// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Config {
    uint256 public supply = 10000;

    function setSupply(uint256 newNumber) public {
        supply = newNumber;
    }

}
