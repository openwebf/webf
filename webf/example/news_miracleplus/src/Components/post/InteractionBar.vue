<template>
    <div class="interaction-bar">
      <div class="stats">
        <span class="views">
          <flutter-cupertino-icon type="eye" class="icon" />{{ viewsCount }}
        </span>
        <span class="follows">
          <flutter-cupertino-icon type="person_2" class="icon" />{{ followersCount }}
        </span>
        <span class="likes" @click="handleLike">
          <flutter-cupertino-icon :type="isLiked ? 'hand_thumbsup_fill' : 'hand_thumbsup'" class="icon" />{{ likesCount }}
        </span>
        <span class="bookmarks" @click="handleBookmark">
          <flutter-cupertino-icon :type="isBookmarked ? 'bookmark_fill' : 'bookmark'" class="icon" />{{ bookmarksCount }}
        </span>
        <span class="comments">
          <flutter-cupertino-icon type="ellipsis_circle" class="icon" />{{ commentsCount }}
        </span>
      </div>
      <div class="actions">
        <div class="action-item" @click="$emit('invite')">
          <flutter-cupertino-icon type="chat_bubble" class="icon" />
          <span>邀请</span>
        </div>
        <div class="action-item" @click="handleFollow">
          <flutter-cupertino-icon :type="isFollowed ? 'heart_fill' : 'heart'" class="icon" />
          <span>{{ isFollowed ? '取消关注' : '关注' }}</span>
        </div>
        <div class="action-item" @click="$emit('share')">
          <flutter-cupertino-icon type="share" class="icon" />
          <span>分享</span>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'InteractionBar',
    props: {
      viewsCount: Number,
      likesCount: Number,
      commentsCount: Number,
      followersCount: Number,
      bookmarksCount: Number,
      isFollowed: {
        type: Boolean,
        default: false
      },
      isLiked: {
        type: Boolean,
        default: false
      },
      isBookmarked: {
        type: Boolean,
        default: false
      }
    },
    methods: {
      handleFollow() {
        this.$emit('follow', !this.isFollowed);
      },
      handleLike() {
        this.$emit('like', !this.isLiked);
      },
      handleBookmark() {
        this.$emit('bookmark', !this.isBookmarked);
      }
    }
  }
  </script>
  <style lang="scss" scoped>
  .interaction-bar {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    align-items: center;
    padding: 16px 0;
    border-bottom: 1px solid var(--border-secondary);
  
    .stats {
      display: flex;
  
      span {
        margin-left: 12px;
        display: flex;
        align-items: center;
      }
  
      .icon {
        margin-right: 4px;
      }
    }
    .actions {
      margin-top: 12px;
      display: flex;

      .action-item {
        margin-right: 12px;
        display: flex;
        justify-content: center;
        align-items: center;
        
        .icon {
          margin-right: 4px;
        }
      }
    }
  }
  </style>