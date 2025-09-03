# Smart Contracts Vault Monorepo

Este repositório é um **monorepo de contratos inteligentes** — um diretório centralizado que concentra diferentes módulos de finanças descentralizadas (DeFi).  
O objetivo é servir como uma **biblioteca viva**, em constante transformação e expansão, com acréscimos e melhorias contínuas.

Ele tem o nome *vault* porque a maior parte dos contratos aqui disponibilizados são voltados para DeFi, especificamente atividades de vault.

## 📂 Estrutura Atual

O monorepo contém os seguintes contratos:

1. **ERC20: Simple Token**  
   - Implementação básica de um token fungível ERC20.  
   - Usado como moeda de referência e meio de interação entre os demais contratos.

2. **Governance Contract**  
   - Permite criação e votação de propostas.  
   - Define a lógica de tomada de decisão descentralizada.  

3. **Swap Contract**  
   - Funções de troca entre tokens compatíveis.  
   - Base para interações simples de AMM (Automated Market Maker).  

4. **Staking / Yielding Contract**  
   - Usuários podem bloquear tokens e receber recompensas.  
   - Mecanismo de incentivo para participação na rede.  

5. **Liquidity Pool Contract**  
   - Gestão de pares de liquidez para swaps.  
   - Permite fornecimento e retirada de liquidez.  

## 🚧 Estado do Projeto

- Este repositório está em **desenvolvimento contínuo**.  
- Novos contratos, melhorias e testes são adicionados regularmente.  
- A arquitetura é modular para facilitar expansão e integração futura.  

## 🛠️ Stack e Ferramentas

- **Solidity** (>=0.8.x)  
- **Hardhat** para compilação, testes e deploy.  
- **OpenZeppelin Contracts** como base de segurança e padronização.  
