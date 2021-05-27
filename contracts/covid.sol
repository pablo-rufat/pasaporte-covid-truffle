pragma solidity 0.5.16;

contract passaporteCovid {

    //pessoas que receberam a primeira dose
     uint32 public totalPrimeiraDose;

     //pessoas que receberam a segunda dose
     uint32 public totalSegundaDose;

     address private owner;

    // tirei o campo address porque já é a key do mapping
    // adicionei documentos (historico medico. para futuras versoes?) e docCount (pra fazer de indice do array de documentos)
    // os documentos sao subidos à IPFS e salvamos aqui um endereço hash. depois a gente pode baixar no app com esse endereço.
     struct Cidadao {
         uint primeiraDose;
         uint segundaDose;
         bool cadastrado;
         uint docCount;
         address[] documentos;
     }

    // adicionei o struct administrador. O booleano ativo é pra ter a posibilidade de desativar medicos
    struct Administrador {
        bool ativo;
        string cfm;
    }

    mapping(address => Cidadao) listaCidadao;
    mapping(address => Administrador) listaAdministradores;

    // O criador do contrato vai ser o owner
    constructor() public {
        owner = msg.sender;
    }

    // Modifiquei tambem esse modifier para buscar na lista de administradores o sender da chamada
    // como nao tem como saber se um endereço existe em um mapping (tecnicamente "existem" todos) uso o atcivo == true para saber se foi "criado"
    modifier podeCadastrar() {
        require(listaAdministradores[msg.sender].ativo == bool(true), "Voce nao pode cadastrar um cidadao.");
        _;
    }

    // mesmo que acima
    modifier podeAdicionarDocumento() {
        require(listaAdministradores[msg.sender].ativo == bool(true), "Voce nao pode adicionar documentos ao historico.");
        _;
    }

    // pensei em só poder cadastrar administradores se for o owner
    modifier podeCadastrarAdministrador() {
        require(msg.sender == owner,"Voce nao pode cadastrar um administrador.");
        _;
    }

    // Aqui pensei que só podem ver o hisotrico de documentos um administrador ou o proprio usuario.
    modifier podeGetDocumentos(address cidadao) {
        require(listaAdministradores[msg.sender].ativo == bool(true) || uint(msg.sender) == uint(cidadao), "Voce nao pode ver historico.");
        _;
    }

    modifier podeAplicarPrimeiraDose(address cidadao) {
        require(listaAdministradores[msg.sender].ativo == bool(true), "Voce nao pode vacinar.");
        require(listaCidadao[cidadao].primeiraDose == uint(0),"Cidadao ja recebeu a primeira dose.");
        require(listaCidadao[cidadao].cadastrado == bool(true), "Cidadao nao cadastrado.");
        _;
    }

    // Aqui pensei que nao pode aplicar a segunda dose se nao aplicou a primeira ainda e adicionei o segundo require
    modifier podeAplicarSegundaDose(address cidadao) {
        require(listaAdministradores[msg.sender].ativo == bool(true), "Voce nao pode vacinar.");
        require(listaCidadao[cidadao].primeiraDose != uint(0),"Cidadao ainda não recebeu a primeira dose.");
        require(listaCidadao[cidadao].segundaDose == uint(0),"Cidadao ja recebeu a segunda dose.");
        require(listaCidadao[cidadao].cadastrado == bool(true), "Cidadao nao cadastrado.");
        _;
    }

    // O endereço cria no ap com web3 (web3.eth.accounts.create();)
    // Cadastra um administrador (botei ativo como parametro, mas na pratica vai passar sempre true)
    function cadastrarAdministrador(address admin, string calldata cfm, bool ativo) external podeCadastrarAdministrador(){
        Administrador memory newAdmin = Administrador(ativo, cfm);
        listaAdministradores[admin] = newAdmin;
    }

    // Aqui cadastra um cidadao. Esse "address[](0)" é uma gambiarra que tem que fazer para inicializar um array vazio
    function cadastrarCidadao(address cidadao) external podeCadastrar(){
        Cidadao memory newCidadao = Cidadao(0, 0, true, 0, new address[](0));
        listaCidadao[cidadao] = newCidadao;
    }

    // Adiciona ao array documentos o endereço do documento no ipfs
    function addDocumento(address cidadao, address ipfs) external podeAdicionarDocumento() {
        listaCidadao[cidadao].documentos[listaCidadao[cidadao].docCount] = ipfs;
        listaCidadao[cidadao].docCount += 1;
    }

    // Que merda é trabalhar com arrays em solidity ein. e pra retornar elas pior
    function getDocumentos(address cidadao) external view podeGetDocumentos(cidadao) returns (address  [] memory) {
        return listaCidadao[cidadao].documentos;
    }

    // Achei que seria bom criar um metodo que retornase o timestamp da duas vacinas ao mesmo tempo em lugar de dois metodos
    function getHistoricoDatasVacinas(address cidadao) external view returns (uint, uint) {
        return (listaCidadao[cidadao].primeiraDose, listaCidadao[cidadao].segundaDose);
    }

     function aplicarPrimeiraDose(uint timestamp, address cidadao) external podeAplicarPrimeiraDose(cidadao) {
         listaCidadao[cidadao].primeiraDose = timestamp;
         totalPrimeiraDose += 1;
     }

     function aplicarSegundaDose(uint timestamp, address cidadao) external podeAplicarSegundaDose(cidadao) {
         listaCidadao[cidadao].segundaDose = timestamp;
         totalSegundaDose += 1;
     }
}