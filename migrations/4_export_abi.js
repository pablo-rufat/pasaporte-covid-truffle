const fs = require("fs/promises");

module.exports = async function getAbi(deployer) {
  const response = await fs.readFile(
    __dirname + "/../build/contracts/passaporteCovid.json"
  );
  const objeto = JSON.parse(response);
  await fs.writeFile(
    __dirname + "/../../pasaporte-covid-administrador/src/utils/abi.json",
    JSON.stringify(objeto.abi, null, 4)
  );
  await fs.writeFile(
    __dirname + "/../../pasaporte-covid-cidadao/src/utils/abi.json",
    JSON.stringify(objeto.abi, null, 4)
  );
};
