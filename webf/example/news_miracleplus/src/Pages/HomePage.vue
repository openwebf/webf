<template>
  <div id="main">
    <feeds-tabs :tabs="tabsConfig">
        <!-- 热门标签页内容 -->
        <template #hot>
            <div>热门内容列表</div>
        </template>
        
        <!-- 最新标签页内容 -->
        <template #latest>
            <div>最新内容列表</div>
        </template>
        
        <!-- 讨论标签页内容 -->
        <template #discussion>
            <div>讨论内容列表</div>
        </template>
        
        <!-- 新闻标签页内容 -->
        <template #news>
            <div>新闻内容列表</div>
        </template>
        
        <!-- 学术标签页内容 -->
        <template #academic>
            <div>学术内容列表</div>
        </template>
        
        <!-- 产品标签页内容 -->
        <template #product>
            <div>产品内容列表</div>
        </template>
    </feeds-tabs>
  </div>

</template>

<script>
import FeedsTabs from "@/Components/FeedsTabs.vue";

export default {
  components: {
    FeedsTabs,
  },
  mounted() {
  },
  data: () => {
    return {
      tabsConfig: [
        { id: 'hot', title: '热门' },
        { id: 'latest', title: '最新' },
        { id: 'discussion', title: '讨论' },
        { id: 'news', title: '新闻' },
        { id: 'academic', title: '学术' },
        { id: 'product', title: '产品' }
      ],
      show: true,
    }
  },
  methods: {
  }
}
</script>


<style scoped>
#list {
  padding: 10px 0;
  height: 100vh;
  width: 100vw;
}
</style>