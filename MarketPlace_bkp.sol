pragma solidity ^0.5.0;

contract MarketPlace {

    Address Contract_owner;
    // data structure that stores a user

    /// destroy the contract and reclaim the leftover funds.
    function kill() public {
        require(msg.sender == Contract_owner);
        selfdestruct(msg.sender);
    }

    struct User {
        string name;
        bytes32 status;
        address walletAddress;
        uint createdAt;
        uint updatedAt;
        uint consulted;
        uint paid; 
    }

    struct Order{

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
    User[] public users;

    // Array of User that holds the list of users and their details
    Order[] public orders;

    // it maps the user's wallet address with the user ID
    mapping (address => uint) public usersIds;

    // event fired when an user is registered
    event newUserRegistered(uint id);

    // event fired when the user updates his status or name
    event userUpdateEvent(uint id);

    // Modifier: check if the caller of the smart contract is registered
    modifier checkSenderIsRegistered {
        require(isRegistered());
        _;
    }
    
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(source, 32))
        }
    }

    constructor() public
    {
        Contract_owner = msg.sender;
        addUser(address(0x0), "dummy_user", "dummy_user");
        addUser(msg.sender, "Contract_owner", "Contract_owner");
        
        orders.push( Order(address(0x0),address(0x0),address(0x0),"dummy_order","dummy_order", "dummy_order", 1, 2, 3, 0) );
    }

    function registerUser(string memory _userName, bytes32 _status) public
    returns(uint)
    {
        return addUser(msg.sender, _userName, _status);
    }

    function addUser(address _wAddr, string memory  _userName, bytes32 _status) private
    returns(uint){
         // checking if the user is already registered
        uint userId = usersIds[_wAddr];
        require (userId == 0);

        // associating the user wallet address with the new ID
        usersIds[_wAddr] = users.length;
        uint newUserId = users.length++;

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

    /**
     * Update the user profile of the caller of this method.
     * Note: the user can modify only his own profile, because of checkSenderIsRegistered modifier.
     */
    function updateUser( string memory _newUserName, 
                         bytes32 _newStatus) 
        checkSenderIsRegistered public
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

    function getUserById(uint _id) public view
    returns(
        uint,
        string memory,
        bytes32,
        address,
        uint,
        uint
    ) {
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

    /**
     * Return the profile information of the caller.
     */
    function getOwnProfile() checkSenderIsRegistered public view
    returns(
        uint,
        string memory,
        bytes32,
        address,
        uint,
        uint
    ) {
        uint id = usersIds[msg.sender];

        return getUserById(id);
    }

    /**
     * Check if the user that is calling the smart contract is registered.
     */
    function isRegistered() public view returns (bool)
    {
        return (usersIds[msg.sender] > 0);
    }

    function totalUsers() public view returns (uint)
    {
        return users.length - 1;
    }

    function totalOrders() public view returns (uint)
    {
        return orders.length - 1;
    }

    function placeOrderWallet(  address w_product, 
                                address w_costumer, 
                                uint amount, 
                                uint value) 
        public {
            bytes32 product_category = users[ usersIds[w_product] ].status;
            bytes32 costumer_category = users[ usersIds[w_costumer] ].status;
            bytes32 supplier_category = users[ usersIds [msg.sender] ].status;
            orders.push( 
                            Order(  w_product, 
                                    w_costumer, 
                                    msg.sender, 
                                    product_category, 
                                    costumer_category, 
                                    supplier_category, 
                                    amount,
                                    value, 
                                    now, 
                                    0) 
                        );

    }
    function reduceOrdersCheck(  bytes32 _product_name, 
                            bytes32 _costumer_category, 
                            uint _begin, 
                            uint _end ) 

        public view returns (uint)
        {
            
            uint counter = 0;
            bool flag1 = true; bool flag2 = true; bool flag3 = true;
            bool flag4 = true; bool flag5 = true;
            
            for (uint i = 0; i < totalOrders(); i++) {
                
                uint temp_amount = orders[i].value * orders[i].amount;
                if(_product_name.length > 0)
                    flag1 = (orders[i].product_name == _product_name);
                if(_costumer_category.length > 0)
                    flag2 = (orders[i].costumer_category == _costumer_category);
                if(_begin > 0)
                    flag4 = (orders[i].timestamp >= _begin);        
                if(_end > 0)
                    flag5 = (orders[i].timestamp <= _end);
                if( flag1 && flag2 && flag3 && flag4 && flag5 ){
                    
                    counter++;
                }
                
            }
        return counter;
    }

    function reduceOrders(  bytes32 _product_name, 
                            bytes32 _costumer_category, 
                            uint _begin, 
                            uint _end ) 

        payable public returns (uint)
        {

            uint payment = msg.value;
            
            uint amount = 0;
            bool flag1 = true; bool flag2 = true; bool flag3 = true;
            bool flag4 = true; bool flag5 = true;
            
            for (uint i = 0; i < totalOrders(); i++) {
                
                uint temp_amount = orders[i].value * orders[i].amount;
                if(_product_name.length > 0)
                    flag1 = (orders[i].product_name == _product_name);
                if(_costumer_category.length > 0)
                    flag2 = (orders[i].costumer_category == _costumer_category);
                if(_begin > 0)
                    flag4 = (orders[i].timestamp >= _begin);        
                if(_end > 0)
                    flag5 = (orders[i].timestamp <= _end);
                if( flag1 && flag2 && flag3 && flag4 && flag5 ){
                    
                    orders[i].consulted++;
                    
                    amount += temp_amount;
                }
                
            }
        return amount;
    }
}
