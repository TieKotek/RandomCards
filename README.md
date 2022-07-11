# RandomCards

A brownie project for random cards system on Ethereum.

## 一、项目背景

近几年来，抽卡游戏在全世界范围内越来越火热，但基本上现存的所有含有抽卡元素的游戏均为传统的中心化游戏。即代码不公开，且由游戏发行商运行传统服务器来维持游戏运营。因此，经常有游戏玩家诟病抽卡机制与商家声称的不一致，游戏发行商“暗箱操作”等等。显然，抽卡游戏需要玩家对发行商的信任，这让我们想到了近年来大火的区块链游戏（GameFi），我们是否能将抽卡游戏做到区块链上呢？依据区块链（公链）公开透明、不可篡改的性质，且[Chainlink](https://chain.link/)为以太坊智能合约提供了可验证随机数（VRF）服务，这使得我们的抽卡系统在理论上可行。因此，我们本次的项目聚焦于一个部署在区块链系统上的、用智能合约编写的抽卡系统，为未来抽卡链游的发展奠定基础。


## 二、项目环境与产出
我们使用了基于web3.py的智能合约框架[brownie](https://github.com/eth-brownie/brownie)进行项目的搭建与测试。主要产出为一份经过充分测试的智能合约代码（/contracts/Cards.sol）以及部署在rinkeby测试网络上的一份实例。


## 三、项目特点
- 抽卡入场费以ETH支付，但入场费的金额与美元价值成正比，ETH和美元汇率的实时数据通过Chainlink预言机获得，这保障了在以太坊剧烈波动的情况下，游戏玩家仍然能以较为稳定的价格参加抽卡，同时也保障了游戏发行商的稳定收入。
  
- 抽卡使用的随机数为向chainlink预言机申请的可验证随机数，理论上任何人均可验证该随机数的随机性，且代码逻辑公开透明，不存在暗箱操作。

- 抽卡结果将以NFT形式发行并发送给发起抽卡的用户，用户可以在NFT交易平台上浏览自己的NFT并且进行转让。 


## 四、rinkeby实例及交互方法


我们的实例部署在了rinkeby测试网络上，可以通过下面这个链接访问到我们的合约并进行交互：
https://rinkeby.etherscan.io/address/0xeb471970806369b4769571e206fe631a033b78e8

如下图为合约读接口：
![读接口](/img/readcontract.png)

合约写接口：
![写接口](/img/writecontract.png)


这之中有部分为ERC721接口，可以参考ERC721标准的文档，这里不赘述。主要用户抽卡过程中可能会需要调用的接口。

### 读接口：

#### 1. usdEntryFee
这个接口会返回由合约部署方决定的单抽美元价格，其小数点精度为18，即返回的数字为：$单抽美元价格* 10^18$


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


## 五、部署方法

上面我们提供了我们部署好的实例，现在我们展示如何简便地部署属于自己的抽卡合约。

### 1. 订阅VRF

之前提到了，我们的随机数由Chainlink提供，因此在部署合约之前，我们需要通过下面的链接进行订阅：https://vrf.chain.link

订阅完毕后，我们需要向VRF coordinator提供一些LINK代币，每一次申请随机数，将会消耗我们一定的LINK（这也是为什么我们的抽卡系统的入场费设置得比较高，因为成本同样不低）
![sub](/img/sub.png)


### 2. 部署Cards.sol
在本项目contracts文件夹中，有本项目核心代码Cards.sol。在部署前，若使用与上面实例中不同的卡片和metadata，需要部署方自己准备图片和元数据并且上传到IPFS上，并对Cards.sol的内容进行一些修改：

找到fulfillrandomWords函数，可以看到如下的代码：
![fulfillrandomWords](/img/fulfill.png)

这部分代码逻辑简单，不难看懂。

四个链接分别对应到了从高到低四个稀有度的metadata url，通过修改这些url，即可修改每个稀有度对应的NFT信息。

若要修改稀有度种类的数量或者每种稀有度对应的卡牌数量，读者可以通过阅读代码并做简易修改实现。

在进行个性化修改后，读者可以通过remix、brownie或者其它方法将合约部署到以太坊测试网或者主网上，如下展示的是该合约constructor信息，也即部署合约时需要提供的参数：
![constructor](/img/constructor.png)

subscriptionId为我们的订阅号，在订阅后能够查询到

vrfCoordinator、keyHash、priceFeedAddress：均可以在 https://docs.chain.link 查询到（注意不同以太坊网络这些合约地址是不相同的），其含义分别为向我们提供随机数的合约地址、不同gas费对应的keyhash（gas费越高，随机数相应越快）、向我们提供ETH/USD汇率数据的地址。
legendRate, epicRate, rareRate, normalRate：即各个稀有度对应的百分比，要求其和必须为100。

将对应的数据填入，并发出部署合约交易。

### 3. 添加Comsumer

在部署合约后，我们需要将合约的地址添加为VRF服务的消费者。这允许了我们的合约使用我们订阅的VRF服务，同样在 https://vrf.chain.link 完成。
![add](/img/add.png)
在部署了合约之后，合约拥有者可以通过withdraw函数取出合约上积攒的ETH。

**注意**：没有正确订阅服务、部署合约时填入错误地址或keyHash、订阅后没有充值LINK或者LINK耗尽、没有将合约添加为Comsumer都会导致合约无法正常运行。

