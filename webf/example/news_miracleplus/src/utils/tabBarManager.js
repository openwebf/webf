class TabBarManager {
    static instance = null;
    tabBarRef = null;
  
    static getInstance() {
      if (!TabBarManager.instance) {
        TabBarManager.instance = new TabBarManager();
      }
      return TabBarManager.instance;
    }
  
    setTabBarRef(ref) {
      this.tabBarRef = ref;
    }
  
    switchTab(path) {
      if (this.tabBarRef) {
        this.tabBarRef.switchTab(path);
      }
    }
  }
  
  export default TabBarManager.getInstance();