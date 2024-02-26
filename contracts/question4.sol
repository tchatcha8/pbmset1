// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20.sol";


/// @title Vickrey Auction Contract
/** @notice This contract implements a Vickrey auction system where participants bid for a amount of ERC20 token prize. 
  * The winner pays the second-highest bid amount, and the prize is awarded after the auction concludes.
  */
contract VickreyAuction {
    address public owner; 
    uint public constant MAX_USERS = 4; 
    uint public constant AUCTION_DURATION = 7 days; 

    struct State{
        uint256 startTime;
        bool initialized;
        bool ended;
        bool settled;
    }

    struct AuctionedItem{
        IERC20  prizeToken; // ERC20 token to be used as the prize
        uint256  prizeAmount; // Amount of the prize token
    }

    address[] public bidders;
    mapping(address => uint) public bids; 
    address public winner; 
    uint public winningBidPrice; // Price paid by the winner (second-highest bid)
    uint public secondHighestBid;
    State public state;
    AuctionedItem public auctionedItem;


    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier auctionNotEnded() {
        require(!state.ended, "The auction has already ended.");
        _;
    }

    constructor(address _prizeToken, uint256 _prizeAmount) public {
        owner = msg.sender;
        auctionedItem.prizeToken = IERC20(_prizeToken); // Address of the ERC20 token to be used as the prize
        auctionedItem.prizeAmount = _prizeAmount; // Amount of the prize token
    }

 
    /**
     * @dev Initializes the auction, Transfers the prize amount from the owner to the contract
     */
    function initializeAuction() public onlyOwner {
        require(!state.initialized, "Auction already initialized.");
        state.startTime = block.timestamp;
        state.initialized = true;
        require(auctionedItem.prizeToken.transferFrom(owner, address(this), auctionedItem.prizeAmount), "Failed to lock prize");
    }

    /**
    * @notice Allows a bidder to place a bid in the auction
    * @dev Adds the bidder to the bidders array and records their bid amount
     */
    function bid() external payable auctionNotEnded {
        require(bids[msg.sender] == 0, "Bid already placed.");
        require(!state.ended, "Auction has already ended");
        require(block.timestamp <= state.startTime + AUCTION_DURATION, "Auction duration has passed.");

        bidders.push(msg.sender);
        bids[msg.sender] = msg.value;

        if (bidders.length == MAX_USERS) {
            state.ended = true;
        }
    }

    /**
    * @dev Settles the auction, determining the winner and the winning bid price
        Finds the winner and second-highest bids, sets the auction as settled
     */
    function settleAuction() external onlyOwner {
        require(state.ended && !state.settled, "Auction not ended or already settled.");
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
        state.settled = true;
    }


    /**
    * @dev  Transfers the prize token amount to the winner
     */
    function claimPrize() external {
        require(msg.sender == winner, "Only the winner can claim the prize.");
        require(state.settled, "Auction must be settled first.");
        require(auctionedItem.prizeToken.transfer(winner, auctionedItem.prizeAmount), "Failed to transfer prize.");
    }

    
    /**
    * @dev  Winners withdraw the difference between their bid and the winning bid, losers withdraw their full bid
     */
    function withdraw() external {
        require(state.settled, "Auction not settled.");
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
        require(state.settled, "Auction not settled.");
        payable(owner).transfer(winningBidPrice);
    }


    /**
    * @dev  Ends the auction. Can only be called by the owner after the auction duration has passed without reaching max users
     */
    function endAuction() external onlyOwner {
        require(block.timestamp > state.startTime + AUCTION_DURATION, "Auction duration not yet passed.");
        require(!state.ended, "Auction already ended by owner or max bidders reached");
        state.ended = true;
    }


    /**
    * @dev  Allows the owner to withdraw the prize if the auction ends unsuccessfully. 
            Can only be done if the auction has ended and not settled
     */
    function ownerWithdrawPrize() external onlyOwner {
        require(!state.settled, "Auction already settled.");
        require(block.timestamp > state.startTime + AUCTION_DURATION, "Auction duration not yet passed.");
        require(auctionedItem.prizeToken.transfer(owner, auctionedItem.prizeAmount), "Failed to transfer prize back to owner");
    }


    /**
    * @dev   Refunds bids if the auction ends unsuccessfully
     */
    function refundBids() external {
        require(state.ended && !state.settled, "Auction not yet ended.");
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
        require(state.settled, "Auction not settled.");
        for (uint i = 0; i < bidders.length; i++) {
            bids[bidders[i]] = 0;
        }
        delete bidders;
        delete state;
        winner = address(0);
        winningBidPrice = 0;
        secondHighestBid = 0;
    }

}
