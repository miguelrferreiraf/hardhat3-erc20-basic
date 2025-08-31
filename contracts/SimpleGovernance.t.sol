// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/SimpleGovernance.sol";

contract SimpleGovernanceTest is Test {
    SimpleGovernance gov;
    address alice = address(0xA11CE);
    address bob   = address(0xB0B);

    function setUp() public {
        gov = new SimpleGovernance();
    }

    function testCreateProposalAndRead() public {
        // cria proposta
        gov.createProposal("Proposta 1");
        // lê dados
        (
            string memory desc,
            uint yesVotes,
            uint noVotes,
            uint deadline,
            bool executed
        ) = gov.getProposal(0);

        assertEq(desc, "Proposta 1");
        assertEq(yesVotes, 0);
        assertEq(noVotes, 0);
        assertTrue(deadline > block.timestamp);
        assertEq(executed, false);
    }

    function testVoteYesAndNo() public {
        gov.createProposal("P");
        // alice vota sim
        vm.prank(alice);
        gov.vote(0, true);
        // bob vota não
        vm.prank(bob);
        gov.vote(0, false);

        (, uint yesVotes, uint noVotes,,) = gov.getProposal(0);
        assertEq(yesVotes, 1);
        assertEq(noVotes, 1);
    }

    function testCannotDoubleVote() public {
        gov.createProposal("P");
        vm.startPrank(alice);
        gov.vote(0, true);
        vm.expectRevert(bytes("Ja votou"));
        gov.vote(0, true);
        vm.stopPrank();
    }

    function testCannotVoteAfterDeadlineAndExecute() public {
        gov.createProposal("P");

        // avança o tempo além do prazo (3 dias + 1s)
        (, , , uint deadline, ) = gov.getProposal(0);
        vm.warp(deadline + 1);

        // votar após o prazo deve falhar
        vm.expectRevert(bytes("Prazo encerrado"));
        gov.vote(0, true);

        // executar deve marcar como executada
        gov.executeProposal(0);
        (, , , , bool executed) = gov.getProposal(0);
        assertTrue(executed);

        // reexecutar deve falhar
        vm.expectRevert(bytes("Ja executada"));
        gov.executeProposal(0);
    }

    function testPassingProposal() public {
        gov.createProposal("P");

        // dois votos "sim"
        vm.prank(alice);
        gov.vote(0, true);
        vm.prank(bob);
        gov.vote(0, true);

        // avança tempo
        (, , , uint deadline, ) = gov.getProposal(0);
        vm.warp(deadline + 1);

        // executa (só evento indica "passed"; aqui checamos apenas que não reverte)
        gov.executeProposal(0);
        (, , , , bool executed) = gov.getProposal(0);
        assertTrue(executed);
    }
}
