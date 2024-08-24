const TronEnergyMarket = artifacts.require("TronEnergyMarket");

contract("TronEnergyMarket", async (accounts) => {
  it("should create an offer correctly", async () => {
    let instance = await TronEnergyMarket.deployed();
    await instance.createOffer(100, 10, { from: accounts[0] });

    let offer = await instance.offers(1);
    let sellerAddress = tronWeb.address.fromHex(offer.seller); // Convert to TRON address format
    assert.equal(sellerAddress, accounts[0], "Seller address is incorrect");
    assert.equal(offer.amount.toNumber(), 100, "Amount is incorrect");
    assert.equal(offer.price.toNumber(), 10, "Price is incorrect");
    assert.equal(offer.isActive, true, "Offer should be active");
  });

  it("should cancel an offer correctly", async () => {
    let instance = await TronEnergyMarket.deployed();
    await instance.createOffer(100, 10, { from: accounts[0] });

    await instance.cancelOffer(2, { from: accounts[0] });
    let offer = await instance.offers(2);
    assert.equal(offer.isActive, false, "Offer should be canceled");
  });

  it("should fulfill an offer correctly", async () => {
    let instance = await TronEnergyMarket.deployed();
    // Create the offer
    await instance.createOffer(197, 10, { from: accounts[0] });

    let offerId = 3;

    let initialBuyerBalance = await tronWeb.trx.getBalance(accounts[1]);

    try {
      await instance.fulfillOffer(offerId, {
        from: accounts[1],
        value: tronWeb.toSun(1970),
      });
    } catch (error) {
      console.error("Transaction failed with error:", error);
    }

    // Introducing a delay to ensure transaction is processed
    await new Promise((resolve) => setTimeout(resolve, 10000));

    let offer = await instance.offers(offerId);

    let newBuyerBalance = await tronWeb.trx.getBalance(accounts[1]);

    assert.isTrue(
      newBuyerBalance < initialBuyerBalance,
      `Buyer should give TRX. Initial: ${initialBuyerBalance}, New: ${newBuyerBalance}`
    );
  });

  it("should create an offer and correctly update contract state", async () => {
    let instance = await TronEnergyMarket.deployed();

    // Seller creates an offer
    await instance.createOffer(100, 10, { from: accounts[0] });

    // Retrieve the offer directly from the contract
    let offer = await instance.offers(4);

    // Convert the returned seller address to the Base58 format
    let sellerAddressBase58 = tronWeb.address.fromHex(offer.seller);

    // Verify the offer's state
    expect(sellerAddressBase58).to.equal(accounts[0]);
    expect(offer.amount.toNumber()).to.equal(100);
    expect(offer.price.toNumber()).to.equal(10);
  });
  it("should only allow the seller to cancel the offer", async () => {
    let instance = await TronEnergyMarket.deployed();

    // Seller creates an offer
    await instance.createOffer(101, 10, { from: accounts[0] });

    let offer = await instance.offers(5);

    try {
      // A different account tries to cancel the offer
      await instance.cancelOffer(5, { from: accounts[1] });
      throw new Error("You are not the seller of this offer");
    } catch (error) {
      expect(error.message).to.include("You are not the seller of this offer");
    }

    // Check that the offer is still active
    expect(offer.isActive).to.be.true;
  });
});
