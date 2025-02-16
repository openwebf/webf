<template>
    <div class="comment-input">
      <flutter-cupertino-input
        class="input"
        placeholder="与他分享、交流你的看法..." 
      />
      <flutter-cupertino-button @click="handleSubmit" class="send-button">
        <div>发送</div>
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
    margin-bottom: 20px;

    .send-button {
      display: flex;
      align-items: center;
      justify-content: center;
      text-align: center;
      border-radius: 8px;
      color: var(--button-primary-text, #fff); 
    }

    .input {
      margin-right: 12px;
      border-radius: 8px;
      flex: 1;
      border: 1px solid #ccc;
    }
  }
  </style>