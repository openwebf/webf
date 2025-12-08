import { WebFRouter } from '../router';

class TabBarManager {
    private static instance: TabBarManager | null = null;
    private tabBarRef: any = null;
    private currentPath = '';
    private tabBarPath = '/routing';
  
    static getInstance(): TabBarManager {
      if (!TabBarManager.instance) {
        TabBarManager.instance = new TabBarManager();
      }
      return TabBarManager.instance;
    }
  
    setTabBarRef(ref: any): void {
      this.tabBarRef = ref;
      console.log('TabBarManager: TabBar ref set', ref);
    }

    setCurrentPath(path: string): void {
      this.currentPath = path;
      console.log('TabBarManager: Current path set to', path);
    }

    setTabBarPath(path: string): void {
      this.tabBarPath = path;
    }

    getCurrentPath(): string {
      return this.currentPath;
    }

    getTabBarPath(): string {
      return this.tabBarPath;
    }
  
    switchTab(targetPath: string): void {
      const isInTabBar = this.tabBarPath === this.currentPath;
      
      if (this.tabBarRef && typeof this.tabBarRef.switchTab === 'function') {
        console.log('TabBarManager: Calling tabBarRef.switchTab');
        this.tabBarRef.switchTab(targetPath);
      } else {
        console.error('TabBarManager: TabBar ref is null or switchTab method not available');
        return;
      }
      
      if (!isInTabBar) {
        console.log('TabBarManager: Not in TabBar page, navigating to', this.tabBarPath);
        WebFRouter.replaceState({}, this.tabBarPath);
        this.currentPath = this.tabBarPath;
      }
    }

    navigateToTab(targetPath: string): void {
      WebFRouter.pushState({}, this.tabBarPath);
      this.currentPath = this.tabBarPath;

      setTimeout(() => {
        this.switchTab(targetPath);
      }, 100);
    }

    reset(): void {
      this.tabBarRef = null;
      this.currentPath = '';
      console.log('TabBarManager: Reset completed');
    }
  }
  
  export default TabBarManager.getInstance();
