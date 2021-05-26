const Covid = artifacts.require("./covid.sol")

module.exports = function(deployer) {
	deployer.deploy(Covid);
};