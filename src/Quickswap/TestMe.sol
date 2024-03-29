// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ERC721A.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestMe is ERC721A, ERC2981, AccessControl,Ownable {
    using Strings for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public baseContractURI;

    string public baseURI;

    string public baseExtension;

    uint256 public maxSupply;

    uint256 public mintLimit = 0;

    uint256 public cost;

    uint256 public secondaryCost;

    uint256 public startTime;

    bool public locked;

    bool public paused;

    mapping(address => bool) public secondTimeUser;

    //@notice constructor
    constructor(
        string memory name,
        string memory symbol,
        string memory initBaseContractURI,
        string memory initBaseURI,
        string memory initBaseExtension,
        uint256 initCost,
        uint256 _secondaryCost,
        uint256 initMaxSupply,
        address initialOwner
    ) ERC721A(name, symbol)
    Ownable(initialOwner)
    {
        baseContractURI = initBaseContractURI;
        baseURI = initBaseURI;
        baseExtension = initBaseExtension;
        cost = initCost;
        secondaryCost = _secondaryCost;
        maxSupply = initMaxSupply;
        locked = false;
        paused = false;
        startTime = block.timestamp;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    //@notice contractURI
    function contractURI() public view returns (string memory) {
        return baseContractURI;
    }

    //@notice tokenURI override
    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721A)
    returns (string memory)
    {
        require(
            _exists(tokenId),
            "Non Exist token"
        );

        return bytes(baseURI).length > 0
            ? string(
                abi.encodePacked(
                    baseURI,
                    (tokenId % 10 == 0 ? 10 : tokenId % 10).toString(),
                    baseExtension
                )
            )
            : "";
    }

    //@notice mint function
    function mint(address to, uint256 amount) public payable onlyRole(MINTER_ROLE) {
        //check
        require(
            block.timestamp >= startTime,
            "Sale Not started"
        );
        require(!paused,"Paused");
        if (maxSupply > 0){
            require(totalSupply() + amount <= maxSupply, "Max Supply");
        }

        if (!secondTimeUser[to]) {
            secondTimeUser[to] = true;
            require(msg.value >= cost * amount, "Not Enough Value");
        }
        else {
            require(msg.value >= secondaryCost * amount, "Not Enough Value");
        }

        //interact
        _mint(to, amount);
    }

    //@notice to contractUri
    function setBaseContractURI(string memory _newBaseContractURI) public onlyRole(DEFAULT_ADMIN_ROLE) {
        baseContractURI = _newBaseContractURI;
    }

    //@notice to tokenUri
    function setBaseURI(string memory _newBaseURI) public onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = _newBaseURI;
    }

    //@notice to tokenUri
    function setBaseExtension(string memory _newBaseExtension) public onlyRole(DEFAULT_ADMIN_ROLE) {
        baseExtension = _newBaseExtension;
    }

    //@notice maxSupply
    function setMaxSupply(uint256 _newMaxSupply) public onlyRole(DEFAULT_ADMIN_ROLE) {
        maxSupply = _newMaxSupply;
    }

    //@notice cost
    function setCost(uint256 _newCost) public onlyRole(DEFAULT_ADMIN_ROLE) {
        cost = _newCost;
    }

    //@notice cost
    function setSecondaryCost(uint256 _newCost) public onlyRole(DEFAULT_ADMIN_ROLE) {
        secondaryCost = _newCost;
    }
    //@notice paused
    function setPaused(bool _newPaused) public onlyRole(DEFAULT_ADMIN_ROLE) {
        paused = _newPaused;
    }

    //@notice locked
    function setLocked(bool _newLocked) public onlyRole(DEFAULT_ADMIN_ROLE) {
        locked = _newLocked;
    }

    //@notice startTime
    function setStartTime(uint256 _newStartTime) public onlyRole(DEFAULT_ADMIN_ROLE) {
        startTime = _newStartTime;
    }

    //@notice set Royality
    function setDefaultRoyalty(
        address _receiver,
        uint96 _feeNumerator
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setDefaultRoyalty(_receiver, _feeNumerator);
    }

    //@notice locked
    function _beforeTokenTransfers(
        address from,
        address,
        uint256,
        uint256
    ) internal virtual override {
        if (locked) {
            require(
                from == address(0),
                "BaseERC721: Transfers are disabled when Locked is true"
            );
        }
    }

    //@notice ERC2981 override
    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721A, ERC2981, AccessControl)
    returns (bool)
    {
        return
            ERC721A.supportsInterface(interfaceId) ||
            ERC2981.supportsInterface(interfaceId) ||
            AccessControl.supportsInterface(interfaceId);
    }

    //@notice ERC721A override
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    //@notice withdraw function
    function withdraw() public onlyRole(DEFAULT_ADMIN_ROLE) {
        payable(msg.sender).transfer(address(this).balance);
    }
}