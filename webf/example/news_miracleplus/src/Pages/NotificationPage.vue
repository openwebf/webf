<template>
  <div class="notification-page" @onscreen="onScreen" @offscreen="offScreen">
    <div class="page-title">通知</div>
    <webf-listview class="notification-list">
      <div v-for="notification in notifications" :key="notification.id" class="notification-item">
        <div class="notification-time">{{ formatTime(notification.created_at) }}</div>
        <div class="notification-content">
          <span class="user-name" @click="handleUserClick(notification.links.user.id)">{{ notification.links.user.name }}</span>
          回复了你关注的分享
          <span class="share-title" @click="handleShareClick(notification.links.share_link.id)">{{ notification.links.share_link.name }}</span>
        </div>
      </div>
    </webf-listview>
    <flutter-cupertino-loading ref="loading" />
  </div>
</template>

<script>
import { useUserStore } from '@/stores/userStore'
import { api } from '@/api';

export default {
  name: 'NotificationPage',
  data() {
    return {
      notifications: [],
      page: 1,
    }
  },
  setup() {
    const userStore = useUserStore();
    return {
      userStore,
    }
  },
  methods: {
    async onScreen() {
      this.$refs.loading.show({
        text: '加载中'
      });
      await this.fetchNotifications();
      this.$refs.loading.hide();
    },
    async fetchNotifications() {
      try {
        const res = await api.auth.getUserNotifications({
          page: this.page
        });
        this.notifications = res?.data?.notifications || [];
      } catch (error) {
        console.error('Failed to fetch notifications:', error);
      }
    },
    formatTime(timeStr) {
      const date = new Date(timeStr);
      return `${date.getFullYear()}/${String(date.getMonth() + 1).padStart(2, '0')}/${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
    },
    handleUserClick(userId) {
      window.webf.hybridHistory.pushState({
        id: userId
      }, '/user');
    },
    handleShareClick(shareId) {
      console.log('shareId', shareId);
      window.webf.hybridHistory.pushState({
        id: shareId
      }, '/share_link');
    }
  }
}
</script>

<style lang="scss" scoped>
.notification-page {
  background: var(--background-color);
  min-height: 100vh;
  padding: 16px;

  .page-title {
    font-size: 24px;
    font-weight: bold;
    margin-bottom: 16px;
  }

  .notification-list {
    height: 100vh;

    .notification-item {
      background: var(--background-primary);
      border-radius: 8px;
      padding: 16px;
      margin-bottom: 12px;

      .notification-time {
        color: #999;
        font-size: 14px;
        margin-bottom: 8px;
      }

      .notification-content {
        font-size: 14px;
        line-height: 1.5;

        .user-name {
          color: #007AFF;
          font-weight: 500;
        }

        .share-title {
          color: #007AFF;
          display: block;
          margin-top: 4px;
        }
      }
    }
  }
}
</style>