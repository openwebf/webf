<template>
    <div class="post-header">
      <div class="author-info">
        <img :src="formattedAvatar" class="avatar" />
        <div class="author-details">
          <div class="name">{{ user?.name }}</div>
          <div class="time">2小时前</div>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  import formatAvatar from '@/utils/formatAvatar';

  export default {
    name: 'PostHeader',
    props: {
      user: {
        type: Object,
        required: true
      }
    },
    data() {
      return {
        showBtn: true
      }
    },
    computed: {
      formattedAvatar() {
        return formatAvatar(this.user.avatar);
      }
    },
    methods: {
      handleFollow() {
        this.showBtn = false;
      },
      handleUnfollow() {
        this.showBtn = true;
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
      width: 100px;
      height: 32px;
      text-align: center;
      border-radius: 8px;
      color: var(--button-primary-text, #fff); 
    }
  }
  </style>