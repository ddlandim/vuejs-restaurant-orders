<template>
  <div class="sidebar">
    <div class="sidebar-logo">
		<img class="sidebar-logo__img" src="@/assets/img/logo.png" alt="">
		<span class="sidebar-logo__brand"></span>
	</div>
	<div class="sidebar-links">
		<li v-for="link in links" class="sidebar-links__box" :key="link.id">
			<router-link :to="link.path">{{link.name}}</router-link>
		</li>
	</div>
  </div>
</template>

<script>
import links from '@/components/sidebarLinks'
  export default {
    name: 'Sidebar',
    data() {
      return {
				links: links,
				logoRestaurante: ''
			};
    },
	};

</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
@media only screen and (max-width: 800px) {
  .sidebar{
		display: none;
	}
}
.sidebar{
	background-color: rgb(3, 68, 56) ;
	height: 100vh;
	box-shadow: 1px 1px 4px #00000073;
	&-logo{
		&__img{
			max-width: 100%;
		}
		&__brand{

		}
	}
	&-links{
		margin-top: 3rem;
		&__box{
			// font-family: 'Kirang Haerang', cursive;
			width: 99%;
			height: 50px;
			list-style: none;
			display: flex;
			align-items: center;
			justify-content: center;
			font-size: 20px;
			border: 1px solid #002A22;
			&:hover{
				transition: 0.3s;
				background-color: rgb(4, 58, 48)
			}
			a{
				width: 100%;
				text-align: center;
				color: #fff;
				text-decoration: none;
			}
		}
	}
}
</style>
