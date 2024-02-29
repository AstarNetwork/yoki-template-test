// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./IYokis.sol";

interface IPartnerNFT {
    function mint(address to, uint256 amount) external;
}

interface IPayablePartnerNFT {
    function mint(address to, uint256 amount) external payable;
}

contract Proxy is AccessControl {
    using ECDSA for bytes32;

    uint256 public constant OMA_TOKEN_ID = 0;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => bool) usedNonces;

    event MultiMinted(address from, address yokiContract, address partnerNftContract, address to, uint256 omaAmount, uint256 partnerNFTTokenId);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function multiMintNonPayable(
        address partnerNFTAddress,
        address yokisAddress,
        address to,
        uint256 omaAmount,
        uint256 partnerNftAmount,
        uint256 nonce,
        bytes memory signature
    ) external {
        _verifySignature(to, omaAmount, partnerNftAmount, nonce, "multiMintNonPayable", signature);

        IYokis(yokisAddress).mintOma(to, omaAmount);
        IPartnerNFT(partnerNFTAddress).mint(to, partnerNftAmount);

        emit MultiMinted(msg.sender, yokisAddress, partnerNFTAddress, to, omaAmount, partnerNftAmount);
    }

    function multiMintPayable(
        address partnerNFTAddress,
        address yokisAddress,
        address to,
        uint256 omaAmount,
        uint256 partnerNftAmount,
        uint256 nonce,
        bytes memory signature
    ) external payable {
        require(msg.value > 0, "Proxy: mint price is greater than 0");
        _verifySignature(to, omaAmount, partnerNftAmount, nonce, "multiMintPayable", signature);

        IYokis(yokisAddress).mintOma(to, omaAmount);
        // Assuming the PartnerNFT contract's mint function requires a payment.
        IPayablePartnerNFT(partnerNFTAddress).mint{value: msg.value}(to, partnerNftAmount);

        emit MultiMinted(msg.sender, yokisAddress, partnerNFTAddress, to, omaAmount, partnerNftAmount);
    }

    function multiMintNonPayableMinter(
        address partnerNFTAddress,
        address yokisAddress,
        address to,
        uint256 omaAmount,
        uint256 partnerNftAmount
    ) external onlyRole(MINTER_ROLE) {
        IYokis(yokisAddress).mintOma(to, omaAmount);
        IPartnerNFT(partnerNFTAddress).mint(to, partnerNftAmount);

        emit MultiMinted(msg.sender, yokisAddress, partnerNFTAddress, to, omaAmount, partnerNftAmount);
    }

    function multiMintPayableMinter(
        address partnerNFTAddress,
        address yokisAddress,
        address to,
        uint256 omaAmount,
        uint256 partnerNftAmount
    ) external payable onlyRole(MINTER_ROLE) {
        require(msg.value > 0, "Proxy: mint price is greater than 0");
        IYokis(yokisAddress).mintOma(to, omaAmount);
        IPayablePartnerNFT(partnerNFTAddress).mint{value: msg.value}(to, partnerNftAmount);

        emit MultiMinted(msg.sender, yokisAddress, partnerNFTAddress, to, omaAmount, partnerNftAmount);
    }

    function _prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
    }

    function _verifySignature(
        address to,
        uint256 omaAmount,
        uint256 partnerNftAmount,
        uint256 nonce,
        string memory methodName,
        bytes memory signature
    ) internal {
        require(!usedNonces[nonce], "Proxy: signature nonce already used.");
        bytes32 hash = keccak256(
            abi.encodePacked(to, omaAmount, partnerNftAmount, nonce, address(this), methodName)
        );

        bytes32 message = _prefixed(hash);
        address signer = message.recover(signature);
        require(
            hasRole(DEFAULT_ADMIN_ROLE, signer),
            "Proxy: bad signer role signature."
        );
        usedNonces[nonce] = true;
    }
}
