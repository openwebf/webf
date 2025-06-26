<template>
  <div class="notification-page">
    <template v-if="isLoading">
      <notification-skeleton />
    </template>
    <template v-else>
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
    </template>
    <flutter-cupertino-loading ref="loading" />
  </div>
</template>

<script>
import NotificationSkeleton from '@/Components/skeleton/NotificationSkeleton.vue';

import { useUserStore } from '@/stores/userStore'
import { api } from '@/api';

export default {
  name: 'NotificationPage',
  components: {
    NotificationSkeleton,
  },
  data() {
    return {
      notifications: [],
      page: 1,
      isLoading: true,
    }
  },
  setup() {
    const userStore = useUserStore();
    return {
      userStore,
    }
  },
  async mounted() {
    await this.onScreen();
  },
  methods: {
    async onScreen() {
      this.isLoading = true;
      await this.fetchNotifications();
      this.isLoading = false;
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
      console.log('userId', userId);
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
        color: var(--link-color);
        font-size: 14px;
        margin-bottom: 8px;
      }

      .notification-content {
        font-size: 14px;
        line-height: 1.5;

        .user-name {
          color: var(--link-color);
          font-weight: 500;
        }

        .share-title {
          color: var(--link-color);
          display: block;
          margin-top: 4px;
        }
      }

      .action {
        color: var(--link-color);
        font-size: 14px;
      }

      .time {
        color: var(--link-color);
        font-size: 14px;
      }
    }
  }

  .empty-state {
    padding: 24px;
    text-align: center;
    color: var(--font-color-secondary);
    font-size: 14px;
  }
}
</style>