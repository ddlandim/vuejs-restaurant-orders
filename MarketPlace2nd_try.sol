pragma solidity >=0.4.22 <0.7.0;

contract MarketPlace {

    address contract_owner = msg.sender;
    
    uint contract_birth_date = now;
    
    //amount of brute value of sales
    uint contract_total_amount = 0;

    struct Order{
        address product;
        address supplier;
        address costumer;
        uint timestamp;
        uint value;
        uint amount;
    }
    
    // Array of User that holds the list of users and their details
    Order[] public orders;

    // FUNCTIONAL data structure that stores a user
    struct User {
        string name;
        bytes32 status;
        address walletAddress;
        uint createdAt;
        uint updatedAt;
    }

    // it maps the user's wallet address with the user ID
    mapping (address => uint) public usersIds;

    // Array of User that holds the list of users and their details
    User[] public users;

    // event fired when an user is registered
    event newUserRegistered(uint id);

    // event fired when the user updates his status or name
    event userUpdateEvent(uint id);

    // Modifier: check if the caller of the smart contract is registered
    modifier checkSenderIsRegistered {
        require(isRegistered());
        _;
    }

    /* Function to register a new user.
     *
     * @param _userName         The displaying name
     * @param _status        The status of the user
     */
    function registerUser(string memory _userName, bytes32 _status) public
    returns(uint)
    {
        return addUser(msg.sender, _userName, _status);
    }

    /* Add a new user. This function must be private because an user
     * cannot insert another user on behalf of someone else.
     *
     * @param _wAddr        Address wallet of the user
     * @param _userName     Displaying name of the user
     * @param _status       Status of the user
     */
    function addUser(address _wAddr, string memory  _userName, bytes32 _status) private
    returns(uint)
    {
        // checking if the user is already registered
        uint userId = usersIds[_wAddr];
        require (userId == 0);

        // associating the user wallet address with the new ID
        usersIds[_wAddr] = users.length;
        uint newUserId = (users.length) + 1;

        // storing the new user details
        users[newUserId] = User({
            name: _userName,
            status: _status,
            walletAddress: _wAddr,
            createdAt: now,
            updatedAt: now
        });

        // emitting the event that a new user has been registered
        emit newUserRegistered(newUserId);

        return newUserId;
    }

    /* Update the user profile of the caller of this method.
     * Note: the user can modify only his own profile.
     *
     * @param _newUserName  The new user's displaying name
     * @param _newStatus    The new user's status
     */
    function updateUser(string memory _newUserName, bytes32 _newStatus) checkSenderIsRegistered public
    returns(uint)
    {
        // An user can modify only his own profile.
        uint userId = usersIds[msg.sender];

        User storage user = users[userId];

        user.name = _newUserName;
        user.status = _newStatus;
        user.updatedAt = now;

        emit userUpdateEvent(userId);

        return userId;
    }

    /* Get the user's profile information.
     *
     * @param _id   The ID of the user stored on the blockchain.
     */
    function getUserById(uint _id) public view
    returns(
        uint,
        string memory,
        bytes32,
        address,
        uint,
        uint
    ){
        // checking if the ID is valid
        require( (_id > 0) || (_id <= users.length) );

        User memory i = users[_id];

        return (
            _id,
            i.name,
            i.status,
            i.walletAddress,
            i.createdAt,
            i.updatedAt
        );
    }

    /* Return the profile information of the caller.
     */
    function getOwnProfile() checkSenderIsRegistered public view
    returns(
        uint,
        string memory,
        bytes32,
        address,
        uint,
        uint
    ){
        uint id = usersIds[msg.sender];

        return getUserById(id);
    }

    /* Check if the user that is calling the smart contract is registered.
    */
    function isRegistered() public view returns (bool)
    {
        return (usersIds[msg.sender] > 0);
    }

    /* Return the number of total registered users.
     */
    function totalUsers() public view returns (uint)
    {
        // NOTE: the total registered user is length-1 because the user with
        // index 0 is empty check the contructor: addUser(address(0x0), "", "");
        return users.length - 1;
    }
    
    // data structure that stores a product
    struct Product {
        string name;
        bytes32 status;
        address walletAddress;
        uint createdAt;
        uint updatedAt;
        //product orders control
        uint first_order_timestamp;
        uint last_order_timestamp;
        uint orders_counter;
        uint orders_amount;
        
        uint[100] orders;
    }

    // it maps the product's wallet address with the product ID
    mapping (address => uint) public productsIds;

    // Array of Product that holds the list of products and their details
    Product[] public products;

    // event fired when an product is registered
    event newProductRegistered(uint id);

    // event fired when the product updates his status or name
    event productUpdateEvent(uint id);

    /* Function to register a new product.
     *
     * @param _productName         The displaying name
     * @param _status        The status of the product
     */
    function registerProduct(address _wAddr, string memory _productName, bytes32 _status) public
    returns(uint)
    {
        return addProduct(_wAddr, _productName, _status);
    }

    /* Add a new product. This function must be private because an product
     * cannot insert another product on behalf of someone else.
     *
     * @param _wAddr        The wallet of product is the wallet of restaraunt owner
     * @param _productName     Displaying name of the product
     * @param _status       Status of the product
     */
    function addProduct(address _productAddrAddr, string memory  _productName, bytes32 _status) private
    returns(uint)
    {
        // checking if the product is already registered
        uint productId = productsIds[_productAddrAddr];
        require (productId == 0);

        // associating the product wallet address with the new ID
        productsIds[_productAddrAddr] = products.length;
        uint newProductId = products.length++;

        uint[100] memory orders;
        
        // storing the new user details
        products[newProductId] = Product({
            name: _productName,
            status: _status,
            walletAddress: _productAddrAddr,
            createdAt: now,
            updatedAt: now,
            first_order_timestamp : 0,
            last_order_timestamp : 0,
            orders_amount : 0,
            orders_counter : 0,
            orders : uint[100]
        });

        // emitting the event that a new product has been registered
        emit newProductRegistered(newProductId);

        return newProductId;
    }

    /* Update the product profile of the caller of this method.
     * Note: the product can modify only his own profile.
     *
     * @param _newProductName  The new product's displaying name
     * @param _newStatus    The new product's status
     */

    function placeOrder(address _productAddr, address _supplierAddr, address _costumerAddr, uint value, uint amount) public
    returns(uint)
    {
        uint product_id = productsIds[_productAddr];
        uint supplier_id = usersIds[_supplierAddr];
        uint costumer_id = usersIds[_costumerAddr];

        require(product_id > 0 && supplier_id > 0 && costumer_id > 0);

        uint product_orders_counter = products[product_id].orders_counter + 1;
        
        orders[orders.length] = Order(_productAddr,_supplierAddr,_costumerAddr,now,value,amount);
        
        products[product_id].orders[ product_orders_counter ] = orders.length;

        if(product_orders_counter == 1){
            products[product_id].first_order_timestamp = now;
        }

        products[product_id].last_order_timestamp = now;
        products[product_id].orders_counter++;
        products[product_id].orders_amount += value*amount;

        contract_total_amount += value*amount;

        emit productUpdateEvent(product_id);

        return product_id;
    }

    /* Get the product's profile information.
     *
     * @param _id   The ID of the product stored on the blockchain.
     */
    function getProductById(uint _id) public view
    returns(
        uint, //id
        string memory, //name
        bytes32, //status or category
        address, // walletAddress
        uint, // createdAt
        uint, //updatedAt
        uint, //first_order_timestamp
        uint, //last_order_timestamp
        uint, // orders_counter
        uint // orders_amount
    ){
        // checking if the ID is valid
        require( (_id > 0) || (_id <= products.length) );

        Product memory i = products[_id];

        return (
            _id,
            i.name,
            i.status,
            i.walletAddress,
            i.createdAt,
            i.updatedAt,
            i.first_order_timestamp,
            i.last_order_timestamp,
            i.orders_counter,
            i.orders_amount
        );
    }

    function getProductOrderId(address _productAddr, uint _id) public view
    returns(
         uint // order_id
    ){
        uint product_id = productsIds[_productAddr];
        
        // checking if the ID is valid
        require( (product_id > 0) && (product_id <= products.length) && _id > 0);

        Product memory i = products[product_id];

        require (_id < i.orders_counter && _id < 100);

        return(
            i.orders[_id]
        );
    }
    
    function getOrder(uint _id) public view
    returns(
         bytes32,
         address,
         bytes32,
         uint,
         uint,
         uint
    ){
        // checking if the ID is valid
        require( _id > 1  && _id < orders.length);
        
        Order memory o = orders[_id];
        User memory supplier =  users[ usersIds[o.supplier] ];
        User memory costumer =  users[ usersIds[o.costumer] ];
        return(
            supplier.status,
            o.product,
            costumer.status,
            o.timestamp,
            o.value,o.amount
        );
    }

    /**
     * Return the number of total registered products.
     */
    function totalProducts() public view returns (uint)
    {
        // NOTE: the total registered product is length-1 because the product with
        // index 0 is empty check the contructor: addProduct(address(0x0), "", "");
        return products.length - 1;
    }
    
    function totalOrders() public view returns (uint)
    {
        // NOTE: the total registered product is length-1 because the product with
        // index 0 is empty check the contructor: addProduct(address(0x0), "", "");
        return orders.length - 1;
    }
    
    function totalAmount() public view returns (uint)
    {
        // NOTE: the total registered product is length-1 because the product with
        // index 0 is empty check the contructor: addProduct(address(0x0), "", "");
        return contract_total_amount;
    }
    
   /* Constructor */
    constructor() public {

        // NOTE: the first user MUST be emtpy: if you are trying to access to an element
        // of the usersIds mapping that does not exist (like usersIds[0x12345]) you will
        // receive 0, that's why in the first position (with index 0) must be initialized
        addUser(address(0x0), "", "");

        addUser(address(0x1), "Douglas", "Aluno");
        addUser(address(0x2), "Arlindo", "Professor");
        addUser(address(0x3), "Suzana", "Aluno");
        addUser(address(0x4), "Luis", "Aluno");     

        addProduct(address(0x0), "", "");

        addProduct(address(0x1), "Batata", "Aluno");
        addProduct(address(0x2), "Carne", "Professor");
        addProduct(address(0x3), "Suco", "Aluno");
        addProduct(address(0x4), "Cerveja", "Aluno");
    }
}