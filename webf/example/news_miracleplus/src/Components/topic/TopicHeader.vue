<template>
    <div class="topic-header">
        <div class="title">{{ topic.title }}</div>
        <div class="stats-section">
            <div class="stats">{{ topic.topicablesCount }}个相关讨论</div>
            <flutter-cupertino-button type="primary" class="follow-btn" @click="handleFollow">
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
    background-color: #FFFFFF;
    padding: 16px;

    .title {
        font-size: 17px;
        font-weight: 600;
        color: #333333;
        margin-bottom: 8px;
    }

    .stats-section {
        display: flex;
        flex-direction: row;
        justify-content: space-between;
        align-items: center;

        .stats {
            font-size: 14px;
            color: #666666;
        }

        .follow-btn {
            width: 100px;
            height: 32px;
            color: var(--font-color-primary);
        }
    }
}
</style>