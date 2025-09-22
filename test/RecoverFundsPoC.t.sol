// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol"; // <-- import console

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
}

contract HarvestResolver {
    function recoverFunds(address token) external {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }
}

contract NonStandardToken is IERC20 {
    uint256 public totalSupply = 1000 ether;
    mapping(address => uint256) private balances;

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }

    function transfer(address, uint256) external pure override returns (bool) {
        // Always returns false to simulate non-standard token
        return false;
    }

    // Mint helper for test setup
    function mint(address to, uint256 amount) public {
        balances[to] += amount;
        totalSupply += amount;
    }
}

contract RecoverFundsPoC is Test {
    HarvestResolver resolver;
    NonStandardToken nst;

    function setUp() public {
        resolver = new HarvestResolver();
        nst = new NonStandardToken();
        nst.mint(address(resolver), 10 ether);

        console.log("Initial resolver balance:", nst.balanceOf(address(resolver)));
        console.log("Initial owner balance:", nst.balanceOf(address(this)));
    }

    function testFrozenTokens() public {
        resolver.recoverFunds(address(nst));

        console.log("Resolver balance after recoverFunds:", nst.balanceOf(address(resolver)));
        console.log("Owner balance after recoverFunds:", nst.balanceOf(address(this)));

        assertEq(nst.balanceOf(address(resolver)), 10 ether, "Tokens should remain stuck");
    }
}

