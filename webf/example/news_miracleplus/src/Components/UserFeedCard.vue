<template>
  <div class="user-feed-card" @click="viewDetail">
    <!-- 将类型标签和状态指示器放在同一行 -->
    <div class="badge-container" v-if="actionTypeName || hasStatusIndicators">
      <div class="action-type-badge" v-if="actionTypeName">
        {{ actionTypeName }}
      </div>
      <div class="status-indicators" v-if="hasStatusIndicators">
        <span class="indicator liked" v-if="feed.item.liked">
          <flutter-cupertino-icon type="heart_fill" class="indicator-icon" />
        </span>
        <span class="indicator bookmarked" v-if="feed.item.bookmarked">
          <flutter-cupertino-icon type="bookmark_fill" class="indicator-icon" />
        </span>
      </div>
    </div>
    
    <!-- 内容部分 -->
    <template v-if="isLinkType && feed.item.link">
      <div class="description">{{ feed.item.content }}</div>
      <a :href="feed.item.link" class="link-preview" target="_blank">
        <div class="link-content">
          <div class="link-title">{{ feed.item.title || '链接' }}</div>
          <div class="link-url">{{ formatUrl(feed.item.link) }}</div>
        </div>
        <flutter-cupertino-icon type="chevron_right" class="arrow-icon" />
      </a>
    </template>

    <template v-else-if="hasLinkProperties && feed.item.introduction">
      <!-- 针对带有 introduction 的内容，比如点赞的链接 -->
      <div class="title">{{ truncatedTitle }}</div>
      <div class="link-card">
        <div v-if="feed.item.logoUrl" class="logo">
          <smart-image :src="feed.item.logoUrl" />
        </div>
        <div class="content">
          <div class="introduction">{{ truncatedIntroduction }}</div>
        </div>
      </div>
    </template>

    <template v-else-if="isAnswerType">
      <!-- 针对回答类型 -->
      <div class="question-title" v-if="feed.item.question">
        <flutter-cupertino-icon type="question_circle" class="question-icon" />
        {{ feed.item.question.title }}
      </div>
      <div class="description">{{ truncatedAnswerContent }}</div>
    </template>

    <template v-else-if="isCommentType">
      <!-- 针对评论类型 -->
      <div class="comment-resource" v-if="feed.item.resource && feed.item.resource.brief">
        <div class="comment-resource-brief">
          {{ feed.item.resource.brief }}
        </div>
      </div>
      <div class="description">{{ truncatedCommentContent }}</div>
      
      <!-- 如果评论有根评论，且根评论不是 ShareLink 类型才显示 -->
      <div class="root-comment" v-if="shouldShowRootComment">
        <div class="root-comment-brief" v-if="feed.item.rootComment.resource && feed.item.rootComment.resource.brief">
          评论于: {{ feed.item.rootComment.resource.brief }}
        </div>
      </div>
    </template>

    <template v-else-if="isFollowType">
      <!-- 关注类型 -->
      <div class="follow-info">
        <flutter-cupertino-icon type="person_add" class="follow-icon" />
        <span>关注了一条内容</span>
      </div>
      <div class="title" v-if="feed.item.title">{{ truncatedTitle }}</div>
      <div class="description" v-if="feed.item.introduction">{{ truncatedIntroduction }}</div>
    </template>

    <template v-else-if="isLikeType">
      <!-- 点赞类型 -->
      <template v-if="feed.item.__typename === 'Comment' || (feed.item.resourceType === 'Comment')">
        <!-- 点赞的是评论 -->
        <div class="comment-container">
          <div class="liked-comment-user" v-if="feed.item.user">
            <flutter-cupertino-icon type="heart" class="liked-icon" />
            <span>点赞了 {{ feed.item.user.name }} 的评论</span>
          </div>
          <div class="description">{{ truncatedCommentContent }}</div>
          
          <!-- 显示评论的来源 -->
          <div class="comment-source" v-if="feed.item.resource && feed.item.resource.brief">
            <div class="comment-source-brief">
              {{ feed.item.resource.brief }}
            </div>
          </div>
        </div>
      </template>
      <template v-else-if="hasLinkProperties && feed.item.introduction">
        <!-- 针对带有 introduction 的内容，比如点赞的链接 -->
        <div class="title">{{ truncatedTitle }}</div>
        <div class="link-card">
          <div v-if="feed.item.logoUrl" class="logo">
            <smart-image :src="feed.item.logoUrl" />
          </div>
          <div class="content">
            <div class="introduction">{{ truncatedIntroduction }}</div>
          </div>
        </div>
      </template>
      <template v-else>
        <!-- 默认点赞内容展示 -->
        <div class="title" v-if="feed.item.title">{{ truncatedTitle }}</div>
        <div class="description" v-if="feed.item.richContent || feed.item.content">
          {{ feed.item.richContent ? truncatedCommentContent : truncatedContent }}
        </div>
      </template>
    </template>

    <template v-else>
      <!-- 默认内容展示 -->
      <div class="title">{{ truncatedTitle }}</div>
      <div class="description">{{ truncatedContent }}</div>
    </template>

    <!-- Bottom info -->
    <div class="bottom-info">
      <div class="user-info">
        <smart-image :src="formattedAvatar" class="avatar" />
        <div class="name">{{ feed.account.name }}</div>
        <div class="time">{{ formattedTime }}</div>
      </div>
      <div class="stats">
        <div class="stat">
          <flutter-cupertino-icon type="eye" class="icon" />
          <span>{{ feed.item.viewsCount || 0 }}</span>
        </div>
        <div class="stat">
          <flutter-cupertino-icon type="heart" class="icon" />
          <span>{{ feed.item.likesCount || 0 }}</span>
        </div>
        <div class="stat">
          <flutter-cupertino-icon type="chat_bubble" class="icon" />
          <span>{{ feed.item.commentsCount || 0 }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import SmartImage from '@/Components/SmartImage.vue';
import formatAvatar from '@/utils/formatAvatar';

export default {
  name: 'UserFeedCard',
  components: {
    SmartImage,
  },
  props: {
    feed: {
      type: Object,
      required: true
    }
  },
  computed: {
    isLinkType() {
      return this.feed.actionType === 'share_link';
    },
    isAnswerType() {
      return this.feed.actionType === 'answer';
    },
    isCommentType() {
      return this.feed.actionType === 'comment';
    },
    isLikeType() {
      return this.feed.actionType === 'like';
    },
    isBookmarkType() {
      return this.feed.actionType === 'collect';
    },
    isFollowType() {
      return this.feed.actionType === 'follow';
    },
    hasLinkProperties() {
      return this.feed.item && (this.feed.item.introduction || this.feed.item.linkDescription || this.feed.item.logoUrl);
    },
    actionTypeName() {
      const types = {
        'share_link': '分享',
        'comment': '评论',
        'like': '点赞',
        'collect': '收藏',
        'answer': '回答',
        'follow': '关注'
      };
      return types[this.feed.actionType] || '';
    },
    truncatedTitle() {
      const title = this.feed.item.title || '';
      return title.length > 50 ? title.slice(0, 50) + '...' : title;
    },
    truncatedContent() {
      const content = this.feed.item.content || '';
      try {
        const parsed = JSON.parse(content);
        const result = parsed.map(block => {
          if (block.type === 'paragraph') {
            return block.children.map(child => child.text).join('');
          }
          return '';
        }).join('\n');
        return result.length > 100 ? result.slice(0, 100) + '...' : result;
      } catch (e) {
        if (this.isMarkdown(content)) {
          const strippedContent = this.stripMarkdown(content);
          return strippedContent.length > 100 
            ? strippedContent.slice(0, 100) + '...' 
            : strippedContent;
        }
        return content.length > 100 ? content.slice(0, 100) + '...' : content;
      }
    },
    truncatedAnswerContent() {
      // 处理回答内容，可能是富文本格式
      const content = this.feed.item.content || '';
      try {
        const parsed = JSON.parse(content);
        const result = parsed.map(block => {
          if (block.type === 'paragraph') {
            return block.children.map(child => child.text).join('');
          }
          return '';
        }).join('\n');
        return result.length > 100 ? result.slice(0, 100) + '...' : result;
      } catch (e) {
        return content.length > 100 ? content.slice(0, 100) + '...' : content;
      }
    },
    truncatedCommentContent() {
      // 处理评论内容，可能是 richContent 字段
      const richContent = this.feed.item.richContent || '';
      try {
        const parsed = JSON.parse(richContent);
        const result = parsed.map(block => {
          if (block.type === 'paragraph') {
            return block.children.map(child => child.text).join('');
          }
          return '';
        }).join('\n');
        return result.length > 100 ? result.slice(0, 100) + '...' : result;
      } catch (e) {
        return richContent.length > 100 ? richContent.slice(0, 100) + '...' : richContent;
      }
    },
    formattedAvatar() {
      return formatAvatar(this.feed.account?.avatar);
    },
    formattedTime() {
      const now = new Date();
      const createdAt = new Date(this.feed.createdAt);
      const diffTime = Math.abs(now - createdAt);
      const diffMinutes = Math.floor(diffTime / (1000 * 60));
      const diffHours = Math.floor(diffTime / (1000 * 60 * 60));
      const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
      
      if (diffMinutes < 60) {
        return `${diffMinutes}分钟前`;
      } else if (diffHours < 24) {
        return `${diffHours}小时前`;
      } else {
        return `${diffDays}天前`;
      }
    },
    truncatedIntroduction() {
      const intro = this.feed.item.introduction || '';
      return intro.length > 100 ? intro.slice(0, 97) + '...' : intro;
    },
    hasStatusIndicators() {
      return (this.feed.item.liked || this.feed.item.bookmarked);
    },
    shouldShowRootComment() {
      // 判断是否应该显示根评论信息
      if (!this.feed.item.rootComment) return false;
      
      // 如果有根评论，进一步判断
      if (this.feed.item.rootComment.resource) {
        // 如果根评论的资源类型是 ShareLink，不显示根评论信息
        if (this.feed.item.rootComment.resource.__typename === 'ShareLink') {
          return false;
        }
        
        // 检查是否是评论的评论（嵌套评论），且原始评论不是 ShareLink
        if (this.feed.item.resourceType === 'Comment' && 
            this.feed.item.resource && 
            this.feed.item.resource.resourceType === 'Comment') {
          return true;
        }
        
        // 对于其他类型的评论，显示根评论信息
        return true;
      }
      
      return false;
    }
  },
  methods: {
    viewDetail() {
      let route = '/share_link';
      let params = { id: this.feed.item.id };
      
      if (this.feed.actionType === 'answer') {
        // 回答类型
        route = '/answer';
        params.id = this.feed.item.id;
        if (this.feed.item.question && this.feed.item.question.id) {
          params.questionId = this.feed.item.question.id;
        }
      } else if (this.feed.actionType === 'comment') {
        // 评论类型处理逻辑优化
        if (this.feed.item.resource) {
          const resourceType = this.feed.item.resource.resourceType;
          const resourceId = this.feed.item.resource.resourceId;
          
          // 根据评论所属资源类型确定路由
          if (resourceType === 'ShareLink') {
            route = '/share_link';
            params.id = resourceId;
          } else if (resourceType === 'Question') {
            route = '/question';
            params.id = resourceId;
          } else if (resourceType === 'Answer') {
            // 针对 Answer 的评论，直接跳转到回答页面
            route = '/answer';
            
            // 从资源中获取 answerId 和 questionId
            if (this.feed.item.resource && this.feed.item.resource.id) {
              // 优先使用 resource.id 作为答案ID
              params.id = this.feed.item.resource.id;
            } else {
              // 退而求其次使用 resourceId
              params.id = resourceId;
            }
            
            // 获取问题ID
            if (this.feed.item.resource && 
                this.feed.item.resource.question && 
                this.feed.item.resource.question.id) {
              params.questionId = this.feed.item.resource.question.id;
            }
            
            console.log('跳转到回答页面:', params);
          } else if (resourceType === 'Comment') {
            // 评论的评论，需要递归查找原始资源
            
            // 首先检查是否有根评论
            if (this.feed.item.rootComment && this.feed.item.rootComment.resource) {
              const rootResource = this.feed.item.rootComment.resource;
              if (rootResource.resourceType) {
                // 如果根评论的资源有 resourceType 属性，说明它也是评论
                if (rootResource.resourceType === 'ShareLink') {
                  route = '/share_link';
                  params.id = rootResource.resourceId;
                } else if (rootResource.resourceType === 'Question') {
                  route = '/question';
                  params.id = rootResource.resourceId;
                } else if (rootResource.resourceType === 'Answer') {
                  route = '/answer';
                  params.id = rootResource.resourceId;
                }
              } else if (rootResource.__typename) {
                // 如果根评论的资源有 __typename 属性，说明它是原始资源
                if (rootResource.__typename === 'ShareLink') {
                  route = '/share_link';
                  params.id = rootResource.id || rootResource.resourceId;
                } else if (rootResource.__typename === 'Question') {
                  route = '/question';
                  params.id = rootResource.id || rootResource.resourceId;
                } else if (rootResource.__typename === 'Answer') {
                  route = '/answer';
                  params.id = rootResource.id || rootResource.resourceId;
                  if (rootResource.question && rootResource.question.id) {
                    params.questionId = rootResource.question.id;
                  }
                }
              }
            } else {
              // 没有根评论信息，尝试直接使用当前资源ID
              route = '/share_link'; // 默认假设是分享链接
              params.id = resourceId;
              console.log('无法确定评论的原始资源类型，默认跳转到分享链接');
            }
          }
        } else if (this.feed.item.rootComment) {
          // 如果没有 resource 但有 rootComment
          const rootComment = this.feed.item.rootComment;
          if (rootComment.resource) {
            if (rootComment.resource.__typename === 'ShareLink') {
              route = '/share_link';
              params.id = rootComment.resource.id;
            } else if (rootComment.resource.__typename === 'Question') {
              route = '/question';
              params.id = rootComment.resource.id;
            } else if (rootComment.resource.__typename === 'Answer') {
              route = '/answer';
              params.id = rootComment.resource.id;
              if (rootComment.resource.question && rootComment.resource.question.id) {
                params.questionId = rootComment.resource.question.id;
              }
            }
          }
        }
        
        // 添加评论ID参数，用于定位到特定评论
        params.commentId = this.feed.item.id;
        console.log(`评论跳转: route=${route}, params=`, params);
      } else if (this.feed.actionType === 'like' || this.feed.actionType === 'collect') {
        // 点赞和收藏都是跳转到原内容
        // 处理点赞/收藏的是评论的情况
        if (this.feed.item.__typename === 'Comment' || 
            (this.feed.item.resourceType === 'Comment')) {
          
          // 跳转到评论所在的资源页面
          if (this.feed.item.resource) {
            // 根据评论所属资源类型确定路由
            const resourceType = this.feed.item.resource.resourceType;
            const resourceId = this.feed.item.resource.resourceId;
            
            if (resourceType === 'ShareLink') {
              route = '/share_link';
              params.id = resourceId;
            } else if (resourceType === 'Poll') {
              route = '/poll';
              params.id = resourceId;
            } else if (resourceType === 'Question') {
              route = '/question';
              params.id = resourceId;
            } else if (resourceType === 'Answer') {
              route = '/answer';
              params.id = resourceId;
              // 尝试获取问题ID
              if (this.feed.item.resource.question && this.feed.item.resource.question.id) {
                params.questionId = this.feed.item.resource.question.id;
              }
            }
            
            // 添加评论ID参数，用于定位到特定评论
            params.commentId = this.feed.item.id;
            console.log(`点赞评论跳转: route=${route}, params=`, params);
          } else {
            // 无法确定评论所属的资源，默认跳转到评论本身
            console.log('无法确定评论的原始资源类型，默认跳转到评论本身');
            route = '/comment';
            params.id = this.feed.item.id;
          }
        } else {
          // 根据 __typename 判断内容类型
          if (this.feed.item.__typename === 'ShareLink') {
            route = '/share_link';
          } else if (this.feed.item.__typename === 'Question') {
            route = '/question';
          } else if (this.feed.item.__typename === 'Answer') {
            route = '/answer';
            // 答案需要问题ID
            if (this.feed.item.questionId) {
              params.questionId = this.feed.item.questionId;
            } else if (this.feed.item.question && this.feed.item.question.id) {
              params.questionId = this.feed.item.question.id;
            }
          } else if (this.feed.item.__typename === 'Poll') {
            route = '/poll';
          }
        }
      } else if (this.feed.actionType === 'follow') {
        // 关注类型，根据内容类型跳转
        // 需要检查 feed.item 的类型
        if (this.feed.item.__typename === 'ShareLink') {
          route = '/share_link';
        } else if (this.feed.item.__typename === 'Question') {
          route = '/question';
        } else if (this.feed.item.__typename === 'User') {
          route = '/user';
          params.userId = this.feed.item.id;
        }
      }
      console.log('route: ', route);
      console.log('params: ', params);
      
      // 针对具体数据结构的优化，特别处理"对问题回答的评论"
      if (this.feed.actionType === 'comment' && 
          this.feed.item.resourceType === 'Answer' &&
          this.feed.item.resource && 
          this.feed.item.resource.__typename === 'Answer') {
        
        // 直接跳转到回答页面
        route = '/answer';
        
        // 使用资源中的 Answer ID
        params.id = this.feed.item.resource.id;
        
        // 获取问题ID
        if (this.feed.item.resource.question && 
            this.feed.item.resource.question.id) {
          params.questionId = this.feed.item.resource.question.id;
        }
        
        // 添加评论ID参数，用于定位到特定评论
        params.commentId = this.feed.item.id;
        
        console.log('评论跳转到回答页面:', params);
      }
      
      window.webf.hybridHistory.pushState(params, route);
    },
    formatUrl(url) {
      if (!url) return '';
      try {
        const urlObj = new URL(url);
        return urlObj.hostname;
      } catch (e) {
        return url;
      }
    },
    isMarkdown(text) {
      if (!text) return false;
      // Common markdown patterns
      const markdownPatterns = [
        /^#\s/m,           // title
        /\*\*(.*?)\*\*/,   // bold
        /\*(.*?)\*/,       // italic
        /\[(.*?)\]\((.*?)\)/, // link
        /```[\s\S]*?```/,  // code
        /^\s*[-*+]\s/m,    // unordered list
        /^\s*\d+\.\s/m,    // ordered list
        /^\s*>\s/m,        // quote
      ];

      return markdownPatterns.some(pattern => pattern.test(text));
    },
    stripMarkdown(text) {
      if (!text) return '';
      return text
        .replace(/^#+\s+/gm, '')           // title
        .replace(/\*\*(.*?)\*\*/g, '$1')   // bold
        .replace(/\*(.*?)\*/g, '$1')       // italic
        .replace(/\[(.*?)\]\(.*?\)/g, '$1') // link
        .replace(/```[\s\S]*?```/g, '')    // code
        .replace(/^\s*[-*+]\s/gm, '')      // unordered list
        .replace(/^\s*\d+\.\s/gm, '')      // ordered list
        .replace(/^\s*>\s/gm, '')          // quote
        .replace(/`(.*?)`/g, '$1')         // code
        .replace(/\n{2,}/g, '\n')          // multiple newlines to single newline
        .trim();
    }
  }
}
</script>

<style lang="scss" scoped>
.user-feed-card {
  background: var(--background-primary);
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 12px;
  position: relative;

  .top-link {
    color: var(--link-color);
    font-size: 12px;
    margin-bottom: 8px;
  }
  
  .badge-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
    
    .action-type-badge {
      padding: 2px 8px;
      background-color: rgba(0, 0, 0, 0.06);
      color: #666;
      border-radius: 10px;
      font-size: 12px;
    }
    
    .status-indicators {
      display: flex;
      
      .indicator {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 24px;
        height: 24px;
        border-radius: 12px;
        margin-left: 8px;
        
        &.liked {
          color: #ff2d55;
        }
        
        &.bookmarked {
          color: #007aff;
        }
        
        .indicator-icon {
          font-size: 16px;
        }
      }
    }
  }

  .title {
    font-size: 16px;
    font-weight: bold;
    margin-bottom: 8px;
    color: var(--font-color);
  }

  .description {
    font-size: 14px;
    color: var(--secondary-font-color);
    margin-bottom: 12px;
    line-height: 1.5;
  }

  .question-title {
    font-size: 15px;
    font-weight: bold;
    color: var(--font-color);
    margin-bottom: 10px;
    background-color: rgba(0, 0, 0, 0.02);
    padding: 10px;
    border-radius: 6px;
    display: flex;
    align-items: flex-start;
    
    .question-icon {
      color: #007AFF;
      margin-right: 6px;
      font-size: 16px;
      flex-shrink: 0;
      width: 20px;
    }
  }
  
  .comment-resource {
    background-color: rgba(0, 0, 0, 0.02);
    padding: 10px;
    border-radius: 6px;
    margin-bottom: 10px;
    
    .comment-resource-brief {
      font-size: 14px;
      color: var(--secondary-font-color);
    }
  }
  
  .root-comment {
    background-color: rgba(0, 0, 0, 0.02);
    padding: 8px 12px;
    border-radius: 6px;
    margin-top: 8px;
    margin-bottom: 10px;
    border-left: 3px solid #ddd;
    
    .root-comment-brief {
      font-size: 12px;
      color: #666;
    }
  }
  
  .follow-info {
    display: flex;
    align-items: center;
    color: #007AFF;
    margin-bottom: 10px;
    
    .follow-icon {
      margin-right: 6px;
    }
  }

  .link-preview {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 16px;
    background: #f5f5f5;
    border-radius: 8px;
    margin-bottom: 12px;
    text-decoration: none;
    
    .link-content {
      flex: 1;
      margin-right: 12px;
      overflow: hidden;

      .link-title {
        font-size: 15px;
        color: #333;
        margin-bottom: 4px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .link-url {
        font-size: 13px;
        color: #666;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
    }

    .arrow-icon {
      color: #999;
      font-size: 20px;
    }
  }

  .bottom-info {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 12px;
    flex-wrap: wrap;

    .user-info {
      display: flex;
      align-items: center;

      .avatar {
        width: 24px;
        height: 24px;
        border-radius: 12px;
        margin-right: 8px;
      }

      .name {
        font-size: 14px;
        color: #333;
        margin-right: 8px;
      }

      .time {
        font-size: 12px;
        color: #999;
      }
    }

    .stats {
      display: flex;
      align-items: center;

      .stat {
        display: flex;
        align-items: center;
        margin-left: 12px;
        color: #999;
        font-size: 12px;

        .icon {
          margin-right: 4px;
          font-size: 14px;
        }
      }
    }
  }

  .link-card {
    display: flex;
    background: #f5f5f5;
    border-radius: 8px;
    padding: 12px;
    margin-bottom: 12px;
    
    .logo {
      width: 60px;
      height: 60px;
      margin-right: 12px;
      
      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 4px;
      }
    }
    
    .content {
      flex: 1;
      display: flex;
      min-width: 0;
      max-width: calc(100% - 50px);
      flex-direction: column;
      justify-content: space-between;
      
      .introduction {
        font-size: 14px;
        color: var(--secondary-font-color);
        margin-bottom: 8px;
        word-wrap: break-word;
        word-break: break-all;
        white-space: normal;
        overflow: hidden;
      }
      
      .link-description {
        font-size: 12px;
        color: #666;
      }
    }
  }

  .comment-container {
    display: flex;
    flex-direction: column;
    background-color: rgba(0, 0, 0, 0.02);
    border-radius: 8px;
    padding: 12px;
    margin-bottom: 12px;
    
    .liked-comment-user {
      display: flex;
      align-items: center;
      margin-bottom: 8px;
      font-size: 14px;
      color: #666;
      
      .liked-icon {
        color: #ff2d55;
        margin-right: 6px;
        font-size: 14px;
      }
    }
    
    .description {
      font-size: 14px;
      color: #333;
      margin-bottom: 8px;
      line-height: 1.5;
    }
  }
  
  .comment-source {
    padding: 8px 12px;
    background-color: rgba(0, 0, 0, 0.03);
    border-radius: 6px;
    margin-top: 4px;
    border-left: 3px solid #ddd;
    
    .comment-source-brief {
      font-size: 12px;
      color: #666;
    }
  }
}
</style> 