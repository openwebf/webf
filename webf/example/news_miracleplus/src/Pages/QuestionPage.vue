<template>
    <div class="question-page">
        <webf-listview class="question-page-listview">
            <QuestionSection 
                :question="question"
                @answer="handleAnswer"
            />
            <CommentsSection :comments="answers" :total="question.answersCount" />

            <!-- <CommentInput @submit="handleCommentSubmit" /> -->
        </webf-listview>
        <flutter-cupertino-loading ref="loading" />
    </div>
</template>

<script>
import { api } from '@/api';
import CommentsSection from '@/Components/comment/CommentsSection.vue';
import QuestionSection from '@/Components/question/QuestionSection.vue';
// import CommentInput from '@/Components/comment/CommentInput.vue';
export default {
    name: 'QuestionPage',
    components: {
        CommentsSection,
        QuestionSection,
        // CommentInput
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
    async mounted() {
        this.$refs.loading.show({
            text: '加载中...'
        });
        const id = window.webf.hybridHistory.state.id;
        const res = await api.question.getDetail(id);
        this.question = res.data.question;
        this.answers = await this.fetchAnswers();
        this.$refs.loading.hide();
        api.news.viewCount({ id, modelType: 'Question' });
    },
    methods: {
        async fetchAnswers() {
            const answers = this.question.answers;
            for (const answer of answers) {
                const subRes = await api.comments.getList({ resourceId: answer.id, resourceType: 'Answer' });
                answer.subComments = subRes.data.comments;
            }
            return answers;
        },
        handleCommentSubmit(comment) {
            console.log('comment: ', comment);
        },
        handleAnswer() {
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
    }
}
</style>
