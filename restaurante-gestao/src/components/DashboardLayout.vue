<template>
  <div class="main">
    <sidebar class="main-sidebar"></sidebar>
    <div class="main-content">
      <top-nav class="main-content-top"></top-nav>
      <router-view></router-view>
    </div>
  </div>
</template>
<script>
  import Nav from './UiComponents/Nav/Nav'
  import Sidebar from './UiComponents/Sidebar/Sidebar'
  export default {
    components: {
      'top-nav': Nav,
      'sidebar': Sidebar
    }
  }

</script>
<style lang="scss" scoped>

</style>
