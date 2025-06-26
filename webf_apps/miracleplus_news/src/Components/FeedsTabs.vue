<template>
    <flutter-cupertino-tab @change="onTabChange">
        <flutter-cupertino-tab-item 
            v-for="tab in tabs" 
            :key="tab.id" 
            :title="tab.title"
        >
            <slot :name="tab.id"></slot>
        </flutter-cupertino-tab-item>
    </flutter-cupertino-tab>
</template>
<script>
export default {
    name: 'FeedsTabs',
    props: {
        tabs: {
            type: Array,
            default: () => [
                { id: 'hot', title: '热门' },
                { id: 'latest', title: '最新' },
                { id: 'discussion', title: '讨论' },
                { id: 'news', title: '新闻' },
                { id: 'academic', title: '学术' },
                { id: 'product', title: '产品' }
            ]
        }
    },
}
</script>