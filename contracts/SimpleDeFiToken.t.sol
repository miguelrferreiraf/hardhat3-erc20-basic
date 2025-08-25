// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol"; // biblioteca padrão de testes Solidity
import "../contracts/SimpleDeFiToken.sol";

/*
SE VOCÊ QUISER PASSAR OS TESTES SOLIDITY PARA A PASTA test/, FAÇA A SEGUINTE SUBSTITUIÇÃO DA import ACIMA:
```
import "../contracts/SimpleDeFiToken.sol";
```
*/

contract SimpleDeFiTokenTest is Test {
    SimpleDeFiToken token;
    address addr1 = address(0x1);
    address addr2 = address(0x2);

    function setUp() public {
        token = new SimpleDeFiToken();
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), 1_000_000 * 10 ** token.decimals());
    }

    function testTransfer() public {
        token.transfer(addr1, 100);
        assertEq(token.balanceOf(addr1), 100);
    }

    function testTransferWithAutoBurn() public {
        token.transfer(addr1, 1000);

        vm.prank(addr1); // simula a chamada feita pelo addr1
        token.transferWithAutoBurn(addr2, 1000);

        // addr2 deve receber 900
        assertEq(token.balanceOf(addr2), 900);

        // totalSupply reduzido em 100
        assertEq(token.totalSupply(), (1_000_000 * 10 ** token.decimals()) - 100);
    }
}
