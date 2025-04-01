<template>
    <div class="share-link-count">
        <span class="views">
          <flutter-cupertino-icon type="eye" class="icon" />{{ viewsCount }}
        </span>
        <span class="likes">
          <flutter-cupertino-icon type="hand_thumbsup" class="icon" />{{ likesCount }}
        </span>
        <span class="comments">
          <flutter-cupertino-icon type="ellipsis_circle" class="icon" />{{ commentsCount }}
        </span>
    </div>
</template>

<script>
export default {
    name: 'ShareLinkCount',
    props: {
        viewsCount: {
            type: Number,
            default: 0
        },
        likesCount: {
            type: Number,
            default: 0
        },
      commentsCount: {
            type: Number,
            default: 0
        }
    }
}
</script>

<style lang="scss">
.share-link-count {
    display: flex;
    margin-left: auto;

    span {
        margin-left: 12px;
        display: flex;
        align-items: center;
    }

    .icon {
        margin-right: 4px;
    }
}
</style>