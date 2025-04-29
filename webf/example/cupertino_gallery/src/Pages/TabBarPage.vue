<template>
  <flutter-cupertino-tab-bar ref="tabBar" :currentIndex="currentTabIndex" @tabchange="handleTabChange">
    <flutter-cupertino-tab-bar-item title="Home" icon="home" path="/home">
      <div class="tab-content">
        <h3>Content of Home</h3>
        <flutter-cupertino-button variant="primary" @click="switchTab('/search')">Switch to Search</flutter-cupertino-button>
      </div>
    </flutter-cupertino-tab-bar-item>
    
    <flutter-cupertino-tab-bar-item title="Search" icon="search" path="/search">
      <div class="tab-content">
        <h3>Content of Search</h3>
        <flutter-cupertino-button @click="switchTab('/profile')">Switch to Profile</flutter-cupertino-button>
      </div>
    </flutter-cupertino-tab-bar-item>
    
    <flutter-cupertino-tab-bar-item title="Add" icon="add_circled_solid" path="/add">
      <div class="tab-content">
        <h3>Content of Add</h3>
      </div>
    </flutter-cupertino-tab-bar-item>
    
    <flutter-cupertino-tab-bar-item title="Notifications" icon="bell" path="/notifications">
      <div class="tab-content">
        <h3>Content of Notifications</h3>
      </div>
    </flutter-cupertino-tab-bar-item>
    
    <flutter-cupertino-tab-bar-item title="Profile" icon="person" path="/profile">
      <div class="tab-content">
        <h3>Content of Profile</h3>
        <flutter-cupertino-button @click="switchTab('/home')">Back to Home</flutter-cupertino-button>
      </div>
    </flutter-cupertino-tab-bar-item>
  </flutter-cupertino-tab-bar>
</template>

<script>
import tabBarManager from '../utils/tabBarManager';

export default {
  name: 'TabBarPage',
  data() {
    return {
      currentTabIndex: 0
    };
  },
  mounted() {
    tabBarManager.setCurrentPath('/home');
    tabBarManager.setTabBarRef(this.$refs.tabBar);
  },
  methods: {
    handleTabChange(event) {
      const index = event.detail;
      this.currentTabIndex = index;
      console.log('Current tab index:', index);
    },
    
    switchTab(path) {
      tabBarManager.switchTab(path);
    }
  }
};
</script>

<style>
.tab-content {
  padding: 20px;
  height: 300px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
</style>
