<script setup lang="ts">
import { ref, computed } from 'vue';
// Type-only import for type augmentation - no runtime JS in Vue package
import type { WebFVideoPlayerElement } from '@openwebf/vue-video-player';

// Refs for video players
const controlledPlayerRef = ref<WebFVideoPlayerElement | null>(null);
const playlistPlayerRef = ref<WebFVideoPlayerElement | null>(null);
const customUIPlayerRef = ref<WebFVideoPlayerElement | null>(null);

// Playback rate options
const playbackRates = [0.5, 0.75, 1, 1.25, 1.5, 2];

// State for controlled video
const controlledState = ref({
  isPlaying: false,
  currentTime: 0,
  duration: 0,
  volume: 1,
  muted: false,
  playbackRate: 1,
  playbackRateIndex: 2,
});

// State for event logging
const eventLogs = ref<string[]>([]);

// State for playlist
const currentPlaylistIndex = ref(0);
const playlist = [
  {
    title: 'Big Buck Bunny',
    src: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    poster: 'https://via.placeholder.com/640x360/4285f4/white?text=Big+Buck+Bunny',
  },
  {
    title: 'Elephants Dream',
    src: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    poster: 'https://via.placeholder.com/640x360/ea4335/white?text=Elephants+Dream',
  },
  {
    title: 'Sintel',
    src: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    poster: 'https://via.placeholder.com/640x360/34a853/white?text=Sintel',
  },
];

// Safe access to current playlist item
const currentPlaylistItem = computed(() => {
  const item = playlist[currentPlaylistIndex.value];
  return item ?? {
    title: 'Big Buck Bunny',
    src: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    poster: 'https://via.placeholder.com/640x360/4285f4/white?text=Big+Buck+Bunny',
  };
});

// Object fit options
const objectFitOptions = ['contain', 'cover', 'fill', 'none'] as const;

// Helper to format time
function formatTime(seconds: number): string {
  if (isNaN(seconds)) return '0:00';
  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

// Helper to log events
function logEvent(eventName: string, detail?: any) {
  const timestamp = new Date().toLocaleTimeString();
  const message = detail
    ? `[${timestamp}] ${eventName}: ${JSON.stringify(detail)}`
    : `[${timestamp}] ${eventName}`;
  eventLogs.value = [message, ...eventLogs.value.slice(0, 19)];
}

// Clear event logs
function clearEventLogs() {
  eventLogs.value = [];
}

// Handle controlled player events
function onControlledTimeupdate(e: CustomEvent<any>) {
  controlledState.value.currentTime = e.detail?.currentTime || 0;
  controlledState.value.duration = e.detail?.duration || 0;
}

function onControlledPlay() {
  controlledState.value.isPlaying = true;
}

function onControlledPause() {
  controlledState.value.isPlaying = false;
}

function onControlledVolumechange(e: CustomEvent<any>) {
  controlledState.value.volume = e.detail?.volume || 1;
  controlledState.value.muted = e.detail?.muted || false;
}

// Controlled player actions
function togglePlayPause() {
  if (controlledState.value.isPlaying) {
    controlledPlayerRef.value?.pause();
  } else {
    controlledPlayerRef.value?.play();
  }
}

function restartVideo() {
  if (controlledPlayerRef.value) {
    controlledPlayerRef.value.currentTime = 0;
  }
}

function seekBackward() {
  if (controlledPlayerRef.value && controlledPlayerRef.value.currentTime !== undefined) {
    controlledPlayerRef.value.currentTime = Math.max(0, controlledPlayerRef.value.currentTime - 10);
  }
}

function seekForward() {
  if (controlledPlayerRef.value && controlledPlayerRef.value.currentTime !== undefined) {
    controlledPlayerRef.value.currentTime = controlledPlayerRef.value.currentTime + 10;
  }
}

function toggleMute() {
  if (controlledPlayerRef.value) {
    controlledPlayerRef.value.muted = !controlledPlayerRef.value.muted;
  }
}

function onPlaybackRateChange(e: CustomEvent<number>) {
  const index = e.detail;
  const rate = playbackRates[index] ?? 1;
  if (controlledPlayerRef.value) {
    controlledPlayerRef.value.playbackRate = rate;
    controlledState.value.playbackRate = rate;
    controlledState.value.playbackRateIndex = index;
  }
}

function onVolumeSliderChange(e: Event) {
  const vol = parseFloat((e.target as HTMLInputElement).value);
  if (controlledPlayerRef.value) {
    controlledPlayerRef.value.volume = vol;
  }
}

// Playlist handlers
function handlePlaylistEnded() {
  const nextIndex = (currentPlaylistIndex.value + 1) % playlist.length;
  currentPlaylistIndex.value = nextIndex;
  setTimeout(() => {
    playlistPlayerRef.value?.play();
  }, 100);
}

function selectPlaylistItem(index: number) {
  currentPlaylistIndex.value = index;
  setTimeout(() => {
    playlistPlayerRef.value?.load();
    playlistPlayerRef.value?.play();
  }, 100);
}

// Custom UI player toggle
function toggleCustomUIPlayer() {
  const player = customUIPlayerRef.value;
  if (player) {
    if (player.paused) {
      player.play();
    } else {
      player.pause();
    }
  }
}

// Feature summary data
const features = [
  { icon: '🎥', title: 'HTML5 API', desc: 'Familiar video element API with src, controls, autoplay, loop, muted, volume' },
  { icon: '📱', title: 'Native Performance', desc: "Powered by Flutter's video_player for smooth native playback" },
  { icon: '🎛️', title: 'Built-in Controls', desc: 'Play/pause, seek, volume, and progress display out of the box' },
  { icon: '⚡', title: 'Full Events', desc: 'Complete HTML5 media events: play, pause, timeupdate, ended, etc.' },
  { icon: '🔧', title: 'Programmatic Control', desc: 'play(), pause(), seek via currentTime, volume, playbackRate' },
  { icon: '📐', title: 'Flexible Sizing', desc: 'object-fit options: contain, cover, fill, none' },
];
</script>

<template>
  <div id="main">
    <webf-list-view class="flex-1 p-0 m-0">
      <div class="p-5 bg-gray-100 min-h-screen">
        <h1 class="text-2xl font-bold text-gray-800 mb-2 text-center">
          WebF Video Player Showcase
        </h1>
        <p class="text-sm text-gray-600 text-center mb-6">
          Native Flutter video player with HTML5-compatible API
        </p>

        <div class="flex flex-col gap-8">
          <!-- Use Case 1: Basic Playback -->
          <div class="bg-white rounded-xl p-6 shadow-md border border-gray-200">
            <h2 class="text-lg font-semibold text-gray-800 mb-2">1. Basic Playback</h2>
            <p class="text-sm text-gray-600 mb-4">
              Simple video player with built-in controls. Just set the src attribute and enable controls.
            </p>
            <div class="bg-gray-900 rounded-lg p-4 mb-4 overflow-x-auto">
              <code class="text-gray-300 font-mono text-sm whitespace-pre">&lt;WebFVideoPlayer
  src="https://example.com/video.mp4"
  controls
  poster="https://example.com/poster.jpg"
/&gt;</code>
            </div>
            <div class="bg-black rounded-lg overflow-hidden shadow-lg">
              <webf-video-player
                ref="basicPlayerRef"
                src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
                controls
                poster="https://via.placeholder.com/640x360/4285f4/white?text=Basic+Playback"
                :style="{ width: '100%', height: '300px' }"
              />
            </div>
          </div>

          <!-- Use Case 2: Autoplay with Muted -->
          <div class="bg-white rounded-xl p-6 shadow-md border border-gray-200">
            <h2 class="text-lg font-semibold text-gray-800 mb-2">2. Autoplay (Muted)</h2>
            <p class="text-sm text-gray-600 mb-4">
              Videos can autoplay when muted. This is required on most platforms for autoplay to work.
            </p>
            <div class="bg-gray-900 rounded-lg p-4 mb-4 overflow-x-auto">
              <code class="text-gray-300 font-mono text-sm whitespace-pre">&lt;WebFVideoPlayer
  src="https://example.com/video.mp4"
  autoplay
  muted
  loop
  controls
/&gt;</code>
            </div>
            <div class="bg-black rounded-lg overflow-hidden shadow-lg">
              <webf-video-player
                src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
                autoplay
                muted
                loop
                controls
                :style="{ width: '100%', height: '300px' }"
              />
            </div>
          </div>

          <!-- Use Case 3: Programmatic Control -->
          <div class="bg-white rounded-xl p-6 shadow-md border border-gray-200">
            <h2 class="text-lg font-semibold text-gray-800 mb-2">3. Programmatic Control</h2>
            <p class="text-sm text-gray-600 mb-4">
              Control video playback programmatically using JavaScript methods and properties.
            </p>
            <div class="bg-black rounded-lg overflow-hidden shadow-lg">
              <webf-video-player
                ref="controlledPlayerRef"
                src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
                poster="https://via.placeholder.com/640x360/ea4335/white?text=Programmatic+Control"
                :style="{ width: '100%', height: '300px' }"
                @timeupdate="onControlledTimeupdate"
                @play="onControlledPlay"
                @pause="onControlledPause"
                @volumechange="onControlledVolumechange"
              />
            </div>
            <div class="bg-gradient-to-b from-gray-800 to-gray-900 p-4 rounded-b-lg">
              <div class="flex flex-wrap gap-3 justify-center mb-3">
                <button
                  class="bg-white/20 hover:bg-white/30 text-white px-4 py-2 rounded-md text-sm font-medium transition-all"
                  @click="togglePlayPause"
                >
                  {{ controlledState.isPlaying ? 'Pause' : 'Play' }}
                </button>
                <button
                  class="bg-white/20 hover:bg-white/30 text-white px-4 py-2 rounded-md text-sm font-medium transition-all"
                  @click="restartVideo"
                >
                  Restart
                </button>
                <button
                  class="bg-white/20 hover:bg-white/30 text-white px-4 py-2 rounded-md text-sm font-medium transition-all"
                  @click="seekBackward"
                >
                  -10s
                </button>
                <button
                  class="bg-white/20 hover:bg-white/30 text-white px-4 py-2 rounded-md text-sm font-medium transition-all"
                  @click="seekForward"
                >
                  +10s
                </button>
              </div>
              <div class="flex flex-wrap gap-3 justify-center items-center mb-3">
                <button
                  class="bg-white/20 hover:bg-white/30 text-white px-4 py-2 rounded-md text-sm font-medium transition-all"
                  @click="toggleMute"
                >
                  {{ controlledState.muted ? 'Unmute' : 'Mute' }}
                </button>
                <flutter-cupertino-sliding-segmented-control
                  :current-index="controlledState.playbackRateIndex"
                  @change="onPlaybackRateChange"
                >
                  <flutter-cupertino-sliding-segmented-control-item title="0.5x" />
                  <flutter-cupertino-sliding-segmented-control-item title="0.75x" />
                  <flutter-cupertino-sliding-segmented-control-item title="1x" />
                  <flutter-cupertino-sliding-segmented-control-item title="1.25x" />
                  <flutter-cupertino-sliding-segmented-control-item title="1.5x" />
                  <flutter-cupertino-sliding-segmented-control-item title="2x" />
                </flutter-cupertino-sliding-segmented-control>
                <input
                  type="range"
                  min="0"
                  max="1"
                  step="0.1"
                  :value="controlledState.volume"
                  class="w-24"
                  @input="onVolumeSliderChange"
                />
              </div>
              <div class="text-center text-white/80 font-mono text-sm">
                {{ formatTime(controlledState.currentTime) }} / {{ formatTime(controlledState.duration) }}
              </div>
            </div>
          </div>

          <!-- Use Case 4: Event Handling -->
          <div class="bg-white rounded-xl p-6 shadow-md border border-gray-200">
            <h2 class="text-lg font-semibold text-gray-800 mb-2">4. Event Handling</h2>
            <p class="text-sm text-gray-600 mb-4">
              Listen to HTML5-compatible video events for custom behavior.
            </p>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-4">
              <div class="min-h-[250px]">
                <webf-video-player
                  ref="eventPlayerRef"
                  src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"
                  controls
                  poster="https://via.placeholder.com/640x360/34a853/white?text=Event+Demo"
                  :style="{ width: '100%', height: '250px' }"
                  @loadstart="logEvent('loadstart')"
                  @loadedmetadata="(e: any) => logEvent('loadedmetadata', e.detail)"
                  @loadeddata="logEvent('loadeddata')"
                  @canplay="logEvent('canplay')"
                  @canplaythrough="logEvent('canplaythrough')"
                  @play="logEvent('play')"
                  @playing="logEvent('playing')"
                  @pause="logEvent('pause')"
                  @ended="logEvent('ended')"
                  @waiting="logEvent('waiting')"
                  @seeking="logEvent('seeking')"
                  @seeked="logEvent('seeked')"
                  @timeupdate="(e: any) => { if (Math.random() < 0.1) logEvent('timeupdate', e.detail); }"
                  @volumechange="(e: any) => logEvent('volumechange', e.detail)"
                  @ratechange="(e: any) => logEvent('ratechange', e.detail)"
                  @error="(e: any) => logEvent('error', e.detail)"
                />
              </div>
              <div class="flex flex-col">
                <div class="text-sm font-semibold text-gray-800 mb-2">Event Log</div>
                <div class="bg-gray-900 rounded-lg p-3 flex-1 min-h-[200px] max-h-[200px] overflow-y-auto font-mono text-xs">
                  <div v-if="eventLogs.length === 0" class="text-gray-500 text-center py-10">
                    Play the video to see events...
                  </div>
                  <div v-else>
                    <div
                      v-for="(log, i) in eventLogs"
                      :key="i"
                      class="text-teal-400 py-0.5 border-b border-gray-700 last:border-0"
                    >
                      {{ log }}
                    </div>
                  </div>
                </div>
                <button
                  class="mt-2 bg-red-500 hover:bg-red-600 text-white px-3 py-1.5 rounded text-xs"
                  @click="clearEventLogs"
                >
                  Clear Log
                </button>
              </div>
            </div>
            <div class="flex flex-col gap-2 text-xs text-gray-600">
              <div class="bg-gray-100 p-2 rounded">
                <strong>Loading:</strong> loadstart, loadedmetadata, loadeddata, canplay, canplaythrough
              </div>
              <div class="bg-gray-100 p-2 rounded">
                <strong>Playback:</strong> play, playing, pause, ended, waiting, seeking, seeked
              </div>
              <div class="bg-gray-100 p-2 rounded">
                <strong>Updates:</strong> timeupdate, volumechange, ratechange, progress, error
              </div>
            </div>
          </div>

          <!-- Use Case 5: Playlist -->
          <div class="bg-white rounded-xl p-6 shadow-md border border-gray-200">
            <h2 class="text-lg font-semibold text-gray-800 mb-2">5. Playlist</h2>
            <p class="text-sm text-gray-600 mb-4">
              Create a video playlist by changing the src attribute dynamically.
            </p>
            <div class="bg-black rounded-lg overflow-hidden shadow-lg">
              <webf-video-player
                ref="playlistPlayerRef"
                :src="currentPlaylistItem.src"
                :poster="currentPlaylistItem.poster"
                controls
                :style="{ width: '100%', height: '300px' }"
                @ended="handlePlaylistEnded"
              />
            </div>
            <div class="mt-4 border border-gray-200 rounded-lg overflow-hidden">
              <div class="bg-blue-500 text-white px-4 py-3 font-semibold text-sm">
                Now Playing: {{ currentPlaylistItem.title }}
              </div>
              <div class="max-h-[200px] overflow-y-auto">
                <div
                  v-for="(item, index) in playlist"
                  :key="index"
                  class="flex items-center px-4 py-3 cursor-pointer border-b border-gray-200 last:border-0 transition-colors"
                  :class="index === currentPlaylistIndex ? 'bg-blue-50 hover:bg-blue-100' : 'hover:bg-gray-50'"
                  @click="selectPlaylistItem(index)"
                >
                  <span
                    class="w-6 h-6 rounded-full flex items-center justify-center text-xs font-semibold mr-3"
                    :class="index === currentPlaylistIndex ? 'bg-blue-500 text-white' : 'bg-gray-200 text-gray-600'"
                  >
                    {{ index + 1 }}
                  </span>
                  <span class="flex-1 text-sm text-gray-800">{{ item.title }}</span>
                  <span v-if="index === currentPlaylistIndex" class="text-xs text-blue-500 font-semibold uppercase">
                    Playing
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Use Case 6: Object Fit Options -->
          <div class="bg-white rounded-xl p-6 shadow-md border border-gray-200">
            <h2 class="text-lg font-semibold text-gray-800 mb-2">6. Object Fit Options</h2>
            <p class="text-sm text-gray-600 mb-4">
              Control how the video fits within its container using the objectFit property.
            </p>
            <div class="grid grid-cols-2 gap-4">
              <div v-for="fit in objectFitOptions" :key="fit" class="border border-gray-200 rounded-lg overflow-hidden">
                <div class="bg-gray-100 px-3 py-2 text-sm font-semibold text-gray-800 text-center font-mono">
                  {{ fit }}
                </div>
                <div class="bg-black h-[150px]">
                  <webf-video-player
                    src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"
                    :object-fit="fit"
                    muted
                    loop
                    autoplay
                    :style="{ width: '100%', height: '150px' }"
                  />
                </div>
              </div>
            </div>
          </div>

          <!-- Use Case 7: Custom UI -->
          <div class="bg-white rounded-xl p-6 shadow-md border border-gray-200">
            <h2 class="text-lg font-semibold text-gray-800 mb-2">7. Custom UI (No Built-in Controls)</h2>
            <p class="text-sm text-gray-600 mb-4">
              Hide built-in controls to create your own custom video UI.
            </p>
            <div class="bg-gray-900 rounded-lg p-4 mb-4 overflow-x-auto">
              <code class="text-gray-300 font-mono text-sm whitespace-pre">&lt;WebFVideoPlayer
  src="https://example.com/video.mp4"
  :controls="false"
/&gt;</code>
            </div>
            <div class="relative rounded-lg overflow-hidden">
              <webf-video-player
                ref="customUIPlayerRef"
                src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"
                poster="https://via.placeholder.com/640x360/fbbc04/white?text=Custom+UI"
                muted
                :style="{ width: '100%', height: '250px' }"
              />
              <div class="absolute inset-0 flex items-center justify-center bg-black/30 hover:bg-black/40 transition-colors">
                <button
                  class="bg-blue-500/90 hover:bg-blue-500 text-white px-8 py-4 rounded-lg text-base font-semibold transition-all hover:scale-105"
                  @click="toggleCustomUIPlayer"
                >
                  Click to Play/Pause
                </button>
              </div>
            </div>
          </div>

          <!-- Feature Summary -->
          <div class="bg-white rounded-xl p-6 shadow-md border border-gray-200">
            <h2 class="text-lg font-semibold text-gray-800 mb-4">Feature Summary</h2>
            <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
              <div
                v-for="(feature, i) in features"
                :key="i"
                class="bg-gray-50 rounded-lg p-5 text-center border border-gray-200 hover:-translate-y-0.5 hover:shadow-md transition-all"
              >
                <div class="text-3xl mb-3">{{ feature.icon }}</div>
                <div class="text-sm font-semibold text-gray-800 mb-2">{{ feature.title }}</div>
                <div class="text-xs text-gray-600 leading-relaxed">{{ feature.desc }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
