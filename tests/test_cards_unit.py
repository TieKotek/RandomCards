from brownie import VRFCoordinatorV2Mock, MockV3Aggregator, Cards, network, accounts
import pytest

BASE_FEE = 0  # The premium
GAS_PRICE_LINK = 0  # Some value calculated depending on the Layer 1 cost and Link


def test_can_enter():
    if network.show_active() != "development":
        pytest.skip()
    vrf = VRFCoordinatorV2Mock.deploy(BASE_FEE, GAS_PRICE_LINK, {"from": accounts[0]})
    aggre = MockV3Aggregator.deploy(8, 100000000000, {"from": accounts[0]})
    tx = vrf.createSubscription({"from": accounts[0]})
    sub_id = tx.events["SubscriptionCreated"]["subId"]
    print(f"sub_id={sub_id}")
    tx2 = vrf.fundSubscription(sub_id, 1000000000000000000, {"from": accounts[0]})
    cards = Cards.deploy(
        sub_id,
        vrf.address,
        "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        aggre.address,
        2,
        8,
        40,
        50,
        {"from": accounts[0]},
    )
    print(f"Cards deployed at {cards.address}")
    entryFee = cards.getEntryFee()
    usdEntryFee = cards.usdEntryFee()
    print(f"entryFee is {entryFee}")
    # times = 1
    # for i in range(times):
    #     tx = cards.Enter({"from": accounts[i], "value": entryFee})
    #     req_id = tx.events["RequestedRandomness"]["requestId"]
    #     tx = vrf.fulfillRandomWords(req_id, cards.address, {"from": accounts[0]})
    #     print(tx.events)
    count = cards.tokenCounter()

    # assert count == times
    assert cards.lengendRate() == 2
    assert usdEntryFee == 50 * 10**18
