<template>
  <div class="comment-input">
    <flutter-cupertino-textarea
      class="input" 
      placeholder="分享、交流你的看法..."
      autoSize="true"
      minLines="3"
      maxLength="1000"
      :val="content"
      @input="handleInput"
    />
    <flutter-cupertino-button type="primary" @click="handleSubmit" class="send-button">
      发送
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
      this.$emit('submit', this.content);
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
  flex-direction: column;
  align-items: center;
  padding-bottom: 30px;
  width: 100%;

  .input {
    border-radius: 8px;
    width: 100%;
    border: 1px solid #ccc;
  }

  .send-button {
    margin-top: 12px;
    align-self: flex-end;
    width: 25%;
    padding: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    border-radius: 8px;
    color: var(--button-primary-text);
  }
}
</style>