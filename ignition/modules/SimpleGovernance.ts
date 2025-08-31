import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SimpleGovernanceModule = buildModule("SimpleGovernanceModule", (m) => {
  const simpleGovernance = m.contract("SimpleGovernance");
  return { simpleGovernance };
});

export default SimpleGovernanceModule;
