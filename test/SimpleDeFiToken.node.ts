import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";
import SimpleDeFiTokenModule from "../ignition/modules/SimpleDeFiToken.js";

const ONE = 10n ** 18n;

describe("SimpleDeFiToken (Viem + Ignition)", () => {
  it("deploy: name/symbol/totalSupply corretos", async () => {
    const { ignition } = await network.connect();
    const { simpleDeFiToken } = await ignition.deploy(SimpleDeFiTokenModule);

    const [name, symbol, supply] = await Promise.all([
      simpleDeFiToken.read.name(),
      simpleDeFiToken.read.symbol(),
      simpleDeFiToken.read.totalSupply(),
    ]);

    assert.equal(name, "Simple DeFi Token");
    assert.equal(symbol, "SDFT");
    assert.equal(supply, 1_000_000n * ONE);
  });

  it("transferWithAutoBurn: queima 10% e transfere 90%", async () => {
    const { ignition, viem } = await network.connect();
    const { simpleDeFiToken } = await ignition.deploy(SimpleDeFiTokenModule);
    const [w0, w1, w2] = await viem.getWalletClients();

    // Deployer (w0) envia 1 token (1e18) para w1
    await simpleDeFiToken.write.transfer([w1.account.address, 1n * ONE], {
      account: w0.account,   // já vem do viem.getWalletClients()
    });

    const supplyBefore = await simpleDeFiToken.read.totalSupply();

    // w1 chama transferWithAutoBurn( w2, 1 token )
    await simpleDeFiToken.write.transferWithAutoBurn([w2.account.address, 1n * ONE], {
      account: w1.account,
    });

    const received = await simpleDeFiToken.read.balanceOf([w2.account.address]);
    assert.equal(received, (9n * ONE) / 10n); // 0.9 token

    const supplyAfter = await simpleDeFiToken.read.totalSupply();
    assert.equal(supplyAfter, supplyBefore - (1n * ONE) / 10n); // queimou 0.1
  });
});
