from brownie import VRFCoordinatorV2Mock, MockV3Aggregator, Cards, network, accounts
import pytest
from scripts.local_deploy import deploy

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
    if network.show_active() not in ["development", "ganache-local"]:
        pytest.skip()
    cards, vrf, entryFee = deploy()
    tx = cards.Enter({"from": accounts[0], "value": entryFee})
    req_id = tx.events["RequestedRandomness"]["requestId"]
    print(f"req_id={req_id}")
    tx = vrf.fulfillRandomWords(req_id, cards.address, {"from": accounts[0]})
    print(tx.events)
    assert match(cards.randomness() % 100, cards.tokenIdToRarity(0))
    assert 1 == cards.tokenCounter()
    assert cards.legendRate() == 2
    assert cards.epicRate() == 8
    assert cards.rareRate() == 40
    assert cards.normalRate() == 50
