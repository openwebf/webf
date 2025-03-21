<template>
  <div id="main">
    <feeds-tabs :tabs="tabsConfig" @change="onTabChange" @onscreen="onScreen" @offscreen="offScreen">
        <!-- 热门标签页内容 -->
        <template #hot>
            <webf-listview class="listview">
              <div v-for="item in hotList" :key="item.id">
                <feed-card :item="item"></feed-card>
              </div>
            </webf-listview>
        </template>

        <!-- 最新标签页内容 -->
        <template #latest>
          <webf-listview class="listview">
            <div v-for="item in latestList" :key="item.id">
              <feed-card :item="item"></feed-card>
            </div>
          </webf-listview>

        </template>

        <!-- 讨论标签页内容 -->
        <template #discussion>
          <webf-listview class="listview">
            <div v-for="item in commentList" :key="item.id">
              <comment-card :item="item"></comment-card>
            </div>
          </webf-listview>
        </template>

        <!-- 新闻标签页内容 -->
        <template #news>
            <webf-listview class="listview">
              <div v-for="item in newsList" :key="item.id">
                <display-card :item="item"></display-card>
              </div>
            </webf-listview>
        </template>

        <!-- 学术标签页内容 -->
        <template #academic>
            <webf-listview class="listview">
              <div v-for="item in academicList" :key="item.id">
                <display-card :item="item"></display-card>
              </div>
            </webf-listview>
        </template>

        <!-- 产品标签页内容 -->
        <template #product>
            <webf-listview class="listview">
              <div v-for="item in productList" :key="item.id">
                <display-card :item="item"></display-card>
              </div>
            </webf-listview>
        </template>
    </feeds-tabs>
    <flutter-cupertino-loading ref="loading" />
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
    }
  },
  methods: {
    async onTabChange(e) {
      const tabIndex = e.detail;
      if (this.loadedTabs.has(this.tabsConfig[tabIndex].id)) {
        console.log('already loaded', this.tabsConfig[tabIndex].id);
        return;
      }
      this.$refs.loading.show({
        text: '加载中'
      });
      if (tabIndex === 0) {
        const res = await api.news.getHotList();
        this.hotList = res.data.feeds;
      } else if (tabIndex === 1) {
        const res = await api.news.getLatestList();
        this.latestList = res.data.feeds;
      } else if (tabIndex === 2) {
        const res = await api.news.getCommentList();
        this.commentList = res.data.feeds;
      } else if (tabIndex === 3) {
        const res = await api.news.getDisplayList({ topic: '新闻' });
        this.newsList = res.data.displays;
      } else if (tabIndex === 4) {
        const res = await api.news.getDisplayList({ topic: '学术' });
        this.academicList = res.data.displays;
      } else if (tabIndex === 5) {
        const res = await api.news.getDisplayList({ topic: '产品' });
        this.productList = res.data.displays;
      }
      this.loadedTabs.add(this.tabsConfig[tabIndex].id);
      this.$refs.loading.hide();
    },
    async onScreen() {
      if (this.hotList.length == 0) {
        this.$refs.loading.show({
          text: '加载中'
        });
        const res = await api.news.getHotList();
        this.hotList = res.data.feeds;
        this.$refs.loading.hide();
      }
    },
    async offScreen() {
    },
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
}
</style>

