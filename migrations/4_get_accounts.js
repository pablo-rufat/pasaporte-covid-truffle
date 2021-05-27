const fs = require("fs/promises");
const Web3 = require("web3");

const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

module.exports = async function getAccountsNetwork(deployer) {
  const listaContas = [];
  const contas = await web3.eth.getAccounts();
  for (let i = 1; i < contas.length; i++) {
    const objeto = {
      nome: `Cidadão ${i}`,
      endereco: contas[i],
      vac1: 0,
      vac2: 0,
    };
    listaContas.push(objeto);
  }
  await fs.writeFile(
    __dirname + "/../../passaportecovid/src/utils/listaCidadaos.json",
    JSON.stringify(listaContas, null, 4)
  );
  await fs.writeFile(
    __dirname + "/../../passaportecovid/src/utils/enderecoAdm.json",
    JSON.stringify({ address: contas[0] }, null, 4)
  );
};
