Overview
This Proof of Concept demonstrates a vulnerability in the HarvestResolver contract where it attempts to recover ERC20 tokens by calling the transfer function on a token contract.

The vulnerability arises because the token contract (NonStandardToken) here implements a non-standard transfer function that always returns false, simulating a failure. As a result, the recoverFunds function fails to transfer the tokens, leaving them stuck in the resolver contract.

This PoC highlights the risk of relying on external token contracts that do not conform strictly to the ERC20 standard, which can cause critical recovery functions to silently fail, leading to locked funds and potential loss.


Requirements:

Foundry (forge) installed
Anvil for running a local Ethereum node
Tested on Solidity 0.8.13 and Foundry 1.3.5-stable

Setup::

1.Clone the repository

git clone https://github.com/rachelvictory9773/MinimalRecoverFunds-PoC.git

cd MinimalRecoverFunds-PoC

2.Install dependencies with Foundry:
  forge install forge-std

3.How to run:
  1.Start a local Ethereum node using Anvil:
   anvil

  2.Run the PoC script
   forge script scripts/MinimalRecoverFunds.s.sol:MinimalRecoverFundsScript --broadcast --fork-url http://127.0.0.1:8545 -vvvv
  
  Expected output:

Resolver before: 10000000000000000000
Caller before: 0
Resolver after: 10000000000000000000
Caller after: 0

Script ran successfully.

This output shows that although tokens were minted to the resolver, the recoverFunds method failed to transfer tokens out because the non-standard token’s transfer function returned false

// whole running this script poc code. it gets some errors like sender address and all ,so while starting anvil, u get some address ,so if u want without that sender error ,attach the address like
forge script scripts/MinimalRecoverFunds.s.sol:MinimalRecoverFundsScript --broadcast --fork-url http://127.0.0.1:8545 --sender 0x18...  -vvvv

if u dont want  its fine ,leave it


4 . (Optional) Run tests:
forge test --match-path  test/RecoverFundsPoC.t.sol -vv

Expected output:

Ran 1 test for test/RecoverFundsPoC.t.sol:RecoverFundsPoC
[PASS] testFrozenTokens() (gas: 31701)
Logs:                                                                   Initial resolver balance: 10000000000000000000
  Initial owner balance: 1000000000000000000000                         Resolver balance after recoverFunds: 10000000000000000000
  Owner balance after recoverFunds: 1000000000000000000000

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 23.55ms (7.05ms CPU time)

Ran 1 test suite in 223.69ms (23.55ms CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
