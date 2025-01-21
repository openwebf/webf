<template>
  <webf-router-link path="/todomvc">
    <todo-m-v-c></todo-m-v-c>
  </webf-router-link>
  <webf-router-link path="/positioned_layout">
    <positioned-layout></positioned-layout>
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
    PositionedLayout
  },
  methods: {}
}
</script>

<style src="./assets/styles/app.css" />
