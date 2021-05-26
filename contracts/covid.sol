pragma solidity 0.5.16;

contract passaporteCovid {

    //pessoas que receberam a primeira dose
     uint32 public totalPrimeiraDose;

     //pessoas que receberam a segunda dose
     uint32 public totalSegundaDose;

     address private owner;

     struct Cidadao {
         uint primeiraDose;
         uint segundaDose;
         bool cadastrado;
         uint docCount;
         address[] documentos;
     }

    struct Administrador {
        bool ativo;
        string cfm;
    }

    mapping(address => Cidadao) listaCidadao;
    mapping(address => Administrador) listaAdministradores;

     constructor() public {
         owner = msg.sender;
     }

     modifier podeCadastrar() {
         require(listaAdministradores[msg.sender].ativo == bool(true), "Voce nao pode cadastrar um cidadao.");
         _;
     }

     modifier podeAdicionarDocumento() {
         require(listaAdministradores[msg.sender].ativo == bool(true), "Voce nao pode adicionar documentos ao historico.");
         _;
     }

     modifier podeCadastrarAdministrador() {
         require(msg.sender == owner,"Voce nao pode cadastrar um administrador.");
         _;
     }

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

     modifier podeAplicarSegundaDose(address cidadao) {
         require(listaAdministradores[msg.sender].ativo == bool(true), "Voce nao pode vacinar.");
         require(listaCidadao[cidadao].primeiraDose != uint(0),"Cidadao ainda não recebeu a primeira dose.");
         require(listaCidadao[cidadao].segundaDose == uint(0),"Cidadao ja recebeu a segunda dose.");
         require(listaCidadao[cidadao].cadastrado == bool(true), "Cidadao nao cadastrado.");
         _;
     }

    function cadastrarAdministrador(address admin, string calldata cfm, bool ativo) external podeCadastrarAdministrador(){
        Administrador memory newAdmin = Administrador(ativo, cfm);
        listaAdministradores[admin] = newAdmin;
    }

    function cadastrarCidadao(address cidadao) external podeCadastrar(){
        Cidadao memory newCidadao = Cidadao(0, 0, true, 0, new address[](0));
        listaCidadao[cidadao] = newCidadao;
    }

    function addDocumento(address cidadao, address ipfs) external podeAdicionarDocumento() {
        listaCidadao[cidadao].documentos[listaCidadao[cidadao].docCount] = ipfs;
        listaCidadao[cidadao].docCount += 1;
    }

    function getDocumentos(address cidadao) external view podeGetDocumentos(cidadao) returns (address  [] memory) {
        return listaCidadao[cidadao].documentos;
    }

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