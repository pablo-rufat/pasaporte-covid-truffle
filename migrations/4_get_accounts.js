const fs = require("fs/promises");
const Web3 = require("web3");

const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

module.exports = async function getAccountsNetwork(deployer) {
  const contas = await web3.eth.getAccounts();
  console.log(contas);
  await fs.writeFile(
    __dirname + "/../../pasaporte-covid-cidadao/src/utils/listaCidadaos.json",
    JSON.stringify(contas, null, 4)
  );
};
