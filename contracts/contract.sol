// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CryptoHashtag is Ownable, ERC721 {
    string private _currentBaseURI;

    mapping (string => Hashtag) public hashtags;
    mapping (uint256 => string) public tokenIdHashtags;

    uint256 private currentIndex = 1;

    struct Hashtag {
      string id;
      address owner;
      bool exist;
      uint256 tokenId;
    }

    constructor() ERC721("cryptohashtags", "CRH") {
        setBaseURI("https://api.cryptohashtags.io/meta/");
    }

    // ERC721
    function setBaseURI(string memory baseURI) public onlyOwner {
        _currentBaseURI = baseURI;
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return _currentBaseURI;
    }

    // Mint
    
    function mint(address to, string memory hashtag) external payable {
        hashtag = _toLower(hashtag);

        // should be at least 2 characters long
        assert(bytes(hashtag).length >= 2);
        // should start with "#"
        assert(uint8(bytes(hashtag)[0]) == 35);
        // hashtag should not exist
        assert(hashtags[hashtag].exist == false);
        
        uint256 tokenId = currentIndex;

        // create hashtag
        hashtags[hashtag] = Hashtag(hashtag, to, true, tokenId);
        tokenIdHashtags[tokenId] = hashtag;
        _safeMint(to, tokenId);
        currentIndex++;
    }

    function get(uint256 tokenId) external view returns (Hashtag memory) {
        require(_exists(tokenId), "token not minted");
        string memory hashtagId = tokenIdHashtags[tokenId];
        return hashtags[hashtagId];
    }

    // Helper
    function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            if (i == 0) {
                assert(uint8(bStr[i]) == 35);
                bLower[i] = bStr[i];
            } else {
                if (uint8(bStr[i]) >= 65 && uint8(bStr[i]) <= 90) {
                    // Add 32 to make it lowercase
                    bLower[i] = bytes1(uint8(bStr[i]) + 32);
                } else if (uint8(bStr[i]) >= 97 && uint8(bStr[i]) <= 122) {
                    // Lowercased
                    bLower[i] = bStr[i];
                } else if (uint8(bStr[i]) >= 48 && uint8(bStr[i]) <= 57) {
                    // Number
                    bLower[i] = bStr[i];
                } else if (uint8(bStr[i]) == 95) {
                    // _
                    bLower[i] = bStr[i];
                } else {
                    revert("Invalid character!");
                }
            }
        }
        
        return string(bLower);
    }
}