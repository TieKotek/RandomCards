from brownie import Cards, network, accounts, config


def main():
    sub_id = config["networks"][network.show_active()]["subscriptionId"]
    vrf_addr = config["networks"][network.show_active()]["VRFCoordinator"]
    price_addr = config["networks"][network.show_active()]["Aggregator"]
    key_hash = config["networks"][network.show_active()]["keyHash"]
    cards = Cards.deploy(
        sub_id,
        vrf_addr,
        key_hash,
        price_addr,
        2,
        8,
        40,
        50,
        {"from": accounts.load("hrq")},
        publish_source=True,
    )
