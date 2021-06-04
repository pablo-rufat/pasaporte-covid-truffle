pragma solidity 0.5.16;

contract PassaporteCovid {

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
         address administrador;
         uint adminTimestamp;
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

    // mesmo que acima
    modifier podeAdicionarDocumento() {
        require(listaAdministradores[msg.sender].ativo == bool(true), "Voce nao pode adicionar documentos ao historico.");
        _;
    }

    // Aqui pensei que só podem ver o hisotrico de documentos um administrador cadastrado pelo usuario como seu administrador
    // dentro de um periodo de uma hora ou o proprio usuario.
    modifier podeGetDocumentos(address cidadao, uint timestamp) {
        require(listaAdministradores[msg.sender].ativo == bool(true) &&
                msg.sender == listaCidadao[cidadao].administrador &&
                uint(timestamp) <= uint(listaCidadao[cidadao].adminTimestamp) + 3600 ||
                msg.sender == cidadao, "Voce nao pode ver historico.");
        _;
    }

    // igual que acima
    modifier podeGetHistoricoVacinas(address cidadao, uint timestamp) {
        require(listaAdministradores[msg.sender].ativo == bool(true) &&
                msg.sender == listaCidadao[cidadao].administrador &&
                uint(timestamp) <= uint(listaCidadao[cidadao].adminTimestamp) + 3600000 ||
                msg.sender == cidadao, "Voce nao pode ver historico.");
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

    // metodo para adicionar um administrador e um timestamp no struct do cidadao.
    // Esse admin só vai poder ver os dados do cidadao durante uma hora.
    function permitirAdministrador(address admin, uint timestamp) external {
        listaCidadao[msg.sender].administrador = admin;
        listaCidadao[msg.sender].adminTimestamp = timestamp;
    }

    // O endereço cria no ap com web3 (web3.eth.accounts.create();)
    // Cadastra um administrador (botei ativo como parametro, mas na pratica vai passar sempre true)
    function cadastrarAdministrador(string calldata cfm, bool ativo) external {
        Administrador memory newAdmin = Administrador(ativo, cfm);
        listaAdministradores[msg.sender] = newAdmin;
    }

    // Aqui cadastra um cidadao. Esse "address[](0)" é uma gambiarra que tem que fazer para inicializar um array vazio
    function cadastrarCidadao() external {
        Cidadao memory newCidadao = Cidadao(0, 0, true, address(0), 0, new address[](0));
        listaCidadao[msg.sender] = newCidadao;
    }

    // Adiciona ao array documentos o endereço do documento no ipfs
    function addDocumento(address cidadao, address ipfs) external podeAdicionarDocumento() {
        listaCidadao[cidadao].documentos.push(ipfs);
    }

    // Que merda é trabalhar com arrays em solidity ein. e pra retornar elas pior
    function getDocumentos(address cidadao, uint timestamp) external view podeGetDocumentos(cidadao, timestamp) returns (address  [] memory) {
        return listaCidadao[cidadao].documentos;
    }

    // Achei que seria bom criar um metodo que retornase o timestamp da duas vacinas ao mesmo tempo em lugar de dois metodos
    function getHistoricoDatasVacinas(address cidadao, uint timestamp) external view podeGetHistoricoVacinas(cidadao, timestamp) returns (uint, uint) {
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