// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title GottaGachaBall contract by NFT Trader
 * @dev Extends ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Pausable, AccessControl basic implementation
 * @author Salad Labs Inc.
*/
contract TestMe is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Pausable, AccessControl, Ownable {
    //bytes identifier for the role `MINTER_ROLE`
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    //price
    uint256 public _tokenPrice = 1000000000000000; //0.001 ETH

    //max supply
    uint256 public MAX_TOKENS;

    //number that represents the max number of tokens purchasable in one shot
    uint public constant mintLimit = 30;

    //boolean that represents if the ALLOW_PUBLIC_MINT is enabled
    bool public ALLOW_PUBLIC_MINT = false;

    //boolean that represents if the ALLOW_MINTER_ROLE_MINT is enabled
    bool public ALLOW_MINTER_ROLE_MINT = true;

    //CONSTRUCTOR

    constructor(address _defaultAdmin, address _minter, uint256 _supply)
    ERC721("GottaGachaBall", "GGB")
    Ownable(_defaultAdmin)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _grantRole(MINTER_ROLE, _minter);

        MAX_TOKENS = _supply;
    }

    // MODIFIERS

    modifier whenPublicMint {
        require(ALLOW_PUBLIC_MINT, "Public mint is disabled.");

        _;
    }

    modifier whenMintAstar {
        require(ALLOW_MINTER_ROLE_MINT, "MINTER_ROLE minting is disabled.");

        _;
    }

    //CALLABLE FUNCTIONS

    /**
    * @dev publicMint(...) is callable only if the contract is not paused and the ALLOW_PUBLIC_MINT is true.
    * @param _amount - the amount of tokens to mint
    */
    function publicMint(uint256 _amount) public payable whenNotPaused whenPublicMint {
        require(_amount <= mintLimit, "Can only mint 30 tokens at a time.");
        require(totalSupply() + _amount <= MAX_TOKENS, "Purchase would exceed max supply.");
        require(_tokenPrice * _amount <= msg.value, "Ether value sent is not correct.");

        for(uint256 _i = 0; _i < _amount; _i++) {
            uint256 _tokenId = totalSupply();
            if (totalSupply() < MAX_TOKENS) {
                _safeMint(msg.sender, _tokenId);
                _setTokenURI(_tokenId, string(abi.encodePacked(Strings.toString(_tokenId), ".json")));
            }
        }
    }

    //MINTER_ROLE CALLABLE FUNCTIONS ONLY

    /**
    * @dev mint(...) is callable only if the contract is not paused, the role of the msg.sender is MINTER_ROLE and ALLOW_MINTER_ROLE_MINT is true.
    * @param to - the wallet/contract that will receive the token
    * @param amount - the amount of tokens to mint
    */
    function mint(address to, uint256 amount) public payable onlyRole(MINTER_ROLE) whenNotPaused whenMintAstar {
        require(amount <= mintLimit, "Can only mint 30 tokens at a time.");
        require(totalSupply() + amount <= MAX_TOKENS, "Purchase would exceed max supply.");
        require(_tokenPrice * amount <= msg.value, "Ether value sent is not correct.");

        for(uint256 _i = 0; _i < amount; _i++) {
            uint256 _tokenId = totalSupply();
            if (totalSupply() < MAX_TOKENS) {
                _safeMint(to, _tokenId);
                _setTokenURI(_tokenId, string(abi.encodePacked(Strings.toString(_tokenId), ".json")));
            }
        }
    }

    //DEFAULT_ADMIN_ROLE CALLABLE FUNCTIONS ONLY

    /**
    * @dev withdraw(...) is callable only if the msg.sender is the admin.
    * @param _receiver - the contract/wallet that will receive the _amount
    */
    function withdraw(uint256 _amount, address payable _receiver) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(address(this).balance >= _amount, "You are trying to withdraw more coins than the current balance.");
        _receiver.transfer(_amount);
    }

    /**
    * @dev setTokenPrice(...) is callable only if the msg.sender is the admin.
    * @param _newPrice - the new price for the token
    */
    function setTokenPrice(uint256 _newPrice) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _tokenPrice = _newPrice;
    }

    /**
    * @dev toggleAllowPublicMint(...) is callable only if the msg.sender is the admin.
    */
    function toggleAllowPublicMint() public onlyRole(DEFAULT_ADMIN_ROLE) {
        ALLOW_PUBLIC_MINT = !ALLOW_PUBLIC_MINT;
    }

    /**
    * @dev toggleAllowMinterRoleMint(...) is callable only if the msg.sender is the admin.
    */
    function toggleAllowMinterRoleMint() public onlyRole(DEFAULT_ADMIN_ROLE) {
        ALLOW_MINTER_ROLE_MINT = !ALLOW_MINTER_ROLE_MINT;
    }

    /**
    * @dev pause(...) is callable only if the msg.sender is the admin.
    */
    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
    * @dev unpause(...) is callable only if the msg.sender is the admin.
    */
    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    //OVERRIDES

    function _baseURI() internal pure override returns (string memory) {
        return "https://nftstorage.link/ipfs/bafybeic5qz2eyg62sd7buvdqskbiiv75q7eanjdprlw34jjeejmsra4wgq/";
    }

    function _update(address to, uint256 tokenId, address auth)
    internal
    override(ERC721, ERC721Enumerable, ERC721Pausable)
    returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
    internal
    override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
