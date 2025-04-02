<template>
    <div style="background: var(--background-primary); border-radius: 8px; padding: 16px; margin-bottom: 12px;" @click="viewDetail">
      <!-- Top link -->
      <div v-if="isPinned" style="color: var(--link-color); font-size: 12px; margin-bottom: 8px;">置顶</div>
      
      <template v-if="item.item.link">
        <div style="font-size: 14px; color: var(--secondary-font-color); margin-bottom: 12px; line-height: 1.5;">{{ item.item.content }}</div>
        <display-content :item="item.item" />
      </template>

      <template v-else>
        <!-- Title -->
        <div style="font-size: 16px; font-weight: bold; margin-bottom: 8px; color: var(--font-color);">{{ truncatedTitle }}</div>

        <!-- Description -->
        <p style="font-size: 14px; color: var(--secondary-font-color); margin-bottom: 12px; line-height: 1.5;">{{ truncatedContent }}</p>
      </template>
      <!-- Bottom info -->
      <card-bottom-info 
          :userName="item.account.name"
          :createdAt="item.createdAt"
          :viewsCount="item.item.viewsCount"
          :likesCount="item.item.likesCount"
          :commentsCount="item.item.commentsCount"
      />
    </div>
  </template>
  
  <script>
  import CardBottomInfo from './CardBottomInfo.vue'
  import DisplayContent from './DisplayContent.vue'
  export default {
    name: 'FeedCard',
    components: {
      CardBottomInfo,
      DisplayContent
    },
    props: {
      item: {
        type: Object,
        default: () => ({
          item: {
            title: '',
            content: '',
            introduction: '',
            link: '',
            logoUrl: '',
            viewsCount: 0,
            likesCount: 0, 
            commentsCount: 0
          },
          account: {
            name: '',
            avatar: ''
          },
          createdAt: '',
          pinnedAt: null,
        })
      },
      account: Object,
      anoymous: Boolean,
      createdAt: String,
      pinnedAt: String,
      id: Number,
      actionType: String,
    },
    computed: {
      isPinned() {
        return this.item.pinnedAt !== null;
      },
      truncatedTitle() {
        const title = this.item.item.title || '';
        return title.length > 50 ? title.slice(0, 50) + '...' : title;
      },
      truncatedContent() {
        // Truncate content to 100 characters and add ellipsis
        const content = this.item.item.content || '';
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
      truncatedIntroduction() {
        const introduction = this.item.item.introduction || '';
        return introduction.length > 100 ? introduction.slice(0, 100) + '...' : introduction;
      },
      computedCreatedAt() {
        const now = new Date();
        const createdAt = new Date(this.item.createdAt);
        const diffTime = Math.abs(now - createdAt);
        const diffMinutes = Math.floor(diffTime / (1000 * 60));
        const diffHours = Math.floor(diffTime / (1000 * 60 * 60));
        const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
        
        if (diffHours < 1) {
          return `${diffMinutes}分钟前`;
        } else if (diffDays < 1) {
          return `${diffHours}小时前`;
        } else {
          return `${diffDays}天前`;
        }
      }
    },
    methods: {
      viewDetail() {
        window.webf.hybridHistory.pushState({
            id: this.item.item.id
        }, '/share_link');
      },
      isMarkdown(text) {
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
  
