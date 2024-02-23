from brownie import VickreyAuction, accounts, web3, exceptions, MockERC20
import pytest

MAX_USERS = 4
PRIZE_AMOUNT = 100 * 10 ** 18

def test_initial_state(auction):
    # Test the initial state of the auction
    assert auction.owner() == accounts[0]
    assert auction.auctionEnded() == False
    assert auction.auctionSettled() == False

def test_place_bid(auction):
    # Test placing bids
    initial_bid = web3.toWei(1, 'ether')
    auction.bid({'from': accounts[1], 'value': initial_bid})
    assert auction.bids(accounts[1]) == initial_bid

def test_settle_auction(auction):
    # Place bids
    bids = {}
    for i in range(1,MAX_USERS+1):
        bid = web3.toWei(i, 'ether')
        auction.bid({'from': accounts[i], 'value': bid})
        bids[bid] = accounts[i].address
    # Settle the auction
    auction.settleAuction({'from': accounts[0]})
    bid_values = list(bids.keys())
    bid_values.sort()
    assert auction.auctionSettled() == True
    assert auction.winningBidPrice() == bid_values[-2]
    assert auction.winner() == bids[bid_values[-1]]

def test_settle_auction_impossible(auction):
    # Place bids
    bids = {}
    for i in range(1,MAX_USERS-1):
        bid = web3.toWei(i, 'ether')
        auction.bid({'from': accounts[i], 'value': bid})
        bids[bid] = accounts[i].address
    # Settle the auction
    with pytest.raises(exceptions.VirtualMachineError):
        auction.settleAuction({'from': accounts[0]})


def test_withdraw(auction):
    initial_balance = [accounts[0].balance()]
    # Place bids
    bids = {}
    for i in range(1,MAX_USERS+1):
        bid = web3.toWei(i, 'ether')
        initial_balance.append(accounts[i].balance())
        auction.bid({'from': accounts[i], 'value': bid})
        bids[bid] = accounts[i].address
        
    # Settle the auction
    auction.settleAuction({'from': accounts[0]})
    bid_values = list(bids.keys())
    bid_values.sort()
    # Perform withdrawal
    for i in range(1,MAX_USERS+1):
        auction.withdraw({'from': accounts[i]})
        if accounts[i].address == bids[bid_values[-1]]:
            # check winner's balance
            assert accounts[i].balance() == initial_balance[i] - bid_values[-2], "Winner's balance is incorrect"
        else:
            # check loser's balance
            print(i)
            assert accounts[i].balance() == initial_balance[i], "Loser's balance is incorrect"
    # check owner's balance
    auction.ownerWithdraw({'from': accounts[0]})
    assert accounts[0].balance() == initial_balance[0] + bid_values[-2], "Owner's balance is incorrect"

def test_reset_auction(auction):
    # Place bids
    bids = {}
    for i in range(1,MAX_USERS+1):
        bid = web3.toWei(i, 'ether')
        auction.bid({'from': accounts[i], 'value': bid})
        bids[bid] = accounts[i].address
    # Settle the auction
    auction.settleAuction({'from': accounts[0]})
    # Reset the auction
    auction.resetAuction({'from': accounts[0]})
    # Assertions: Check the auction state is reset
    assert not auction.auctionEnded(), "Auction should not be marked as ended"
    assert not auction.auctionSettled(), "Auction should not be marked as settled"


def test_claim_price(auction,mock_erc20):
    # Place bids
    bids = {}
    for i in range(1,MAX_USERS+1):
        bid = web3.toWei(i, 'ether')
        auction.bid({'from': accounts[i], 'value': bid})
        bids[bid] = accounts[i].address
    # Settle the auction
    auction.settleAuction({'from': accounts[0]})
    bid_values = list(bids.keys())
    bid_values.sort()
    # Perform withdrawal
    for i in range(1,MAX_USERS+1):
        auction.withdraw({'from': accounts[i]})
    # check owner's balance
    auction.ownerWithdraw({'from': accounts[0]})

    assert mock_erc20.balanceOf(accounts[4]) == 0
    auction.claimPrize({'from':accounts[4]})
    assert mock_erc20.balanceOf(accounts[4]) == PRIZE_AMOUNT
