// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleDeFiToken is ERC20 {
    constructor() ERC20("Simple DeFi Token", "SDFT") {
        _mint(msg.sender, 1_000_000 * 10 ** decimals()); 
        // 1 milhão de tokens, já com 18 casas decimais
    }

    function transferWithAutoBurn(address to, uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Not enough tokens");

        uint256 burnAmount = amount / 10; // 10% burn

        _burn(msg.sender, burnAmount); // queima do remetente
        _transfer(msg.sender, to, amount - burnAmount);
    }
}
