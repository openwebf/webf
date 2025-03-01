<template>
    <div class="question-page">
        <webf-listview class="question-page-listview">
            <div class="question-section">
                <text class="title">{{ question.title }}</text>

                <text v-if="question.content" class="content">{{ question.content }}</text>

                <div class="user-info">
                    <div class="left">
                        <img class="avatar" :src="question.user.avatar" mode="aspectFill" />
                        <div class="user-meta">
                            <text class="name">{{ question.user.name }}</text>
                            <text class="desc">{{ userDesc }}</text>
                        </div>
                    </div>
                </div>

                <div class="action-bar">
                    <div class="left-actions">
                        <div class="follow-btn">
                            <template v-if="question.followed">
                                <flutter-cupertino-icon type="heart_fill" class="icon" />
                                <text class="text">已关注</text>
                            </template>
                            <template v-else>
                                <flutter-cupertino-icon type="heart" class="icon" />
                                <text class="text">关注问题 {{ question.followersCount }}</text>
                            </template>
                        </div>
                        <div class="invite-btn">
                            <flutter-cupertino-icon type="chat_bubble" class="icon" />
                            <text class="text">邀请回答</text>
                        </div>
                    </div>
                    <flutter-cupertino-button type="primary" class="answer-btn">
                        回答
                    </flutter-cupertino-button>
                    <flutter-cupertino-icon type="share" class="share-icon" />
                </div>
            </div>
            <CommentsSection :comments="answers" :total="question.answersCount" />

            <!-- <CommentInput @submit="handleCommentSubmit" /> -->
        </webf-listview>
    </div>
</template>

<script>
import { api } from '@/api';
import CommentsSection from '@/Components/comment/CommentsSection.vue';
// import CommentInput from '@/Components/comment/CommentInput.vue';
export default {
    name: 'QuestionPage',
    components: {
        CommentsSection,
        // CommentInput
    },
    data() {
        return {
            question: {
                user: {
                    avatar: '',
                    name: '',
                },
                title: '',
                content: '',
                followersCount: 0,
                answersCount: 0,
                answers: [],
            },
            answers: [],
        }
    },
    computed: {
        userDesc() {
            const user = this.question.user || {};
            const parts = [];
            if (user.company) parts.push(user.company);
            if (user.jobTitle) parts.push(user.jobTitle);
            return parts.join(' · ');
        }
    },
    async mounted() {
        const id = window.webf.hybridHistory.state.id;
        const res = await api.question.getDetail(id);
        this.question = res.data.question;
        this.answers = await this.fetchAnswers();
    },
    methods: {
        formatUserDesc(user) {
            const parts = [];
            if (user.company) parts.push(user.company);
            if (user.jobTitle) parts.push(user.jobTitle);
            return parts.join(' · ');
        },
        parseContent(content) {
            try {
                const parsed = JSON.parse(content);
                // 简单处理，只提取文本内容
                return parsed.map(block => {
                    if (block.type === 'paragraph') {
                        return block.children.map(child => child.text).join('');
                    }
                    return '';
                }).join('\n');
            } catch (e) {
                return content;
            }
        },
        async fetchAnswers() {
            const answers = this.question.answers;
            for (const answer of answers) {
                const subRes = await api.comments.getList({ resourceId: answer.id, resourceType: 'Answer' });
                answer.subComments = subRes.data.comments;
            }
            return answers;
        },
        handleCommentSubmit(comment) {
            console.log('comment: ', comment);
        }
    }
}
</script>

<style lang="scss" scoped>
.question-page {
    background: var(--background-primary);
    min-height: 100vh;
    padding: 16px;


    .question-page-listview {
        height: 100vh;

        .question-section {
            padding-bottom: 16px;
            border-bottom: 1px solid var(--border-secondary);

            .title {
                font-size: 17px;
                font-weight: 500;
                color: #333333;
                margin-bottom: 8px;
            }

            .content {
                font-size: 15px;
                color: #666666;
                margin-bottom: 16px;
            }

            .user-info {
                display: flex;
                flex-direction: row;
                justify-content: space-between;
                align-items: center;

                .left {
                    display: flex;
                    flex-direction: row;
                    align-items: center;
                }

                .avatar {
                    width: 32px;
                    height: 32px;
                    border-radius: 16px;
                    margin-right: 8px;
                }

                .user-meta {
                    .name {
                        font-size: 14px;
                        color: #333333;
                        margin-bottom: 2px;
                    }

                    .desc {
                        font-size: 12px;
                        color: #999999;
                    }
                }
            }

            .action-bar {
                margin-top: 16px;
                height: 32px;
                display: flex;
                flex-direction: row;
                justify-content: space-between;
                align-items: center;

                .left-actions {
                    display: flex;
                    flex-direction: row;
                    align-items: center;

                    .follow-btn,
                    .invite-btn {
                        display: flex;
                        flex-direction: row;
                        align-items: center;
                        margin-right: 16px;

                        .icon {
                            width: 16px;
                            height: 16px;
                            margin-right: 4px;
                        }

                        .text {
                            font-size: 14px;
                            color: #666666;
                        }
                    }
                }

                .answer-btn {
                    width: 70px;
                    height: 32px;
                    border-radius: 16px;
                    font-size: 14px;
                    color: var(--font-color-primary);
                }
            }
        }
    }
}
</style>
