# Problem Set 1 - Smart Contract with Ethereum

##  1. Set up the Environment
Simple Contract Test

```
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract SimpleStorage {
    string storedData;

    function set(string memory x) public {
        storedData = x;
    }

    function get() public view returns (string memory) {
        return storedData;
    }
}
```

Contract Address : 0xd8e538a9f313A2aac2D6CA5e9020D45129E2CCf8

Deployment transaction : https://sepolia.etherscan.io/tx/0xbf8d40047c24dc514351db0345265d0fe505ffed5e532b05ff5c8d1c911a5a49

Contract : https://sepolia.etherscan.io/address/0xd8e538a9f313a2aac2d6ca5e9020d45129e2ccf8

##  2. Exercise

### Question 1 - Simple Transaction

https://sepolia.etherscan.io/tx/0xbaa7752beb30250b9c3fed39801b666a5dd504110c2d9ce7108f9e3bdbb08d3b

### Question 2 - Simple Contract - Faucet

See contracts/question2.sol

### Question 3 - Augmented Faucet

See contracts/question3.sol

### Question 4 - Vickrey Auction

See contracts/question4.sol

Corresponding tests are in tests/test_vickrey_auction.py 

To run tests 

```
  $ brownie test
```
