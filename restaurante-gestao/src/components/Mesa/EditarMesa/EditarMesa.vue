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
                  <option v-for="produto in produtos" :key="produto" :value="produto">{{produto.nome}}</option>
                </select>
              </div>
              <div class="form-group col-6 col-sm-12 ">
                <label class="control-label" for="">Quantidade</label>
                <input class="control-input" type="number" v-model="produto.quantidade">
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

  export default {
		created(){
			this.chamaProdutos()
			if(this.$route.params.id){
				console.log(this.$route.params)
				this.mesa = this.$route.params
			}
		},
    methods: {
			chamaProdutos(){
				axios.get(`${endpoint}/produtos`)
				.then(response => {
				this.produtos = response.data
				}).catch(e => { console.log(` error ==> ${e}`)})
			},
      adicionaProduto() {
        if (this.produto.quantidade) {
          this.mesa.pedidos.push(JSON.parse(JSON.stringify(this.produto)))
          this.atualizaPedidos();
        }
      },
      atualizaPedidos(){
          this.mesa.total_valor = this.mesa.pedidos.reduce(function (soma, m) {
            return soma + (m.valor * m.quantidade);
          }, 0)
          this.mesa.total_valor_pessoa = (this.mesa.total_valor / this.mesa.num_pessoas).toFixed(2)
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
          nome: null,
          valor: null
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
        mesa: {
          num_pessoas: '',
          pedidos: [],
          total_valor: '',
          total_valor_pessoa: '',
        },
				produtos:null
      };
    },
  };

</script>
<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
</style>
