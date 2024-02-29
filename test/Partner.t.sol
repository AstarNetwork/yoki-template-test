// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {PartnerNFT} from "../src/PartnerNFT.sol";

contract PartnerNFTTest is Test {
    PartnerNFT public partnerNFT;

    function setUp() public {
        partnerNFT = new PartnerNFT("Partner", "PTN");
    }

    function test_MinterRole() public {
        partnerNFT.grantRole(partnerNFT.MINTER_ROLE(), address(this));
        assertEq(partnerNFT.hasRole(partnerNFT.MINTER_ROLE(), address(this)), true);
    }

}
