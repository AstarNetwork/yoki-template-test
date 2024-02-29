// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IYokis {
    // External functions
    function adminMint(address account, uint256 id, uint256 amount) external;
    function mint(address account, uint256 id, uint256 amount, bytes memory data) external;
    function mintSpecialYoki() external;
    function mintOma(address account, uint256 amount) external;
    function mintDailyOma(address to, uint256 quantity, uint256 nonce, bytes memory signature) external;
    function mintWithSignature(address to, uint256 tokenId, uint256 quantity, uint256 nonce, bytes memory signature) external;
    function claimFirstEditionCapsule(bytes32[] memory proof) external;
    function setEvolutionPath(uint256 _baseTokenId, uint256[] memory _evolvedTokenId, uint256 _evolutionOmaPayment, uint256 _evolutionTokenPayment) external;
    function setMerkleRoot(bytes32 _merkleRoot) external;
    function setTokenLimit(uint256 _tokenId, uint256 _maxLimit) external;
    function setCapsules(uint256[] memory _tokenIds) external;
    function setCapsuleOmaPayment(uint256 _numTokens) external;
    function withdraw() external;

    // External functions that are view
    function getTokenLimit(uint256 _tokenId) external view returns (uint256);
    function getBaseTokenId(uint256 _tokenId) external view returns (uint256);
    function isEvolutionToken(uint256 _tokenId) external view returns (bool);
    function isCapsuleToken(uint256 _tokenId) external view returns (bool);
}