pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT

//import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

//import "@openzeppelin/contracts/access/Ownable.sol";
//learn more: https://docs.openzeppelin.com/contracts/3.x/erc721

// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

contract Pokemon is ERC721,ERC721URIStorage,ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string private baseURI;
    uint256 public maxSupply = 100;
    uint256 public mintPrice = 0.1 ether;

    constructor(bytes32[] memory assetsForSale) ERC721("Pokemon", "PKMON") {
        baseURI = "https://ipfs.io/ipfs/";
        for (uint256 i = 0; i < assetsForSale.length; i++) {
            forSale[assetsForSale[i]] = true;
        }
    }

    //this marks an item in IPFS as "forsale"
    mapping(bytes32 => bool) public forSale;
    //this lets you look up a token by the uri (assuming there is only one of each uri for now)
    mapping(bytes32 => uint256) public uriToTokenId;

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory){
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable){
        ERC721Enumerable._beforeTokenTransfer(from, to, tokenId);
    }
    
    function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage){
        ERC721URIStorage._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool){
        return ERC721Enumerable.supportsInterface(interfaceId);
    }
    
    function mintItem(string memory _tokenURI)
        public
        payable
        returns (uint256)
    {
        uint256 supply = totalSupply();
        require(supply < maxSupply, "Would exceed max supply");
        require(msg.value == mintPrice, "Exact mint price is not provided");

        bytes32 uriHash = keccak256(abi.encodePacked(_tokenURI));

        //make sure they are only minting something that is marked "forsale"
        require(forSale[uriHash], "NOT FOR SALE");
        forSale[uriHash] = false;

        _tokenIds.increment();

        uint256 id = _tokenIds.current();
        _safeMint(msg.sender, id);
        _setTokenURI(id, _tokenURI);
        uriToTokenId[uriHash] = id;

        return id;
    }
}
