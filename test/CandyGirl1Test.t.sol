// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "forge-std/console.sol";
import {Test, console} from "forge-std/Test.sol";
import {TestMe} from "../src/CandyGirl1-MAR12/TestMe.sol";
import {Config} from "../src/CandyGirl1-MAR12/Config.sol";

contract TestMe1Test is Test {
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
        testMe = new TestMe(address(this), address(this), "NAME", "SYMBOL", 3, "ipfs");
        config = new Config();

        vm.deal(address(this), 100 ether);
    }

    function _callMint(address to, uint256 amount) internal {
        testMe.mint(to, amount);
    }

    function test_EnsureMinterRole() public {
        testMe.grantRole(testMe.MINTER_ROLE(), address(this));
        assertEq(testMe.hasRole(testMe.MINTER_ROLE(), address(this)), true);
    }

    function test_MintOne() public {
        address alice = makeAddr("alice");
        testMe.grantRole(testMe.MINTER_ROLE(), address(this));
        _callMint(alice, 1);
    }

    function test_MintWithNonMinterRoleFails() public {
        address alice = makeAddr("alice");
        vm.deal(alice, 100 ether);
        testMe.revokeRole(testMe.MINTER_ROLE(), address(this));
        uint256 balanceBefore = testMe.balanceOf(alice);

        vm.expectRevert();
        _callMint(alice, 1);
        assertEq(testMe.balanceOf(alice), balanceBefore);
    }

    function test_UserCannotMint() public {
        address alice = makeAddr("alice");
        vm.deal(alice, 100 ether);
        vm.expectRevert();
        vm.prank(alice);
        _callMint(alice, 1);
    }

    function test_MaxMintPerUser() public {
        if (config.maxMintPerUser() == 0) {
            return;
        }
        address alice = makeAddr("alice");
        vm.deal(alice, 1 ether);
        for (uint256 i = 0; i < config.maxMintPerUser(); i++) {
            _callMint(alice, 1);
        }

        vm.expectRevert();
        _callMint(alice, 1);
    }

    function test_maxSuppy() public {
        if (config.maxSupply() == 0) {
            return;
        }

        for (uint256 i = 0; i < config.maxSupply(); i++) {
            address someUser = makeAddr(string(abi.encode(i)));
            vm.deal(someUser, 1 ether);
            _callMint(someUser, 1);
        }

        address alice = makeAddr("alice");
        vm.expectRevert();
        vm.deal(alice, 1 ether);
        _callMint(alice, 1);
    }

    function test_noFreeMint() public {
        if (config.mintPrice() == 0) {
            return;
        }
        address alice = makeAddr("alice");
        vm.expectRevert();
        _callMint(alice, 1);
    }

    function test_totalSupplyIsIncreasing() public {
        address alice = makeAddr("alice");
        testMe.grantRole(testMe.MINTER_ROLE(), address(this));
        assertEq(testMe.totalSupply(), 0);
        _callMint(alice, 1);
        assertEq(testMe.totalSupply(), 1);
    }

    function test_mint5AndPrintsTokenUri() public {
        for (uint256 i = 0; i < 5; i++) {
            address someUser = makeAddr(string(abi.encode(i)));
            vm.deal(someUser, 1 ether);
            _callMint(someUser, 1);
        }
        for (uint256 i = 0; i < 5; i++) {
            string memory tokenUri = testMe.tokenURI(i);
            console.log("Token URI: %s", tokenUri);
        }
    }

    function test_totalSupplyIsPublic() public {
        uint256 supply = testMe.totalSupply();
        console.log("Total Supply: %s", supply);
    }
}
