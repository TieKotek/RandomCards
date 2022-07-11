# RandomCards

A brownie project for random cards system on Ethereum.

## 一、项目背景

近几年来，抽卡游戏在全世界范围内越来越火热，但基本上现存的所有含有抽卡元素的游戏均为传统的中心化游戏。即，代码不公开，且由游戏发行商运行传统服务器来维持游戏运营。因此，经常有游戏玩家诟病抽卡机制与商家声称的不一致，游戏发行商“暗箱操作”等等。显然，抽卡游戏需要玩家对发行商的信任，这让我们想到了近年来大火的区块链游戏（GameFi），我们是否能将抽卡游戏做到区块链上呢？依据区块链（公链）公开透明、不可篡改的性质，且[Chainlink](https://chain.link/)为以太坊智能合约提供了可验证随机数（VRF）服务，这使得我们的抽卡系统在理论上可行。因此，我们本次的项目聚焦于一个部署在区块链系统上的、用智能合约编写的抽卡系统，为未来抽卡链游的发展奠定基础。


## 二、项目环境与产出
我们使用了基于web3.py的智能合约框架[brownie](https://github.com/eth-brownie/brownie)进行项目的搭建与测试。主要产出为一份经过充分测试的智能合约代码（/contracts/Cards.sol）以及部署在rinkeby测试网络上的一份实例。


## 三、项目特点
- 抽卡入场费以ETH支付，但入场费的金额与美元价值成正比，ETH和美元汇率的实时数据通过Chainlink预言机获得，这保障了在以太坊剧烈波动的情况下，游戏玩家仍然能以较为稳定的价格参加抽卡，同时也保障了游戏发行商的稳定收入。
  
- 抽卡使用的随机数为向chainlink预言机申请的可验证随机数，理论上任何人均可验证该随机数的随机性，且代码逻辑公开透明，不存在暗箱操作。

- 抽卡结果将以NFT形式发行并发送给发起抽卡的用户，用户可以在NFT交易平台上浏览自己的NFT并且进行转让。 


## 四、rinkeby实例及交互方法


我们的实例部署在了rinkeby测试网络上，可以通过下面这个链接访问到我们的合约并进行交互。
https://rinkeby.etherscan.io/address/0xeb471970806369b4769571e206fe631a033b78e8

如下图为合约读接口：
![读接口](/img/readcontract.png)

合约写接口：
![写接口](/img/writecontract.png)


这之中有部分为ERC721接口，可以参考ERC721标准的文档，这里不赘述。主要用户抽卡过程中可能会需要调用的接口。

### 读接口：

#### 1. usdEntryFee
这个接口会返回由合约部署方决定的单抽美元价格，其小数点精度为18，即返回的数字为
$$
        单抽美元价格\times 10^{18}
$$

#### 2. getEntryFee
这个接口会返回usdEntryFee美元数量对应的ETH价格，以wei为单位，这个价格为参加抽卡所需的最小ETH数量。

#### 3. legendRate, epicRate, rareRate, normalRate
在我们部署的实例中，卡片被分为四个稀有度，即传说（legend），史诗（epic），稀有（rare），普通（normal），这四个接口分别返回抽中这四个稀有度卡片的百分比。合约保证了这四个接口的返回值之和为100

### 写接口：
#### 1. Enter
即参与抽卡接口，任何用户均可调用，需要附带至少价值为上面提到的最小数量的ETH，否则将回滚。参与抽卡一定时间后可以访问 https://testnets.opensea.io/collection/randomcards 来查看已发行的卡片，并且可以通过搜索自己的地址来查看自己持有的卡片。


在我们部署的实例中，卡池中的卡片和对应稀有度信息如下：

#### LEGEND:

![Legend](/img/pug.png)

metadata url:  https://ipfs.io/ipfs/QmYdD4NWtd8cYRbos82HhKJFnuJEEdLGuQNELt41HxQsxT?filename=legend.json

概率：2%


#### EPIC

![Epic](/img/st-bernard.png)

metadata url: https://ipfs.io/ipfs/QmeWrdkv96Aq92Bvs6NYq6GWpZpcaAmpz9THQH3ZUJuvpz?filename=epic.json

概率：8%

#### RARE

![Rare](/img/shiba-inu.png)

metadata url: https://ipfs.io/ipfs/QmQ9XZQFa7jamtZj9f6wfzkN3udxuSwki5wBd1W82RBf3i?filename=rare.json

概率：40%

#### NORMAL

![Normal](/img/dog.png)

metadata url: https://ipfs.io/ipfs/QmQ9XZQFa7jamtZj9f6wfzkN3udxuSwki5wBd1W82RBf3i?filename=rare.json


概率：50%