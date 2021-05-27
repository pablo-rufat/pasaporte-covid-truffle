const fs = require("fs/promises");
const Web3 = require("web3");

const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

module.exports = async function givePrivilege(deployer) {
  const responseAbi = await fs.readFile(
    __dirname + "/../build/contracts/passaporteCovid.json"
  );
  const abi = JSON.parse(responseAbi).abi;
  const responseAddress = await fs.readFile(
    __dirname + "/../build/contracts/passaporteCovid.json"
  );
  const address = JSON.parse(responseAddress).networks["5777"].address;
  const contrato = new web3.eth.Contract(abi, address);
  const contas = await web3.eth.getAccounts();
  for (let i = 3; i < contas.length; i++) {
    try {
      await contrato.methods
        .cadastrarCidadao(contas[i])
        .send({ from: contas[0] });
    } catch (error) {
      console.log(error);
    }
  }
};
