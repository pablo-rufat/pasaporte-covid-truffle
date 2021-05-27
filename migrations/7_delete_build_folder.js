const fs = require("fs");

module.exports = async function deleteBuild(deployer) {
  fs.rmdir(__dirname + "/../build", { recursive: true }, err => {
    if (err) {
      console.log("Deu ruim.");
    }
    console.log("Sucesso.");
  });
};
