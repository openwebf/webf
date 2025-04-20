<template>
    <div class="share-page" @onscreen="onScreen" @offscreen="offScreen">
        <template v-if="loading">
            <share-link-skeleton />
        </template>
        <webf-listview id="share_root" class="webf-listview" @refresh="onRefresh">
            <!-- 共用的分享头部 -->
            <PostHeader :user="shareLink.user" />
            <PostContent :post="shareLink" />
            <LinkPreview v-if="shareLink.link" :title="shareLink.title" :introduction="shareLink.introduction"
                :logo-url="shareLink.logoUrl" />

            <!-- 内容块 -->
            <ContentBlock v-if="shareLink.introduction" title="内容导读" :content="shareLink.introduction" />
            <ContentBlock v-if="shareLink.summariedLinkContent" title="自动总结"
                :content="shareLink.summariedLinkContent" />
            <RecommendList :recommend-list="recommendList" @recommend-click="handleRecommendClick" />

            <!-- 交互栏 -->
            <InteractionBar v-bind="interactionBarProps" @follow="handleFollow" @like="handleLike"
                @bookmark="handleBookmark" @invite="handleInvite" @share="handleShare" />

            <!-- 可选的"查看全部"按钮 -->
            <slot name="view-all" :comments-count="shareLink.commentsCount" />
            <!-- 评论区 -->
            <CommentsSection :comments="allComments" :total="shareLink.commentsCount" />

            <!-- 评论输入框 -->
            <slot name="comment-input" :handle-comment-submit="handleCommentSubmit" />
        </webf-listview>

        <!-- 通用的弹窗组件 -->
        <alert-dialog ref="alertRef" />
        <flutter-cupertino-loading ref="loading" />
        <flutter-cupertino-toast ref="toast" />
        <InviteModal :show="showInviteModal" :loading="loadingUsers" :users="invitedUsers"
            :search-keyword="searchKeyword" @close="onInviteModalClose" @search="handleSearchInput"
            @invite="handleInviteUser" />
    </div>
</template>

<script>
import { api } from '@/api';
import { formatToRichContent } from '@/utils/parseRichContent';
import PostHeader from './PostHeader.vue';
import PostContent from './PostContent.vue';
import LinkPreview from './LinkPreview.vue';
import InteractionBar from './InteractionBar.vue';
import CommentsSection from '../comment/CommentsSection.vue';
import InviteModal from './InviteModal.vue';
import AlertDialog from '../AlertDialog.vue';
import ContentBlock from './ContentBlock.vue';
import RecommendList from './RecommendList.vue';
import ShareLinkSkeleton from '@/Components/skeleton/ShareLinkSkeleton.vue';

export default {
    name: 'BaseShareLinkPage',
    components: {
        PostHeader,
        PostContent,
        LinkPreview,
        InteractionBar,
        CommentsSection,
        InviteModal,
        AlertDialog,
        ContentBlock,
        RecommendList,
        ShareLinkSkeleton,
    },

    props: {
        pageType: {
            type: String,
            required: true,
            validator: (value) => ['shareLink', 'comment'].includes(value)
        },
    },

    data() {
        return {
            shareLinkId: '',
            singleCommentId: '',
            shareLink: {
                user: {},
                commentsCount: 0,
            },
            allComments: [],
            showInviteModal: false,
            loadingUsers: false,
            invitedUsers: [],
            searchKeyword: '',
            recommendList: [],
            loading: true,
        }
    },

    computed: {
        isLiked() {
            return this.shareLink.currentUserLike === 'like';
        },

        isBookmarked() {
            return this.shareLink.currentUserBookmark === 'bookmark';
        },

        isFollowed() {
            return !!this.shareLink.followed;
        },

        interactionBarProps() {
            return {
                viewsCount: this.shareLink.viewsCount,
                likesCount: this.shareLink.likesCount,
                commentsCount: this.shareLink.commentsCount,
                followersCount: this.shareLink.followersCount,
                bookmarksCount: this.shareLink.bookmarksCount,
                isFollowed: this.isFollowed,
                isLiked: this.isLiked,
                isBookmarked: this.isBookmarked,
            }
        }
    },

    provide() {
        return {
            update: this.updateComment,
            addReply: this.addCommentReply,
        }
    },

    methods: {
        async onScreen() {
            this.loading = true;
            try {
                if (this.pageType === 'comment') {
                    const { id, shareLinkId } = window.webf.hybridHistory.state;
                    this.singleCommentId = id;
                    this.shareLinkId = shareLinkId;
                    // 先加载主要内容
                    await this.fetchShareLinkDetail(this.shareLinkId);
                    this.loading = false;
                    // 后续加载评论
                    await this.fetchComment(this.singleCommentId);
                } else {
                    const { id } = window.webf.hybridHistory.state;
                    this.shareLinkId = id;
                    // 先加载主要内容
                    await this.fetchShareLinkDetail(this.shareLinkId);
                    this.loading = false;
                    // 后续并行加载评论和推荐
                    Promise.all([
                        this.fetchComments(),
                        this.fetchRecommendations(id)
                    ]).catch(() => {
                        this.$refs.alertRef.show({
                            message: '加载部分内容失败，请稍后重试'
                        });
                    });
                }
                // 浏览量统计可以放在最后
                api.news.viewCount({ id: this.shareLinkId }).catch(() => {
                    // 浏览量统计失败不影响使用，可以静默失败
                    console.warn('View count update failed');
                });
            } catch (error) {
                this.$refs.alertRef.show({
                    message: '加载失败，请稍后重试'
                });
            } finally {
                // 确保主要内容加载失败时也会关闭加载状态
                if (this.loading) {
                    this.loading = false;
                }
            }
        },
        async offScreen() {
            this.loading = true;
            // Reset data to initial state to prevent flashing when re-entering the page
            this.shareLinkId = '';
            this.singleCommentId = '';
            this.shareLink = {
                user: {}
            };
            this.allComments = [];
            this.invitedUsers = [];
            this.searchKeyword = '';
            this.loadingUsers = false;
            this.recommendList = [];
        },
        async fetchShareLinkDetail(id) {
            try {
                const res = await api.news.getDetail(id);
                this.shareLink = res.data.share_link;
            } catch (error) {
                this.$refs.alertRef.show({
                    message: '获取详情失败'
                });
                throw error;
            }
        },
        async fetchComment(id) {
            const res = await api.comments.getSingleComment(id);
            const comment = res.data.comment;
            const subRes = await api.comments.getSubComments(id);
            comment.subComments = subRes.data.comments;
            this.allComments = [comment];
        },
        async fetchComments() {
            console.log('fetchComments', this.shareLinkId);
            const res = await api.comments.getShareLinkComments({ id: this.shareLinkId });
            console.log('res.data.comments', res.data.comments.length);
            const comments = res.data.comments.reverse();
            for (const comment of comments) {
                const subRes = await api.comments.getSubComments(comment.id);
                comment.subComments = subRes.data.comments;
            }
            this.allComments = comments;
        },
        async fetchRecommendations(id) {
            try {
                const res = await api.news.getRecommendations(id);
                this.recommendList = res.data.share_links;
            } catch (error) {
                this.$refs.alertRef.show({
                    message: '获取相关分享失败'
                });
            }
        },
        async handleFollow(newFollowState) {
            console.log('handleFollow', newFollowState);
            try {
                let res;
                if (newFollowState) {
                    res = await api.news.follow(this.shareLinkId);
                } else {
                    res = await api.news.unfollow(this.shareLinkId);
                }
                console.log('follow res', res);
                if (res.success) {
                    await this.fetchShareLinkDetail();
                }
            } catch (error) {
                this.$refs.alertRef.show({
                    title: '提示',
                    message: newFollowState ? '关注失败' : '取消关注失败'
                });
            }
        },
        async handleInvite() {
            console.log('invite clicked');
            this.showInviteModal = true;
            await this.fetchInvitedUsers();
        },
        onInviteModalClose() {
            this.showInviteModal = false;
            this.searchKeyword = '';
            this.invitedUsers = [];
        },
        async fetchInvitedUsers() {
            try {
                this.loadingUsers = true;
                const res = await api.user.getInvitedUsers({
                    resource: 'ShareLink',
                    id: this.shareLinkId,
                    search: this.searchKeyword
                });
                this.invitedUsers = res.data.users;
            } catch (error) {
                this.$refs.alertRef.show({
                    message: '获取用户列表失败'
                });
            } finally {
                this.loadingUsers = false;
            }
        },
        handleSearchInput(e) {
            this.searchKeyword = e.detail;
            if (this.searchTimeout) {
                clearTimeout(this.searchTimeout);
            }

            this.searchTimeout = setTimeout(() => {
                this.fetchInvitedUsers();
            }, 300);
        },
        async handleInviteUser(user) {
            try {
                this.$refs.loading.show({
                    text: '邀请中'
                });

                const res = await api.user.invite({
                    resourceType: 'share_link',
                    resourceId: this.shareLinkId,
                    userId: user.id
                });

                if (res.success) {
                    this.$refs.toast.show({
                        type: 'success',
                        content: `已成功邀请 ${user.name}`
                    });
                    await this.fetchInvitedUsers();
                }
            } catch (error) {
                this.$refs.alertRef.show({
                    message: '邀请用户失败'
                });
            } finally {
                this.$refs.loading.hide();
            }
        },
        async handleShare() {
            return new Promise((resolve) => {
                requestAnimationFrame(async () => {
                    try {
                        console.log(11);
                        const element = document.getElementById('share_root');
                        if (!element) {
                            throw new Error('Share element not found');
                        }
                        const blob = await element.toBlob(2.0);

                        const arrayBuffer = await blob.arrayBuffer();

                        const title = this.shareLink.title || '分享';
                        const subject = this.shareLink.introduction || '';
                        // Call native share through WebF method channel
                        const result = await window.webf.invokeModuleAsync('Share', 'share', arrayBuffer, title, subject);
                        console.log('Share result:', result);
                        resolve(result);
                    } catch (error) {
                        console.error('Share failed:', error);
                        this.$refs.alertRef.show({
                            message: '分享失败，请稍后重试'
                        });
                        resolve();
                    }
                });
            });
        },
        async handleLike() {
            // 处理点赞按钮点击
            if (this.isLiked) {
                await api.news.unlike(this.shareLinkId);
            } else {
                await api.news.like(this.shareLinkId);
            }
            await this.fetchShareLinkDetail();
        },
        async handleBookmark() {
            await api.news.bookmark(this.shareLinkId);
            await this.fetchShareLinkDetail();
        },
        handleRecommendClick(item) {
            window.webf.hybridHistory.pushState(
                { id: item.id },
                '/share_link'
            );
        },
        updateComment(commentId, updatedData) {
            const updateCommentInList = (comments) => {
                for (let comment of comments) {
                    if (comment.id === commentId) {
                        Object.assign(comment, updatedData);
                        return true;
                    }
                    if (comment.subComments?.length) {
                        if (updateCommentInList(comment.subComments)) {
                            return true;
                        }
                    }
                }
                return false;
            };

            updateCommentInList(this.allComments);
        },
        addCommentReply(parentId, replyData) {
            const addReplyToComment = (comments) => {
                for (let comment of comments) {
                    if (comment.id === parentId) {
                        if (!comment.subComments) {
                            comment.subComments = [];
                        }
                        comment.subComments.push(replyData);
                        return true;
                    }
                    if (comment.subComments?.length) {
                        if (addReplyToComment(comment.subComments)) {
                            return true;
                        }
                    }
                }
                return false;
            };

            addReplyToComment(this.allComments);
        },
        async handleCommentSubmit(content) {
            const richContent = formatToRichContent(content);

            const commentRes = await api.comments.create({
                resourceId: this.shareLinkId,
                resourceType: 'ShareLink',
                content: richContent,
            });

            if (commentRes.success) {
                this.$refs.toast.show({
                    type: 'success',
                    content: '评论成功',
                });
                await this.fetchComments();
            }
        },
        async onRefresh() {
            this.loading = true;
            try {
                await this.onScreen();
            } finally {
                this.loading = false;
            }
        },
    }
}
</script>

<style lang="scss" scoped>
.share-page {
    background: var(--background-primary);
    padding: 16px;
    padding-bottom: 60px;

    .webf-listview {
        height: 100vh;
    }
}
</style>