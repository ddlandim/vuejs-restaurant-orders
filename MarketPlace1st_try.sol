pragma solidity >=0.4.22 <0.7.0;

// contract Ownable {
//   address owner;
//   function Ownable() public {
//     owner = msg.sender;
//   }

//   modifier Owned {
//     require(msg.sender == owner);
//     _;
//   }
// }

// contract Mortal is Ownable {
//   function kill() public Owned {
//     selfdestruct(owner);
//   }
// }

contract MarketPlace {

    address contract_owner = msg.sender;
    
    uint256 contract_birth_date = 0;

    //amount of users registered
    uint contract_total_users = 0;
    
    //amount of products registered
    uint contract_total_products = 0;
    
    //amount of brute value of sales
    uint contract_total_orders = 0;
    
    //amount of brute value of sales
    uint contract_total_amount = 0;
    
    // function() public { //fallback
    //     revert();
    // }
    
    function checkContractBalance() public view returns(uint) {
      return address(this).balance;
    }


    function strCompare(bytes32 a, bytes32 b) payable public returns(bool){
        require(msg.value > 200);
        return (a == b);
    }

    function getCurrentTimestamp() payable public returns (uint){
      require(msg.value > 300);
      return now;
    }

    struct User{
        uint eth_address;
        bytes32 name;
        bytes32 category;
        uint registered_date;
        uint total_spended;
        bool exist;
    }
    
    //consider as product.
    struct Product{
        //name
        bytes32 name;
        
        //product type as drink or food
        bytes32 category;
        
        //value
        uint value;

        bool exist;
    }
    
    //consider as user_order of a single product (table-order has a map of users_orders).
    struct Order{
        uint timestamp;
        User supplier;
        User costumer;
        uint product_amount;
        Product product;
        bool exist;
    }
    
    //Mappings
    mapping (uint => User) users;
    
    mapping (bytes32 => Product) products;
    
    mapping (uint => Order) orders;
  
  /* TRANSACTIONS */
    
    function getAtributes() payable public returns(uint, uint, uint, uint){
        require(msg.value > 1300);
        return (contract_total_amount,
                contract_total_orders,
                contract_total_users,
                contract_total_products);
    }

    //User methods
    // struct User{
    //     uint eth_address;
    //     bytes32 name;
    //     bytes32 category;
    //     uint registered_date;
    //     uint total_spended;
    //     bool exist;
    // }
    function getUser(uint eth_address) payable public returns (bytes32 , bytes32 , uint, uint) {
        require(msg.value > 1800);
        if (users[eth_address].exist)
            return ( users[eth_address].name, 
                        users[eth_address].category, 
                        users[eth_address].registered_date, 
                        users[eth_address].total_spended);

        return("not_founded", "not_founded", 0, 0);
    }
    //if a existing address is called, this function update the user information
    function setUser(uint eth_address, bytes32  name , bytes32  category) payable public returns(bool){
         require(msg.value > 127000);
         if (users[eth_address].exist){
                users[eth_address].name = name; 
                users[eth_address].category = category;
                users[eth_address].registered_date = now;
                return false;
         }else{
            users[eth_address] = User(eth_address,name,category,now,0,true);
            contract_total_users++;
            return true;
         }
    }

    //Product Methods
    // struct Product{
    //     bytes32 name;
    //     bytes32 category;
    //     uint value;
    //     bool exist;
    // }
    //we cant have 2 products with same nome, so, i created a set map of bytes32 => uint.
    //if a same name is passed, the map overload the product
    function getProduct(bytes32  name) payable public returns (bytes32 , uint) {
        require(msg.value > 1100);
        if(products[name].exist){
            return(products[name].category,products[name].value);    
        }
        else return("not_founded",0);
    }
    function setProduct(bytes32  name, bytes32  category, uint value) payable public returns(bool){
        require(msg.value > 102000);
        if (products[name].exist){
                products[name].category = category;
                products[name].value = value;
                return false;
         }else{
            products[name] = Product(name,category,value,true);
            contract_total_products++;
            return true;
         }
    }
    // struct Order{
    //     uint timestamp;
    //     User supplier;
    //     User costumer;
    //     uint product_amount;
    //     Product product;
    //     bool exist;
    // }
    function setOrder(uint supplier_address, uint costumer_address, bytes32 name, uint product_amount) payable public {
        require(msg.value > 470000);
        if(users[supplier_address].exist && users[costumer_address].exist && products[name].exist){
            
            //Updating counters
                uint transation_amount = products[name].value * product_amount;
                
                users[supplier_address].total_spended += transation_amount;

                users[costumer_address].total_spended += transation_amount;
                
                contract_total_amount += transation_amount;
            
            //Setting order
            orders[contract_total_orders] = Order(now,users[supplier_address],users[costumer_address],product_amount,products[name],true);
            
            contract_total_orders ++;
        }
    }
    function reduceOrders(uint timestamp_begin, uint timestamp_end) payable public returns (uint) {
        uint time_amount = 0;
        for(uint i = 0; i < 100; i++){
            if(timestamp_begin <= orders[i].timestamp && orders[i].timestamp <= timestamp_end)
                time_amount += (orders[i].product.value * orders[i].product_amount);
        }
        return time_amount;
    }

    function reduceProductNameOrders(bytes32  name, uint timestamp_begin, uint timestamp_end) payable public returns (uint) {
        uint time_amount = 0;
        for(uint i = 0; i < contract_total_orders; i++){
            if(strCompare(orders[i].product.name, name) && timestamp_begin <= orders[i].timestamp  && orders[i].timestamp <= timestamp_end)
                time_amount += (orders[i].product.value * orders[i].product_amount);
        }
        return time_amount;
    }
    
    function reduceProductCategoryOrders(bytes32  category, uint timestamp_begin, uint timestamp_end) payable public returns (uint) {
        uint time_amount = 0;
        for(uint i = 0; i < contract_total_orders; i++){
            if(strCompare(orders[i].product.category, category) && timestamp_begin <= orders[i].timestamp  && orders[i].timestamp <= timestamp_end)
                time_amount += (orders[i].product.value * orders[i].product_amount);
        }
        return time_amount;
    }

    function reduceCostumerCategoryOrders(bytes32  costumer_category, uint timestamp_begin, uint timestamp_end) payable public returns (uint) {
        uint time_amount = 0;
        for(uint i = 0; i < contract_total_orders; i++){
            if(orders[i].exist && strCompare(orders[i].costumer.category, costumer_category) && timestamp_begin <= orders[i].timestamp  && orders[i].timestamp <= timestamp_end)
                time_amount += (orders[i].product.value * orders[i].product_amount);
        }
        return time_amount;
    }

    function reduceSupplierCategoryOrders(bytes32  supplier_category, uint timestamp_begin, uint timestamp_end) payable public returns (uint) {
        uint time_amount = 0;
        for(uint i = 0; i < contract_total_orders; i++){
            if(orders[i].exist && strCompare(orders[i].supplier.category, supplier_category) && timestamp_begin <= orders[i].timestamp  && orders[i].timestamp <= timestamp_end)
                time_amount += (orders[i].product.value * orders[i].product_amount);
        }
        return time_amount;
    }
    
   /* Constructor */
    constructor() public {
        contract_total_users = 0;
        contract_total_products = 0;
        contract_total_orders = 0;
        contract_total_amount = 0;
        contract_birth_date = now;
        
        users[0] = User(0,"contract_user","dapp",now,0,true);
        products["contract_product"] = Product("contract_product", "dapp", 0, true);
        orders[0] = Order(now,users[0],users[0],1,products["contract_product"],true);
    }
}