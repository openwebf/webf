<script setup lang="ts">
import { Route, Routes } from '@openwebf/vue-router';
import { appRoutes } from './routes';
</script>

<template>
  <div class="min-h-screen w-full text-left">
    <Routes>
      <Route
        v-for="r in appRoutes"
        :key="r.path"
        :path="r.path"
        :title="r.title"
        :theme="r.theme"
        :element="r.element"
      />
    </Routes>
  </div>
</template>
