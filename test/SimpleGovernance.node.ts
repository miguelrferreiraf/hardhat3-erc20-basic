import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";
import SimpleGovernanceModule from "../ignition/modules/SimpleGovernance.js"; // IMPORTANTE: OBSERVE COMO EU MUDO A EXTENSÃO DO MÓDULO DE IGNIÇÃO DE TYPESCRIPT PARA JAVASCRIPT!

describe("SimpleGovernance (Viem + Ignition)", () => {
  it("cria proposta e lê dados iniciais", async () => {
    const { ignition, viem } = await network.connect();
    const { simpleGovernance }: any = await ignition.deploy(SimpleGovernanceModule);

    // cria proposta
    const [deployer] = await viem.getWalletClients();
    await simpleGovernance.write.createProposal(["Proposta 1"], {
      account: deployer.account,
    });

    // lê
    const p0 = await simpleGovernance.read.getProposal([0n]);
    // p0 = [description, yesVotes, noVotes, deadline, executed]
    assert.equal(p0[0], "Proposta 1");
    assert.equal(p0[1], 0n);
    assert.equal(p0[2], 0n);
    assert.equal(typeof p0[3], "bigint");
    assert.equal(p0[4], false);
  });

  it("vota sim/não, bloqueia voto duplo e executa após deadline", async () => {
    const { ignition, viem } = await network.connect();
    const { simpleGovernance }: any = await ignition.deploy(SimpleGovernanceModule);

    const [w0, w1, w2] = await viem.getWalletClients();
    const testClient = await viem.getTestClient();

    // cria proposta
    await simpleGovernance.write.createProposal(["P"], { account: w0.account });

    // w1 = sim
    await simpleGovernance.write.vote([0n, true], { account: w1.account });

    // w1 tentar votar de novo -> deve falhar
    await assert.rejects(
      simpleGovernance.write.vote([0n, true], { account: w1.account }),
      /Ja votou/
    );

    // w2 = não
    await simpleGovernance.write.vote([0n, false], { account: w2.account });

    // lê contagem
    const afterVotes = await simpleGovernance.read.getProposal([0n]);
    assert.equal(afterVotes[1], 1n); // yes
    assert.equal(afterVotes[2], 1n); // no

    // tenta votar após deadline (avança o tempo)
    const deadline = afterVotes[3] as bigint;
    const publicClient = await viem.getPublicClient();
    const nowBlock = await publicClient.getBlock({ blockTag: "latest" }); // ✅ correto
    const nowTs = nowBlock.timestamp as bigint;
    const advance = (deadline - nowTs) + 1n;


    await testClient.increaseTime({ seconds: Number(advance) });
    await testClient.mine({ blocks: 1 });

    await assert.rejects(
      simpleGovernance.write.vote([0n, true], { account: w2.account }),
      /Prazo encerrado/
    );

    // executa (marca executed = true)
    await simpleGovernance.write.executeProposal([0n], { account: w0.account });

    const afterExec = await simpleGovernance.read.getProposal([0n]);
    assert.equal(afterExec[4], true);

    // reexecutar deve falhar
    await assert.rejects(
      simpleGovernance.write.executeProposal([0n], { account: w0.account }),
      /Ja executada/
    );
  });
});
