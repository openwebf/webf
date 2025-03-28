<template>
  <flutter-shimmer>
    <div class="skeleton-container">
      <!-- 页面标题骨架 -->
      <flutter-shimmer-text class="page-title" />

      <!-- 通知列表骨架 -->
      <div class="notification-list">
        <div v-for="i in 5" :key="i" class="notification-item">
          <!-- 时间骨架 -->
          <flutter-shimmer-text class="notification-time" />

          <!-- 内容骨架 -->
          <div class="notification-content">
            <div class="content-row">
              <flutter-shimmer-button class="user-name" />
              <flutter-shimmer-text class="action-text" />
            </div>
            <flutter-shimmer-text class="share-title" />
          </div>
        </div>
      </div>
    </div>
  </flutter-shimmer>
</template>

<style lang="scss" scoped>
.skeleton-container {
  min-height: 100vh;
  padding: 16px;
}

.page-title {
  width: 60px;
  height: 28px;
  margin-bottom: 16px;
}

.notification-list {
  .notification-item {
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 12px;

    .notification-time {
      width: 120px;
      height: 16px;
      margin-bottom: 8px;
    }

    .notification-content {
      .content-row {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 8px;
      }

      .user-name {
        width: 80px;
        height: 20px;
      }

      .action-text {
        width: 140px;
        height: 20px;
      }

      .share-title {
        width: 200px;
        height: 20px;
        margin-top: 4px;
      }
    }
  }
}
</style>