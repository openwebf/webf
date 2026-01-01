<script setup lang="ts">
import { computed, ref } from 'vue';

const basicChecked = ref(false);
const tristateValue = ref<boolean | null>(false);

const termsChecked = ref(false);
const privacyChecked = ref(false);
const notificationsChecked = ref(true);

const task1 = ref(false);
const task2 = ref(true);
const task3 = ref(false);

const eventLog = ref<string[]>([]);
function addEventLog(message: string) {
  eventLog.value = [message, ...eventLog.value].slice(0, 5);
}

const tristateLabel = computed(() => (tristateValue.value === null ? 'Mixed' : tristateValue.value ? 'Checked' : 'Unchecked'));
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino CheckBox</h1>
      <p class="text-fg-secondary mb-6">iOS-style checkbox for binary or three-state selections.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Basic Checkbox</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6">
            <div class="flex items-center gap-3 mb-4">
              <flutter-cupertino-checkbox :checked="basicChecked" @change="(e) => (basicChecked = e.detail)" />
              <span class="text-lg">{{ basicChecked ? 'Checked' : 'Unchecked' }}</span>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Disabled State</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6 space-y-4">
            <div class="flex items-center gap-3">
              <flutter-cupertino-checkbox :checked="false" disabled />
              <span class="text-gray-400">Disabled (Unchecked)</span>
            </div>
            <div class="flex items-center gap-3">
              <flutter-cupertino-checkbox :checked="true" disabled />
              <span class="text-gray-400">Disabled (Checked)</span>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Tristate Checkbox</h2>
        <p class="text-fg-secondary mb-4">Cycles through unchecked → checked → mixed.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6">
            <div class="flex items-center gap-3 mb-2">
              <flutter-cupertino-checkbox
                :checked="tristateValue"
                tristate
                @statechange="
                  (e) => {
                    if (e.detail === 'unchecked') tristateValue = false;
                    else if (e.detail === 'checked') tristateValue = true;
                    else tristateValue = null;
                    addEventLog(`tristate: ${e.detail}`);
                  }
                "
              />
              <span class="text-lg font-semibold">State: {{ tristateLabel }}</span>
            </div>
            <div class="text-sm text-gray-600">Click to cycle through states.</div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Custom Colors</h2>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-lg p-6 space-y-4">
            <div class="flex items-center gap-3">
              <flutter-cupertino-checkbox :checked="true" active-color="#FF3B30" check-color="#FFFFFF" />
              <span>Red Theme</span>
            </div>
            <div class="flex items-center gap-3">
              <flutter-cupertino-checkbox :checked="true" active-color="#34C759" check-color="#FFFFFF" />
              <span>Green Theme</span>
            </div>
            <div class="flex items-center gap-3">
              <flutter-cupertino-checkbox :checked="true" active-color="#5856D6" check-color="#FFFFFF" />
              <span>Purple Theme</span>
            </div>
            <div class="flex items-center gap-3">
              <flutter-cupertino-checkbox :checked="true" active-color="#FF9500" check-color="#000000" />
              <span>Orange Theme (Black Check)</span>
            </div>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Practical Examples</h2>
        <p class="text-fg-secondary mb-4">Agreements, preferences, and tasks.</p>
        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
          <div class="bg-white rounded-lg p-6">
            <div class="font-semibold mb-3">Agreement Form</div>
            <div class="space-y-3">
              <div class="flex items-center gap-3">
                <flutter-cupertino-checkbox
                  :checked="termsChecked"
                  @change="
                    (e) => {
                      termsChecked = e.detail;
                      addEventLog(`terms: ${e.detail}`);
                    }
                  "
                />
                <span>I agree to the Terms of Service</span>
              </div>
              <div class="flex items-center gap-3">
                <flutter-cupertino-checkbox
                  :checked="privacyChecked"
                  @change="
                    (e) => {
                      privacyChecked = e.detail;
                      addEventLog(`privacy: ${e.detail}`);
                    }
                  "
                />
                <span>I agree to the Privacy Policy</span>
              </div>
              <div class="text-xs text-gray-600">Both must be accepted to continue.</div>
            </div>
          </div>

          <div class="bg-white rounded-lg p-6">
            <div class="font-semibold mb-3">Notification Preferences</div>
            <div class="space-y-3">
              <div class="flex items-center gap-3">
                <flutter-cupertino-checkbox :checked="notificationsChecked" @change="(e) => (notificationsChecked = e.detail)" />
                <span>Enable notifications</span>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-lg p-6">
            <div class="font-semibold mb-3">Task List</div>
            <div class="space-y-2">
              <div class="flex items-center gap-3">
                <flutter-cupertino-checkbox :checked="task1" @change="(e) => (task1 = e.detail)" />
                <span :class="task1 ? 'line-through text-gray-400' : ''">Buy groceries</span>
              </div>
              <div class="flex items-center gap-3">
                <flutter-cupertino-checkbox :checked="task2" @change="(e) => (task2 = e.detail)" />
                <span :class="task2 ? 'line-through text-gray-400' : ''">Send email</span>
              </div>
              <div class="flex items-center gap-3">
                <flutter-cupertino-checkbox :checked="task3" @change="(e) => (task3 = e.detail)" />
                <span :class="task3 ? 'line-through text-gray-400' : ''">Prepare meeting notes</span>
              </div>
            </div>
          </div>
        </div>

        <div v-if="eventLog.length" class="bg-gray-50 rounded-lg p-4 border border-gray-200">
          <div class="text-sm font-semibold mb-2">Event Log (last 5)</div>
          <div class="space-y-1">
            <div v-for="(line, idx) in eventLog" :key="idx" class="text-xs font-mono text-gray-700">{{ line }}</div>
          </div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>

