// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { IERC1155MetadataURI } from "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

contract TestMe is ERC1155URIStorage, Ownable, AccessControl {
    uint256 public minted = 0;

    uint256 public SUPPLY_LIMIT = 450;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 private _totalSupplyAll;

    mapping(uint256 id => uint256) private _totalSupply;

    constructor() Ownable(msg.sender) ERC1155("") {
        _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, 0xCB1095416b6A8e0C3ea39F8fe6Df84f4179C93C2);

        _setURI(1, "ipfs://QmRD4w6rFQPbg2dhfFwy76x8inyvegeH81D57MsVmSeJ8Q/1");
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            interfaceId == type(IAccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function name() public pure returns (string memory) {
        return "Bitget x Suzuki Jimny NFT";
    }

    function symbol() public pure returns (string memory) {
        return "BGJIMNY";
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(minted + amount <= SUPPLY_LIMIT, "Supply limit exceeded");
        _mint(to, 1, amount, "");
        minted += amount;
    }

    function setURI(uint256 tokenId, string memory tokenURI) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(tokenId, tokenURI);
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