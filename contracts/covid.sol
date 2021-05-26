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
     }

    struct Administrador {
        bool ativo;
        string cfm;
    }

    struct Historico {
       uint primeiraDose;
       uint segundaDose;
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

     modifier podeCadastrarAdministrador() {
         require(msg.sender == owner,"Voce nao pode cadastrar um administrador.");
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

    function cadastrarAdministrador(address admin, string cfm, bool ativo) external podeCadastrarAdministrador(){
        var newAdmin = Administrador(ativo, cfm);
        listaAdministradores[admin] = newAdmin;
    }

    function cadastrarCidadao(address cidadao) external podeCadastrar(){
        var newCidadao = Cidadao(0, 0, true);
        listaCidadao[cidadao] = newCidadao;
    }

    function getHistorico(address cidadao) external view returns (Historico) {
        var hist = Historico(listaCidadao[cidadao].primeiraDose, listaCidadao[cidadao].segundaDose);
        return hist;
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