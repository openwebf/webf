class TabBarManager {
    static instance = null;
    tabBarRef = null;

    currentPath = '';
    tabBarPath = '/home';
  
    static getInstance() {
      if (!TabBarManager.instance) {
        TabBarManager.instance = new TabBarManager();
      }
      return TabBarManager.instance;
    }
  
    setTabBarRef(ref) {
      this.tabBarRef = ref;
    }

    setCurrentPath(path) {
      this.currentPath = path;
    }
  
    switchTab(targetPath) {
      const isInTabBar = this.tabBarPath === this.currentPath;
      if (this.tabBarRef) {
        this.tabBarRef.switchTab(targetPath);
      }
      if (!isInTabBar) {
        window.webf.hybridHistory.replaceState({}, this.tabBarPath);
        this.currentPath = this.tabBarPath;
      }
    }
  }
  
  export default TabBarManager.getInstance();