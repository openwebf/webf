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
  <router-view path="/segmented_tab" title="Segmented Tab">
    <segmented-tab-page></segmented-tab-page>
  </router-view>
  <router-view path="/alert" title="Alert">
    <alert-page></alert-page>
  </router-view>
  <router-view path="/date_picker" title="Date Picker">
    <date-picker-page></date-picker-page>
  </router-view>
  <router-view path="/loading" title="Loading">
    <loading-page></loading-page>
  </router-view>
  <router-view path="/modal_popup" title="Modal Popup">
    <modal-popup-page></modal-popup-page>
  </router-view>
  <router-view path="/picker" title="Picker">
    <picker-page></picker-page>
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
import SegmentedTabPage from './Pages/SegmentedTabPage.vue';
import AlertPage from './Pages/AlertPage.vue';
import DatePickerPage from './Pages/DatePickerPage.vue';
import LoadingPage from './Pages/LoadingPage.vue';
import ModalPopupPage from './Pages/ModalPopupPage.vue';
import PickerPage from './Pages/PickerPage.vue';

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
    SegmentedTabPage,
    AlertPage,
    DatePickerPage,
    LoadingPage,
    ModalPopupPage,
    PickerPage,
  },
};
</script>

<style src="./assets/styles/app.css" />
