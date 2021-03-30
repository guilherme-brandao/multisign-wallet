const multiSignWallet = artifacts.require("MultiSignWallet");
const safemath = artifacts.require("hello");


module.exports = function (deployer) {
    deployer.deploy(safemath);
    deployer.deploy(multiSignWallet);
};
