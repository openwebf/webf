<template>
  <div class="question-page">
      <webf-listview class="question-page-listview">
          <QuestionSection 
              :question="question"
              @answer="goToQuestionPage"
          />
          <div class="view-all-btn" @click="goToQuestionPage">查看全部 {{ question.answersCount }} 个回答</div>
          <CommentsSection :comments="answers" :total="question.answersCount" />
      </webf-listview>
  </div>
</template>

<script>
import { api } from '@/api';
import CommentsSection from '@/Components/comment/CommentsSection.vue';
import QuestionSection from '@/Components/question/QuestionSection.vue';

export default {
  name: 'AnswerPage',
  components: {
      CommentsSection,
      QuestionSection
  },
  data() {
      return {
          question: {
              user: {
                  avatar: '',
                  name: '',
              },
              title: '',
              content: '',
              followersCount: 0,
              answersCount: 0,
              answers: [],
          },
          answers: [],
      }
  },
  computed: {
      userDesc() {
          const user = this.question.user || {};
          const parts = [];
          if (user.company) parts.push(user.company);
          if (user.jobTitle) parts.push(user.jobTitle);
          return parts.join(' · ');
      }
  },
  async mounted() {
      const { id, questionId } = window.webf.hybridHistory.state;
      const res = await api.question.getDetail(questionId);
      this.question = res.data.question;
      console.log('question: ', this.question);
      const currentAnswer = await this.fetchAnswer(id);
      this.answers = [currentAnswer];
  },
  methods: {
      formatUserDesc(user) {
          const parts = [];
          if (user.company) parts.push(user.company);
          if (user.jobTitle) parts.push(user.jobTitle);
          return parts.join(' · ');
      },
      parseContent(content) {
          try {
              const parsed = JSON.parse(content);
              // 简单处理，只提取文本内容
              return parsed.map(block => {
                  if (block.type === 'paragraph') {
                      return block.children.map(child => child.text).join('');
                  }
                  return '';
              }).join('\n');
          } catch (e) {
              return content;
          }
      },
      async fetchAnswer(id) {
        const res = await api.question.getAnswerDetail(id);
        const answer = res.data.answer;
        const subRes = await api.comments.getList({ resourceId: answer.id, resourceType: 'Answer' });
        answer.subComments = subRes.data.comments;
        return answer;
      },
      goToQuestionPage() {
        const { questionId } = window.webf.hybridHistory.state;
        window.webf.hybridHistory.pushState({
          id: questionId,
        }, '/question');
      }
  }
}
</script>

<style lang="scss" scoped>
.question-page {
  background: var(--background-primary);
  min-height: 100vh;
  padding: 16px;


  .question-page-listview {
      height: 100vh;

      .view-all-btn {
        text-align: center;
        font-size: 14px;
        color: #666666;
        padding-top: 16px;
        padding-bottom: 16px;
        border-bottom: 1px solid var(--border-secondary);
      }
  }
}
</style>
