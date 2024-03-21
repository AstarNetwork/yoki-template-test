// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TestMe is ERC721Enumerable, ERC721URIStorage, AccessControl {
    uint256 public _tokenIds;
    uint256 public price;
    address payable feeReceipent;
    string public baseURI;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event CardMinted(address indexed to, uint256 tokenId);

    constructor(string memory _name, string memory _symbol, string memory __baseURI) ERC721(_name, _symbol) {
        baseURI = __baseURI;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 /* tokenId */) public view virtual override(ERC721URIStorage, ERC721) returns (string memory) {
        return _baseURI();
    }

    function mintYooldoPlayingCards(address to) external payable {
        require(msg.value == price, "YooldoPlayingCard: Incorrect amount sent");
        (bool sent, ) = feeReceipent.call{value: price}("");
        require(sent, "YooldoPlayingCard: Sent failed");

        for (uint8 i = 0; i < 2; i++) {
            _tokenIds++;
            _safeMint(to, _tokenIds);
            emit CardMinted(to, _tokenIds);
        }
    }

    function updateDetails(address payable _feeReceipent, uint256 _price, address _minter) external onlyRole(DEFAULT_ADMIN_ROLE) {
        feeReceipent = _feeReceipent;
        price = _price;
        _grantRole(MINTER_ROLE, _minter);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, ERC721URIStorage, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mint(address to, uint256 amount) public payable onlyRole(MINTER_ROLE) {
        require(msg.value == price * amount, "YooldoPlayingCard: Incorrect amount sent");
        (bool sent, ) = feeReceipent.call{value: price * amount}("");
        require(sent, "YooldoPlayingCard: Sent failed");

        for (uint8 i = 0; i < 2 * amount; i++) {
            _tokenIds++;
            _safeMint(to, _tokenIds);
            emit CardMinted(to, _tokenIds);
        }
    }

    function _update(address to, uint256 tokenId, address auth) override(ERC721Enumerable, ERC721) internal virtual returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) override(ERC721Enumerable, ERC721) internal virtual {
        super._increaseBalance(account, value);
    }
}
