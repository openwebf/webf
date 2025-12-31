<script setup lang="ts">
import RouterDemoHome from '../components/RouterDemoHome.vue';
import RoutingDemoShell from './routing/_shared/RoutingDemoShell.vue';
</script>

<template>
  <RoutingDemoShell
    title="Routing & Navigation"
    description="Router demos rendered inside a scrollable webf-list-view. Navigate within /routing/*."
    :demo="RouterDemoHome"
  />
</template>
