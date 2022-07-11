from typing import Counter
from brownie import config, network, accounts, Contract
import pytest
import time
import json

BASE_FEE = 0  # The premium
GAS_PRICE_LINK = 0  # Some value calculated depending on the Layer 1 cost and Link


def match(randomness, rarity):
    if 1 <= randomness and randomness <= 2:
        return rarity == 0
    if 3 <= randomness and randomness <= 10:
        return rarity == 1
    if 11 <= randomness and randomness <= 50:
        return rarity == 2
    if 51 <= randomness and randomness <= 100:
        return rarity == 3


def test_can_enter():
    if network.show_active() in ["development", "ganache-local"]:
        pytest.skip()
    with open("abi/cards_abi.json") as f:
        abi_str = f.read()
    abi = json.loads(abi_str)
    cards = Contract.from_abi(
        "Cards", "0xeB471970806369B4769571E206FE631A033B78e8", abi
    )
    cnt = cards.tokenCounter()
    account = accounts.add(config["wallets"]["from_key"])
    cards.Enter({"from": account, "value": cards.getEntryFee()})
    time.sleep(90)
    assert match(
        cards.randomness() % 100, cards.tokenIdToRarity(cards.tokenCounter() - 1)
    )
    assert 1 + cnt == cards.tokenCounter()
    assert cards.legendRate() == 2
    assert cards.epicRate() == 8
    assert cards.rareRate() == 40
    assert cards.normalRate() == 50
