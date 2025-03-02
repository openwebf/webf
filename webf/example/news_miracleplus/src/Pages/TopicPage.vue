<template>
    <div class="topic-page">
        <webf-listview class="topic-page-listview">
            <TopicHeader 
                :topic="topic"
                @follow="handleFollow"
            />
            <div v-for="item in feeds" :key="item.id">
                <feed-card :item="item"></feed-card>
            </div>
        </webf-listview>
    </div>
</template>

<script>
import TopicHeader from '@/Components/topic/TopicHeader.vue';
import FeedCard from '@/Components/topic/FeedCard.vue';
import { api } from '@/api';
export default {
    name: 'TopicPage',
    components: {
        TopicHeader,
        FeedCard
    },
    data() {
        return {
            topic: {
                id: 0,
                title: '',
                questionsCount: 0,
                topicablesCount: 0,
                followed: null
            },
            feeds: []
        }
    },
    async mounted() {
        const id = window.webf.hybridHistory.state.id;
        const res = await api.topic.getDetail(id);
        this.topic = res.data.topic;
        this.feeds = res.data.feeds;
    },
    methods: {
        handleFollow(topicId) {
            // 处理关注/取消关注逻辑
            console.log('Follow topic:', topicId);
        }
    }
}
</script>

<style lang="scss" scoped>
.topic-page {
    background: var(--background-primary);
    min-height: 100vh;

    .topic-page-listview {
        height: 100vh;
    }
}
</style>