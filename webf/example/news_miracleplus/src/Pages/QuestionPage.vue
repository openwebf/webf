<template>
    <BaseQuestionPage page-type="question" @answer="handleAnswer">
        <template #answer-input="{ handleAnswerSubmit }">
            <CommentInput ref="commentInput" @submit="handleAnswerSubmit" />
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
    methods: {
        handleAnswer() {
            this.$nextTick(() => {
                const element = this.$refs.commentInput.$el;
                const rect = element.getBoundingClientRect();
                console.log('rect: ', rect);
                const scrollTop = document.documentElement.scrollTop;
                console.log('scrollTop: ', scrollTop);
                window.scrollTo({
                    top: scrollTop + rect.top - 100,
                    behavior: 'smooth'
                });
            }
            );
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
