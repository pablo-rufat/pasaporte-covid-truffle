const fs = require("fs/promises");

module.exports = async function getAbi(deployer) {
  const response = await fs.readFile(
    __dirname + "/../build/contracts/passaporteCovid.json"
  );
  const objeto = JSON.parse(response);
  await fs.writeFile(
    __dirname + "/../../passaportecovid/src/utils/abi.json",
    JSON.stringify(objeto.abi, null, 4)
  );
};
