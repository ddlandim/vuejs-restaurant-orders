import Vue from 'vue';
import Router from 'vue-router';
import DashboardLayout from '@/components/DashboardLayout';
import VisaoGeral from '@/components/VisaoGeral';
import EditarMesa from '@/components/Mesa/EditarMesa/EditarMesa';

Vue.use(Router);

const router = new Router({
  mode: 'history',
  routes: [
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
        }
      ]
    }
  ]
})

export default router
