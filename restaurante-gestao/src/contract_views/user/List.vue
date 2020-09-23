<template>
    <div>
        <h1 class="title">Usuarios e Produtos</h1>

        <div class="clearfix"></div>

        <h2 v-show="!bcConnected">Not connect to the blockchain: please wait.</h2>

        <h2 v-show="(isLoading && bcConnected)">Loading...</h2>

        <div class="col-md-3" v-if = "autorizedSuppliers" >
            <table class="table table-striped" v-show="!isLoading">
                <thead class="thead-dark">
                    <tr>
                        <th>User ID</th>
                        <th>Name</th>
                        <th>Status</th>
                        <th>Address</th>
                        <th>Created At</th>
                        <th>Updated At</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="user in users">
                        <td>{{ user[0].toNumber() }}</td>
                        <td>{{ user[1] }}</td>
                        <td>{{ toAscii(user[2]) }}</td>
                        <td>{{ user[3] }}</td>
                        <td>{{ toDate( user[4].toNumber() ) }}</td>
                        <td>{{ toDate( user[5].toNumber() ) }}</td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div class="col-md-3" v-if = "autorizedUsers" >
            <table class="table table-striped" v-show="!isLoading">
                <thead class="thead-dark">
                    <tr>
                        <th>User ID</th>
                        <th>Status</th>
                        <th>Address</th>
                        <th>Created At</th>
                        <th>Updated At</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="user in users">
                        <td>{{ user[0].toNumber() }}</td>
                        <td>{{ toAscii(user[2]) }}</td>
                        <td>{{ user[3] }}</td>
                        <td>{{ toDate( user[4].toNumber() ) }}</td>
                        <td>{{ toDate( user[5].toNumber() ) }}</td>
                    </tr>
                </tbody>
            </table>
        </div>    
    </div>
</template>
<script>
    // importing common function
    import mixin from '../../libs/mixinViews';
    import axios from 'axios';
    let endpoint = "http://localhost:3000";

    /**
     * List view component: this component shows list of the registered users
     * and their statuses.
     */
    export default {
        mixins: [mixin],

        data() {
            return {
                userId: 2,
                bc_totalOrders: 0,
                users: [], // array that stores all the registered users
                isLoading: true, // true when the user list is loading form the blockchain
                bcConnected: false, // blockchain is connected ()
                tmoConn: null, // contain the intervalID given by setInterval
                j_produtos:[],
                j_users:[],
                m_Restaurant : {},
                m_Blockchain : {},
                bc_totalUsers : 0,
                bc_totalOrders : 0,
                bc_totalConsulted : 0,
                bc_totalPaid : 0,
                bc_orders : [],
                total_bc_orders : 0,
                m_Restaurant : {},
                m_Blockchain : {},
                userStatus: ''
            }
        },
         computed: {

            autorizedSuppliers(){
                this.getProfile();
                return(
                    this.userId < 2
                );
            },
            autorizedUsers(){
                this.getProfile();
                return(
                    this.userId >= 2
                );
            },
        },

        methods: {

            showErrorMessage(err) {
                console.error(err);

                this.errorStr = null;

                if (err) this.errorStr = err.toString();

                if (! this.errorStr) this.errorStr = 'Error occurred!';
            },   
            chamaProdutos(){
                console.log("Chamando banco local de produtos");
                axios.get(`${endpoint}/produtos`)
                    .then(response => {
                        this.j_produtos = response.data
                }).catch(e => { console.log(` error ==> ${e}`)})
            },
            chamaUsuarios(){
                console.log("Chamando banco local de usuários");
                axios.get(`${endpoint}/users`)
                  .then(response => {
                    this.j_users = response.data
                  }).catch(e => { console.log(` error ==> ${e}`)})
              },
            chamaBc_Orders(){
                console.log("Chamando banco local de pedidos para enviar para blockchain");
                axios.get(`${endpoint}/bc_orders`)
                  .then(response => {
                    this.bc_orders = response.data
                    console.log(this.bc_orders);
                  })
                  .catch(e => { console.log(` error ==> ${e}`)});
            },
            getUserList() {
                if (this.blockchainIsConnected()) {
                    // it shows the loading message
                    this.isLoading = true;

                    // stopping the interval
                    clearInterval(this.tmoConn);

                    // getting all the users from the blockchain
                    this.getAllUsers(userProfile => {

                        console.log("Chamando blockchain...");

                        this.isLoading = false;
                        this.users.push(userProfile);

                        let status =  window.bc.toAscii(userProfile[2]);
                          
                        const found_user = this.j_users.find(element => element.Address == userProfile[3]);
                        const found_produto = this.j_produtos.find(element => element.Address == userProfile[3]);

                        if(found_user != undefined)
                        {
                            console.log("Usuario " + found_user.Name + " ja existente no banco local");
                        }
                        else if(found_produto != undefined)
                        {
                            console.log("Produto " + found_produto.Name + " ja existente no banco local");
                        }
                        else
                        {
                             if(status.includes("Produto"))
                                this.saveProduct(userProfile);
                             else
                                this.saveUser(userProfile);
                        }
                    });                        
                }
            },

            saveProduct(product) {

                console.log("SALVANDO PRODUTO");

                let prod = {
                    ProductID: product[0].toNumber(), 
                    Name: product[1],
                    Status:  window.bc.toAscii(product[2]),
                    Address: product[3],
                    CreatedAt:   window.bc.toDate( product[4].toNumber()),
                    UpdatedAt:   window.bc.toDate( product[5].toNumber())
                };

                axios.post(`${endpoint}/produtos`, prod)
                    .then(response => { });

            },

            saveUser(userProfile) {

                console.log("SALVANDO USUARIO");

                let user = {
                    UserID: userProfile[0].toNumber(), 
                    Name: userProfile[1],
                    Status:  window.bc.toAscii(userProfile[2]),
                    Address: userProfile[3],
                    CreatedAt:   window.bc.toDate( userProfile[4].toNumber()),
                    UpdatedAt:   window.bc.toDate( userProfile[5].toNumber())
                };

                console.log(user);

                axios.post(`${endpoint}/users`, user)
                    .then(response => {


                        console.log(response);

                     });

            },

            reloadList() {
                this.users = [];

                this.getUserList();
            },

            getAllUsers(callback) {
                // getting the total number of users stored in the blockchain
                // calling the method totalUsers from the smart contract
                window.bc.contract().totalUsers((err, total) => {
                    var tot = 0;
                    if (total) tot = total.toNumber();

                    if (tot > 0) {
                        // getting the user one by one
                        for (var i=1; i<=tot; i++) {
                            window.bc.contract().getUserById.call(i, (error, userProfile) => {
                                
                                    //

                                callback(userProfile);
                            });
                        } // end for
                    } // end if
                }); // end totalUsers call
            },
            getTotalBc_Orders(){
                window.bc.contract().totalOrders((err, total) => {
                    var tot = 0;
                    if (total) tot = total.toNumber();

                    if (tot > 0) {
                        // getting the user one by one
                        this.bc_totalOrders = tot;
                    } // end if
                });
            },
            getProfile() {
                window.bc.getMainAccount().then(account => {
                    window.bc.contract().getOwnProfile.call({ from: account },
                        (error, userDet) => {
                            if (userDet) {
                                this.userId = userDet[0].toNumber();
                            }
                            this.setErrorMessage(error);
                        }
                    );
                });
            }//last method
        }, // end methods

        created() {
            this.getProfile();
            this.chamaProdutos();
            this.chamaUsuarios();
            this.chamaBc_Orders();
            // it tries to get the user list from the blockchian once
            // the connection is established
            this.tmoConn = setInterval(() => {
                this.getUserList();
            }, 1000);
        }
    }
</script>

<style>
</style>
