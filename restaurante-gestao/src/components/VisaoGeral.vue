<template>
<div>
  <div class="row justify-content-around">
    <div class="col-6 col-sm-12 card">
      <div class="card-header">
        <h2 class="card-title">Comandas em Aberto</h2>
      </div>
      <div class="row">
        <h3>{{comandas.length}}</h3>
      </div>
    </div>
    <div class="col-6 col-sm-12 card">
      <div class="card-header">
        <h2 class="card-title">Faturamento do Dia</h2>
      </div>
      <div class="row">
        <h3>R${{faturamento}}</h3>
      </div>
    </div>
  </div>
  <div class="row">
    <div class="card col-12 col-sm-12">
      <div class="card-header">
        <div class="row justify-content-between">
          <h2 class="card-title">
            Lista de Comandas Abertas
          </h2>
          <div>
            <button @click="adicionaComanda" class="btn btn-success">Adicionar</button>
          </div>
        </div>
        <div class="row  tableheader align-center">
          <div class="col-2 col-sm-2">
            <h4 class="table-title">Numero</h4>
          </div>
          <div class="col-2 col-sm-2 none-mobile">
            <h4 class="table-title">Nº de Pessoas</h4>
          </div>
          <div class="col-2 col-sm-2 ">
            <h4 class="table-title">Valor</h4>
          </div>
          <div class="col-5 col-sm-7">
            <h4 class="table-title">Ação</h4>
          </div>
        </div>
        <div class="row row-table align-center" v-for="(comanda,index) in comandas" :key="comanda.id">
          <div class="col-2 col-sm-2">{{comanda.id}}</div>
          <div class="col-2 col-sm-2 none-mobile">{{comanda.num_pessoas}}</div>
          <div class="col-2 col-sm-2">R${{comanda.total_valor}}</div>
          <div class="col-5  col-sm-7 justify-content-between">
            <button class="btn btn-warning" @click="editarComanda(comanda)">EDITAR</button>
            <button class="btn btn-danger" @click="deletaComanda(comanda,index)">Fechar</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
</template>

<script>
import axios from 'axios';

let endpoint = "http://localhost:3000"

export default {
  name: 'Visao Geral',
  methods:{
    adicionaComanda () {
      this.$router.push({name:'Editar Mesa'})  
    },
    editarComanda(comanda){
      this.$router.push({name: 'Editar Mesa' , params: comanda})
    },
    deletaComanda(comanda,index){

      this.comandas.find(e => {
        if(e.id == comanda.id){
          this.comandas.splice(index,1);
          axios.delete(`${endpoint}/comandas/${comanda.id}`)
          .then(response => {})
          .catch(e => {
            this.errors.push(e)
          })
        }
        }); 
    },
    chamaComandas(){
      axios.get(`${endpoint}/comandas`)
      .then(response => {
      this.comandas = response.data
      if(this.comandas.length>1){
        this.faturamento = this.comandas.reduce(function (soma, m) {
            return soma + m.total_valor;
            console.log(m.total_valor)
          }, 0)
      }else{
        this.faturamento = this.comandas[0].total_valor
      }
      }).catch(e => { console.log(` error ==> ${e}`)})
       
    },
  },
  mounted(){
    this.chamaComandas();
  },
  created() {
    this.chamaComandas();
  },
  data() {
    return {
      comandas:[],
      faturamento: ''
    };
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.box-mesas{
  display: flex;
  flex-wrap: wrap;
  justify-content: space-around;
  .card{
    width: 29%;
    margin: .5rem;
  }
}
</style>
