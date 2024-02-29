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

    function test_MintOne() public {
        address alice = makeAddr("alice");
        partnerNFT.grantRole(partnerNFT.MINTER_ROLE(), address(this));
        partnerNFT.mint(alice, 1);
    }

    function testFails_UnauthorisedMinter() public {
        address someUser = address(1234);
        vm.prank(someUser);
        partnerNFT.mint(someUser, 1);
    }

    function test_TokenUri() public {
        // alice mints 1 token
        address alice = address(1234);
        partnerNFT.grantRole(partnerNFT.MINTER_ROLE(), address(this));
        partnerNFT.mint(alice, 1);

        // set BAseUri
        string memory baseURI = "ipfs://example.com/";
        partnerNFT.setBaseURI(baseURI);
        // get the token URI
        string memory uri = partnerNFT.tokenURI(1);
    

        assertEq(uri, string.concat(baseURI, "1.json"), "unexpected token URI");
    }

    function testFails_TokenUriNotExist() public {
        // alice mints 1 token
        address alice = address(1234);
        partnerNFT.grantRole(partnerNFT.MINTER_ROLE(), address(this));
        partnerNFT.mint(alice, 1);

        // set BAseUri
        string memory baseURI = "ipfs://example.com/";
        partnerNFT.setBaseURI(baseURI);
        uint256 supply = partnerNFT.maxSupply();
        // get the token URI
        string memory _uri = partnerNFT.tokenURI(supply+1);
    }

}
