

from brownie import VickreyAuction, accounts, web3, exceptions, MockERC20
import pytest


@pytest.fixture(scope="function")
def mock_erc20():
    # Deploy the auction contract with ERC20 token address and prize amount as parameters
    mock_erc20 = MockERC20.deploy("TestToken", "TT", 18, 1e24, {'from': accounts[0]})
    yield mock_erc20


@pytest.fixture(scope="function")
def auction(mock_erc20):
    prize_amount = 100 * 10 ** 18
    auction = VickreyAuction.deploy(mock_erc20.address, prize_amount, {'from': accounts[0]})
    # Set allowance: approve the auction contract to spend tokens on behalf of the owner
    mock_erc20.approve(auction.address, prize_amount, {'from': accounts[0]})
    auction.initializeAuction({'from': accounts[0]})
    yield auction
