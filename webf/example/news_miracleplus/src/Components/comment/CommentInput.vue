<template>
  <div class="comment-input">
    <flutter-cupertino-input 
      class="input" 
      placeholder="分享、交流你的看法..."
      :value="content"
      @input="handleInput"
    />
    <flutter-cupertino-button type="primary" @click="handleSubmit" class="send-button">
      发送1
    </flutter-cupertino-button>
  </div>
</template>

<script>
export default {
  name: 'CommentInput',
  data() {
    return {
      content: ''
    }
  },
  methods: {
    handleSubmit() {
      console.log('111111');
      // this.$emit('submit', this.content);
      this.content = '';
    },
    handleInput(e) {
      this.content = e.detail;
    }
  }
}
</script>

<style lang="scss" scoped>
.comment-input {
  padding: 12px;
  background: white;
  display: flex;
  align-items: center;
  padding-bottom: 30px;

  .send-button {
    width: 25%;
    padding: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    border-radius: 8px;
    color: var(--button-primary-text);
  }

  .input {
    margin-right: 12px;
    border-radius: 8px;
    width: 75%;
    border: 1px solid #ccc;
  }
}
</style>