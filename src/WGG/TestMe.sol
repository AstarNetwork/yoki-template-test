// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { IERC1155MetadataURI } from "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

contract TestMe is ERC1155URIStorage, Ownable, AccessControl {
    uint256 public minted = 0;

    uint256 public SUPPLY_LIMIT = 15_000;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 private _totalSupplyAll;

    mapping(uint256 id => uint256) private _totalSupply;

    constructor() Ownable(msg.sender) ERC1155("") {
        _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, 0xCB1095416b6A8e0C3ea39F8fe6Df84f4179C93C2);

        _setBaseURI("https://bafybeibtooe3vahtu6z2bwvg2f3mw6acbnoo7e5s6m6fcf2klo77q4wnby.ipfs.nftstorage.link/");
        _setURI(0, "0.json");
        _setURI(1, "1.json");
        _setURI(2, "2.json");
        _setURI(3, "3.json");
        _setURI(4, "4.json");
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            interfaceId == type(IAccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function name() public pure returns (string memory) {
        return "Dragon Ghost x KEKKAI";
    }

    function symbol() public pure returns (string memory) {
        return "DGK";
    }

    function setURI(uint256 tokenId, string memory tokenURI) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(tokenId, tokenURI);
    }

    function setBaseURI(string memory baseURI) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setBaseURI(baseURI);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(minted + amount <= SUPPLY_LIMIT, "Supply limit exceeded");
        for (uint i = 0; i < amount; i++) {
            _mint(to, (minted + i) % 5, 1, "");
        }
        minted += amount;
    }

    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupplyAll;
    }

    function exists(uint256 id) public view virtual returns (bool) {
        return totalSupply(id) > 0;
    }

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual override {
        super._update(from, to, ids, values);

        if (from == address(0)) {
            uint256 totalMintValue = 0;
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 value = values[i];
                _totalSupply[ids[i]] += value;
                totalMintValue += value;
            }
            _totalSupplyAll += totalMintValue;
        }

        if (to == address(0)) {
            uint256 totalBurnValue = 0;
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 value = values[i];

                unchecked {
                    _totalSupply[ids[i]] -= value;
                    totalBurnValue += value;
                }
            }
            unchecked {
                _totalSupplyAll -= totalBurnValue;
            }
        }
    }
}
