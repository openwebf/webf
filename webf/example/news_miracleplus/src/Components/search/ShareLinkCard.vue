<template>
    <template v-if="data.link">
        <ShareLinkPreviewCard :data="data" />
    </template>
    <template v-else>
        <ShareLinkCommonCard :data="data" />
    </template>
</template>
  
<script>
import ShareLinkPreviewCard from './ShareLinkPreviewCard.vue';
import ShareLinkCommonCard from './ShareLinkCommonCard.vue';
export default {
    name: 'ShareLinkCard',
    components: {
        ShareLinkPreviewCard,
        ShareLinkCommonCard,
    },
    props: {
        data: {
            type: Object,
            required: true
        }
    }
}
</script>
  
<style lang="scss" scoped>
</style>