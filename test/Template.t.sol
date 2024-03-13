// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "forge-std/console.sol";
import {Test, console} from "forge-std/Test.sol";
import {TestMe} from "../src/TestMe.sol";
import {Config} from "../src/Config.sol";

contract TemplateTest is Test {
    TestMe public testMe;
    Config public config;

    function setUp() public {
        /* Here please set up you constructors args
        for admin and miter role, please use address(this) so that this Test contract have all access rights
        example for:
            constructor(address defaultAdmin, address minter, string memory name, string memory symbol, uint256 _maxSupply, uint256 _mintLimit, string memory _uri) ERC721(name, symbol) { ... }
        you can use:
            testMe = new TestMe(address(this), address(this), "NAME", "SYMBOL", 1000, 1, "ipfs://example.com/");
        */
        testMe = new TestMe(address(this), "NAME", "SYMBOL");
        config = new Config();

        vm.deal(address(this), 100 ether);
    }

    function test_EnsureMinterRole() public {
        testMe.grantRole(testMe.MINTER_ROLE(), address(this));
        assertEq(testMe.hasRole(testMe.MINTER_ROLE(), address(this)), true);
    }

    function test_MintOne() public {
        address alice = makeAddr("alice");
        testMe.grantRole(testMe.MINTER_ROLE(), address(this));
        testMe.mint{value: config.mintPrice()}(alice, 1);
    }

    function test_MintWithNonMinterRoleFails() public {
        address alice = makeAddr("alice");
        vm.deal(alice, 100 ether);
        testMe.revokeRole(testMe.MINTER_ROLE(), address(this));
        uint256 balanceBefore = testMe.balanceOf(alice);

        uint256 price = config.mintPrice();
        vm.expectRevert();
        testMe.mint{value: price}(alice, 1);
        assertEq(testMe.balanceOf(alice), balanceBefore);
    }

    function test_UserCannotMint() public {
        address alice = makeAddr("alice");
        vm.deal(alice, 100 ether);
        uint256 price = config.mintPrice();
        vm.expectRevert();
        vm.prank(alice);
        testMe.mint{value: price}(alice, 1);
    }

    function test_MaxMintPerUser() public {
        if (config.maxMintPerUser() == 0) {
            return;
        }
        address alice = makeAddr("alice");
        vm.deal(alice, 1 ether);
        for (uint256 i = 0; i < config.maxMintPerUser(); i++) {
            testMe.mint{value: config.mintPrice()}(alice, 1);
        }

        uint256 price = config.mintPrice();
        vm.expectRevert();
        testMe.mint{value: price}(alice, 1);
    }

    function test_maxSuppy() public {
        if (config.maxSupply() == 0) {
            return;
        }
        uint256 price = config.mintPrice();
        for (uint256 i = 0; i < config.maxSupply(); i++) {
            address someUser = makeAddr(string(abi.encode(i)));
            vm.deal(someUser, 1 ether);
            testMe.mint{value: price}(someUser, 1);
        }

        address alice = makeAddr("alice");
        vm.expectRevert();
        vm.deal(alice, 1 ether);
        testMe.mint{value: price}(alice, 1);
    }

    function test_noFreeMint() public {
        address alice = makeAddr("alice");
        vm.expectRevert();
        testMe.mint{value: 0}(alice, 1);
    }

    function test_getTokenUri() public {
        address alice = makeAddr("alice");
        testMe.mint{value: config.mintPrice()}(alice, 1);
        string memory tokenUri = testMe.tokenURI(0);
        console.log("Token URI: %s", tokenUri);
    }

    function test_totalSupplyIsIncreasing() public {
        address alice = makeAddr("alice");
        testMe.grantRole(testMe.MINTER_ROLE(), address(this));
        assertEq(testMe.totalSupply(), 0);
        testMe.mint{value: config.mintPrice()}(alice, 1);
        assertEq(testMe.totalSupply(), 1);
    }
}
