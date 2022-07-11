from brownie import Cards, network, accounts, Contract, config
import pytest
import json


def main():
    with open("abi/cards_abi.json") as f:
        abi_str = f.read()
    abi = json.loads(abi_str)
    cards = Contract.from_abi(
        "Cards", "0xeB471970806369B4769571E206FE631A033B78e8", abi
    )
    cnt = cards.tokenCounter()
    print(cnt)
    account = accounts.add(config["wallets"]["from_key"])
    print(account.address)
