<template>
    <div class="question-page" @onscreen="onScreen" @offscreen="offScreen">
        <webf-listview class="question-page-listview">
            <QuestionSection
                :question="question"
                @answer="goToQuestionPage"
                @follow="handleFollow"
                @invite="handleInvite"
            />
            <div class="view-all-btn" @click="goToQuestionPage">查看全部 {{ question.answersCount }} 个回答</div>
            <CommentsSection :comments="answers" :total="question.answersCount" />
        </webf-listview>
        <alert-dialog ref="alertRef" />
        <flutter-cupertino-loading ref="loading" />
        <flutter-cupertino-toast ref="toast" />
        <InviteModal
            :show="showInviteModal"
            :loading="loadingUsers"
            :users="invitedUsers"
            :search-keyword="searchKeyword"
            @close="onInviteModalClose"
            @search="handleSearchInput"
            @invite="handleInviteUser"
        />
    </div>
</template>

<script>
import { api } from '@/api';
import CommentsSection from '@/Components/comment/CommentsSection.vue';
import QuestionSection from '@/Components/question/QuestionSection.vue';
import InviteModal from '@/Components/post/InviteModal.vue';
import AlertDialog from '@/Components/AlertDialog.vue';

export default {
    name: 'AnswerPage',
    components: {
        CommentsSection,
        QuestionSection,
        InviteModal,
        AlertDialog
    },
    data() {
        return {
            id: '',
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
            answers: [],
            showInviteModal: false,
            loadingUsers: false,
            invitedUsers: [],
            searchKeyword: '',
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
    methods: {
        async onScreen() {
            this.$refs.loading.show({
                text: '加载中'
            });
            const { id, questionId } = window.webf.hybridHistory.state;
            this.id = id;
            this.questionId = questionId;
            await this.fetchQuestionDetail(questionId);
            const currentAnswer = await this.fetchAnswer(id);
            this.answers = [currentAnswer];
            this.$refs.loading.hide();
            api.news.viewCount({ id, modelType: 'Answer' });
        },
        async offScreen() {
            this.question = {
                user: {
                    avatar: '',
                    name: '',
                },
            };
            this.answers = [];
        },
        async fetchQuestionDetail(id) {
            try {
                const res = await api.question.getDetail(id);
                this.question = res.data.question;
            } catch (error) {
                console.error('error: ', error);
            }
        },
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
        },
        async handleFollow(newFollowState) {
            try {
                console.log('handleFollow', newFollowState);
                console.log('handleFollow', this.question.id);
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
            console.log('invite clicked');
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
                    resourceId: this.id,
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
        onInviteModalClose() {
            this.showInviteModal = false;
            this.searchKeyword = '';
            this.invitedUsers = [];
        },
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
