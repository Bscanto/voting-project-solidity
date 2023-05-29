// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract Votacao {
    address public i_owner; // variavel para determinar quem é o dono do contrato

    // Registrar no struct pessoa com os atributos nome e quantidade de voto
    struct Person { 
        uint256 votos;
        string name;
    }
    Person[] public people; // lista de pessoas

    Person[] public emptyArray; // lista vazia para esvaziar a lista no final da votação

    uint256 public constant VOTE_LIMIT_PER_WALLET = 1; // limite de votos por carteira

    // Contagem de votos
    // Variáveis criadas para determinar quantos votos cada carteira possui
    mapping(string => uint256) public votosDasPessoas;
    mapping(address => uint256) public voteCountMap;
    mapping(address => uint256) public allowedVoteCountMap;

    bool public voteIsActive = false; // variável vai determinar se a votação está ativa ou não

    uint256 public numPeople; // variável para determinar quantas pessoas existem para serem votadas
   
    // Função construtora para definir os valores quando criar um novo contrato na blockchain
    constructor() {
        i_owner = msg.sender;
        numPeople = 0;
    }

    // Função que verifica a carteira que está votando e verifica se ela já terminou a votação
    function allowedVoteCount(address voter) public view returns (uint256) {
        return VOTE_LIMIT_PER_WALLET - voteCountMap[voter];
    }

    // Função que atualiza o número de votos para uma determinada carteira
    function updateVoteCount(address voter) private {
        voteCountMap[voter] += 1;
    }

    // Modificador que permite apenas ao dono do contrato executar determinadas ações
    modifier onlyOwner() {
        require(msg.sender == i_owner, "Not Owner");
        _;
    }

    // Função que apenas o dono do contrato pode chamar para determinar se a votação está ativa ou não
    function setVoteIsActive(bool voteIsActive_) external onlyOwner {
        voteIsActive = voteIsActive_;
    }

    // Função de votação onde ela recebe um nome, procura se esse nome está na lista e, se não estiver, retorna um erro 
    function vote(string memory _name) public {
        require(voteIsActive, "Voting not active");

        if (allowedVoteCount(msg.sender) == 0) {
            revert("Already voted!");
        }

        updateVoteCount(msg.sender);
        votosDasPessoas[_name] += 1; // incrementar o número de votos para a pessoa
    }

    // Função que transforma a lista de pessoas em um array vazio e zera o contrato, removendo todas as pessoas da lista
    function reset() public onlyOwner {
        delete people;
    }

    // Função para adicionar as pessoas que vão ser votadas
    function addPerson(string memory _name) public onlyOwner {
        require(!voteIsActive, "Voting active");
        people.push(Person(0, _name));
        numPeople = people.length;
    }
}