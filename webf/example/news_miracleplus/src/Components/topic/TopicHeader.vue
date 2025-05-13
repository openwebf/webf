<template>
    <div class="topic-header">
        <div class="title">{{ topic.title }}</div>
        <div class="stats-section">
            <div class="stats">{{ topic.topicablesCount }}个相关讨论</div>
            <flutter-cupertino-button variant="filled" class="follow-btn" @click="handleFollow">
                + 关注
            </flutter-cupertino-button>
        </div>
    </div>
</template>

<script>
export default {
    name: 'TopicHeader',
    props: {
        topic: {
            type: Object,
            required: true,
            default: () => ({
                id: 0,
                title: '',
                questionsCount: 0,
                topicablesCount: 0,
                followed: null
            })
        }
    },
    methods: {
        handleFollow() {
            this.$emit('follow', this.topic.id);
        }
    }
}
</script>

<style lang="scss" scoped>
.topic-header {
    background-color: var(--background-primary);
    padding: 16px;

    .title {
        font-size: 17px;
        font-weight: 600;
        color: var(--font-color-primary);
        margin-bottom: 8px;
    }

    .stats-section {
        display: flex;
        flex-direction: row;
        justify-content: space-between;
        align-items: center;

        .stats {
            font-size: 14px;
            color: var(--font-color-secondary);
        }

        .follow-btn {
            width: 100px;
            height: 32px;
            color: var(--button-primary-text);
        }
    }
}
</style>