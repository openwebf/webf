class TabBarManager {
    static instance = null;
    tabBarRef = null;

    currentPath = '';
    tabBarPath = '/home';
  
    static getInstance() {
      if (!TabBarManager.instance) {
        TabBarManager.instance = new TabBarManager();
        window.addEventListener('hybridrouterchange', (e) => {
          TabBarManager.instance.setCurrentPath(e.name);
        });
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
        window.webf.hybridHistory.pushState({}, this.tabBarPath);
        this.currentPath = this.tabBarPath;
      }
    }
  }
  
  export default TabBarManager.getInstance();