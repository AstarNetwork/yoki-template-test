// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "forge-std/console.sol";
import "forge-std/Test.sol";
import {TestMe} from "../src/TestMeTemplateERC1155.sol";

// Update this config or import your own (see Miyako-MAR13 contract)
contract Config {
    uint256 public maxSupply = 0; // 0 for unlimited
    string public baseURI = "ipfs://example.com/";
    uint256 public maxMintPerUser = 0; // 0 for unlimited
    uint256 public mintPrice = 0.0005 ether; // 0 for free

    function setSupply(uint256 newNumber) public {
        maxSupply = newNumber;
    }
}

contract BaseTemplateTest is Test {
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
        testMe = new TestMe();
        config = new Config();

        vm.deal(address(this), 100 ether);

        // IMPORTANT Specific to Miyako-MAR13 - delete if not needed
        testMe.changeSaleState(true);
    }

    // IMPORTANT: uncomment relevant line
    function _callMint(address to, uint256 amount) internal {
        /*
        If mint is non-payable please add this line:
            testMe.mint(to, amount);
        If mint is payable please add the lines:
            uint256 price = config.mintPrice();
            testMe.mint{value: price}(to, amount);
        */
        uint256 price = config.mintPrice();
        testMe.mint{value: price}(to, amount);
    }

    // IMPORTANT: comment this test is mint is non payable
    function test_noFreeMint() public {
        address alice = makeAddr("alice");
        vm.expectRevert();
        testMe.mint{value: 0}(alice, 1);
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
        uint256 balanceBefore = testMe.balanceOf(alice, 0);

        uint256 price = config.mintPrice();
        vm.expectRevert();
        testMe.mint{value: price}(alice, 1);
        assertEq(testMe.balanceOf(alice, 0), balanceBefore);
    }

    function test_UserCannotMint() public {
        address alice = makeAddr("alice");
        uint256 price = config.mintPrice();
        vm.deal(alice, 100 ether);
        vm.expectRevert();
        vm.prank(alice);
        testMe.mint{value: price}(alice, 1);
    }

    function test_MaxMintPerUser() public {
        if (config.maxMintPerUser() == 0) {
            return;
        }
        address alice = makeAddr("alice");
        vm.deal(alice, 1000 ether);
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

    function test_mint5AndPrintsTokenUri() public {
        for (uint256 i = 0; i < 5; i++) {
            address someUser = makeAddr(string(abi.encode(i)));
            vm.deal(someUser, 1 ether);
            _callMint(someUser, 1);
        }
        for (uint256 i = 0; i < 5; i++) {
            string memory tokenUri = testMe.uri(i);
            console.log("Token URI: %s", tokenUri);
        }
    }
}