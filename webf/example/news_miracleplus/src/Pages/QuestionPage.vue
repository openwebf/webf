<template>
    <div class="question-page" @onscreen="onScreen" @offscreen="offScreen">
        <webf-listview class="question-page-listview">
            <QuestionSection 
                :question="question"
                @answer="handleAnswer"
                @follow="handleFollow"
                @invite="handleInvite"
            />
            <CommentsSection :comments="answers" :total="question.answersCount" />

            <!-- <CommentInput @submit="handleCommentSubmit" /> -->
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
import AlertDialog from '@/Components/AlertDialog.vue';
import InviteModal from '@/Components/post/InviteModal.vue';
// import CommentInput from '@/Components/comment/CommentInput.vue';
export default {
    name: 'QuestionPage',
    components: {
        CommentsSection,
        QuestionSection,
        AlertDialog,
        InviteModal,
        // CommentInput
    },
    data() {
        return {
            id: '',
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
    methods: {
        async onScreen() {
            this.$refs.loading.show({
                text: '加载中'
            });
            this.id = window.webf.hybridHistory.state.id;
            await this.fetchQuestionDetail();
            this.$refs.loading.hide();
            await this.fetchAnswers();
            api.question.viewCount({ id: this.id });
        },
        async offScreen() {
            this.id = '';
            this.question = {
                user: {
                    avatar: '',
                    name: '',
                },
            };
            this.answers = [];
        },
        async fetchQuestionDetail() {
            try {
                const res = await api.question.getDetail(this.id);
                this.question = res.data.question;
            } catch (error) {
                console.error('error: ', error);
            }
        },
        async fetchAnswers() {
            const answers = this.question.answers;
            for (const answer of answers) {
                const subRes = await api.comments.getList({ resourceId: answer.id, resourceType: 'Answer' });
                answer.subComments = subRes.data.comments;
            }
            this.answers = answers;
        },
        handleCommentSubmit(comment) {
            console.log('comment: ', comment);
        },
        handleAnswer() {
        },
        async handleFollow(newFollowState) {
            console.log('handleFollow', newFollowState);
            console.log('handleFollow', this.question.id);
            try {
                let res;
                if (newFollowState) {
                    res = await api.question.follow(this.question.id);
                } else {
                    res = await api.question.unfollow(this.question.id);
                }
                if (res.success) {
                    await this.fetchQuestionDetail();
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
                    id: this.id,
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
    }
}
</style>
