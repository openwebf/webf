<script setup lang="ts">
import { onUnmounted, ref } from 'vue';

type Status = 'disconnected' | 'connecting' | 'connected';

const endpoint = ref('wss://echo.websocket.org');
const status = ref<Status>('disconnected');
const message = ref('Hello, WebF!');
const log = ref<string[]>([]);
const wsRef = ref<WebSocket | null>(null);

function appendLog(line: string) {
  log.value = [...log.value, `${new Date().toLocaleTimeString()} ${line}`];
}

function connect() {
  if (status.value !== 'disconnected') return;
  status.value = 'connecting';
  appendLog(`Connecting to ${endpoint.value} ...`);
  try {
    const ws = new WebSocket(endpoint.value);
    wsRef.value = ws;
    ws.onopen = () => {
      status.value = 'connected';
      appendLog('Connected');
    };
    ws.onmessage = (e) => appendLog(`← ${String(e.data)}`);
    ws.onerror = () => appendLog('Error');
    ws.onclose = () => {
      status.value = 'disconnected';
      appendLog('Closed');
    };
  } catch (e: any) {
    status.value = 'disconnected';
    appendLog(`Connection error: ${e?.message ?? e}`);
  }
}

function disconnect() {
  wsRef.value?.close();
  wsRef.value = null;
}

function send() {
  if (status.value !== 'connected' || !wsRef.value) return;
  wsRef.value.send(message.value);
  appendLog(`→ ${message.value}`);
}

onUnmounted(() => {
  wsRef.value?.close();
});
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
      <h1 class="text-2xl font-semibold text-fg-primary mb-4">WebSocket</h1>
      <p class="text-fg-secondary mb-4">Connect to an echo server and exchange messages.</p>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <label class="text-sm text-fg-secondary">Endpoint</label>
        <input v-model="endpoint" class="w-full rounded border border-line px-3 py-2 bg-surface mt-1" />
        <div class="mt-3 flex space-x-2">
          <button
            v-if="status !== 'connected'"
            class="px-4 py-2 rounded bg-black text-white hover:bg-neutral-700"
            @click="connect"
          >
            {{ status === 'connecting' ? 'Connecting...' : 'Connect' }}
          </button>
          <button
            v-else
            class="px-4 py-2 rounded border border-line hover:bg-surface-hover"
            @click="disconnect"
          >
            Disconnect
          </button>

          <div class="ml-auto text-sm text-fg-secondary">Status: {{ status }}</div>
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
        <h2 class="text-lg font-medium text-fg-primary mb-2">Send Message</h2>
        <div class="md:flex md:space-x-3 space-y-3 md:space-y-0">
          <input v-model="message" class="flex-1 rounded border border-line px-3 py-2 bg-surface" />
          <button
            class="px-4 py-2 rounded bg-black text-white hover:bg-neutral-700 disabled:opacity-50"
            :disabled="status !== 'connected'"
            @click="send"
          >
            Send
          </button>
        </div>
      </div>

      <div class="bg-surface-secondary border border-line rounded-xl p-4">
        <h2 class="text-lg font-medium text-fg-primary mb-2">Log</h2>
        <div class="text-sm h-64 overflow-auto rounded border border-line p-2 bg-surface">
          <div v-if="log.length === 0" class="text-fg-secondary">No messages</div>
          <div v-else v-for="(l, i) in log" :key="i">{{ l }}</div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
