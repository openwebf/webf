<template>
    <div class="question-card" @click="viewQuestionDetail">
      <div class="title">{{ question.title }}</div>
      <div class="stats">
        <div class="stat-item">
          <flutter-cupertino-icon class="icon" type="eye" />
          <span>{{ question.viewsCount }}</span>
        </div>
        <div class="stat-item answer-count">
          <flutter-cupertino-icon class="icon" type="chat_bubble" />
          <span>{{ question.answersCount }}</span>
        </div>
        <div class="tag" v-if="question.followed === null" @click="handleFollowQuestion">
          <span>关注问题</span>
        </div>
        <div class="tag" v-else>已关注</div>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'QuestionCard',
    props: {
      question: {
        type: Object,
        required: true,
        validator: (obj) => {
          return ['title', 'id', 'viewsCount', 'answersCount'].every(key => key in obj)
        }
      }
    },
    methods: {
      viewQuestionDetail() {
        console.log('viewQuestionDetail', this.question);
        window.webf.hybridHistory.pushState({ id: this.question.id }, '/question');
      },
      handleFollowQuestion() {
        console.log('handleFollowQuestion', this.question.followed);
        // this.question.followed = !this.question.followed;
      }
    }
  }
  </script>
  
  <style lang="scss" scoped>
  .question-card {
    padding: 16px;
    border-radius: 8px;
    margin-top: 8px;
    background-color: var(--background-color);
  }
  
  .title {
    font-size: 16px;
    font-weight: 500;
    color: #333;
    margin-bottom: 8px;
    line-height: 1.4;
  }
  
  .stats {
    display: flex;
    align-items: center;
    justify-content: center;

    .stat-item {
        display: flex;
        align-items: center;
        justify-content: center;
        color: #999;
        font-size: 14px;

        .icon {
        font-size: 14px;
        }

        span {
        margin-left: 4px;
        }
    }

    .answer-count {
        margin-left: 16px;
    }

    .tag {
        margin-left: 16px;
        font-size: 14px;
        color: #999;
    }
  }
  

  </style>