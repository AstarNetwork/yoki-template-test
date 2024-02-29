// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {TemplateNFT} from "../src/TemplateNFT.sol";

contract TemplateNFTTest is Test {
    TemplateNFT public templateNFT;

    function setUp() public {
        templateNFT = new TemplateNFT("Partner", "PTN");
    }

    function test_MinterRole() public {
        templateNFT.grantRole(templateNFT.MINTER_ROLE(), address(this));
        assertEq(templateNFT.hasRole(templateNFT.MINTER_ROLE(), address(this)), true);
    }

    function test_MintOne() public {
        address alice = makeAddr("alice");
        templateNFT.grantRole(templateNFT.MINTER_ROLE(), address(this));
        templateNFT.mint(alice, 1);
    }

    function testFails_UnauthorisedMinter() public {
        address someUser = address(1234);
        vm.prank(someUser);
        templateNFT.mint(someUser, 1);
    }

    function test_TokenUri() public {
        // alice mints 1 token
        address alice = address(1234);
        templateNFT.grantRole(templateNFT.MINTER_ROLE(), address(this));
        templateNFT.mint(alice, 1);

        // set BAseUri
        string memory baseURI = "ipfs://example.com/";
        templateNFT.setBaseURI(baseURI);
        // get the token URI
        string memory uri = templateNFT.tokenURI(1);
    

        assertEq(uri, string.concat(baseURI, "1.json"), "unexpected token URI");
    }

    function testFails_TokenUriNotExist() public {
        // alice mints 1 token
        address alice = address(1234);
        templateNFT.grantRole(templateNFT.MINTER_ROLE(), address(this));
        templateNFT.mint(alice, 1);

        // set BAseUri
        string memory baseURI = "ipfs://example.com/";
        templateNFT.setBaseURI(baseURI);
        uint256 supply = templateNFT.maxSupply();
        // get the token URI
        string memory _uri = templateNFT.tokenURI(supply+1);
    }

}
