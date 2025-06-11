const { expect } = require("chai");

describe("LiveGifts", function () {
  it("should send gift and emit event", async function () {
    const [sender, receiver] = await ethers.getSigners();
    const LiveGifts = await ethers.getContractFactory("LiveGifts");
    const contract = await LiveGifts.deploy();
    await contract.deployed();

    const tx = await contract.connect(sender).sendGift(receiver.address, "A gift!", {
      value: ethers.parseEther("1.0"),
    });

    await expect(tx)
      .to.emit(contract, "GiftSent")
      .withArgs(sender.address, receiver.address, ethers.parseEther("1.0"), "A gift!");
  });
});
