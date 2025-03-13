<template>
  <div @onscreen="onScreen" @offscreen="offScreen">
    <BaseQuestionPage
      page-type="answer"
      :question-id="questionId"
      :single-answer-id="answerId"
      @answer="goToQuestionPage"
    >
      <template #view-all="{ answersCount }">
        <div class="view-all-btn" @click="goToQuestionPage">
          查看全部 {{ answersCount }} 个回答
        </div>
      </template>
    </BaseQuestionPage>
  </div>
</template>

<script>
import BaseQuestionPage from '@/Components/question/BaseQuestionPage.vue';

export default {
  name: 'AnswerPage',
  components: {
    BaseQuestionPage
  },
  data() {
    return {
      answerId: '',
      questionId: '',
    }
  },
  methods: {
    async onScreen() {
      const { id, questionId } = window.webf.hybridHistory.state;
      this.answerId = id;
      this.questionId = questionId;
    },
    async offScreen() {
      this.answerId = '';
      this.questionId = '';
    },
    goToQuestionPage() {
      window.webf.hybridHistory.pushState(
        { id: this.questionId },
        '/question'
      );
    }
  }
}
</script>

<style lang="scss" scoped>
.view-all-btn {
  text-align: center;
  font-size: 14px;
  color: #666666;
  padding: 16px 0;
  border-bottom: 1px solid var(--border-secondary);
}
</style>
