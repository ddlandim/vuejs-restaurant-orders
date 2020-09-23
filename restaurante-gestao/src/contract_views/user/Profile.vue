<template>
    <div>
        <h1 class="title" >Profile</h1>

        <div class="col-md-6">
            <div class="col-md-3">
                <h3>Update your Profile</h3><hr>

                <h4>
                    Your ID: {{ userId }}
                </h4>

                <div class="form-group">
                    <label for="description">Name</label>
                    <input class="form-control" placeholder="Enter your name" type="text" v-model="userName">
                </div>

                <div class="form-group">
                    <label for="description">Status</label>
                    <input class="form-control" placeholder="Update your status" type="text" v-model="userStatus">
                </div>

                <button class="btn btn-primary" :disabled="disableSubmit" @click="performSubmit">Save</button>

                <strong v-show="submitting" class="ml-2">Submitting...</strong>
                <strong v-show="successSave" class="ml-2 text-success">Tx submitted!</strong>
            </div>

            <div class="col-md-3">
                <h3>Info</h3><hr>

                <p>
                    <strong>Address</strong>: {{ userAddressAccount }}
                </p>
                <p>
                    <strong>Balance</strong>: {{ balance }} ETH
                </p>
                <p>
                    <strong>Consulted</strong>: {{ consulted }} Times
                </p>
                <p>
                    <strong>Paid</strong>: {{ paid }} ETH
                </p>
            </div>

            <div class="col-md-3" v-if = "autorizedSuppliers" >
                    <h3>Contract Owner Section</h3><hr>

                    <p><strong>Orders to send to blockchain</strong></p>
                    <table class="table table-striped" v-show="!isLoading">
                        <thead class="thead-dark">
                            <tr>
                                <th>id</th>
                                <th>Amount</th>
                                <th>CostumerID</th>
                                <th>ProductID</th>
                                <th>Value</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="m_order in bc_orders">
                                <td>{{ m_order.id }}</td>
                                <td>{{ m_order.Amount }}</td>
                                <td>{{ m_order.CostumerID }}</td>
                                <td>{{ m_order.ProductID }}</td>
                                <td>{{ m_order.Value }}</td>
                            </tr>
                        </tbody>
                    </table>
            </div>

             <div class="col-md-3" v-if = "autorizedUsers" >
                    <h3>User Section</h3><hr>
            </div>

        </div>

        <div class="row justify-content-md-center" v-show="errorMessage">
            <div class="col-md-6">
                <div class="alert alert-danger mt-4">
                    {{ errorMessage }}
                </div>
            </div>
        </div>

    </div>
</template>

<script>
    // importing common function
    import mixin from '../../libs/mixinViews';
    import axios from 'axios';
    let endpoint = "http://localhost:3000"

    /**
     * Profile view component: this component shows the user profile.
     * In this page the user can update his own profile and he can
     * view other details like his wallet address and balance.
     */
    export default {
        mixins: [mixin],

        data() {
            return {
                userName: '', // variable binded with the name's input field
                userStatus: '', // varialbe binded to the status's input filed
                userId: 0, // user ID from the blockchain

                userAddressAccount: '0x0', // address of the user
                balance: 0, // balance of the user

                consulted: 0,
                paid : 0,

                tmoConn: null, // contain the intervalID given by setInterval

                submitting: false, // true when the submit is pressed
                successSave: false, // it show the success message
                errorMessage: null, // it shows the error message
                _msgStatus : '',
                m_Restaurant : {},
                m_Blockchain : {},
                bc_totalUsers : 0,
                bc_totalOrders : 0,
                bc_totalConsulted : 0,
                bc_totalPaid : 0,
                bc_orders : [],
                total_bc_orders : 0,
                m_Restaurant : {},
                m_Blockchain : {}
            }
        },

        computed: {
            /**
             * It disables the submit button when the the userName or userStatus are not filled
             * or the submit button is pressed or the connection with the blockchin is
             * not established.
             */
            disableSubmit() {
                return (
                    !this.userName.length ||
                    !this.userStatus.length ||
                    this.submitting ||
                    !this.blockchainIsConnected()
                );
            },
            autorizedSuppliers(){
                return(
                    this.userId == 1
                );
            },
            autorizedUsers(){
                return(
                    this.userId != 1 && this.userStatus != "Produto"
                );
            },
            disablePay() {
                return (
                    this.userId != 1
                );
            },
            disableSendOrders() {
                return (
                    this.userId != 1
                );
            },
        },

        methods: {
            /**
             * Get the profile details of the user.
             * This methos calls the smart contract function getOwnProfile
             * and it returns the user details where:
             *      userDet[0] => uint     user ID
             *      userDet[1] => string   user's name
             *      userDet[2] => bytes32  user's status
             *
             * @return {void}
             */
            getProfile() {
                window.bc.getMainAccount().then(account => {
                    window.bc.contract().getOwnProfile.call({ from: account },
                        (error, userDet) => {
                            if (userDet) {
                                this.userId = userDet[0].toNumber();
                                this.userName = userDet[1];
                                // userDet[2] is bytes32 format so it has to be trasformed to stirng
                                this.userStatus = this.toAscii(userDet[2]);
                                this.consulted = userDet[6].toNumber();
                                this.consulted = userDet[7].toNumber();
                            }

                            this.setErrorMessage(error);
                        }
                    );
                });
            },
            whatIAm(){
                if (this.userId < 2){
                    this._msgStatus = "You are the contract owner!";
                }
                else if (this.userStatus == "Produto"){
                    this._msgStatus = "You are a product, You cant pay users";
                }
                else{
                    this._msgStatus = "You are a user, You cant pay users";
                }
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
            /**
             * Set the error message showing the alert.
             *
             * @param {object} error
             * @return {void}
             */
            setErrorMessage(error) {
                this.errorMessage = null;

                if (error) {
                    console.error(error);

                    this.errorMessage = error.toString();

                    if (! this.errorMessage.length) this.errorMessage = 'Error occurred!';
                }
            },

            /**
             * Updates the user's details when the button is pressed.
             *
             * @return {void}
             */
            performSubmit() {
                this.submitting = true;
                this.errorMessage = null;
                this.successSave = false;

                // calling the method updateUser from the smart contract
                window.bc.getMainAccount()
                .then(account => {
                    window.bc.contract().updateUser(
                        this.userName,
                        this.userStatus,
                        {
                            from: account,
                            gas: 800000
                        },
                        (err, txHash) => this.handleSubmitResult(err, txHash)
                    )
                })
                .catch(error => this.setErrorMessage(error));
            },
            performPay() {
                this.submitting = true;
                this.errorMessage = null;
                this.successSave = false;

                window.bc.getMainAccount()
                .then(account => {
                    window.bc.contract().payDay(
                        {
                            from: account,
                            gas: 800000
                        },
                        (err, txHash) => this.handleSubmitResult(err, txHash)
                    )
                })
                .catch(error => this.setErrorMessage(error));
            },

            getTotalBc_Orders(){
                axios.get(`${endpoint}/bc_orders`)
                    .then(response => {
                        this.bc_orders = response;
                        order.OrderID = response.lengh;
                        axios.post(`${endpoint}/bc_orders`, order)
                            .then(response => {
                                this.m_Restaurant.total_bc_orders++;
                                this.atualizaM_Restaurant();
                            });
                        console.log("Order Placed");
                        console.log(order);
                    }).catch(e => { console.log(` error ==> ${e}`)});
            },

            getBc_Orders(id){

            },

            performPlaceOrderID() {
                this.submitting = true;
                this.errorMessage = null;
                this.successSave = false;
                


                // window.bc.contract().placeOrderID(    
                // )
            },

            /**
             * Handle the result of the response of updateUser.
             *
             * @param {object} err
             * @param {string} txHash
             * @return {void}
             */
            handleSubmitResult(error, txHash) {
                this.submitting = false;

                if (error) {
                    this.setErrorMessage(error);
                } else if (txHash) {
                    this.successSave = true;
                }
            },

            /**
             * It loads the general info (address and balance of the user).
             *
             * @return {void}
             */
            getInfoBc() {
                window.bc.loadInfo().then(info => {
                    this.userAddressAccount = info.mainAccount;

                    this.balance = window.bc.weiToEther( info.balance );
                });
            },

            /**
             * It loads the user information once connected to the blockchian.
             *
             * @return {void}
             */
            checkConnectionAndLoad() {
                if (this.blockchainIsConnected()) {
                    // stopping the interval
                    clearInterval(this.tmoConn);

                    this.loadEverything();
                }
            },

            /**
             * Load the user's info: user name, status and general info.
             *
             * @return {void}
             */
            loadEverything() {
                // checking if the user is registered
                this.isRegistered()
                .then(res => {
                    // if the user is registered it will load the profile page
                    if (res) {
                        this.getProfile();
                        this.getInfoBc();
                        this.whatIAm();
                    }

                    // if the user not registered the user will be redirected to the Register page
                    else this.$router.push("register");
                })
                .catch(error => {
                    console.error(error);
                    this.$router.push("register");
                });
            }
        },

        created() {
            // it will call the function checkConnectionAndLoad every 500ms
            // until the connection to the blockchain is enstablished
            this.tmoConn = setInterval(() => {
                this.checkConnectionAndLoad();
            }, 500);
            this.chamaBc_Orders();
        }
    }
</script>
