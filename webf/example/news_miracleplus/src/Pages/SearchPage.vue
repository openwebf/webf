<template>
  <div class="search-page">
    <div class="search-input">
      <flutter-cupertino-search-input
        class="input"
        placeholder="提出你的问题吧"
        @search="handleSearch"
      />
    </div>
    <div v-if="hasSearch">
      <flutter-cupertino-segmented-tab @change="onTabChange">
        <flutter-cupertino-segmented-tab-item title="分享">
          <webf-listview class="share-link-list" @loadmore="onLoadMoreShareLinks">
            <div v-if="shareLinks.length === 0" class="empty-state">暂无相关内容</div>
            <share-link-card v-for="shareLink in shareLinks" :key="shareLink.id" :data="shareLink" />
          </webf-listview>
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="回答">
          <webf-listview class="answer-list" @loadmore="onLoadMoreAnswers">
            <div v-if="answers.length === 0" class="empty-state">暂无相关内容</div>
            <answer-card v-for="answer in answers" :key="answer.id" :data="answer" />
          </webf-listview>
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="问题">
          <webf-listview class="question-list" @loadmore="onLoadMoreQuestions">
            <div v-if="questions.length === 0" class="empty-state">暂无相关内容</div>
            <question-card v-for="question in questions" :key="question.id" :question="question" />
          </webf-listview>
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="用户">
          <webf-listview class="user-list" @loadmore="onLoadMoreUsers">
            <div v-if="users.length === 0" class="empty-state">暂无相关内容</div>
            <user-card v-for="user in users" :key="user.id" :user="user" />
          </webf-listview>
        </flutter-cupertino-segmented-tab-item>
      </flutter-cupertino-segmented-tab>
    </div>
    <div v-else class="search-empty">
      <img src="@/assets/img/logo.png" alt="logo" />
      <div class="search-empty-text">最新最有趣的科技前沿内容</div>
    </div>
    <flutter-cupertino-loading ref="loading" />
    <flutter-cupertino-toast ref="toast" />
  </div>
</template>

<script>
import { api } from '@/api';
import QuestionCard from '@/Components/search/QuestionCard.vue';
import AnswerCard from '@/Components/search/AnswerCard.vue';
import UserCard from '@/Components/search/UserCard.vue';
import ShareLinkCard from '@/Components/search/ShareLinkCard.vue';

export default {
  name: 'SearchPage',
  components: {
    QuestionCard,
    UserCard,
    ShareLinkCard,
    AnswerCard,
  },
  data() {
    return {
      hasSearch: false,
      keyword: '',
      users: [],
      answers: [],
      questions: [],
      shareLinks: [],
      userPage: 1,
      answerPage: 1,
      questionPage: 1,
      shareLinkPage: 1,
      userHasMore: true,
      answerHasMore: true,
      questionHasMore: true,
      shareLinkHasMore: true,
      currentTabIndex: 0,
      isLoading: false
    }
  },
  methods: {
    handleSearch(event) {
      this.keyword = event.detail;
      
      if (!this.keyword.trim()) {
        this.hasSearch = false;
        return;
      }
      
      this.hasSearch = true;
      
      this.resetSearchData();
      
      this.$refs.loading.show({
        text: '搜索中'
      });
      
      this.searchCurrentTabData(true);
    },
    
    resetSearchData() {
      this.users = [];
      this.answers = [];
      this.questions = [];
      this.shareLinks = [];
      
      this.userPage = 1;
      this.answerPage = 1;
      this.questionPage = 1;
      this.shareLinkPage = 1;
      
      this.userHasMore = true;
      this.answerHasMore = true;
      this.questionHasMore = true;
      this.shareLinkHasMore = true;
    },
    
    onTabChange(e) {
      this.currentTabIndex = e.detail;
      
      if (this.hasSearch && this.keyword) {
        const tabs = ['shareLinks', 'answers', 'questions', 'users'];
        const currentTab = tabs[this.currentTabIndex];
        
        if (this[currentTab].length === 0) {
          this.searchCurrentTabData(true);
        }
      }
    },
    
    searchCurrentTabData(showLoading = false) {
      if (this.isLoading) return;
      
      const tabMethods = [
        { type: 'shareLinks', method: api.search.shareLinks, page: this.shareLinkPage },
        { type: 'answers', method: api.search.answers, page: this.answerPage },
        { type: 'questions', method: api.search.questions, page: this.questionPage },
        { type: 'users', method: api.search.users, page: this.userPage }
      ];
      
      const currentTab = tabMethods[this.currentTabIndex];
      
      if (showLoading) {
        this.$refs.loading.show({
          text: '加载中'
        });
      }
      
      this.isLoading = true;
      
      currentTab.method({ 
        keyword: this.keyword, 
        perPage: 10,
        page: currentTab.page
      }).then(res => {
        this.handleSearchResult(currentTab.type, res, currentTab.page > 1);
        
        if (showLoading) {
          this.$refs.loading.hide();
        }
        this.isLoading = false;
      }).catch(err => {
        console.error(`搜索${currentTab.type}失败:`, err);
        if (showLoading) {
          this.$refs.loading.hide();
        }
        this.$refs.toast.show({
          type: 'error',
          content: '搜索失败，请重试'
        });
        this.isLoading = false;
      });
    },
    
    handleSearchResult(type, res, append = false) {
      let dataKey, dataList;
      
      switch (type) {
        case 'shareLinks':
          dataKey = 'share_links';
          dataList = 'shareLinks';
          break;
        case 'answers':
          dataKey = 'answers';
          dataList = 'answers';
          break;
        case 'questions':
          dataKey = 'questions';
          dataList = 'questions';
          break;
        case 'users':
          dataKey = 'users';
          dataList = 'users';
          break;
      }
      
      const results = res.data[dataKey] || [];
      
      this[`${dataList.charAt(0).toLowerCase() + dataList.slice(1)}HasMore`] = results.length > 0;
      
      if (append) {
        this[dataList] = [...this[dataList], ...results];
      } else {
        this[dataList] = results;
      }
      
      if (results.length > 0) {
        const pageKey = type === 'shareLinks' ? 'shareLinkPage' : `${type.charAt(0).toLowerCase() + type.slice(1)}Page`;
        if (append) {
          this[pageKey]++;
        }
      }
    },
    
    onLoadMoreShareLinks() {
      if (!this.shareLinkHasMore || this.isLoading || !this.keyword) return;
      
      const savedIndex = this.currentTabIndex;
      this.currentTabIndex = 0;
      
      this.shareLinkPage++;
      
      this.searchCurrentTabData(false);
      
      this.currentTabIndex = savedIndex;
    },
    
    onLoadMoreAnswers() {
      if (!this.answerHasMore || this.isLoading || !this.keyword) return;
      
      const savedIndex = this.currentTabIndex;
      this.currentTabIndex = 1;
      
      this.answerPage++;
      
      this.searchCurrentTabData(false);
      
      this.currentTabIndex = savedIndex;
    },
    
    onLoadMoreQuestions() {
      if (!this.questionHasMore || this.isLoading || !this.keyword) return;
      
      const savedIndex = this.currentTabIndex;
      this.currentTabIndex = 2;
      
      this.questionPage++;
      
      this.searchCurrentTabData(false);
      
      this.currentTabIndex = savedIndex;
    },
    
    onLoadMoreUsers() {
      if (!this.userHasMore || this.isLoading || !this.keyword) return;
      
      const savedIndex = this.currentTabIndex;
      this.currentTabIndex = 3;
      
      this.userPage++;
      
      this.searchCurrentTabData(false);
      
      this.currentTabIndex = savedIndex;
    }
  }
}
</script>

<style lang="scss" scoped>
.search-page {
  padding: 16px;
  min-height: 100vh;
  .search-input {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px;
    border-radius: 16px;

    .input {
      padding: 0;
    }
  }
  .search-empty {
    margin-top: 100px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-direction: column;

    .search-empty-text {
      margin-top: 16px;
      font-size: 14px;
      color: #999999;
    }
  }
  .share-link-list {
    height: 100vh;
  }
  .answer-list {
    height: 100vh;
  }
  .question-list {
    height: 100vh;
  }
  .user-list {
    height: 100vh;
  }
  .empty-state {
    padding: 24px;
    text-align: center;
    color: #999;
    font-size: 14px;
  }
}
</style>
