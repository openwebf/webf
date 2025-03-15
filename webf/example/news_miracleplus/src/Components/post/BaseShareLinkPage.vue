<template>
    <div class="share-page" @onscreen="onScreen" @offscreen="offScreen">
        <webf-listview class="webf-listview">
            <!-- 共用的分享头部 -->
            <PostHeader :user="shareLink.user" />
            <PostContent :post="shareLink" />
            <LinkPreview v-if="shareLink.link" :title="shareLink.title" :introduction="shareLink.introduction"
                :logo-url="shareLink.logoUrl" />

            <!-- 内容块 -->
            <ContentBlock v-if="shareLink.introduction" title="内容导读" :content="shareLink.introduction" />
            <ContentBlock v-if="shareLink.summariedLinkContent" title="自动总结" :content="shareLink.summariedLinkContent" />
            <NotesList v-if="shareLink.notes" :notes="shareLink.notes" :notes-list="notesList" @note-click="handleNoteClick" />
            <RecommendList :recommend-list="recommendList" @recommend-click="handleRecommendClick" />

            <!-- 交互栏 -->
            <InteractionBar v-bind="interactionBarProps" @follow="handleFollow" @like="handleLike"
                @bookmark="handleBookmark" @invite="handleInvite" @share="handleShare" />
            
            <!-- 可选的"查看全部"按钮 -->
            <slot name="view-all" :comments-count="shareLink.commentsCount" />
            <!-- 评论区 -->
            <CommentsSection :comments="allComments" :total="shareLink.commentsCount" />

            <!-- 评论输入框 -->
            <slot name="comment-input" />
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
import PostHeader from './PostHeader.vue';
import PostContent from './PostContent.vue';
import LinkPreview from './LinkPreview.vue';
import InteractionBar from './InteractionBar.vue';
import CommentsSection from '../comment/CommentsSection.vue';
import InviteModal from './InviteModal.vue';
import AlertDialog from '../AlertDialog.vue';
import ContentBlock from './ContentBlock.vue';
import NotesList from './NotesList.vue';
import RecommendList from './RecommendList.vue';

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
        NotesList,
        RecommendList,
    },

    props: {
        pageType: {
            type: String,
            required: true,
            validator: (value) => ['share', 'comment'].includes(value)
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
            notesList: [],
            recommendList: [],
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

    methods: {
        async onScreen() {
            this.$refs.loading.show({
                text: '加载中'
            });
            if (this.pageType === 'comment') {
                const { id, shareLinkId } = window.webf.hybridHistory.state;
                this.singleCommentId = id;
                this.shareLinkId = shareLinkId;
                console.log('shareLinkId', this.shareLinkId);
                console.log('singleCommentId', this.singleCommentId);
                await this.fetchShareLinkDetail(this.shareLinkId);
                this.$refs.loading.hide();
                await this.fetchComment(this.singleCommentId);
            } else {
                const { id } = window.webf.hybridHistory.state;
                this.shareLinkId = id;
                await this.fetchShareLinkDetail(this.shareLinkId);
                this.$refs.loading.hide();
                await this.fetchComments();
                await this.fetchNotes(id);
                await this.fetchRecommendations(id);
            }
            api.news.viewCount({ id: this.shareLinkId });
        },
        async offScreen() {
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
            this.notesList = [];
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
        async fetchNotes(id) {
            if (!this.shareLink.notes) return;

            try {
                const res = await api.news.getNotes(id);
                this.notesList = res.data.notes;
            } catch (error) {
                this.$refs.alertRef.show({
                    message: '获取相关问题失败'
                });
            }
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
        async handleCommentSubmit(content) {
            console.log('handleCommentSubmit', content);
            const structuredContent = JSON.stringify([{
                type: 'paragraph',
                children: [
                    {
                        text: content,
                    }
                ]
            }]);
            // Handle new comment submission
            const commentRes = await api.comments.create({
                resourceId: this.id,
                resourceType: 'ShareLink',
                content: structuredContent,
            });
            if (commentRes.success) {
                this.$refs.toast.show({
                    type: 'success',
                    content: '评论成功',
                });
                this.allComments = await this.fetchComments();
            }
        },
        async handleFollow(newFollowState) {
            console.log('handleFollow', newFollowState);
            try {
                let res;
                if (newFollowState) {
                    res = await api.news.follow(this.id);
                } else {
                    res = await api.news.unfollow(this.id);
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
                    id: this.id,
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
                    resourceId: this.id,
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
        handleShare() {
            // 处理分享按钮点击
            console.log('share clicked');
        },
        async handleLike() {
            // 处理点赞按钮点击
            if (this.isLiked) {
                await api.news.unlike(this.id);
            } else {
                await api.news.like(this.id);
            }
            await this.fetchShareLinkDetail();
        },
        async handleBookmark() {
            await api.news.bookmark(this.id);
            await this.fetchShareLinkDetail();
        },
        async handleNoteClick(note) {
            if (note.comment_id) {
                // TODO：如果有关联的评论，滚动到评论点
            } else {
                // TODO: 否则直接发起评论
                const res = await api.news.createByNote({ noteId: note.id });
                if (res.success) {
                    // TODO: 刷新评论列表，滚动到评论列表的第一项
                }
            }
        },
        handleRecommendClick(item) {
            window.webf.hybridHistory.pushState(
                { id: item.id },
                '/share_link'
            );
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