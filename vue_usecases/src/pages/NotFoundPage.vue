<script setup lang="ts">
import { useLocation } from '@openwebf/vue-router';
import PlaceholderPage from './_shared/PlaceholderPage.vue';

const location = useLocation();
</script>

<template>
  <PlaceholderPage title="Not Found" :source="`No route matched: ${location.pathname}`" />
</template>

