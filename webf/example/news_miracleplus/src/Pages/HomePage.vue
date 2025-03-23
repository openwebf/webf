<template>
  <div id="main">
    <feeds-tabs :tabs="tabsConfig" @change="onTabChange" @onscreen="onScreen" @offscreen="offScreen">
        <!-- 热门标签页内容 -->
        <template #hot>
            <webf-listview class="listview" @refresh="onRefreshHot" @loadmore="onLoadMoreHot">
              <div v-for="item in hotList" :key="item.id">
                <feed-card :item="item"></feed-card>
              </div>
            </webf-listview>
        </template>

        <!-- 最新标签页内容 -->
        <template #latest>
          <webf-listview class="listview" @refresh="onRefreshLatest" @loadmore="onLoadMoreLatest">
            <div v-for="item in latestList" :key="item.id">
              <feed-card :item="item"></feed-card>
            </div>
          </webf-listview>
        </template>

        <!-- 讨论标签页内容 -->
        <template #discussion>
          <webf-listview class="listview" @refresh="onRefreshComment" @loadmore="onLoadMoreComment">
            <div v-for="item in commentList" :key="item.id">
              <comment-card :item="item"></comment-card>
            </div>
          </webf-listview>
        </template>

        <!-- 新闻标签页内容 -->
        <template #news>
            <webf-listview class="listview" @refresh="onRefreshNews" @loadmore="onLoadMoreNews">
              <div v-for="item in newsList" :key="item.id">
                <display-card :item="item"></display-card>
              </div>
            </webf-listview>
        </template>

        <!-- 学术标签页内容 -->
        <template #academic>
            <webf-listview class="listview" @refresh="onRefreshAcademic" @loadmore="onLoadMoreAcademic">
              <div v-for="item in academicList" :key="item.id">
                <display-card :item="item"></display-card>
              </div>
            </webf-listview>
        </template>

        <!-- 产品标签页内容 -->
        <template #product>
            <webf-listview class="listview" @refresh="onRefreshProduct" @loadmore="onLoadMoreProduct">
              <div v-for="item in productList" :key="item.id">
                <display-card :item="item"></display-card>
              </div>
            </webf-listview>
        </template>
    </feeds-tabs>
    <flutter-cupertino-loading ref="loading" />
    <flutter-cupertino-toast ref="toast" />
  </div>
</template>

<script>
import { useUserStore } from '@/stores/userStore'
import FeedsTabs from "@/Components/FeedsTabs.vue";
import FeedCard from "@/Components/FeedCard.vue";
import CommentCard from "@/Components/comment/CommentCard.vue";
import DisplayCard from "@/Components/DisplayCard.vue";
import { api } from '@/api';

export default {
  components: {
    FeedsTabs,
    FeedCard,
    CommentCard,
    DisplayCard,
  },
  setup() {
    const userStore = useUserStore();
    return {
      userStore,
    }
  },
  computed: {
    isLoggedIn() {
      return this.userStore.isLoggedIn;
    },
    userInfo() {
      return this.userStore.userInfo;
    },
    userName() {
      return this.userStore.userName;
    },
    userAvatar() {
      return this.userStore.userAvatar;
    }
  },
  data: () => {
    return {
      tabsConfig: [
        { id: 'hot', title: '热门' },
        { id: 'latest', title: '最新' },
        { id: 'discussion', title: '讨论' },
        { id: 'news', title: '新闻' },
        { id: 'academic', title: '学术' },
        { id: 'product', title: '产品' }
      ],
      loadedTabs: new Set(['hot']),
      hotList: [],
      latestList: [],
      commentList: [],
      newsList: [],
      academicList: [],
      productList: [],
      // 为每个列表添加分页信息
      hotPage: 1,
      latestPage: 1,
      commentPage: 1,
      newsPage: 1,
      academicPage: 1,
      productPage: 1,
      // 记录是否有更多数据可加载
      hotHasMore: true,
      latestHasMore: true,
      commentHasMore: true,
      newsHasMore: true,
      academicHasMore: true,
      productHasMore: true,
      // 记录是否正在加载中
      isLoading: false
    }
  },
  methods: {
    async onTabChange(e) {
      const tabIndex = e.detail;
      if (this.loadedTabs.has(this.tabsConfig[tabIndex].id)) {
        console.log('already loaded', this.tabsConfig[tabIndex].id);
        return;
      }
      
      this.showLoading('加载中');
      
      try {
        if (tabIndex === 0) {
          await this.loadHotList(1, true);
        } else if (tabIndex === 1) {
          await this.loadLatestList(1, true);
        } else if (tabIndex === 2) {
          await this.loadCommentList(1, true);
        } else if (tabIndex === 3) {
          await this.loadNewsList(1, true);
        } else if (tabIndex === 4) {
          await this.loadAcademicList(1, true);
        } else if (tabIndex === 5) {
          await this.loadProductList(1, true);
        }
        
        this.loadedTabs.add(this.tabsConfig[tabIndex].id);
      } catch (error) {
        console.error('加载标签页数据失败:', error);
        this.showToast('加载失败，请重试', 'error');
      } finally {
        this.hideLoading();
      }
    },
    
    async onScreen() {
      if (this.hotList.length == 0) {
        this.showLoading('加载中');
        try {
          await this.loadHotList(1, true);
        } catch (error) {
          console.error('加载热门列表失败:', error);
          this.showToast('加载失败，请重试', 'error');
        } finally {
          this.hideLoading();
        }
      }
    },
    
    // 热门列表加载逻辑
    async loadHotList(page, replace = false) {
      try {
        if (this.isLoading) return;
        this.isLoading = true;
        
        const res = await api.news.getHotList({ page });
        
        if (res.data && res.data.feeds) {
          if (replace) {
            this.hotList = res.data.feeds;
            this.hotPage = 1;
          } else {
            this.hotList = [...this.hotList, ...res.data.feeds];
          }
          
          // 判断是否还有更多数据
          this.hotHasMore = res.data.feeds.length > 0;
          
          // 如果成功加载了数据，更新页码
          if (!replace && res.data.feeds.length > 0) {
            this.hotPage = page;
          }
        } else {
          this.hotHasMore = false;
        }
      } catch (error) {
        console.error('加载热门列表失败:', error);
        throw error;
      } finally {
        this.isLoading = false;
      }
    },
    
    // 下拉刷新热门列表
    async onRefreshHot() {
      try {
        await this.loadHotList(1, true);
        this.showToast('刷新成功', 'success');
      } catch (error) {
        this.showToast('刷新失败，请重试', 'error');
      }
    },
    
    // 上拉加载更多热门列表
    async onLoadMoreHot() {
      if (!this.hotHasMore || this.isLoading) return;
      
      try {
        const nextPage = this.hotPage + 1;
        await this.loadHotList(nextPage);
      } catch (error) {
        console.error('加载更多热门内容失败:', error);
        this.showToast('加载更多失败', 'error');
      }
    },
    
    // 最新列表加载逻辑
    async loadLatestList(page, replace = false) {
      try {
        if (this.isLoading) return;
        this.isLoading = true;
        
        const res = await api.news.getLatestList({ page });
        
        if (res.data && res.data.feeds) {
          if (replace) {
            this.latestList = res.data.feeds;
            this.latestPage = 1;
          } else {
            this.latestList = [...this.latestList, ...res.data.feeds];
          }
          
          // 判断是否还有更多数据
          this.latestHasMore = res.data.feeds.length > 0;
          
          // 如果成功加载了数据，更新页码
          if (!replace && res.data.feeds.length > 0) {
            this.latestPage = page;
          }
        } else {
          this.latestHasMore = false;
        }
      } catch (error) {
        console.error('加载最新列表失败:', error);
        throw error;
      } finally {
        this.isLoading = false;
      }
    },
    
    // 下拉刷新最新列表
    async onRefreshLatest() {
      try {
        await this.loadLatestList(1, true);
        this.showToast('刷新成功', 'success');
      } catch (error) {
        this.showToast('刷新失败，请重试', 'error');
      }
    },
    
    // 上拉加载更多最新列表
    async onLoadMoreLatest() {
      if (!this.latestHasMore || this.isLoading) return;
      
      try {
        const nextPage = this.latestPage + 1;
        await this.loadLatestList(nextPage);
      } catch (error) {
        console.error('加载更多最新内容失败:', error);
        this.showToast('加载更多失败', 'error');
      }
    },
    
    // 评论列表加载逻辑
    async loadCommentList(page, replace = false) {
      try {
        if (this.isLoading) return;
        this.isLoading = true;
        
        const res = await api.news.getCommentList({ page });
        
        if (res.data && res.data.feeds) {
          if (replace) {
            this.commentList = res.data.feeds;
            this.commentPage = 1;
          } else {
            this.commentList = [...this.commentList, ...res.data.feeds];
          }
          
          // 判断是否还有更多数据
          this.commentHasMore = res.data.feeds.length > 0;
          
          // 如果成功加载了数据，更新页码
          if (!replace && res.data.feeds.length > 0) {
            this.commentPage = page;
          }
        } else {
          this.commentHasMore = false;
        }
      } catch (error) {
        console.error('加载评论列表失败:', error);
        throw error;
      } finally {
        this.isLoading = false;
      }
    },
    
    // 下拉刷新评论列表
    async onRefreshComment() {
      try {
        await this.loadCommentList(1, true);
        this.showToast('刷新成功', 'success');
      } catch (error) {
        this.showToast('刷新失败，请重试', 'error');
      }
    },
    
    // 上拉加载更多评论列表
    async onLoadMoreComment() {
      if (!this.commentHasMore || this.isLoading) return;
      
      try {
        const nextPage = this.commentPage + 1;
        await this.loadCommentList(nextPage);
      } catch (error) {
        console.error('加载更多评论内容失败:', error);
        this.showToast('加载更多失败', 'error');
      }
    },
    
    // 新闻列表加载逻辑
    async loadNewsList(page, replace = false) {
      try {
        if (this.isLoading) return;
        this.isLoading = true;
        
        const res = await api.news.getDisplayList({ page, topic: '新闻' });
        
        if (res.data && res.data.displays) {
          if (replace) {
            this.newsList = res.data.displays;
            this.newsPage = 1;
          } else {
            this.newsList = [...this.newsList, ...res.data.displays];
          }
          
          // 判断是否还有更多数据
          this.newsHasMore = res.data.displays.length > 0;
          
          // 如果成功加载了数据，更新页码
          if (!replace && res.data.displays.length > 0) {
            this.newsPage = page;
          }
        } else {
          this.newsHasMore = false;
        }
      } catch (error) {
        console.error('加载新闻列表失败:', error);
        throw error;
      } finally {
        this.isLoading = false;
      }
    },
    
    // 下拉刷新新闻列表
    async onRefreshNews() {
      try {
        await this.loadNewsList(1, true);
        this.showToast('刷新成功', 'success');
      } catch (error) {
        this.showToast('刷新失败，请重试', 'error');
      }
    },
    
    // 上拉加载更多新闻列表
    async onLoadMoreNews() {
      if (!this.newsHasMore || this.isLoading) return;
      
      try {
        const nextPage = this.newsPage + 1;
        await this.loadNewsList(nextPage);
      } catch (error) {
        console.error('加载更多新闻内容失败:', error);
        this.showToast('加载更多失败', 'error');
      }
    },
    
    // 学术列表加载逻辑
    async loadAcademicList(page, replace = false) {
      try {
        if (this.isLoading) return;
        this.isLoading = true;
        
        const res = await api.news.getDisplayList({ page, topic: '学术' });
        
        if (res.data && res.data.displays) {
          if (replace) {
            this.academicList = res.data.displays;
            this.academicPage = 1;
          } else {
            this.academicList = [...this.academicList, ...res.data.displays];
          }
          
          // 判断是否还有更多数据
          this.academicHasMore = res.data.displays.length > 0;
          
          // 如果成功加载了数据，更新页码
          if (!replace && res.data.displays.length > 0) {
            this.academicPage = page;
          }
        } else {
          this.academicHasMore = false;
        }
      } catch (error) {
        console.error('加载学术列表失败:', error);
        throw error;
      } finally {
        this.isLoading = false;
      }
    },
    
    // 下拉刷新学术列表
    async onRefreshAcademic() {
      try {
        await this.loadAcademicList(1, true);
        this.showToast('刷新成功', 'success');
      } catch (error) {
        this.showToast('刷新失败，请重试', 'error');
      }
    },
    
    // 上拉加载更多学术列表
    async onLoadMoreAcademic() {
      if (!this.academicHasMore || this.isLoading) return;
      
      try {
        const nextPage = this.academicPage + 1;
        await this.loadAcademicList(nextPage);
      } catch (error) {
        console.error('加载更多学术内容失败:', error);
        this.showToast('加载更多失败', 'error');
      }
    },
    
    // 产品列表加载逻辑
    async loadProductList(page, replace = false) {
      try {
        if (this.isLoading) return;
        this.isLoading = true;
        
        const res = await api.news.getDisplayList({ page, topic: '产品' });
        
        if (res.data && res.data.displays) {
          if (replace) {
            this.productList = res.data.displays;
            this.productPage = 1;
          } else {
            this.productList = [...this.productList, ...res.data.displays];
          }
          
          // 判断是否还有更多数据
          this.productHasMore = res.data.displays.length > 0;
          
          // 如果成功加载了数据，更新页码
          if (!replace && res.data.displays.length > 0) {
            this.productPage = page;
          }
        } else {
          this.productHasMore = false;
        }
      } catch (error) {
        console.error('加载产品列表失败:', error);
        throw error;
      } finally {
        this.isLoading = false;
      }
    },
    
    // 下拉刷新产品列表
    async onRefreshProduct() {
      try {
        await this.loadProductList(1, true);
        this.showToast('刷新成功', 'success');
      } catch (error) {
        this.showToast('刷新失败，请重试', 'error');
      }
    },
    
    // 上拉加载更多产品列表
    async onLoadMoreProduct() {
      if (!this.productHasMore || this.isLoading) return;
      
      try {
        const nextPage = this.productPage + 1;
        await this.loadProductList(nextPage);
      } catch (error) {
        console.error('加载更多产品内容失败:', error);
        this.showToast('加载更多失败', 'error');
      }
    },
    
    // 辅助方法：显示加载状态
    showLoading(text = '加载中') {
      this.$refs.loading.show({
        text
      });
    },
    
    // 辅助方法：隐藏加载状态
    hideLoading() {
      this.$refs.loading.hide();
    },
    
    // 辅助方法：显示提示消息
    showToast(content, type = 'info') {
      this.$refs.toast.show({
        content,
        type
      });
    },
    
    // 为兼容原来的方法保留这些空方法
    async onRefresh() {
      console.log('onRefresh');
    },
    async onLoadMore() {
      console.log('onLoadMore');
    },
    async offScreen() {
      console.log('offScreen');
    }
  }
}
</script>

<style scoped>
#list {
  padding: 10px 0;
  height: 100vh;
  width: 100vw;
}

.listview {
  height: 100vh;
  width: 100vw;
  padding-bottom: 90px;
}
</style>