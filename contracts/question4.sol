// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20.sol";

/// @title Vickrey Auction Contract
/** @notice This contract implements a Vickrey auction system where participants bid for an ERC20 token prize. 
  * The winner pays the second-highest bid amount, and the prize is awarded after the auction concludes.
  */
contract VickreyAuction {
    uint public constant MAX_USERS = 4; 
    address public owner; 
    IERC20 public prizeToken; // ERC20 token to be used as the prize
    uint256 public prizeAmount; // Amount of the prize token
    uint public constant AUCTION_DURATION = 7 days; 

    address[] public bidders;
    mapping(address => uint) public bids; 
    address public winner; 
    uint public winningBidPrice; // Price paid by the winner (second-highest bid)
    uint public secondHighestBid; 

    bool public auctionEnded; 
    bool public auctionSettled; 
    uint public auctionStartTime; 
    bool public auctionInitialized = false; 

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier auctionNotEnded() {
        require(!auctionEnded, "The auction has already ended.");
        _;
    }

    constructor(address _prizeToken, uint256 _prizeAmount) public {
        owner = msg.sender;
        prizeToken = IERC20(_prizeToken); // Address of the ERC20 token to be used as the prize
        prizeAmount = _prizeAmount; // Amount of the prize token
    }

 
    /**
     * @dev Initializes the auction, Transfers the prize amount from the owner to the contract
     */
    function initializeAuction() public onlyOwner {
        require(!auctionInitialized, "Auction already initialized.");
        auctionStartTime = block.timestamp;
        auctionInitialized = true;
        require(prizeToken.transferFrom(owner, address(this), prizeAmount), "Failed to lock prize");
    }



    /**
    * @notice Allows a bidder to place a bid in the auction
    * @dev Adds the bidder to the bidders array and records their bid amount
     */
    function bid() external payable auctionNotEnded {
        require(bids[msg.sender] == 0, "Bid already placed.");
        require(!auctionEnded, "Auction has already ended");
        require(block.timestamp <= auctionStartTime + AUCTION_DURATION, "Auction duration has passed.");

        bidders.push(msg.sender);
        bids[msg.sender] = msg.value;

        if (bidders.length == MAX_USERS) {
            auctionEnded = true;
        }
    }

    /**
    * @notice Settles the auction, determining the winner and the winning bid price
    * @dev Finds the winner and second-highest bids, sets the auction as settled
     */
    function settleAuction() external onlyOwner {
        require(auctionEnded && !auctionSettled, "Auction not ended or already settled.");
        uint highestBid = 0;

        for (uint i = 0; i < bidders.length; i++) {
            uint bidValue = bids[bidders[i]];
            if (bidValue > highestBid) {
                secondHighestBid = highestBid;
                highestBid = bidValue;
                winner = bidders[i];
            } else if (bidValue > secondHighestBid) {
                secondHighestBid = bidValue;
            }
        }

        winningBidPrice = secondHighestBid;
        auctionSettled = true;
    }


    /**
    * @dev  Transfers the prize token amount to the winner
     */
    function claimPrize() external {
        require(msg.sender == winner, "Only the winner can claim the prize.");
        require(auctionSettled, "Auction must be settled first.");
        require(prizeToken.transfer(winner, prizeAmount), "Failed to transfer prize.");
    }

    
    /**
    * @dev  Winners withdraw the difference between their bid and the winning bid, losers withdraw their full bid
     */
    function withdraw() external {
        require(auctionSettled, "Auction not settled.");
        if (msg.sender == winner) {
            payable(msg.sender).transfer(bids[msg.sender] - winningBidPrice);
        } else {
            payable(msg.sender).transfer(bids[msg.sender]);
        }
        bids[msg.sender] = 0;
    }


    /**
    * @dev  Allows the owner to withdraw the winning bid amount after the auction is settled
     */
    function ownerWithdraw() external onlyOwner {
        require(auctionSettled, "Auction not settled.");
        payable(owner).transfer(winningBidPrice);
    }


    /**
    * @dev  Ends the auction. Can only be called by the owner after the auction duration has passed without reaching max users
     */
    function endAuction() external onlyOwner {
        require(block.timestamp > auctionStartTime + AUCTION_DURATION, "Auction duration not yet passed.");
        require(!auctionEnded, "Auction already ended by owner or max bidders reached");
        auctionEnded = true;
    }


    /**
    * @dev  Allows the owner to withdraw the prize if the auction ends unsuccessfully. Can only be done if the auction has ended and not settled
     */
    function ownerWithdrawPrize() external onlyOwner {
        require(!auctionSettled, "Auction already settled.");
        require(block.timestamp > auctionStartTime + AUCTION_DURATION, "Auction duration not yet passed.");
        require(prizeToken.transfer(owner, prizeAmount), "Failed to transfer prize back to owner");
    }


    /**
    * @dev   Refunds bids if the auction ends unsuccessfully
     */
    function refundBids() external {
        require(auctionEnded && !auctionSettled, "Auction not yet ended.");
        require(bidders.length < MAX_USERS, "Maximum users reached, auction can be settled.");
        require(bids[msg.sender] > 0, "No bid to refund.");

        uint refundAmount = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);
    }


    /**
    * @dev  Resets auction state
     */
    function resetAuction() external onlyOwner {
        require(auctionSettled, "Auction not settled.");
        for (uint i = 0; i < bidders.length; i++) {
            bids[bidders[i]] = 0;
        }
        delete bidders;
        winner = address(0);
        winningBidPrice = 0;
        secondHighestBid = 0;
        auctionEnded = false;
        auctionSettled = false;
        auctionStartTime = 0;
        auctionInitialized = false;
    }

}
