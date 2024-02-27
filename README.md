# Problem Set 1 - Smart Contract with Ethereum


pip install -r requirements.txt

brownie install

    https://eth-brownie.readthedocs.io/en/stable/install.html

nvm use 16.13.2

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

Deployment transaction : https://sepolia.etherscan.io/tx/0xbf8d40047c24dc514351db0345265d0fe505ffed5e532b05ff5c8d1c911a5a49

Contract : https://sepolia.etherscan.io/address/0xd8e538a9f313a2aac2d6ca5e9020d45129e2ccf8

Owner : 0xF5E2F05561773c811690c4804AcEad780B54dd7d

##  2. Exercise

### Question 1 - Simple Transaction

https://sepolia.etherscan.io/tx/0xbaa7752beb30250b9c3fed39801b666a5dd504110c2d9ce7108f9e3bdbb08d3b

### Question 2 - Simple Contract - Faucet

See contracts/question2.sol

https://sepolia.etherscan.io/address/0x5d87f1b5665ef46ff2ab2a6d1d55b41b985b7ea1

### Question 3 - Augmented Faucet

See contracts/question3.sol

https://sepolia.etherscan.io/address/0x58ef770f108580aed786dbc302e2b31947be303b

### Question 4 - Vickrey Auction

See contracts/question4.sol

Corresponding tests are in tests/test_vickrey_auction.py 

To run tests: 

```
  $ brownie test
```
Auctionned item corresponds to 10000000000000000 Uni Token
8000000000000000

* UNI Token Address https://sepolia.etherscan.io/token/0x1f9840a85d5af5bf1d1762f925bdaddc4201f984


* Auction contract address
https://sepolia.etherscan.io/address/0x8652c45ee8c21dc61e4a8e88e1de61f2cbf92ce8

* Before calling initializeAuction() call approve() on  

    https://sepolia.etherscan.io/address/0x1f9840a85d5af5bf1d1762f925bdaddc4201f984#tokentxns

    Use auction's contract address as input for spender's address

