<template>
  <router-view path="/" title="首页">
    <home-page></home-page>
  </router-view>
  <router-view path="/show_case" title="Show Case">
    <show-case-page></show-case-page>
  </router-view>
  <router-view path="/listview" title="Listview">
    <listview-page></listview-page>
  </router-view>
</template>

<script>
import RouterView from './Components/RouterView.vue';
import HomePage from './Pages/HomePage.vue';
import ShowCasePage from './Pages/ShowCasePage.vue';
import ListviewPage from './Pages/ListviewPage.vue';
export default {
  name: 'App',
  components: {
    RouterView,
    HomePage,
    ShowCasePage,
    ListviewPage,
  },
};
</script>

<style src="./assets/styles/app.css" />
