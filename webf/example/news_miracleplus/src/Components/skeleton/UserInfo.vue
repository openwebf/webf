<template>
    <flutter-shimmer>
        <div class="user-info-skeleton">
            <!-- 头像 -->
            <flutter-shimmer-avatar class="avatar" />

            <!-- 名字 -->
            <flutter-shimmer-text class="name" />

            <!-- 职位信息 -->
            <flutter-shimmer-text class="title" />

            <!-- 统计信息 -->
            <div class="stats">
                <div class="stat-item">
                    <flutter-shimmer-text class="number" />
                    <flutter-shimmer-text class="label" />
                </div>
                <div class="stat-item">
                    <flutter-shimmer-text class="number" />
                    <flutter-shimmer-text class="label" />
                </div>
            </div>

            <!-- 按钮组 -->
            <div class="edit-block">
                <flutter-shimmer-button class="edit-profile" />
                <flutter-shimmer-button class="setting" />
            </div>

            <!-- Karma -->
            <flutter-shimmer-text class="karma" />
        </div>
    </flutter-shimmer>
</template>

<style lang="scss" scoped>
.user-info-skeleton {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 16px;
    border-radius: 12px;

    .avatar {
        width: 80px;
        height: 80px;
        margin-bottom: 12px;
    }

    .name {
        width: 120px;
        height: 24px;
        margin-bottom: 24px;
    }

    .title {
        width: 200px;
        height: 16px;
        margin-bottom: 20px;
    }

    .stats {
        display: flex;
        margin-bottom: 16px;
        margin-left: -24px;
        margin-right: -24px;
        align-items: center;

        .stat-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding-left: 24px;
            padding-right: 24px;

            .number {
                width: 40px;
                height: 24px;
                margin-bottom: 4px;
            }

            .label {
                width: 28px;
                height: 16px;
            }
        }
    }

    .edit-block {
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 12px;
        gap: 12px;

        .edit-profile,
        .setting {
            width: 100px;
            height: 36px;
        }
    }

    .karma {
        width: 140px;
        height: 16px;
    }
}
</style>