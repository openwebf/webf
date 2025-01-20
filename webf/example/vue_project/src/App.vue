<template>
  <webf-router-link path="/todomvc">
    <todo-m-v-c></todo-m-v-c>
  </webf-router-link>

  <home-page></home-page>
</template>

<script>
import HomePage from './Pages/HomePage.vue';
import TodoMVC from './Pages/TodoMVC.vue';

export default {
  name: 'App',
  components: {
    HomePage,
    TodoMVC,
  },
  methods: {}
}
</script>

<style src="./assets/styles/app.css" />
