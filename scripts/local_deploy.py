from brownie import (
    VRFCoordinatorV2Mock,
    MockV3Aggregator,
    Cards,
    network,
    accounts,
)

BASE_FEE = 0  # The premium
GAS_PRICE_LINK = 0  # Some value calculated depending on the Layer 1 cost and Link


def deploy():
    assert network.show_active() in ["development", "ganache-local"]
    vrf = VRFCoordinatorV2Mock.deploy(BASE_FEE, GAS_PRICE_LINK, {"from": accounts[0]})
    aggre = MockV3Aggregator.deploy(8, 100000000000, {"from": accounts[0]})
    tx = vrf.createSubscription({"from": accounts[0]})
    sub_id = tx.events["SubscriptionCreated"]["subId"]
    print(f"sub_id={sub_id}")
    vrf.fundSubscription(sub_id, 1000000000000000000, {"from": accounts[0]})
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
    entryFee = cards.getEntryFee()
    print(f"entryFee is {entryFee}")
    return cards, vrf, entryFee


def main():
    deploy()
