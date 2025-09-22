// scripts/MinimalRecoverFunds.s.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function mint(address to, uint256 amount) external;
}

contract HarvestResolver {
    function recoverFunds(address token) external {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }
}

contract NonStandardToken is IERC20 {
    mapping(address => uint256) private balances;

    function mint(address to, uint256 amount) external override {
        balances[to] += amount;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }

    function transfer(address, uint256) external pure override returns (bool) {
        return false; // simulate failure
    }
}

contract MinimalRecoverFundsScript is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy contracts
        HarvestResolver resolver = new HarvestResolver();
        NonStandardToken token = new NonStandardToken();

        // Mint 10 tokens to resolver
        token.mint(address(resolver), 10 ether);

        // Log before
        console.log("Resolver before:", token.balanceOf(address(resolver)));
        console.log("Caller before:", token.balanceOf(msg.sender));

        // Attempt recovery
        resolver.recoverFunds(address(token));

        // Log after
        console.log("Resolver after:", token.balanceOf(address(resolver)));
        console.log("Caller after:", token.balanceOf(msg.sender));

        vm.stopBroadcast();
    }
}

