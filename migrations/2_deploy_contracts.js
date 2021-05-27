const PassaporteCovid = artifacts.require("PassaporteCovid");

module.exports = function (deployer) {
  deployer.deploy(PassaporteCovid);
};
