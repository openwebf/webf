<template>
  <div class="question-page" @onscreen="onScreen" @offscreen="offScreen" repaint-boundary>
    <template v-if="loading">
      <question-skeleton />
    </template>
    <webf-listview class="question-page-listview" @refresh="onRefresh">
      <QuestionHeader :question="question" @answer="handleAnswer" @follow="handleFollow" @invite="handleInvite" @share="handleShare" />

      <slot name="view-all" :answers-count="question.answersCount" />

      <CommentsSection :comments="allAnswers" :total="question.answersCount" />

      <slot name="answer-input" :handle-answer-submit="handleAnswerSubmit" />
    </webf-listview>

    <alert-dialog ref="alertRef" />
    <flutter-cupertino-loading ref="loading" />
    <flutter-cupertino-toast ref="toast" />
    <InviteModal :show="showInviteModal" :loading="loadingUsers" :users="invitedUsers" :search-keyword="searchKeyword"
      @close="onInviteModalClose" @search="handleSearchInput" @invite="handleInviteUser" />
  </div>
</template>

<script>
import { api } from '@/api';
import { formatToRichContent } from '@/utils/parseRichContent';
import QuestionHeader from './QuestionHeader.vue';
import CommentsSection from '../comment/CommentsSection.vue';
import InviteModal from '../post/InviteModal.vue';
import AlertDialog from '../AlertDialog.vue';
import QuestionSkeleton from '@/Components/skeleton/QuestionSkeleton.vue';

export default {
  name: 'BaseQuestionPage',
  components: {
    QuestionHeader,
    CommentsSection,
    InviteModal,
    AlertDialog,
    QuestionSkeleton,
  },

  props: {
    pageType: {
      type: String,
      required: true,
      validator: (value) => ['question', 'answer'].includes(value)
    },
  },

  data() {
    return {
      singleAnswerId: '',
      questionId: '',
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
      allAnswers: [],
      showInviteModal: false,
      loadingUsers: false,
      invitedUsers: [],
      searchKeyword: '',
      loading: true,
    }
  },

  provide() {
    return {
      update: this.updateAnswer,
      addReply: this.addAnswerReply,
    }
  },

  methods: {
    async onScreen() {
      this.loading = true;

      try {
        if (this.pageType === 'answer') {
          const { id, questionId } = window.webf.hybridHistory.state;
          this.singleAnswerId = id;
          this.questionId = questionId;
          await this.fetchQuestionDetail(this.questionId);
          this.loading = false;
          const currentAnswer = await this.fetchAnswer(this.singleAnswerId);
          this.allAnswers = [currentAnswer];
        } else {
          const { id } = window.webf.hybridHistory.state;
          this.questionId = id;
          await this.fetchQuestionDetail(this.questionId);
          this.loading = false;
          await this.fetchAnswers();
        }
        api.question.viewCount({
          id: this.questionId,
          modelType: this.pageType === 'answer' ? 'Answer' : 'Question'
        }).catch(() => {
          console.warn('View count update failed');
        });
      } catch (error) {
        this.$refs.alertRef.show({
          message: '加载失败，请稍后重试'
        });
      } finally {
        if (this.loading) {
          this.loading = false;
        }
      }
    },

    async offScreen() {
      this.loading = true;
      this.singleAnswerId = '';
      this.questionId = '';
      this.question = {
        user: { avatar: '', name: '' },
      };
      this.allAnswers = [];
      this.invitedUsers = [];
      this.searchKeyword = '';
      this.loadingUsers = false;
    },

    async fetchQuestionDetail(id) {
      try {
        const res = await api.question.getDetail(id);
        this.question = res.data.question;
      } catch (error) {
        console.error('error: ', error);
      }
    },

    // TODO: 回答完后，需要刷新回答
    async fetchAnswers() {
      const answers = this.question.answers;
      for (const answer of answers) {
        const subRes = await api.comments.getList({
          resourceId: answer.id,
          resourceType: 'Answer'
        });
        answer.subComments = subRes.data.comments;
      }
      this.allAnswers = answers;
    },

    async fetchAnswer(id) {
      const res = await api.question.getAnswerDetail(id);
      const answer = res.data.answer;
      const subRes = await api.comments.getList({
        resourceId: answer.id,
        resourceType: 'Answer'
      });
      answer.subComments = subRes.data.comments;
      return answer;
    },

    handleAnswer() {
      this.$emit('answer');
    },

    async handleShare() {
        return new Promise((resolve) => {
            requestAnimationFrame(async () => {
                try {
                    const element = document.getElementsByClassName('question-page')[0];
                    if (!element) {
                        throw new Error('question page element not found');
                    }
                    const blob = await element.toBlob(1.0);
                    
                    const arrayBuffer = await blob.arrayBuffer();
                    const uint8Array = new Uint8Array(arrayBuffer); 
                    const array = Array.from(uint8Array);
                    
                    // Call native share through WebF method channel
                    const result = await window.webf.methodChannel.invokeMethod('share', {
                        blob: array,
                        title: this.question.title || '分享',
                        text: this.question.content || ''
                    });
                    console.log('Share result:', result);
                    resolve(result);
                } catch (error) {
                    console.error('Share failed:', error);
                    this.$refs.alertRef.show({
                        message: '分享失败，请稍后重试'
                    });
                    resolve();
                }
            });
        });
    },

    async handleFollow(newFollowState) {
      try {
        let res;
        if (newFollowState) {
          res = await api.question.follow(this.question.id);
        } else {
          res = await api.question.unfollow(this.question.id);
        }
        if (res.success) {
          await this.fetchQuestionDetail(this.questionId);
        }
      } catch (error) {
        console.error('error: ', error);
      }
    },
    async handleInvite() {
      this.showInviteModal = true;
      await this.fetchInvitedUsers();
    },
    async fetchInvitedUsers() {
      try {
        this.loadingUsers = true;
        const res = await api.user.getInvitedUsers({
          resource: 'Question',
          id: this.questionId,
          search: this.searchKeyword
        });
        this.invitedUsers = res.data.users;
      } catch (error) {
        this.$refs.alertRef.show({
          message: '获取用户列表失败'
        });
      } finally {
        this.loadingUsers = false;
      }
    },
    onInviteModalClose() {
      this.showInviteModal = false;
      this.searchKeyword = '';
      this.invitedUsers = [];
    },
    handleSearchInput(e) {
      this.searchKeyword = e.detail;
      if (this.searchTimeout) {
        clearTimeout(this.searchTimeout);
      }

      this.searchTimeout = setTimeout(() => {
        this.fetchInvitedUsers();
      }, 300);
    },
    async handleInviteUser(user) {
      try {
        this.$refs.loading.show({
          text: '邀请中'
        });

        const res = await api.user.invite({
          resourceType: 'question',
          resourceId: this.questionId,
          userId: user.id
        });
        console.log('invite res: ', res);

        if (res.success) {
          this.$refs.toast.show({
            type: 'success',
            content: `已成功邀请 ${user.name}`
          });
          await this.fetchInvitedUsers();
        }
      } catch (error) {
        console.error('invite error: ', error);
        this.$refs.alertRef.show({
          message: '邀请用户失败'
        });
      } finally {
        this.$refs.loading.hide();
      }
    },
    async handleAnswerSubmit(content) {
      const richContent = formatToRichContent(content);
      const answerRes = await api.question.answer({
        questionId: this.questionId,
        content: richContent,
      });
      if (answerRes.success) {
        this.$refs.toast.show({
          type: 'success',
          content: '回答成功',
        });
        await this.fetchQuestionDetail(this.questionId);
        await this.fetchAnswers();
      }
    },
    updateAnswer(answerId, updatedData) {
      const updateAnswerInList = (answers) => {
        for (let answer of answers) {
          if (answer.id === answerId) {
            Object.assign(answer, updatedData);
            return true;
          }
          if (answer.subComments?.length) {
            if (updateAnswerInList(answer.subComments)) {
              return true;
            }
          }
        }
        return false;
      };

      updateAnswerInList(this.allAnswers);
    },
    addAnswerReply(parentId, replyData) {
      const addReplyToAnswer = (answers) => {
        for (let answer of answers) {
          if (answer.id === parentId) {
            if (!answer.subComments) {
              answer.subComments = [];
            }
            answer.subComments.push(replyData);
            return true;
          }
          if (answer.subComments?.length) {
            if (addReplyToAnswer(answer.subComments)) {
              return true;
            }
          }
        }
        return false;
      };

      addReplyToAnswer(this.allAnswers);
    },
    async onRefresh() {
      this.loading = true;
      try {
        await this.onScreen();
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.question-page {
  background: var(--background-primary);
  padding: 16px;

  .question-page-listview {
    height: 100vh;
  }
}
</style>