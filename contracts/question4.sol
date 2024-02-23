// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./IERC20.sol";


contract VickreyAuction {
    uint public constant MAX_USERS = 4;
    address public owner;
    IERC20 public prizeToken;
    uint256 public prizeAmount;

    address[] public bidders;
    mapping(address => uint) public bids;
    address public winner;
    uint public winningBidPrice;
    uint public secondHighestBid;
    bool public auctionEnded;
    bool public auctionSettled;

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
        prizeToken = IERC20(_prizeToken);
        prizeAmount = _prizeAmount;
    }

    function bid() external payable auctionNotEnded {
        require(bids[msg.sender] == 0, "Bid already placed.");
        require(!auctionEnded,"Auction has already ended");

        // add bidder to bidders' list 
        bidders.push(msg.sender); 
        // register bid amount
        bids[msg.sender] = msg.value;

        if (bidders.length == MAX_USERS) {
            auctionEnded = true;
        }
    }

    function settleAuction() external onlyOwner {
        require(auctionEnded && !auctionSettled, "Auction not ended or already settled.");
        uint highestBid = 0;

        // Find the highest and second-highest bids
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

        // Ensure the winner pays the second-highest bid
        winningBidPrice = secondHighestBid;
        auctionSettled = true;
    }

    function withdraw() external {
        require(auctionSettled, "Auction not settled.");
        if (msg.sender == winner) {
            // Winner can withdraw the difference between their bid and the winning bid
            payable(msg.sender).transfer(bids[msg.sender] - winningBidPrice);
        } else {
            // Losers can withdraw their full bid amount
            payable(msg.sender).transfer(bids[msg.sender]);
        }
        bids[msg.sender] = 0;
    }

    function ownerWithdraw() external onlyOwner {
        require(auctionSettled, "Auction not settled.");
        payable(owner).transfer(winningBidPrice);
    }

    function resetAuction() external onlyOwner {
        require(auctionSettled, "Auction not settled.");
        // Reset the state for a new auction
        for (uint i = 0; i < bidders.length; i++) {
            bids[bidders[i]] = 0;
        }
        delete bidders;
        winner = address(0);
        winningBidPrice = 0;
        secondHighestBid = 0;
        auctionEnded = false;
        auctionSettled = false;
    }

    function claimPrize() external {
        require(msg.sender == winner, "Only the winner can claim the prize.");
        require(auctionSettled, "Auction must be settled first.");
        require(prizeToken.transfer(winner, prizeAmount), "Failed to transfer prize.");
    }
}