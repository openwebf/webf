<template>
    <flutter-cupertino-modal-popup :show="show" height="400" @close="$emit('close')">
        <div class="invite-modal-content">
            <div class="invite-search-container">
                <flutter-cupertino-input placeholder="搜索用户" class="invite-search-input" :value="searchKeyword"
                    @input="$emit('search', $event)" />
            </div>
            <div class="invite-users-list">
                <div v-if="loading" class="loading-indicator">
                    <flutter-cupertino-activity-indicator />
                    <span>加载中...</span>
                </div>
                <div v-else-if="users.length === 0" class="no-users">
                    没有找到匹配的用户
                </div>
                <webf-listview v-else class="invite-users-list">
                    <div v-for="user in users" :key="user.id" class="invite-user-item">
                        <img :src="user.avatar" class="user-avatar" />
                        <div class="user-info">
                            <div class="user-name">{{ user.name }}</div>
                            <div class="user-company">{{ user.company }} {{ user.jobTitle }}</div>
                        </div>
                        <flutter-cupertino-icon type="bookmark" class="invite-btn" @click="$emit('invite', user)" />
                    </div>
                </webf-listview>
            </div>
        </div>
    </flutter-cupertino-modal-popup>
</template>

<script>
export default {
    name: 'InviteModal',
    props: {
        show: Boolean,
        loading: Boolean,
        users: {
            type: Array,
            default: () => []
        },
        searchKeyword: String
    },
    emits: ['close', 'search', 'invite']
}
</script>

<style lang="scss" scoped>
.invite-modal-content {
    display: flex;
    flex-direction: column;
    height: 100%;
    padding: 16px;

    .invite-search-container {
        margin-bottom: 16px;

        .invite-search-input {
            width: 100%;
        }
    }

    .invite-users-list {
        height: 300px;
        flex: 1;
        overflow-y: auto;

        .loading-indicator {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100px;
            color: #999;
        }

        .no-users {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100px;
            color: #999;
        }

        .invite-user-item {
            display: flex;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #eee;

            .user-avatar {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                margin-right: 12px;
                object-fit: cover;
            }

            .user-info {
                flex: 1;

                .user-name {
                    font-size: 16px;
                    font-weight: 500;
                    color: #333;
                    margin-bottom: 4px;
                }

                .user-company {
                    font-size: 12px;
                    color: #666;
                }
            }

            .invite-btn {
                padding: 4px 12px;
                font-size: 14px;
            }
        }
    }
}
</style>