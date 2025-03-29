<template>
    <div class="login-tip">
        <flutter-cupertino-icon type="doc_text" class="icon" />
        <p class="tip-text">登录后查看更多内容</p>
    </div>
</template>

<script>
export default {
    name: 'LoginTip'
}
</script>

<style lang="scss" scoped>
.login-tip {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 40px 20px;

    .icon {
        font-size: 32px;
        color: var(--font-color-secondary);
        margin-bottom: 16px;
    }

    .tip-text {
        font-size: 14px;
        color: var(--font-color-secondary);
        margin: 0;
    }
}
</style>