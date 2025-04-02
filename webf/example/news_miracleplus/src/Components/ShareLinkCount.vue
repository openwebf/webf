<template>
    <div style="display: flex; align-items: center; font-size: 12px; color: var(--secondary-font-color); padding-top: 12px;">
        <span style="margin-right: 12px;">
          <flutter-cupertino-icon type="eye" style="margin-right: 4px;" />{{ viewsCount }}
        </span>
        <span style="margin-right: 12px;">
          <flutter-cupertino-icon type="hand_thumbsup" style="margin-right: 4px;" />{{ likesCount }}
        </span>
        <span style="margin-right: 12px;">
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