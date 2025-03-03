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
          <webf-listview class="answer-list">
            <answer-card v-for="answer in answers" :key="answer.id" :data="answer" />
          </webf-listview>
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
      <div class="search-empty-text">最新最有趣的科技前沿内容</div>
    </div>
    <flutter-cupertino-loading ref="loading" />
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
      users: [],
      answers: [],
      questions: [],
      shareLinks: [],
    }
  },
  methods: {
    handleSearch(event) {
      this.hasSearch = true;
      this.$refs.loading.show({
        text: '加载中'
      });
      Promise.all([
        api.search.users({ keyword: event.detail }),
        api.search.answers({ keyword: event.detail }),
        api.search.questions({ keyword: event.detail }),
        api.search.shareLinks({ keyword: event.detail })
      ]).then(([usersRes, answersRes, questionsRes, shareLinksRes]) => {
        console.log('search res', usersRes, answersRes, questionsRes, shareLinksRes);
        this.users = usersRes.data.users;
        this.answers = answersRes.data.answers;
        this.questions = questionsRes.data.questions;
        this.shareLinks = shareLinksRes.data.share_links;
        this.$refs.loading.hide();
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
}
</style>
