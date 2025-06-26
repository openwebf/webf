<template>
    <div style="display: flex;margin-left:auto;">
        <span style="display: flex;align-items: center;margin-right: 12px;">
          <flutter-cupertino-icon type="eye" style="margin-right: 4px;" />{{ viewsCount }}
        </span>
        <span style="display: flex;align-items: center;margin-right: 12px;">
          <flutter-cupertino-icon type="hand_thumbsup" style="margin-right: 4px;" />{{ likesCount }}
        </span>
        <span style="display: flex;align-items: center;margin-right: 12px;">
          <flutter-cupertino-icon type="ellipsis_circle" style="margin-right: 4px;" />{{ commentsCount }}
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