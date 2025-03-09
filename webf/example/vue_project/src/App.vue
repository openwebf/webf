<template>
  <webf-router-link path="/todomvc" @mount="handleRouterMount('todomvc')">
    <todo-m-v-c v-if="enableTodoMVC"></todo-m-v-c>
  </webf-router-link>
  <webf-router-link path="/positioned_layout" @mount="handleRouterMount('positioned')">
    <positioned-layout v-if="enablePositionedLayout"></positioned-layout>
  </webf-router-link>
  <home-page></home-page>
</template>

<script>
import HomePage from './Pages/HomePage.vue';
import TodoMVC from './Pages/TodoMVC.vue';
import PositionedLayout from './Pages/PositionedLayout.vue';

export default {
  name: 'App',
  components: {
    HomePage,
    TodoMVC,
    PositionedLayout,
  },
  methods: {
    handleRouterMount(page) {
      switch(page) {
        case 'todomvc':
          this.enableTodoMVC = true;
          break;
        case 'positioned':
          this.enablePositionedLayout = true;
          break;
      }
    }
  },
  data() {
    return {
      enableTodoMVC: false,
      enablePositionedLayout: false
    }
  }
}
</script>

<style src="./assets/styles/app.css" />
