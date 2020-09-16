# Restaurante-Controle-Comandas-Vuejs

# English Description:

## This is a ACADEMIC project, and the scenario is as follows:

- I have a restaurant with a vuejs system working to manage tables that accommodate multiple users and users place orders.
The order is the request for a product in a certain quantity made by a user inside a table, and this system in vuejs
works with json-server database.

This all works!

- I am broken in the pandemic and I need to make money with the restaurant closed, selling my data to market analysts and people who need data for AI studies, etc.

- But I don't want my competitors to know that the data is mine, I need my data to be anonymous for those who consult it, and I want to be paid for each consultation.

The role of blockchain integration:

On the blockchain I created 2 structures:

```
struct User {
 string name;
 bytes32 status;
 address walletAddress;
 uint createdAt;
 uint updatedAt;
}

struct Order {
 address product;
 address costumer;
 address supplier;

 bytes32 product_name;
 bytes32 costumer_category;
 bytes32 supplier_category;

 uint amount;
 uint value;
 uint timestamp;

 uint consulted;
}

// Array of User that holds the list of users and their details
User [] public users;

// Array of User that holds the list of users and their details
Order [] public orders;

```

The rest are functions that update and manage these structures ...
User can be a consumer, supplier, broker, and even a product! rs, and why can a product be a user? because each product will be unique in the whole blockchain and I will avoid duplicates (for those who analyze the market and want to know about potato consumption; the potato from bar do joão is no different from the potato from bar do zé, and as there is a registration cost I will avoid suppliers to create irrelevant variations).

An Order links a product being sold to a consumer through a supplier. (the supplier is the address connected to the metamask of the system making the transaction)

With the blockchain integrated into my existing platform, each order "order" that I place, a copy of this order goes as a struct "order" for the blockchain, with the address of the product, consumer and supplier wallet, and the transaction information : (amount of the product, amount that I stipulated for the product, and date of the transaction).

On the query side:
If a market analyst wants to research market movement that involves users of the type "Professor" consuming "Beer" in a specific amount or value or or date, he can and can do this without knowing who the professor and the supplier are, because the public functions for consultation only allow you to enter the product name and category of the user.

In the query loop, each "order" that matches the query is incremented in the uint consulted field.

After that, the contract owner can periodically take the entire balance of ETH accumulated by the contract, because the consultation functions are "payable" and distribute to users / suppliers linked in each order, using the parameter uint consulted to know how many times that order was relevant and consulted. This function is private and accessible only by the contract owner.

There are other public consultation functions such as the one that lists users and products, and the one that registers a user and product, and the one that checks the address of msg.sender and allows only the user himself to change his user data in the vector of users.

## What is already integrated in the VUEJS:

In the VUEJS system there are 2 pages that interact with the blockchain:

"ESTATISTICAS" which lists users and products of the blockchain.

"Registration" that adds a new user or product to the blockchain. It also changes the registered data. (when accessing it, it checks the address of your wallet in metamask connected to the system, if the address does not exist, it registers, if the address exists, it updates the data).
### What neet to be done:

#### 1) Fix the users listing:
On the "Estatisticas" page where the users and products is listed, i have to split in 2 lists (users and products), and I need to Vuejs compare this data with what is stored on the json-server, and ask if I want to include the missing users/products. (with checkboxes).
 
#### 2) Add the views in front end:
On this same page I need to do the front end to call the functionality of querying orders on the blockchain.
this front-end will work with the following functions:
- 1 button, with output block to return the function value:
```
function totalUsers () public view returns (uint){ …}
```
- 1 button, with output block to return the function value:
```
function totalOrders () public view returns (uint) { … }
```
- 1 field for me to enter how much "gas" I want to pay for the reduce orders function,
- 4 fields  fields for calling this function:
```
function reduceOrders ( bytes32 _product_name, bytes32 _costumer_category, uint _begin, uint _end ) payable public returns (uint)
```
all the fiels are optional, and the begin and end are timestamp value, so I need the input data to be in the calendar/time format.

- 1 button to do the query, with output block.

#### 3) Link VUEJS “place order” in JSON-SERVER through axios with “place order function in blockchain”
- On page “visao-geral” I need to do a functionally to add users on a table when a table is created (today this is only a numeric value, we don’t have users on table struct yet), linking with the users of blockchain (if the  milestone “1” is done, this part can done taking the users from json-server with is integrated too). 
Remembering the users in vuejs data base need a field to inform it is in or not in blockchain.

- In page “editar-mesa” when we build a order, I want to display a user selection, and then when the order is placed (wich is already sended/updated to json-server) 
I want to call the blockchain function:
```
function placeOrder(address w_product, address w_costumer, uint amount, uint value) public { … }
```

# PT-BR
PROJETO FINAL DA DISCIPLINA DE SISTEMAS DISTRIBUÍDOS!!!
ddlandim@unifesp.br

- Este projeto é uma ramificação de um sistema de controle de restaurante elaborado em vuejs
https://github.com/ddlandim/cs-unifespbr-paradigmas/tree/master/projetoFinal

Neste branch o sistema está integrado à blockchain Ethereum.

Com a blockchain Ethreum o sistema pode atualizar sua base de dados com usuários e produtos existentes na rede Blockchain (sem se desfazer de sua atual plataforma)

Pode cadastrar na blockchain toda a sua movimentação, para gerar estatísticas de mercado na blockchain e ser pago por quem consultar os dados nos quais o restaurante está envolvido (um pedido cadastrado na blockchain possui um rastreamento de produto, consumidor e vendedor)

E também pode fazer o seu cadastro e consultador estatísticas na blockchain.

Créditos aos projetos e tutoriais que me guiaram neste passo a passo (foram muitas tentativas até chegar em uma solução).

Aliás você pode ver as tentativas nos arquivos .sol localizados na raiz do projeto.

Tutoriais:
[Truffle Guide] ETHEREUM PET SHOP -- YOUR FIRST DAPP
https://www.trufflesuite.com/tutorials/pet-shop

Decentralized E-Commerce using ETHEReact! (ganache enviroment) : 
https://github.com/PruthviKumarBK/Decentralized_eCom

dapp-tutorial : Ethereum Casino with Vuejs (remix enviroment) :
https://github.com/kyriediculous/dapp-tutorial

# Configurações de Ambiente / ENVIROMENT SETUP

- Instalação NodeJS https://nodejs.org/en/download/
- sudo apt-get install npm yarn nodejs
- sudo npm install -g json-server

# Execute o banco local da plataforma: entre no diretorio diretorio: /json-server
- json-server info.json

# Implantação e Configuração da blockchain:
- Primeiro verifique o contrato que se localiza em /contracts/MarketPlace.sol e entenda as lógicas das funções e estruturas de dados que vamos hospedar na rede virtual Ethereum.

* Particularmente eu gosto de mexer em um smartcontract .sol no editor de arquivos, e quando quero testar utilizo a plataforma : https://remix.ethereum.org/ . Mas cuidado faça sempre uma cópia local do seu arquivo. Esta IDE online pode potencialmente dar um crash em seu sistema operacional se houver algum código que gere loop infinito.

- Instale a Rede Ethereum pelo comando: npm install -g ganache-cli , eu prefiro a interface gráfica e uso windows, então instalei a partir do link: https://www.trufflesuite.com/ganache
- Pelo aplicativo da interface gráfica, você pode opcionalmente acessar a aba contracts e adicionar o arquivo truffle-config.js na rede virtual. Isso tornará o código em solidity rastreável na aba Contracts.

- Após os passos anteriores e com o ganache instalado execute o comando na pasta raíz do projeto, onde o se encontra arquivo "truffle-config.js": 
```
$ truffle console ––network ganache
```
- E depois dentro do novo console aberto do ganache execute o novo comando: 
```
truffle(ganache)> migrate ––reset ––compile-all
```
# Implantação e Configuração do Metamask:
- Agora o contrato está implantado na rede e o Ganache criou um arquivo "artefato" json, que fornece todas as propriedades do contrato inteligente, bem como seu endereço, suas funções e suas estruturas.
vá até a pasta /build/contracts/ e copie o arquivo MarketPlace.json para a pasta /restaurante-gestao/src/assets/ 
Os componentes do Vuejs estão configurados para buscar este arquivo nesta pasta e carregador suas propriedades (que fazem um link para as funções e estruturas de dados do contrato implatado na blockchain ethereum)

- Ultimo passo é configurar a Metamask. Instale o plugin no chrome e importe uma conta. No Ganache (app com interface gráfica) você pode acessar a aba contas e copiar uma das chaves privadas e importar a conta no metamask de seu navegador.
 a metamask é a ponte entre o código front-end sendo executado em seu navegador e a blockchain. Toda vez que alguma página do vuejs for acessar uma função ou estrutura hospedada pelo smartcontract, esse código irá acionar um pagamento para o contrato, e sua metamask te fará uma notificação para autorizar o pagamento e ter acesso aos dados.

# Para rodar o projeto:
##instalar dependencias do projeto: 
 - Com a metamask configurada com uma conta com ETH, vá até a pasta /restaurante-gestao e execute o comando para instalar os pacotes do projeto e em seguida executálo: 
  sudo npm install && npm run dev

  ou 
  
- sudo npm install
- npm run dev

# Mais informações sobre o sistema do restaurante em "documentacao.pdf"
