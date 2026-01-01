<script setup lang="ts">
import { reactive, ref } from 'vue';
import styles from './WebFSharePage.module.css';

type ShareSaveResult = {
  success: boolean;
  message?: string;
  filePath?: string;
};

const screenshotResult = ref('');
const screenshotImage = ref('');
const shareResult = ref('');
const shareImage = ref('');
const isProcessing = reactive<Record<string, boolean>>({});

const screenshotTargetRef = ref<HTMLElement | null>(null);
const shareTargetRef = ref<HTMLElement | null>(null);

function isShareAvailable() {
  return typeof (globalThis as any).webf?.invokeModuleAsync === 'function';
}

async function invokeShare(method: string, ...args: any[]) {
  return (globalThis as any).webf.invokeModuleAsync('Share', method, ...args);
}

function ensureFileScheme(path: string) {
  if (!path) return path;
  if (path.includes('://')) return path;
  if (path.startsWith('/')) return `file://${path}`;
  return path;
}

async function createDisplayableUrl(blob: Blob, fallbackPrefix = 'preview'): Promise<string> {
  if (typeof URL !== 'undefined' && typeof URL.createObjectURL === 'function') {
    return URL.createObjectURL(blob);
  }
  if (typeof FileReader !== 'undefined') {
    return new Promise<string>((resolve) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result as string);
      reader.readAsDataURL(blob);
    });
  }

  try {
    const arrayBuffer = await blob.arrayBuffer();
    if (!isShareAvailable()) return '';
    const result = (await invokeShare('saveForPreview', arrayBuffer, `${fallbackPrefix}_${Date.now()}`)) as ShareSaveResult;
    return result?.filePath ? ensureFileScheme(result.filePath) : '';
  } catch {
    return '';
  }
}

async function saveScreenshotToLocal(element: HTMLElement | null) {
  isProcessing.saveScreenshot = true;
  screenshotResult.value = '';
  screenshotImage.value = '';

  await new Promise((resolve) => setTimeout(resolve, 200));

  try {
    if (!isShareAvailable()) throw new Error('Share module not available. Register ShareModule in WebF.');
    if (!element) throw new Error('Target element not found');
    if (typeof (element as any).toBlob !== 'function') throw new Error('toBlob method not available on this element');

    const blob = await (element as any).toBlob(window.devicePixelRatio || 1.0);
    const arrayBuffer = await blob.arrayBuffer();
    const filename = `Screenshot_${Date.now()}`;

    const result = (await invokeShare('save', arrayBuffer, filename)) as ShareSaveResult;
    if (result?.success && result.filePath) {
      screenshotResult.value = `Screenshot saved successfully!\nPath: ${result.filePath}`;
      screenshotImage.value = ensureFileScheme(result.filePath);
    } else {
      screenshotResult.value = result?.message || 'Failed to save screenshot to device';
    }
  } catch (error) {
    screenshotResult.value = `Save screenshot failed: ${error instanceof Error ? error.message : 'Unknown error'}`;
  } finally {
    isProcessing.saveScreenshot = false;
  }
}

async function shareContent(element: HTMLElement | null) {
  isProcessing.share = true;
  shareResult.value = '';
  shareImage.value = '';

  await new Promise((resolve) => setTimeout(resolve, 200));

  try {
    if (!isShareAvailable()) throw new Error('Share module not available. Register ShareModule in WebF.');
    if (!element) throw new Error('Target element not found');
    if (typeof (element as any).toBlob !== 'function') throw new Error('toBlob method not available on this element');

    const blob = await (element as any).toBlob(window.devicePixelRatio || 1.0);
    shareImage.value = await createDisplayableUrl(blob, 'share');

    const arrayBuffer = await blob.arrayBuffer();
    const text = 'WebF Vue Demo';
    const subject =
      'Check out this awesome WebF demo! Built with WebF. Visit: https://github.com/openwebf/webf';

    const ok = (await invokeShare('share', arrayBuffer, text, subject)) as boolean;
    shareResult.value = ok ? 'Shared successfully' : 'Failed to share';
  } catch (error) {
    shareResult.value = `Share failed: ${error instanceof Error ? error.message : 'Unknown error'}`;
  } finally {
    isProcessing.share = false;
  }
}

async function shareTextOnly() {
  isProcessing.textShare = true;
  shareResult.value = '';

  try {
    if (!isShareAvailable()) throw new Error('Share module not available. Register ShareModule in WebF.');
    const title = 'WebF Vue Demo';
    const text =
      'WebF Share module demo application. WebF enables seamless integration between Vue and Flutter native capabilities. Visit: https://github.com/openwebf/webf';
    const ok = (await invokeShare('shareText', { title, text })) as boolean;
    shareResult.value = ok ? 'Text shared successfully' : 'Failed to share text';
  } catch (error) {
    shareResult.value = `Text share failed: ${error instanceof Error ? error.message : 'Unknown error'}`;
  } finally {
    isProcessing.textShare = false;
  }
}
</script>

<template>
  <div id="main">
    <webf-list-view :class="styles.list">
      <div :class="styles.componentSection">
        <div :class="styles.sectionTitle">WebF Share Module</div>
        <div :class="styles.componentBlock">
          <div v-if="!isShareAvailable()" class="rounded-lg border border-white/10 bg-black/20 p-4 text-sm mb-6">
            <div class="opacity-90">This page requires the WebF Share module registered in the WebF runtime.</div>
            <div class="mt-2 opacity-80 font-mono text-xs">WebF.defineModule((context) =&gt; ShareModule(context))</div>
          </div>

          <div :class="styles.componentItem">
            <div :class="styles.itemLabel">Save Screenshot to Device</div>
            <div :class="styles.itemDesc">Capture and save DOM elements directly to device storage</div>
            <div :class="styles.actionContainer">
              <div ref="screenshotTargetRef" :class="styles.screenshotTarget">
                <div :class="styles.targetContent">
                  <h3>📸 Screenshot Target Area</h3>
                  <p>This is the content that will be captured and saved to your device.</p>
                  <div :class="styles.sampleContent">
                    <div :class="styles.colorBox" :style="{ backgroundColor: '#ff6b6b' }">Red</div>
                    <div :class="styles.colorBox" :style="{ backgroundColor: '#4ecdc4' }">Teal</div>
                    <div :class="styles.colorBox" :style="{ backgroundColor: '#45b7d1' }">Blue</div>
                    <div :class="styles.colorBox" :style="{ backgroundColor: '#96ceb4' }">Green</div>
                  </div>
                  <p>Timestamp: {{ new Date().toLocaleString() }}</p>
                </div>
              </div>

              <button
                :class="[styles.actionButton, isProcessing.saveScreenshot ? styles.processing : '']"
                :disabled="!!isProcessing.saveScreenshot"
                @click="saveScreenshotToLocal(screenshotTargetRef)"
              >
                {{ isProcessing.saveScreenshot ? 'Saving...' : 'Save to Device' }}
              </button>

              <div v-if="screenshotResult || screenshotImage" :class="styles.resultContainer">
                <template v-if="screenshotResult">
                  <div :class="styles.resultLabel">Save Result:</div>
                  <div :class="styles.resultText">{{ screenshotResult }}</div>
                </template>
                <template v-if="screenshotImage">
                  <div :class="styles.resultLabel">Saved Screenshot:</div>
                  <div :class="styles.imagePreview">
                    <img :src="screenshotImage" alt="Saved screenshot" :class="styles.previewImage" />
                  </div>
                </template>
              </div>
            </div>
          </div>

          <div :class="styles.componentItem">
            <div :class="styles.itemLabel">Share with Screenshot</div>
            <div :class="styles.itemDesc">Share DOM element content as image through native share functionality</div>
            <div :class="styles.actionContainer">
              <div ref="shareTargetRef" :class="styles.shareTarget">
                <div :class="styles.targetContent">
                  <h3>🚀 WebF Vue Demo</h3>
                  <p>Demonstrating seamless integration between Vue and Flutter native capabilities.</p>
                  <div :class="styles.featureGrid">
                    <div :class="styles.featureItem">
                      <span :class="styles.featureIcon">⚡</span>
                      <span>Fast Performance</span>
                    </div>
                    <div :class="styles.featureItem">
                      <span :class="styles.featureIcon">🔄</span>
                      <span>Native Integration</span>
                    </div>
                    <div :class="styles.featureItem">
                      <span :class="styles.featureIcon">📱</span>
                      <span>Cross Platform</span>
                    </div>
                    <div :class="styles.featureItem">
                      <span :class="styles.featureIcon">🎨</span>
                      <span>Rich UI</span>
                    </div>
                  </div>
                  <p :class="styles.shareNote">Share this awesome demo!</p>
                </div>
              </div>

              <div :class="styles.buttonGroup">
                <button
                  :class="[styles.actionButton, isProcessing.share ? styles.processing : '']"
                  :disabled="!!isProcessing.share"
                  @click="shareContent(shareTargetRef)"
                >
                  {{ isProcessing.share ? 'Sharing...' : 'Share as Image' }}
                </button>
                <button
                  :class="[styles.actionButton, styles.secondaryButton, isProcessing.textShare ? styles.processing : '']"
                  :disabled="!!isProcessing.textShare"
                  @click="shareTextOnly"
                >
                  {{ isProcessing.textShare ? 'Sharing...' : 'Share Text Only' }}
                </button>
              </div>

              <div v-if="shareResult || shareImage" :class="styles.resultContainer">
                <template v-if="shareResult">
                  <div :class="styles.resultLabel">Status:</div>
                  <div :class="styles.resultText">{{ shareResult }}</div>
                </template>
                <template v-if="shareImage">
                  <div :class="styles.resultLabel">Image to Share:</div>
                  <div :class="styles.imagePreview">
                    <img :src="shareImage" alt="Share preview" :class="styles.previewImage" />
                  </div>
                </template>
              </div>
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
