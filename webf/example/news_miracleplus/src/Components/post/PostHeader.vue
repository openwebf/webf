<template>
    <div class="post-header">
      <div class="author-info">
        <img :src="user?.avatar" class="avatar" />
        <div class="author-details">
          <div class="name">{{ user?.name }}</div>
          <div class="time">2小时前</div>
        </div>
      </div>
      <flutter-cupertino-button class="follow-btn">
        <div>+ 关注</div>
      </flutter-cupertino-button>
    </div>
  </template>
  
  <script>
  export default {
    name: 'PostHeader',
    props: {
      user: {
        type: Object,
        required: true
      }
    }
  }
  </script>
  
  <style lang="scss" scoped>
  .post-header {
    display: flex;
    justify-content: space-between;
    align-items: center;

    .author-info {
      display: flex;
      align-items: center;
      gap: 12px;
      
      .avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        margin-right: 10px;
      }

      .author-details {
        .name {
          font-size: 16px;
          font-weight: 600;
        }
        .time {
          font-size: 12px;
          color: #999;
        }
      }
    }
    .follow-btn {
      text-align: center;
      border-radius: 8px;
      color: var(--button-primary-text, #fff); 
    }
  }
  </style>