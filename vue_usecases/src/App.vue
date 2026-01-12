<script setup lang="ts">
// import { Route, Routes } from '@openwebf/vue-router';
// import { appRoutes } from './routes';
import FeatureCatalogPage from "./pages/FeatureCatalogPage.vue";
</script>

<template>
  <div class="min-h-screen w-full text-left">
    <div class="fixed top-3 right-3 z-50 pointer-events-none">
      <div class="rounded-full bg-emerald-600 px-2.5 py-1 text-xs font-semibold text-white shadow">
        Vue
      </div>
    </div>
<!--    <Routes>-->
<!--      <Route-->
<!--        v-for="r in appRoutes"-->
<!--        :key="r.path"-->
<!--        :path="r.path"-->
<!--        :title="r.title"-->
<!--        :theme="r.theme"-->
<!--        :element="r.element"-->
<!--      />-->
<!--    </Routes>-->
    <FeatureCatalogPage />
  </div>
</template>
