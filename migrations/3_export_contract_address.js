const fs = require("fs/promises");

module.exports = async function getAddress(deployer) {
  const response = await fs.readFile(
    __dirname + "/../build/contracts/passaporteCovid.json"
  );
  const objeto = JSON.parse(response);
  const address = objeto.networks["5777"].address;
  const escrita = {
    address,
  };
  await fs.writeFile(
    __dirname + "/../../pasaporte-covid-administrador/src/utils/contractAddress.json",
    JSON.stringify(escrita, null, 4)
  );
  await fs.writeFile(
    __dirname + "/../../pasaporte-covid-cidadao/src/utils/contractAddress.json",
    JSON.stringify(escrita, null, 4)
  );
};
