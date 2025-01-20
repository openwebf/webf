<template>
  <div id="main">
    <webf-listview id="list">
      <view-card title="TodoMVC" :src="require('@/assets/todomvc.png')" href="/todomvc"
      desc="The TodoMVC demo built in Vue.js"></view-card>
    </webf-listview>
  </div>

</template>

<script>
import ViewCard from '@/Components/ViewCard.vue';

export default {
  components: {
    ViewCard,
  },
  data: () => {
    return {
      show: true,
    }
  },
  methods: {
    handleArticleClick() {
      window.webf.hybridHistory.pushState({}, '/activity')
    },
    handleSelectChange(e) {
      const option = this.selectOptions.find(op => op.value === e.detail);
      this.selectValueName = option.name;
    },
    handleBuy: async function (data) {
      this.activeValue = data;
      await this.$refs['bottom-sheet'].showBottomSheet_async();
    }
  }
}
</script>


<style scoped>
#main {
  background-color: rgb(36, 30, 47);
}

#list {
  height: 100vh;
  width: 100vw;
}
</style>