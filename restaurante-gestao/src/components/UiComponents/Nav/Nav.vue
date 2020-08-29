<template>
  <div>
    <div class="nav ">
      <div class="nav-home">
        <router-link to="/visao-geral"  class="btn-mobile">Home</router-link>
      </div>
      <ul class="nav-box">
        <li v-for="item in links" :key="item.id">
          <a v-link="item.router" class="nav-box--link">{{item.name}}</a>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'NavBar',
    data() {
      return {
        links: [
          {
            id: 1,
            name: 'Sair',
            router: 'Lista Mesas'
          }
        ]
      };
    },
  };

</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  .nav {
    margin: 0 auto;
    height: 60px;
    background-color: #f3eeee;
    display: flex;
    align-items: center;
    justify-content: space-between;
    box-shadow: 1px 1px 4px #00000073;
    &-home{
      height: 100%;
      width: 15%;
      display: flex;
      padding-right: 7px;
      align-items: center;
      justify-content: center;
      border-right: 1px solid #c9c9c9;
      a{
        text-decoration: none;
        cursor: pointer;
        color: #002A22;
        font-weight: 600;
      }
    }
    &-box {
      width: 70%;
      display: flex;
      list-style: none;
      justify-content: flex-end;
      &--link {
        color: #002A22;
        margin: 10px;
        text-decoration: none;
        &:hover {
          color: #c9c9c9;
        }
      }
    }
    &-mobile {
      display: none;
    }
  }

</style>
