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
  <router-view path="/icon" title="Icon">
    <icon-page></icon-page>
  </router-view>
  <router-view path="/search_input" title="SearchInput">
    <search-input-page></search-input-page>
  </router-view>
  <router-view path="/textarea" title="Textarea">
    <textarea-page></textarea-page>
  </router-view>
</template>

<script>
import RouterView from './Components/RouterView.vue';
import HomePage from './Pages/HomePage.vue';
import ButtonPage from './Pages/ButtonPage.vue';
import SwitchPage from './Pages/SwitchPage.vue';
import InputPage from './Pages/InputPage.vue';
import IconPage from './Pages/IconPage.vue';
import SearchInputPage from './Pages/SearchInputPage.vue';
import TextareaPage from './Pages/TextareaPage.vue';
export default {
  name: 'App',
  components: {
    RouterView,
    HomePage,
    ButtonPage,
    SwitchPage,
    InputPage,
    IconPage,
    SearchInputPage,
    TextareaPage,
  },
};
</script>

<style src="./assets/styles/app.css" />
