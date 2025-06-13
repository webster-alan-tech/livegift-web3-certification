// Script de implantação
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // Deploy AccountLedger
  const AccountLedger = await hre.ethers.getContractFactory("AccountLedger");
  const ledger = await AccountLedger.deploy(); // ✅ correto
  await ledger.deployed(); // ✅ ledger é um contrato válido
  console.log("AccountLedger deployed to:", ledger.address);

  // Deploy Custody com referência ao AccountLedger
  const Custody = await hre.ethers.getContractFactory("Custody");
  const custody = await Custody.deploy(ledger.address);
  await custody.deployed();
  console.log("Custody deployed to:", custody.address);
}

main().catch((error) => {
  console.error("Error during deployment:", error);
  process.exitCode = 1;
});
