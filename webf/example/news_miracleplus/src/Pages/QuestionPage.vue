<template>
    <BaseQuestionPage
        :question-id="questionId"
        page-type="question" 
        @answer="handleAnswer"
    >
        <template #answer-input="{ handleAnswerSubmit }">
            <CommentInput v-if="showCommentInput" @submit="handleAnswerSubmit" />
        </template>
    </BaseQuestionPage>
</template>

<script>
import BaseQuestionPage from '@/Components/question/BaseQuestionPage.vue';
import CommentInput from '@/Components/comment/CommentInput.vue';

export default {
    name: 'QuestionPage',
    components: {
        BaseQuestionPage,
        CommentInput,
    },
    data() {
        return {
            questionId: '',
            showCommentInput: false
        }
    },
    methods: {
        handleAnswer() {
            console.log('收到啦');
            this.showCommentInput = true;
        },
        async onScreen() {
            console.log('onScreen 2', new Date().getTime());
            this.questionId = window.webf.hybridHistory.state.id;
        },
        async offScreen() {
            this.questionId = '';
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
