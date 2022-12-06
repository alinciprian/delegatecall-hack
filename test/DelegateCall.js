const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Attack", () => {
  let libContract, victimContract, attackContract;

  beforeEach(async () => {
    const LibContract = await ethers.getContractFactory("Lib");
    libContract = await LibContract.deploy();

    const VictimContract = await ethers.getContractFactory("VictimContract");
    victimContract = await VictimContract.deploy(libContract.address);

    const AttackContract = await ethers.getContractFactory("Attack");
    attackContract = await AttackContract.deploy(victimContract.address);

    let accounts = await ethers.getSigners();
    deployer = accounts[0];
    attacker = accounts[1];
    console.log("Deployer Address:", deployer.address);
    console.log("attackContract address:", attackContract.address);
  });

  describe("the attack", () => {
    it("should change ownership of victimContract", async () => {
      //checking for the initial owner who should be the deployer
      console.log(
        "Owner of victimContract before the attack:",
        await victimContract.owner()
      );
      expect(await victimContract.owner()).to.equal(deployer.address);

      //perform the attack
      let tx = await attackContract.connect(attacker).attack();
      await tx.wait();

      //checking for the new owner who should now be the attacker contract
      console.log(
        "Owner of victimContract after the attack:",
        await victimContract.owner()
      );
      expect(await victimContract.owner()).to.equal(attackContract.address);
    });
  });
});
