<template>
    <div class="user-card" @click="viewUserDetail">
      <img :src="user.avatar" class="avatar" />
      <div class="user-info">
        <div class="name">{{ user.name }}</div>
        <div class="title">{{ formattedTitle }}</div>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'UserCard',
    props: {
      user: {
        type: Object,
        required: true,
        validator: (user) => {
          return user.name && user.avatar;
        }
      }
    },
    computed: {
      formattedTitle() {
        const parts = [];
        if (this.user.company) parts.push(this.user.company);
        if (this.user.job_title) parts.push(this.user.job_title);
        return parts.join(' · ') || '';
      }
    },
    methods: {
      viewUserDetail() {
        window.webf.hybridHistory.pushState({ id: this.user.id }, '/user');
      }
    }
  }
  </script>
  
  <style lang="scss" scoped>
  .user-card {
    display: flex;
    align-items: center;
    padding: 12px;
    border-bottom: 1px solid #EEEEEE;
    background: var(--background-color);
    // border-radius: 8px;
  
    .avatar {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      object-fit: cover;
      margin-right: 12px;
    }
  
    .user-info {
      flex: 1;
      overflow: hidden;
  
      .name {
        font-size: 16px;
        font-weight: 500;
        color: #333;
        margin-bottom: 4px;
        // 防止过长的名字溢出
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
  
      .title {
        font-size: 14px;
        color: #666;
        // 防止过长的职位信息溢出
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
    }
  }
  </style>