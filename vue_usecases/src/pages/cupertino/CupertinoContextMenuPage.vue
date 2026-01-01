<script setup lang="ts">
import { onMounted, ref } from 'vue';
import type { FlutterCupertinoContextMenuElement, FlutterCupertinoContextMenuSelectDetail } from '@openwebf/vue-cupertino-ui';
import { CupertinoIcons } from '@openwebf/vue-cupertino-ui';

const lastAction = ref('');

const basicRef = ref<FlutterCupertinoContextMenuElement | null>(null);
const iconRef = ref<FlutterCupertinoContextMenuElement | null>(null);
const destructiveRef = ref<FlutterCupertinoContextMenuElement | null>(null);
const defaultRef = ref<FlutterCupertinoContextMenuElement | null>(null);
const dynamicRef = ref<FlutterCupertinoContextMenuElement | null>(null);
const hapticRef = ref<FlutterCupertinoContextMenuElement | null>(null);
const photoRef = ref<FlutterCupertinoContextMenuElement | null>(null);
const musicRef = ref<FlutterCupertinoContextMenuElement | null>(null);
const videoRef = ref<FlutterCupertinoContextMenuElement | null>(null);

function handleSelect(e: CustomEvent<FlutterCupertinoContextMenuSelectDetail>) {
  const detail = e.detail;
  const prefix = detail.default ? 'Default: ' : '';
  const suffix = detail.destructive ? ' (destructive)' : '';
  lastAction.value = `${prefix}${detail.text}${suffix} [index: ${detail.index}]`;
}

function setDynamicActions(mode: 'file' | 'folder') {
  if (mode === 'file') {
    dynamicRef.value?.setActions([
      { text: 'Open', default: true, icon: 'doc_text', event: 'open' },
      { text: 'Share', icon: 'square_arrow_up', event: 'share' },
      { text: 'Move', icon: 'folder', event: 'move' },
      { text: 'Delete', destructive: true, icon: 'trash', event: 'delete' },
    ]);
  } else {
    dynamicRef.value?.setActions([
      { text: 'Open', default: true, icon: 'folder', event: 'open' },
      { text: 'Rename', icon: 'pencil', event: 'rename' },
      { text: 'Compress', icon: 'archivebox', event: 'compress' },
      { text: 'Delete', destructive: true, icon: 'trash', event: 'delete' },
    ]);
  }
}

onMounted(() => {
  basicRef.value?.setActions([
    { text: 'Open', event: 'open' },
    { text: 'Get Info', event: 'info' },
    { text: 'Rename', event: 'rename' },
  ]);

  iconRef.value?.setActions([
    { text: 'Share', icon: 'square_arrow_up', event: 'share' },
    { text: 'Edit', icon: 'pencil', event: 'edit' },
    { text: 'Duplicate', icon: 'doc_on_doc', event: 'duplicate' },
    { text: 'Delete', icon: 'trash', destructive: true, event: 'delete' },
  ]);

  destructiveRef.value?.setActions([
    { text: 'Mark as Read', event: 'read' },
    { text: 'Archive', event: 'archive' },
    { text: 'Delete', event: 'delete', destructive: true },
    { text: 'Block Sender', event: 'block', destructive: true },
  ]);

  defaultRef.value?.setActions([
    { text: 'Open', event: 'open', default: true },
    { text: 'Get Info', event: 'info' },
    { text: 'Rename', event: 'rename' },
    { text: 'Compress', event: 'compress' },
  ]);

  hapticRef.value?.setActions([
    { text: 'Call', event: 'call', icon: 'phone' },
    { text: 'Message', event: 'message', icon: 'chat_bubble' },
    { text: 'Email', event: 'email', icon: 'mail' },
  ]);

  photoRef.value?.setActions([
    { text: 'View', default: true, icon: 'eye', event: 'view' },
    { text: 'Edit', icon: 'pencil', event: 'edit' },
    { text: 'Share', icon: 'square_arrow_up', event: 'share' },
    { text: 'Delete', destructive: true, icon: 'trash', event: 'delete' },
  ]);

  musicRef.value?.setActions([
    { text: 'Play', default: true, icon: 'play', event: 'play' },
    { text: 'Add to Playlist', icon: 'music_note', event: 'playlist' },
    { text: 'Share', icon: 'square_arrow_up', event: 'share' },
  ]);

  videoRef.value?.setActions([
    { text: 'Play', default: true, icon: 'play', event: 'play' },
    { text: 'Get Info', icon: 'info', event: 'info' },
    { text: 'Share', icon: 'square_arrow_up', event: 'share' },
    { text: 'Delete', destructive: true, icon: 'trash', event: 'delete' },
  ]);

  setDynamicActions('file');
});
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Context Menu</h1>
      <p class="text-fg-secondary mb-6">iOS-style long-press context menu with preview and actions.</p>

      <div class="bg-blue-50 border-l-4 border-blue-500 p-4 rounded mb-8">
        <p class="text-sm text-gray-700"><strong>How to use:</strong> Long-press (click and hold) on any card below.</p>
      </div>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Basic Context Menu</h2>
        <p class="text-fg-secondary mb-4">Simple context menu with multiple actions.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <flutter-cupertino-context-menu ref="basicRef" @select="handleSelect">
            <div class="bg-blue-100 rounded-lg p-6 border-2 border-blue-300 text-center cursor-pointer select-none" id="bug">
              <div class="text-2xl mb-2">📄</div>
              <div class="font-semibold text-blue-900">Document.txt</div>
              <div class="text-sm text-blue-700 mt-1">Long-press for options</div>
            </div>
          </flutter-cupertino-context-menu>
          <div v-if="lastAction" class="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Actions with Icons</h2>
        <p class="text-fg-secondary mb-4">Configure actions with Cupertino icon names.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <flutter-cupertino-context-menu ref="iconRef" @select="handleSelect">
            <div class="bg-purple-100 rounded-lg p-6 border-2 border-purple-300 text-center cursor-pointer select-none">
              <div class="text-2xl mb-2">
                <flutter-cupertino-icon :type="CupertinoIcons.photo" />
              </div>
              <div class="font-semibold text-purple-900">Image.jpg</div>
              <div class="text-sm text-purple-700 mt-1">Long-press for options</div>
            </div>
          </flutter-cupertino-context-menu>
          <div v-if="lastAction" class="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Destructive Actions</h2>
        <p class="text-fg-secondary mb-4">Mark dangerous actions as destructive.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <flutter-cupertino-context-menu ref="destructiveRef" @select="handleSelect">
            <div class="bg-red-100 rounded-lg p-6 border-2 border-red-300 text-center cursor-pointer select-none">
              <div class="text-2xl mb-2"><flutter-cupertino-icon :type="CupertinoIcons.mail_solid" /></div>
              <div class="font-semibold text-red-900">Spam Email</div>
              <div class="text-sm text-red-700 mt-1">Long-press to manage</div>
            </div>
          </flutter-cupertino-context-menu>
          <div v-if="lastAction" class="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Default Action</h2>
        <p class="text-fg-secondary mb-4">Mark the most common action as default (bold).</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <flutter-cupertino-context-menu ref="defaultRef" @select="handleSelect">
            <div class="bg-green-100 rounded-lg p-6 border-2 border-green-300 text-center cursor-pointer select-none">
              <div class="text-2xl mb-2"><flutter-cupertino-icon :type="CupertinoIcons.folder_fill" /></div>
              <div class="font-semibold text-green-900">Project Folder</div>
              <div class="text-sm text-green-700 mt-1">Long-press for actions</div>
            </div>
          </flutter-cupertino-context-menu>
          <div v-if="lastAction" class="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Dynamic Actions</h2>
        <p class="text-fg-secondary mb-4">Update menu actions dynamically with <code>setActions</code>.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <div class="flex gap-2 flex-wrap">
            <button class="px-3 py-2 rounded border border-line hover:bg-surface-hover" @click="setDynamicActions('file')">
              File Actions
            </button>
            <button class="px-3 py-2 rounded border border-line hover:bg-surface-hover" @click="setDynamicActions('folder')">
              Folder Actions
            </button>
          </div>
          <flutter-cupertino-context-menu ref="dynamicRef" @select="handleSelect">
            <div class="bg-gray-100 rounded-lg p-6 border-2 border-gray-300 text-center cursor-pointer select-none">
              <div class="text-2xl mb-2">🧩</div>
              <div class="font-semibold text-gray-900">Dynamic Target</div>
              <div class="text-sm text-gray-700 mt-1">Long-press, then switch modes above</div>
            </div>
          </flutter-cupertino-context-menu>
          <div v-if="lastAction" class="p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Haptic Feedback</h2>
        <p class="text-fg-secondary mb-4">Enable haptic feedback for menu interactions.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <flutter-cupertino-context-menu ref="hapticRef" enable-haptic-feedback @select="handleSelect">
            <div class="bg-indigo-100 rounded-lg p-6 border-2 border-indigo-300 text-center cursor-pointer select-none">
              <div class="text-2xl mb-2">📞</div>
              <div class="font-semibold text-indigo-900">Contact Card</div>
              <div class="text-sm text-indigo-700 mt-1">Long-press for quick actions</div>
            </div>
          </flutter-cupertino-context-menu>
          <div v-if="lastAction" class="mt-4 p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Media Cards</h2>
        <p class="text-fg-secondary mb-4">Different menus for photo, music, and video.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 grid md:grid-cols-3 gap-4">
          <flutter-cupertino-context-menu ref="photoRef" @select="handleSelect">
            <div class="bg-purple-100 rounded-lg p-6 border-2 border-purple-300 text-center cursor-pointer select-none">
              <div class="text-2xl mb-2"><flutter-cupertino-icon :type="CupertinoIcons.photo" /></div>
              <div class="font-semibold text-purple-900">Photo</div>
              <div class="text-sm text-purple-700 mt-1">Long-press</div>
            </div>
          </flutter-cupertino-context-menu>

          <flutter-cupertino-context-menu ref="musicRef" @select="handleSelect">
            <div class="bg-pink-100 rounded-lg p-6 border-2 border-pink-300 text-center cursor-pointer select-none">
              <div class="text-2xl mb-2"><flutter-cupertino-icon :type="CupertinoIcons.music_note" /></div>
              <div class="font-semibold text-pink-900">Music</div>
              <div class="text-sm text-pink-700 mt-1">Long-press</div>
            </div>
          </flutter-cupertino-context-menu>

          <flutter-cupertino-context-menu ref="videoRef" @select="handleSelect">
            <div class="bg-orange-100 rounded-lg p-6 border-2 border-orange-300 text-center cursor-pointer select-none">
              <div class="text-2xl mb-2"><flutter-cupertino-icon :type="CupertinoIcons.play_rectangle" /></div>
              <div class="font-semibold text-orange-900">Video</div>
              <div class="text-sm text-orange-700 mt-1">Long-press</div>
            </div>
          </flutter-cupertino-context-menu>
        </div>
        <div v-if="lastAction" class="p-3 bg-blue-50 rounded-lg text-sm text-gray-700">Last action: {{ lastAction }}</div>
      </section>
    </webf-list-view>
  </div>
</template>

