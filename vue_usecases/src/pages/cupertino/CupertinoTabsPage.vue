<script setup lang="ts">
import { ref } from 'vue';
import { CupertinoIcons, CupertinoColors } from '@openwebf/vue-cupertino-ui';

const basicTabIndex = ref(0);
const scaffoldTabIndex = ref(0);
const navTabIndex = ref(0);
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Tabs</h1>
      <p class="text-fg-secondary mb-6">iOS-style tab bars, scaffolds, and per-tab navigation.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Basic TabBar</h2>
        <p class="text-fg-secondary mb-4">A standalone bottom tab bar that drives an index.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg h-[300px] relative overflow-hidden">
            <div class="p-6 text-center">
              <h3 class="text-lg font-semibold mb-2">Selected Tab: {{ basicTabIndex }}</h3>
              <p class="text-gray-600">
                <span v-if="basicTabIndex === 0">Home content</span>
                <span v-else-if="basicTabIndex === 1">Search content</span>
                <span v-else>Profile content</span>
              </p>
            </div>

            <div class="absolute bottom-0 left-0 right-0">
              <flutter-cupertino-tab-bar
                :current-index="basicTabIndex"
                :active-color="CupertinoColors.activeBlue"
                @change="(e) => (basicTabIndex = e.detail)"
              >
                <flutter-cupertino-tab-bar-item title="Home">
                  <flutter-cupertino-icon :type="CupertinoIcons.house_fill" />
                </flutter-cupertino-tab-bar-item>
                <flutter-cupertino-tab-bar-item title="Search">
                  <flutter-cupertino-icon :type="CupertinoIcons.search" />
                </flutter-cupertino-tab-bar-item>
                <flutter-cupertino-tab-bar-item title="Profile">
                  <flutter-cupertino-icon :type="CupertinoIcons.person_fill" />
                </flutter-cupertino-tab-bar-item>
              </flutter-cupertino-tab-bar>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">TabScaffold</h2>
        <p class="text-fg-secondary mb-4">A complete tab layout with integrated bottom bar and per-tab content.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg h-[420px] overflow-hidden">
            <flutter-cupertino-tab-scaffold class="h-full" :current-index="scaffoldTabIndex" @change="(e) => (scaffoldTabIndex = e.detail)">
              <flutter-cupertino-tab-scaffold-tab title="Home">
                <flutter-cupertino-icon :type="CupertinoIcons.house_fill" />
                <div class="p-6">
                  <h3 class="text-lg font-semibold mb-2">Home</h3>
                  <p class="text-gray-600 mb-4">Welcome to the home tab.</p>
                  <div class="space-y-2">
                    <div class="bg-blue-50 p-4 rounded-lg">Recent Activity</div>
                    <div class="bg-blue-50 p-4 rounded-lg">Quick Actions</div>
                    <div class="bg-blue-50 p-4 rounded-lg">News Feed</div>
                  </div>
                </div>
              </flutter-cupertino-tab-scaffold-tab>

              <flutter-cupertino-tab-scaffold-tab title="Favorites">
                <flutter-cupertino-icon :type="CupertinoIcons.star_fill" />
                <div class="p-6">
                  <h3 class="text-lg font-semibold mb-2">Favorites</h3>
                  <p class="text-gray-600 mb-4">Your saved items appear here.</p>
                  <div class="space-y-2">
                    <div class="bg-yellow-50 p-4 rounded-lg flex items-center gap-2">
                      <flutter-cupertino-icon :type="CupertinoIcons.star_fill" />
                      <span>Favorite Item 1</span>
                    </div>
                    <div class="bg-yellow-50 p-4 rounded-lg flex items-center gap-2">
                      <flutter-cupertino-icon :type="CupertinoIcons.star_fill" />
                      <span>Favorite Item 2</span>
                    </div>
                    <div class="bg-yellow-50 p-4 rounded-lg flex items-center gap-2">
                      <flutter-cupertino-icon :type="CupertinoIcons.star_fill" />
                      <span>Favorite Item 3</span>
                    </div>
                  </div>
                </div>
              </flutter-cupertino-tab-scaffold-tab>

              <flutter-cupertino-tab-scaffold-tab title="Gallery">
                <flutter-cupertino-icon :type="CupertinoIcons.photo_fill" />
                <div class="p-6">
                  <h3 class="text-lg font-semibold mb-2">Gallery</h3>
                  <p class="text-gray-600 mb-4">A simple grid preview.</p>
                  <div class="flex flex-wrap gap-3">
                    <div v-for="i in 9" :key="i" class="bg-purple-100 aspect-square rounded-lg flex items-center justify-center w-[90px]">
                      <flutter-cupertino-icon :type="CupertinoIcons.photo_fill" />
                    </div>
                  </div>
                </div>
              </flutter-cupertino-tab-scaffold-tab>
            </flutter-cupertino-tab-scaffold>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">TabView (Per-Tab Navigation)</h2>
        <p class="text-fg-secondary mb-4">Each tab can host its own navigation stack using <code>TabView</code>.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg overflow-hidden h-[420px]">
            <flutter-cupertino-tab-scaffold class="h-full" :current-index="navTabIndex" @change="(e) => (navTabIndex = e.detail)">
              <flutter-cupertino-tab-scaffold-tab title="Feed">
                <flutter-cupertino-icon :type="CupertinoIcons.rectangle_stack_fill" />
                <flutter-cupertino-tab-view default-title="Feed">
                  <div class="p-6">
                    <h3 class="text-lg font-semibold mb-2">Activity Feed</h3>
                    <p class="text-gray-600 mb-4">This view maintains its own navigation stack (handled by Flutter).</p>
                    <div class="space-y-2">
                      <div v-for="i in 3" :key="i" class="bg-indigo-50 p-4 rounded-lg border-l-4 border-indigo-500">
                        <div class="font-semibold">Update {{ i }}</div>
                        <div class="text-sm text-gray-600">Tap interactions are handled inside the tab view.</div>
                      </div>
                    </div>
                  </div>
                </flutter-cupertino-tab-view>
              </flutter-cupertino-tab-scaffold-tab>

              <flutter-cupertino-tab-scaffold-tab title="Account">
                <flutter-cupertino-icon :type="CupertinoIcons.person_crop_circle" />
                <flutter-cupertino-tab-view default-title="Account">
                  <div class="p-6">
                    <h3 class="text-lg font-semibold mb-2">Account</h3>
                    <p class="text-gray-600 mb-4">A second navigation stack in a different tab.</p>
                    <div class="space-y-2">
                      <div class="bg-gray-50 p-4 rounded-lg flex items-center justify-between">
                        <div>
                          <div class="font-semibold">Profile</div>
                          <div class="text-sm text-gray-600">Manage your profile</div>
                        </div>
                        <flutter-cupertino-icon :type="CupertinoIcons.chevron_right" />
                      </div>
                      <div class="bg-gray-50 p-4 rounded-lg flex items-center justify-between">
                        <div>
                          <div class="font-semibold">Settings</div>
                          <div class="text-sm text-gray-600">Preferences</div>
                        </div>
                        <flutter-cupertino-icon :type="CupertinoIcons.chevron_right" />
                      </div>
                    </div>
                  </div>
                </flutter-cupertino-tab-view>
              </flutter-cupertino-tab-scaffold-tab>
            </flutter-cupertino-tab-scaffold>
          </div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>

