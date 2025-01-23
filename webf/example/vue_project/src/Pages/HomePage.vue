<template>
  <div id="main">
    <webf-listview id="list">
      <div style="display: flex; flex-direction: row; flex-wrap: wrap;">
        <view-card title="TodoMVC" :src="require('@/assets/todomvc.png')" href="/todomvc"
          desc="The TodoMVC demo built in Vue.js"></view-card>
        <view-card title="PositionedLayout" :src="require('@/assets/positioned_layout.png')" href="/positioned_layout"
          desc="CSS Positioning with Examples"></view-card>
      </div>
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