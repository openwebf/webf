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
      if (this.tabBarRef) {
        this.tabBarRef.switchTab(targetPath);
      }
    }
  }
  
  export default TabBarManager.getInstance(); 