
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleGovernance { // Início do contrato.
    struct Proposal {
        string description;
        uint yesVotes;
        uint noVotes;
        uint deadline;
        bool executed;
        mapping(address => bool) hasVoted;
    }
    // ESTRUTURA DE UMA PROPOSTA:
    // description: descrição da proposta.
    // yesVotes e noVotes: contadores de votos.
    // deadline: prazo para votar.
    // executed: se a proposta já foi encerrada.
    // hasVoted: impede que um mesmo endereço vote duas vezes.

    Proposal[] public proposals; // Lista de propostas já criadas.

    event ProposalCreated(uint proposalId, string description, uint deadline); // Evento para registrar ações no log (útil para frontends).
    event Voted(uint proposalId, address voter, bool vote); // Evento para registrar ações no log (útil para frontends).
    event ProposalExecuted(uint proposalId, bool passed); // Evento para registrar ações no log (útil para frontends).

    uint public votingDuration = 3 days; // Duração fixa da votação (3 dias).

    // ----------------- CRIAÇÃO DA PROPOSTA -----------------------------------------------------
    
    function createProposal(string calldata description) external { // Qualquer um pode criar uma proposta.
        Proposal storage newProposal = proposals.push();
        newProposal.description = description;
        newProposal.deadline = block.timestamp + votingDuration;
        emit ProposalCreated(proposals.length - 1, description, newProposal.deadline);
    } // Cria uma nova proposta com o prazo de 3 dias.

    // ------------------ VOTAR ------------------------------------------------------------------

    function vote(uint proposalId, bool support) external { // Usuário pode votar a favor (true) ou contra (false).
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.deadline, "Prazo encerrado");
        require(!proposal.hasVoted[msg.sender], "Ja votou"); // Garante um voto por endereço.

        proposal.hasVoted[msg.sender] = true;

        if (support) {
            proposal.yesVotes += 1;
        } else {
            proposal.noVotes += 1;
        } // Conta o voto no campo correto.

        emit Voted(proposalId, msg.sender, support);
    }

    // ------------------ EXECUTAR PROPOSTA -------------------------------------------------------

    function executeProposal(uint proposalId) external { // Pode ser chamado por qualquer pessoa após o prazo.
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.deadline, "Ainda em votacao");
        require(!proposal.executed, "Ja executada");
        
        proposal.executed = true; // Marca como encerrada e emite evento dizendo se passou ou não.
        bool passed = proposal.yesVotes > proposal.noVotes;
        emit ProposalExecuted(proposalId, passed);
    }

    // ------------------- VISUALIZAR PROPOSTA -----------------------------------------------------
    function getProposal(uint proposalId) external view returns (
        string memory description,
        uint yesVotes,
        uint noVotes,
        uint deadline,
        bool executed
    ) {
        Proposal storage p = proposals[proposalId];
        return (p.description, p.yesVotes, p.noVotes, p.deadline, p.executed);
    }
}