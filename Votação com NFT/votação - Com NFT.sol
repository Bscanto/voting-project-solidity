// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Votacao is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    address public i_owner;
    
    struct Pessoa {
        uint256 votos;
        string nome;
    }
    
    Pessoa[] public pessoas;
    
    mapping(string => uint256) public votosDasPessoas;
    mapping(address => uint256) public voteCountMap;
    mapping(address => uint256) public permitidoVoteCountMap;
    
    bool public voteIsActive = false;
    uint256 public numPessoas;
    
    constructor() ERC721( 'Votacao NFT', 'VOTNFT') {
        i_owner = msg.sender;
        numPessoas = 0;
    }
    
    function permitidaVoteCount(address votador) public view returns (uint256) {
        return VOTE_LIMIT_PER_WALLET - voteCountMap[votador];
    }
    
    function updateVoteCount(address votador) private {
        voteCountMap[votador] += 1;
    }
    
    modifier onlyOwner() {
        require(msg.sender == i_owner, 'Nao e o proprietario');
        _;
    }
    
    function setVoteIsActive(bool voteIsActive_) external onlyOwner {
        voteIsActive = voteIsActive_;
    }
    
    function vote(string memory _name) public {
        require(voteIsActive, 'Votacao nao esta ativa');
        if (permitidaVoteCount(msg.sender) == 0) {
            revert('Voce ja votou!');
        }
        updateVoteCount(msg.sender);
        votosDasPessoas[_name] += 1;
    }
    
    function reset() public onlyOwner {
        delete pessoas;
        for (uint256 i = 0; i < _tokenIds.current(); i++) {
            _burn(i);
        }
        _tokenIds.reset();
    }
    
    function addPerson(string memory _name) public onlyOwner {
        require(!voteIsActive, 'Votacao esta ativa');
        pessoas.push(Pessoa(0, _name));
        uint256 newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        numPessoas = pessoas.length;
        _tokenIds.increment();
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return "https://example.com/metadata/";
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseUri = _baseURI();
        string memory tokenIdStr = Strings.toString(tokenId);
        return string(abi.encodePacked(baseUri, tokenIdStr));
    }
}
