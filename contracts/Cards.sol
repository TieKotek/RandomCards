// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Cards is VRFConsumerBaseV2, ERC721 {
    using Strings for uint256;
    uint256 public randomness;
    uint256 public usdEntryFee;
    VRFCoordinatorV2Interface immutable COORDINATOR;
    AggregatorV3Interface internal ethUsdPriceFeed;
    address payable s_owner;
    uint64 immutable s_subscriptionId;
    bytes32 keyHash;
    uint32 callbackGasLimit = 1000000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint256 public legendRate = 2;
    uint256 public epicRate = 8;
    uint256 public rareRate = 40;
    uint256 public normalRate = 50;
    uint256 public tokenCounter;
    enum Rarity {
        LEGEND,
        EPIC,
        RARE,
        NORMAL
    }
    mapping(uint256 => address) public requestIdToSender;
    mapping(uint256 => Rarity) public tokenIdToRarity;
    mapping(uint256 => string) private _tokenURIs;
    string private _baseURIextended;

    event RequestedRandomness(uint256 requestId, address sender);
    event rarityAssigned(uint256 newTokenId, Rarity rarity);
    event tokenURISet(address owner, uint256 tokenId, string tokenURI);
    event ReturnedRandomness(uint256[] randomWords);

    constructor(
        uint64 subscriptionId,
        address vrfCoordinator,
        bytes32 _keyHash,
        address _priceFeedAddress,
        uint256 _legendRate,
        uint256 _epicRate,
        uint256 _rareRate,
        uint256 _normalRate
    ) VRFConsumerBaseV2(vrfCoordinator) ERC721("RandomCards", "RC") {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = payable(msg.sender);
        s_subscriptionId = subscriptionId;
        keyHash = _keyHash;
        usdEntryFee = 50 * 10**18;
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        legendRate = _legendRate;
        epicRate = _epicRate;
        rareRate = _rareRate;
        normalRate = _normalRate;
        require(
            legendRate + epicRate + rareRate + normalRate == 100,
            "Invaild rate setting!"
        );
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function setusdEntryFee(uint256 _fee) public onlyOwner {
        usdEntryFee = _fee * 10**18;
    } // centralized, may be deleted in the future.

    function Enter() public payable {
        require(msg.value >= getEntryFee(), "YOU NEED MORE ETH!");
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        requestIdToSender[requestId] = msg.sender;
        emit RequestedRandomness(requestId, msg.sender);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        randomness = randomWords[0];
        emit ReturnedRandomness(randomWords);
        uint256 r1 = (randomness % 100) + 1; // for lottery
        uint256 kind;
        string memory _tokenURI;
        if (r1 <= legendRate) {
            kind = 0;
            _tokenURI = "https://ipfs.io/ipfs/QmYdD4NWtd8cYRbos82HhKJFnuJEEdLGuQNELt41HxQsxT?filename=legend.json";
        }
        if (legendRate < r1 && r1 <= legendRate + epicRate) {
            kind = 1;
            _tokenURI = "https://ipfs.io/ipfs/QmeWrdkv96Aq92Bvs6NYq6GWpZpcaAmpz9THQH3ZUJuvpz?filename=epic.json";
        }
        if (
            legendRate + epicRate < r1 && r1 <= legendRate + epicRate + rareRate
        ) {
            kind = 2;
            _tokenURI = "https://ipfs.io/ipfs/QmQ9XZQFa7jamtZj9f6wfzkN3udxuSwki5wBd1W82RBf3i?filename=rare.json";
        }
        if (legendRate + epicRate + rareRate < r1) {
            kind = 3;
            _tokenURI = "https://ipfs.io/ipfs/Qme6qr1yKQVA4PL7XwS9rkmAoGMgX8CaTRunGUMgnyL5qg?filename=normal.json";
        }
        Rarity rarity = Rarity(kind);
        uint256 newTokenId = tokenCounter;
        tokenIdToRarity[newTokenId] = rarity;
        emit rarityAssigned(newTokenId, rarity);
        address owner = requestIdToSender[requestId];
        _safeMint(owner, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        emit tokenURISet(owner, newTokenId, _tokenURI);
        tokenCounter = tokenCounter + 1;
    }

    function getEntryFee() public view returns (uint256) {
        (, int256 fee, , , ) = ethUsdPriceFeed.latestRoundData();
        uint256 price = uint256(fee) * 10**10;
        uint256 costToEnter = (usdEntryFee * 10**18) / price;
        return costToEnter;
    }

    function withdraw() public onlyOwner {
        s_owner.transfer(address(this).balance);
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }
}
