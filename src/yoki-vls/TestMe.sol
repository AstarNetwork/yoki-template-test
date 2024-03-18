// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import { ERC721AQueryable } from "./ERC721AQueryable.sol";
import "./ERC721A.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC4906 {
    /// @dev This event emits when the metadata of a token is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFT.
    event MetadataUpdate(uint256 _tokenId);

    /// @dev This event emits when the metadata of a range of tokens is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFTs.
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
}

error MaxSupplyOver();
error NotEnoughFunds(uint256 balance);
error NotMintable();
error AlreadyClaimedMax();
error MintAmountOver();

contract TestMe is ERC721A, IERC4906, ERC721AQueryable, AccessControl, ERC2981, Ownable {
    string private constant BASE_EXTENSION = ".json";
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public immutable maxSupply = 30000;
    bool public mintable = true;

    string private baseURI = "https://gateway.irys.xyz/hvxDR2qlC27-iqN8wo9DaWA_PZ4tbjaZWXhTumE4pVk/";

    mapping(uint256 => string) private metadataURI;

    constructor() ERC721A("YokiVLS", "YokiVLS") Ownable(_msgSender()) {
        _setDefaultRoyalty(_msgSender(), 1000);
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    modifier whenMintable() {
        if (mintable == false) revert NotMintable();
        _;
    }

    // internal
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        if (bytes(metadataURI[tokenId]).length == 0) {
            return string(abi.encodePacked(ERC721A.tokenURI(tokenId), BASE_EXTENSION));
        } else {
            return metadataURI[tokenId];
        }
    }

    function setTokenMetadataURI(uint256 tokenId, string memory metadata) external onlyRole(DEFAULT_ADMIN_ROLE) {
        metadataURI[tokenId] = metadata;
        emit MetadataUpdate(tokenId);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function mint(address _to, uint256 _mintAmount) external whenMintable onlyRole(MINTER_ROLE) {
        if (_totalMinted() + _mintAmount > maxSupply) revert MaxSupplyOver();
        _mint(_to, _mintAmount);
    }

    function ownerMint(address _address, uint256 count) external onlyRole(MINTER_ROLE) {
        _safeMint(_address, count);
    }

    function setMintable(bool _state) external onlyRole(DEFAULT_ADMIN_ROLE) {
        mintable = _state;
    }

    function setBaseURI(string memory _newBaseURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = _newBaseURI;
        emit BatchMetadataUpdate(_startTokenId(), totalSupply());
    }

    function withdraw() external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        payable(_msgSender()).transfer(address(this).balance);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, IERC721A, ERC2981, AccessControl) returns (bool) {
        return ERC721A.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setDefaultRoyalty(receiver, feeNumerator);
    }
}