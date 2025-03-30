<template>
  <router-view path="/" title="首页">
    <home-page></home-page>
  </router-view>
  <router-view path="/button" title="Button">
    <button-page></button-page>
  </router-view>
  <router-view path="/switch" title="Switch">
    <switch-page></switch-page>
  </router-view>
  <router-view path="/input" title="Input">
    <input-page></input-page>
  </router-view>
</template>

<script>
import RouterView from './Components/RouterView.vue';
import HomePage from './Pages/HomePage.vue';
import ButtonPage from './Pages/ButtonPage.vue';
import SwitchPage from './Pages/SwitchPage.vue';
import InputPage from './Pages/InputPage.vue';

export default {
  name: 'App',
  components: {
    RouterView,
    HomePage,
    ButtonPage,
    SwitchPage,
    InputPage,
  }
}
</script>

<style src="./assets/styles/app.css" />
