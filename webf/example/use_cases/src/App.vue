<template>
  <router-view path="/" title="首页">
    <home-page></home-page>
  </router-view>
  <router-view path="/show_case" title="Show Case">
    <show-case-page></show-case-page>
  </router-view>
</template>

<script>
import RouterView from './Components/RouterView.vue';
import HomePage from './Pages/HomePage.vue';
import ShowCasePage from './Pages/ShowCasePage.vue';

export default {
  name: 'App',
  components: {
    RouterView,
    HomePage,
    ShowCasePage,
  },
};
</script>

<style src="./assets/styles/app.css" />
