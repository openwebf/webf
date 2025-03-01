<template>
  <div class="question-page">
      <webf-listview class="question-page-listview">
          <!-- 问题区域 -->
          <div class="question-section">
              <!-- 问题标题 -->
              <text class="title">{{ question.title }}</text>

              <!-- 问题内容 -->
              <text v-if="question.content" class="content">{{ question.content }}</text>

              <!-- 提问者信息 -->
              <div class="user-info">
                  <div class="left">
                      <img class="avatar" :src="question.user.avatar" mode="aspectFill" />
                      <div class="user-meta">
                          <text class="name">{{ question.user.name }}</text>
                          <text class="desc">{{ userDesc }}</text>
                      </div>
                  </div>
              </div>

              <!-- 底部操作栏 -->
              <div class="action-bar">
                  <div class="left-actions">
                      <div class="follow-btn">
                          <template v-if="question.followed">
                              <flutter-cupertino-icon type="heart_fill" class="icon" />
                              <text class="text">已关注</text>
                          </template>
                          <template v-else>
                              <flutter-cupertino-icon type="heart" class="icon" />
                              <text class="text">关注问题 {{ question.followersCount }}</text>
                          </template>
                      </div>
                      <div class="invite-btn">
                          <flutter-cupertino-icon type="chat_bubble" class="icon" />
                          <text class="text">邀请回答</text>
                      </div>
                  </div>
                  <flutter-cupertino-button type="primary" class="answer-btn" @click="goToQuestionPage">
                      回答
                  </flutter-cupertino-button>
                  <flutter-cupertino-icon type="share" class="share-icon" />
              </div>
          </div>
          <div class="view-all-btn" @click="goToQuestionPage">查看全部 {{ question.answersCount }} 个回答</div>
          <CommentsSection :comments="answers" :total="question.answersCount" />
      </webf-listview>
  </div>
</template>

<script>
import { api } from '@/api';
import CommentsSection from '@/Components/comment/CommentsSection.vue';
export default {
  name: 'QuestionPage',
  components: {
      CommentsSection,
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

      .question-section {
          padding-bottom: 16px;
          border-bottom: 1px solid var(--border-secondary);

          .title {
              font-size: 17px;
              font-weight: 500;
              color: #333333;
              margin-bottom: 8px;
          }

          .content {
              font-size: 15px;
              color: #666666;
              margin-bottom: 16px;
          }

          .user-info {
              display: flex;
              flex-direction: row;
              justify-content: space-between;
              align-items: center;

              .left {
                  display: flex;
                  flex-direction: row;
                  align-items: center;
              }

              .avatar {
                  width: 32px;
                  height: 32px;
                  border-radius: 16px;
                  margin-right: 8px;
              }

              .user-meta {
                  .name {
                      font-size: 14px;
                      color: #333333;
                      margin-bottom: 2px;
                  }

                  .desc {
                      font-size: 12px;
                      color: #999999;
                  }
              }
          }

          .action-bar {
              margin-top: 16px;
              height: 32px;
              display: flex;
              flex-direction: row;
              justify-content: space-between;
              align-items: center;

              .left-actions {
                  display: flex;
                  flex-direction: row;
                  align-items: center;

                  .follow-btn,
                  .invite-btn {
                      display: flex;
                      flex-direction: row;
                      align-items: center;
                      margin-right: 16px;

                      .icon {
                          width: 16px;
                          height: 16px;
                          margin-right: 4px;
                      }

                      .text {
                          font-size: 14px;
                          color: #666666;
                      }
                  }
              }

              .answer-btn {
                  width: 70px;
                  height: 32px;
                  border-radius: 16px;
                  font-size: 14px;
                  color: var(--font-color-primary);
              }
          }
      }

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
