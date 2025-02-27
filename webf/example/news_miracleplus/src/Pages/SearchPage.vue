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
      <flutter-cupertino-segmented-tab>
        <flutter-cupertino-segmented-tab-item title="分享">
          <webf-listview class="share-link-list">
            <share-link-card v-for="shareLink in shareLinks" :key="shareLink.id" :data="shareLink" />
          </webf-listview>
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="回答">
          <div>{{ answers.length }}</div>
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="问题">
          <webf-listview class="question-list">
            <question-card v-for="question in questions" :key="question.id" :question="question" />
          </webf-listview>
        </flutter-cupertino-segmented-tab-item>
        <flutter-cupertino-segmented-tab-item title="用户">
          <webf-listview class="user-list">
            <user-card v-for="user in users" :key="user.id" :user="user" />
          </webf-listview>
        </flutter-cupertino-segmented-tab-item>
      </flutter-cupertino-segmented-tab>
    </div>
    <div v-else class="search-empty">
      <img src="@/assets/img/logo.png" alt="logo" />
    </div>
  </div>
</template>

<script>
import { api } from '@/api';
import QuestionCard from '@/Components/search/QuestionCard.vue';
import UserCard from '@/Components/search/UserCard.vue';
import ShareLinkCard from '@/Components/search/ShareLinkCard.vue';

export default {
  name: 'SearchPage',
  components: {
    QuestionCard,
    UserCard,
    ShareLinkCard,
  },
  data() {
    return {
      hasSearch: false,
      users: [],
      answers: [],
      questions: [],
      shareLinks: [],
    }
  },
  methods: {
    handleSearch(event) {
      console.log('handleSearch', event.detail);
      this.hasSearch = true;
      api.search.users({ keyword: event.detail }).then(res => {
        console.log('search res', res);
        this.users = res.data.users;
      });
      api.search.answers({ keyword: event.detail }).then(res => {
        console.log('search res', res);
        this.answers = res.data.answers;
      });
      api.search.questions({ keyword: event.detail }).then(res => {
        console.log('search res', res);
        this.questions = res.data.questions;
      });
      api.search.shareLinks({ keyword: event.detail }).then(res => {
        console.log('search res', res);
        this.shareLinks = res.data.share_links;
      });
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
  }
  .share-link-list {
    height: 100vh;
  }
  .question-list {
    height: 100vh;
  }
  .user-list {
    height: 100vh;
  }
}
</style>
