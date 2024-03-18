//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract TestMe is ERC721, ERC721URIStorage, AccessControl, Ownable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public constant MAX_SUPPLY = 30000;
    uint256 public constant MAX_PUBLIC_MINT = 10;
    uint256 public constant PRICE_PER_TOKEN = 0.0007 ether;

    string public baseURI = "";
    uint256 public totalSupply = 0;

    constructor(address minter, string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, minter);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        require(tokenId <= totalSupply, "not found");
        return string.concat(baseURI, Strings.toString(tokenId));
    }

    function setURI (string memory uri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = uri;
    }

    function mint(address to, uint numberOfTokens) payable public onlyRole(MINTER_ROLE) {
        require(numberOfTokens <= MAX_PUBLIC_MINT, "exceed per mint");
        require(totalSupply + numberOfTokens <= MAX_SUPPLY, "exceed total supply");
        require(PRICE_PER_TOKEN * numberOfTokens <= msg.value, "insufficient tokens");

        for (uint256 i = 0; i < numberOfTokens; i++) {
            totalSupply = totalSupply + 1;
            _safeMint(to, totalSupply);
        }
    }

    function withdraw(address to) public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 amount = address(this).balance;
        require(amount > 0, "no balance");
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "fail withdraw");
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721URIStorage, AccessControl)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    receive() external payable { }
    fallback() external payable { }
}