import { WebFRouter } from '@openwebf/vue-router';

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
  }

  setCurrentPath(path: string): void {
    this.currentPath = path;
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
      this.tabBarRef.switchTab(targetPath);
    } else {
      return;
    }

    if (!isInTabBar) {
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
  }
}

export default TabBarManager.getInstance();

