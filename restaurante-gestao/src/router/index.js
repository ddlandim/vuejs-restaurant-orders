import Vue from 'vue';
import Router from 'vue-router';
import DashboardLayout from '@/components/DashboardLayout';
import VisaoGeral from '@/components/VisaoGeral';
import EditarMesa from '@/components/Mesa/EditarMesa/EditarMesa';

//contracts views
import Profile from '@/contract_views/user/Profile';
import List from '@/contract_views/user/List';
import Register from '@/contract_views/user/Register';

Vue.use(Router);

const router = new Router({
 // mode: 'history',
  routes: 
  [
    {
      path: '/',
      component: DashboardLayout,
      redirect: '/visao-geral',
      children: [
        {
        component: VisaoGeral,
        name: 'Visao Geral',
        path: '/visao-geral',
        },
        {
          component: EditarMesa,
          name: 'Editar Mesa',
          path: '/editar-mesa',
        },
        //Contract Components
        {
          path: '/List',
          name: 'List',
          component: List
        },
        {
          path: '/profile',
          name: 'Profile',
          component: Profile
        },
        {
          path: '/register',
          name: 'Register',
          component: Register
        }
      ]
    }
  ],
  linkActiveClass: 'active'
})
export default router
