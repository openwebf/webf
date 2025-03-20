<template>
    <div class="question-section">
        <!-- question title -->
        <div class="title">{{ question.title }}</div>

        <!-- topic tags -->
        <div v-if="question.topics && question.topics.length" class="topics">
            <div v-for="topic in question.topics" :key="topic.id" class="topic-tag">
                <div class="topic-div" @click="goToTopicPage(topic.id)"># {{ topic.title }}</div>
            </div>
        </div>

        <!-- question link -->
        <a v-if="question.link" :href="question.link" class="question-link" target="_blank">
            <flutter-cupertino-icon type="link" class="link-icon" />
            <span class="link-text">{{ formatUrl(question.link) }}</span>
        </a>

        <!-- question content -->
        <div v-if="question.content" class="content">{{ question.content }}</div>

        <!-- questioner info -->
        <div class="user-info">
            <div class="left">
                <img class="avatar" :src="question.user.avatar" mode="aspectFill" />
                <div class="user-meta">
                    <div class="name">{{ question.user.name }}</div>
                    <div class="desc">{{ userDesc }}</div>
                </div>
            </div>
        </div>

        <!-- bottom action bar -->
        <div class="action-bar">
            <div class="left-actions">
                <div class="follow-btn" @click="handleFollow">
                    <template v-if="isFollowed">
                        <flutter-cupertino-icon type="heart_fill" class="icon" />
                        <div class="div">已关注</div>
                    </template>
                    <template v-else>
                        <flutter-cupertino-icon type="heart" class="icon" />
                        <div class="div">关注问题 {{ question.followersCount }}</div>
                    </template>
                </div>
                <div class="invite-btn" @click="$emit('invite')">
                    <flutter-cupertino-icon type="chat_bubble" class="icon" />
                    <div class="div">邀请回答</div>
                </div>
            </div>
            <flutter-cupertino-button type="primary" class="answer-btn" @click="$emit('answer')">
                回答
            </flutter-cupertino-button>
            <flutter-cupertino-icon type="share" class="share-icon" />
        </div>
    </div>
</template>

<script>
export default {
    name: 'QuestionSection',
    props: {
        question: {
            type: Object,
            required: true,
            default: () => ({
                user: {
                    avatar: '',
                    name: '',
                },
                title: '',
                content: '',
                followersCount: 0,
                answersCount: 0,
                topics: [],
            })
        }
    },
    computed: {
        userDesc() {
            const user = this.question.user || {};
            const parts = [];
            if (user.company) parts.push(user.company);
            if (user.jobTitle) parts.push(user.jobTitle);
            return parts.join(' · ');
        },
        isFollowed() {
            return !!this.question.followed;
        }
    },
    methods: {
        handleFollow() {
            this.$emit('follow', !this.isFollowed);
        },
        goToTopicPage(topicId) {
            window.webf.hybridHistory.pushState({
                id: topicId,
            }, '/topic');
        },
        formatUrl(url) {
            try {
                const urlObj = new URL(url);
                return urlObj.hostname;
            } catch (e) {
                return url;
            }
        }
    }
}
</script>

<style lang="scss" scoped>
.question-section {
    padding-bottom: 16px;
    border-bottom: 1px solid var(--border-secondary);

    .title {
        font-size: 17px;
        font-weight: 500;
        color: #333333;
        margin-bottom: 8px;
    }

    .topics {
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
        margin: 8px 0 12px 0;

        .topic-tag {
            background-color: #F5F5F5;
            border-radius: 12px;
            padding: 4px 12px;
            margin-right: 8px;
            margin-bottom: 8px;

            .topic-div {
                font-size: 12px;
                color: #666666;
            }
        }
    }

    .content {
        font-size: 15px;
        color: #666666;
        margin-bottom: 16px;
    }

    .question-link {
        display: inline-flex;
        align-items: center;
        margin-bottom: 12px;
        padding: 6px 12px;
        background-color: #F5F5F5;
        border-radius: 4px;
        text-decoration: none;
        color: var(--link-color);
        font-size: 14px;

        .link-icon {
            margin-right: 6px;
            font-size: 16px;
        }

        .link-text {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        &:active {
            background-color: #ebebeb;
        }
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

                .div {
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
</style>