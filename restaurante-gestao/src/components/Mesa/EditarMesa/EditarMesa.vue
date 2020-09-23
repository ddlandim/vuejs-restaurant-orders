<template>
  <div>
    <div class="row justify-content-around">
      <div class="card col-6 col-sm-12">
        <div class="card-header">
          <h2 class="card-title">Lançamentos</h2>
        </div>
        <div class="mesa">
          <div class="mesa">
            <div class="row justify-content-between">
              <div class="form-group col-6 col-sm-12">
                <label class="control-label" for="">Produtos</label>
                <select class="control-input" v-model="produto" name="" id="">
                  <option v-for="p in produtos" :key="p.ProductID" :value="p">{{p.Name}}</option>
                </select>
              </div>
              <div class="form-group col-6 col-sm-12">
                <label class="control-label" for="">Usuarios</label>
                <select class="control-input" v-model="user" name="" id="">
                  <option v-for="user in users" :key="user.UserID" :value="user">{{user.Name}}</option>
                </select>
              </div>
              <div class="form-group col-6 col-sm-12 ">
                <label class="control-label" for="">Quantidade</label>
                <input class="control-input" type="number" min="1" v-model="produto.quantidade">
              </div>
              <div class="form-group col-6 col-sm-12 ">
                <label class="control-label" for="">Valor</label>
                <input class="control-input" type="number" min="1" v-model="produto.valor">
              </div>
            </div>
            <div class="row align-down justify-content-between">
              <div class="form-group col-6 col-sm-12">
                <label class="control-label" for="">Numero de Pessoas na Mesa:</label>
                <select class="control-input" v-model="mesa.num_pessoas" name="" id="">
                  <option v-for="numero in numero_pessoas" :key="numero.value" :value="numero.value">{{numero.label}}</option>
                </select>
              </div>
              <div class="form-group col-6 col-sm-12">
                <button class="btn btn-success" @click="adicionaProduto">Adicionar</button>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="card col-6 col-sm-12 ">
        <div class="card-header">
          <h2 class="card-title">Pagamento</h2>
        </div>
        <div class="row">
          <div class="form-group col-6 col-sm-12">
            <label class="control-label" for="">Total à pagar:</label>
            <span class="control-input">R${{mesa.total_valor}}</span>
          </div>
          <div class="form-group col-6 col-sm-12">
            <label class="control-label" for="">Total à pagar por pessoa:</label>
            <span class="control-input">R${{mesa.total_valor_pessoa}}</span>
          </div>
        </div>
        <div class="row align-down">
          <div class="form-group col-4 col-sm-12">
            <label class="control-label" for="">Tipo de Pagamento:</label>
            <select class="control-input" v-model="pagamento.tipo" name="" id="">
              <option v-for="tipo in tipos" :key="tipo.value" :value="tipo.value">{{tipo.label}}</option>
            </select>
          </div>
          <div class="form-group col-4 col-sm-12">
            <label class="control-label" for="">Quantidade de pessoas:</label>
            <select class="control-input" v-model="pagamento.quantidade_pagantes" name="" id="">
              <option v-for="numero in numero_pessoas" :key="numero.value" :value="numero.value">{{numero.label}}</option>
            </select>
          </div>
          <div class="col-3">
            <button class="btn btn-warning" @click="pagaConta">Pagar</button>
          </div>
        </div>
      </div>
    </div>
    <div class="row">
      <div class="card col-12 col-sm-12">
        <div class="card-header">
					<div class="row justify-content-between">
						<h2 class="card-title">Produtos Consumidos</h2>
						<div>
							<button class="btn btn-success" @click="salvarLancamentos">Salvar</button>
						</div>
					</div>
        </div>
        <div class="row  tableheader align-center">
          <div class="col-3 col-sm-2">
            <h4 class="table-title">Nome</h4>
          </div>
          <div class="col-3 col-sm-2">
            <h4 class="table-title">Qtd</h4>
          </div>
          <div class="col-3 col-sm-2">
            <h4 class="table-title">Valor</h4>
          </div>
          <div class="col-3 col-sm-2">
            <h4 class="table-title">Ação</h4>
          </div>
        </div>
        <div class="row row-table align-center" v-for="(pedido,index) in mesa.pedidos" :key="pedido">
          <div class="col-3 col-sm-2">{{pedido.nome}}</div>
          <div class="col-3 col-sm-2">{{pedido.quantidade}}</div>
          <div class="col-3 col-sm-2">R${{pedido.valor}}</div>
          <div class="col-3 col-sm-2">
            <button class="btn btn-danger" @click="removePedido(index,pedido)">Remover</button>
          </div>
        </div>
      </div>
    </div>
		<!-- <pre>{{produtos}}</pre> -->
  </div>
</template>
<script>
	import axios from 'axios';
	let endpoint = "http://localhost:3000"
  import mixin from '../../../libs/mixinViews';
  export default {
    mixins: [mixin],
		created(){
			this.chamaProdutos();
      this.chamaUsuarios();
      this.chamaRestaurante();
			if(this.$route.params.id){
				console.log(this.$route.params);
				this.mesa = this.$route.params;
			}
		},
    methods: {
      showErrorMessage(err) {
                console.error(err);

                this.errorStr = null;

                if (err) this.errorStr = err.toString();

                if (! this.errorStr) this.errorStr = 'Error occurred!';
            },
			chamaProdutos(){
				axios.get(`${endpoint}/produtos`)
  				.then(response => {
  				  this.produtos = response.data
            //console.log(this.produtos);
  				}).catch(e => { console.log(` error ==> ${e}`)})
			},
      chamaUsuarios(){
        axios.get(`${endpoint}/users`)
          .then(response => {
            this.users = response.data
          }).catch(e => { console.log(` error ==> ${e}`)})
      },
      chamaRestaurante(){
        axios.get(`${endpoint}/m_Restaurant/0`)
          .then(response => {
            this.m_Restaurant = response.data;
            //console.log("This Response Data");
            //console.log(response.data);
            //console.log("This Restaurante");
            console.log(this.m_Restaurant);
          }).catch(e => { console.log(` error ==> ${e}`)})
      },
      atualizaM_Restaurant(){
        this.m_Restaurant.total_bc_orders = this.bc_orders.lengh - 1;
        axios.put(  `${endpoint}/m_Restaurant/0`, this.m_Restaurant)
                .then(response => {})
                .catch(e => {
                   if(e){
                    this.errors.push(e);
                    console.log(e);
                  } else console.log("m_Restaurant updated");
                })
      },
      place_bc_orders(order){
        console.log("Placing order starts ");
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
      adicionaProduto() { //place order
        
        let order = {
                    OrderID: this.m_Restaurant.total_bc_orders,
                    ProductID: parseInt(this.produto.ProductID),
                    CostumerID:  parseInt(this.user.UserID),
                    Amount : parseInt(this.produto.quantidade),
                    Value : parseInt(this.produto.valor)
        };
        this.place_bc_orders(order);

        if(this.produto.quantidade) {
          this.mesa.pedidos.push(JSON.parse(JSON.stringify(this.produto)))
          this.atualizaPedidos();
        }

      },
      atualizaPedidos(){
          this.mesa.total_valor = this.mesa.pedidos.reduce(function (soma, m) {
            return soma + (m.valor * m.quantidade);
          }, 0)
          this.mesa.total_valor_pessoa = (this.mesa.total_valor / this.mesa.num_pessoas).toFixed(2)
          this.m_Restaurant.total_valor+= this.mesa.total_valor;
      },
			salvarLancamentos(){
				if(this.mesa.id){
					axios.put(`${endpoint}/comandas/${this.mesa.id}`,this.mesa).then(response =>{
					this.$router.push({name: 'Visao Geral'})
						console.log(response)
					}).cath( e => {console.log(e)})
				}else{
					axios.post(`${endpoint}/comandas`,this.mesa)
					.then(response => {})
					.catch(e => {
						this.errors.push(e)
					})
					this.$router.push({name: 'Visao Geral'})
				}
      },
      deletaComanda(comanda){
        axios.delete(`${endpoint}/comandas/${comanda.id}`)
        .then(response => {})
        .catch(e => {
          this.errors.push(e)
        })
        this.$router.push({name: 'Visao Geral'})
      },
      removePedido(index,pedido){
        this.mesa.pedidos.splice(index, 1)
        this.atualizaPedidos();
      },
      pagaConta() {
        if (this.pagamento.tipo == 1) {
          alert(`Pagamento total da Mesa R$ ${this.mesa.total_valor.toFixed(2)}`)
          this.deletaComanda(this.mesa)
        } else {
          let valorParcialTotal = this.mesa.total_valor_pessoa * this.pagamento.quantidade_pagantes
          alert(
            `Valor parcial referente a ${this.pagamento.quantidade_pessoas} pessoas R$ ${valorParcialTotal.toFixed(2)}`
          )
          this.mesa.num_pessoas = this.mesa.num_pessoas - this.pagamento.quantidade_pagantes
          this.mesa.total_valor = this.mesa.total_valor - valorParcialTotal
          this.mesa.total_valor_pessoa = (this.mesa.total_valor / this.mesa.num_pessoas).toFixed(2)
        }
        this.salvarLancamentos();
      }
    },
    data() {
      return {
        produto: {
          quantidade: null,
          valor: null,
          Name: null,
          ProductID: null,
          Address: 123
				},
        user: {
          Name: null,
          UserID:null,
          Address:null,
        },
				posts:null,
        numero_pessoas: [{
            value: 1,
            label: 'Uma'
          },
          {
            value: 2,
            label: 'Duas'
          },
          {
            value: 3,
            label: 'Tres'
          },
          {
            value: 4,
            label: 'Quatro'
          },
          {
            value: 5,
            label: 'Cinco'
          }
        ],
        tipos: [{
            value: 1,
            label: 'Total'
          },
          {
            value: 2,
            label: 'Parcial'
          }
        ],
        pagamento: {
          tipo: '',
          quantidade_pagantes: ''
        },
        cliente: {
          id: '',
          name: '',
          eth_id: '',
          mesa: '',
          saldo_mesa:'',
        },
        mesa: {
          id:'',
          cliente: [],
          pedidos: [],
          total_valor: '',
          total_valor_pessoa: '',
        },
				produtos:[],
        users:[],
        bc_orders:[],
        m_Restaurant : {
          "id" : 0,
          "total_valor" : 0,
          "total_bc_orders": 0
        }
      };
    },
  };

</script>
<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
</style>
