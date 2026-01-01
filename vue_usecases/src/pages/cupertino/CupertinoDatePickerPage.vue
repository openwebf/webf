<script setup lang="ts">
import { computed, ref } from 'vue';
import type { FlutterCupertinoModalPopupElement } from '@openwebf/vue-cupertino-ui';

type PickerMode = 'dateAndTime' | 'date' | 'time' | 'monthYear' | 'styledDate';

const quickStartCode = `import { ref } from 'vue';

const value = ref<string | null>(null);

<flutter-cupertino-date-picker
  mode="dateAndTime"
  :value="value ?? new Date().toISOString()"
  @change={(event) => (value = event.detail)}
/>
<div class="mt-2 text-sm text-gray-700">
  Selected: <code>{{ value ?? '(none)' }}</code>
</div>`;

const modesCode = `<flutter-cupertino-date-picker
  mode="dateAndTime"  // 'time' | 'date' | 'dateAndTime' | 'monthYear'
  minimum-date="2024-01-01T00:00:00.000Z"
  maximum-date="2025-12-31T23:59:59.000Z"
  :minimum-year="2000"
  :maximum-year="2030"
  :minute-interval="5"
  use-24-h
  show-day-of-week
  :value="currentIsoString"
/>`;

const eventsCode = `<flutter-cupertino-date-picker
  @change={(event) => {
    // event.detail is an ISO8601 DateTime string
    console.log('change', event.detail);
  }}
/>`;

const imperativeCode = `const pickerRef = ref<FlutterCupertinoDatePickerElement | null>(null);

// Set the current value programmatically
pickerRef.value?.setValue(new Date(2025, 0, 1).toISOString());

<flutter-cupertino-date-picker ref="pickerRef" />`;

const stylingCode = `<flutter-cupertino-date-picker
  mode="date"
  style="height: 220px"
/>`;

const dateTimeValue = ref<string | null>(null);
const dateValue = ref<string | null>(null);
const timeValue = ref<string | null>(null);
const monthYearValue = ref<string | null>(null);

const modalRef = ref<FlutterCupertinoModalPopupElement | null>(null);
const activeMode = ref<PickerMode | null>(null);

const today = new Date();
const minDate = new Date(today.getFullYear() - 1, 0, 1);
const maxDate = new Date(today.getFullYear() + 1, 11, 31);

const minDateIso = minDate.toISOString();
const maxDateIso = maxDate.toISOString();

const modalTitle = computed(() => {
  if (activeMode.value === 'dateAndTime') return 'Select Date & Time';
  if (activeMode.value === 'date') return 'Select Date';
  if (activeMode.value === 'time') return 'Select Time';
  if (activeMode.value === 'monthYear') return 'Select Month & Year';
  if (activeMode.value === 'styledDate') return 'Styled Date Picker';
  return '';
});

function formatDisplay(value: string | null) {
  return value ?? '(none)';
}

function openPicker(mode: PickerMode) {
  activeMode.value = mode;
  modalRef.value?.show();
}

function onModalClose() {
  activeMode.value = null;
}
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Date Picker</h1>
      <p class="text-fg-secondary mb-6">
        iOS-style date &amp; time picker backed by Flutter&apos;s <code>CupertinoDatePicker</code>.
      </p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Quick Start</h2>
        <p class="text-fg-secondary mb-4">
          Use <code>flutter-cupertino-date-picker</code> with <code>mode=&quot;dateAndTime&quot;</code> and bind
          <code>value</code> to an ISO8601 string (for example, <code>Date.toISOString()</code>). The picker is
          typically presented from a bottom popup.
        </p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="space-y-3">
            <flutter-cupertino-button variant="filled" @click="openPicker('dateAndTime')">
              Choose Date &amp; Time
            </flutter-cupertino-button>
            <div class="text-sm text-fg-secondary">
              Selected: <span class="font-mono break-all">{{ formatDisplay(dateTimeValue) }}</span>
            </div>
          </div>
        </div>

        <div class="bg-gray-50 rounded-lg p-4 border border-gray-200">
          <pre class="text-sm overflow-x-auto"><code>{{ quickStartCode }}</code></pre>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Modes &amp; Constraints</h2>
        <p class="text-fg-secondary mb-4">
          Configure the picker with different <code>mode</code> values, minimum/maximum dates, year bounds, and minute
          intervals. Each example below opens the picker as a bottom popup.
        </p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <h3 class="text-sm font-semibold text-fg-primary mb-2">Date Only</h3>
          <p class="text-xs text-fg-secondary mb-3">
            Use <code>mode=&quot;date&quot;</code> together with <code>minimum-date</code>, <code>maximum-date</code>,
            <code>minimum-year</code>, <code>maximum-year</code>, and <code>show-day-of-week</code>.
          </p>
          <div class="space-y-3">
            <flutter-cupertino-button variant="filled" @click="openPicker('date')">Choose Date</flutter-cupertino-button>
            <div class="text-sm text-fg-secondary">
              Selected date: <span class="font-mono break-all">{{ formatDisplay(dateValue) }}</span>
            </div>
          </div>
        </div>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <h3 class="text-sm font-semibold text-fg-primary mb-2">Time Only</h3>
          <p class="text-xs text-fg-secondary mb-3">
            Use <code>mode=&quot;time&quot;</code> with <code>minute-interval</code> and <code>use-24-h</code> for
            time-only pickers.
          </p>
          <div class="space-y-3">
            <flutter-cupertino-button variant="filled" @click="openPicker('time')">Choose Time</flutter-cupertino-button>
            <div class="text-sm text-fg-secondary">
              Selected time: <span class="font-mono break-all">{{ formatDisplay(timeValue) }}</span>
            </div>
          </div>
        </div>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <h3 class="text-sm font-semibold text-fg-primary mb-2">Month &amp; Year</h3>
          <p class="text-xs text-fg-secondary mb-3">
            Use <code>mode=&quot;monthYear&quot;</code> to let users pick just month and year, with optional year bounds.
          </p>
          <div class="space-y-3">
            <flutter-cupertino-button variant="filled" @click="openPicker('monthYear')">
              Choose Month &amp; Year
            </flutter-cupertino-button>
            <div class="text-sm text-fg-secondary">
              Selected month/year: <span class="font-mono break-all">{{ formatDisplay(monthYearValue) }}</span>
            </div>
          </div>
        </div>

        <div class="bg-gray-50 rounded-lg p-4 border border-gray-200">
          <pre class="text-sm overflow-x-auto"><code>{{ modesCode }}</code></pre>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Events</h2>
        <p class="text-fg-secondary mb-4">
          Listen to <code>change</code> to react whenever the selected date or time changes. The
          <code>event.detail</code> is always an ISO8601 string.
        </p>

        <div class="bg-gray-50 rounded-lg p-4 border border-gray-200">
          <pre class="text-sm overflow-x-auto"><code>{{ eventsCode }}</code></pre>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Imperative API</h2>
        <p class="text-fg-secondary mb-4">
          Use a ref to call <code>setValue(isoString)</code> and update the picker programmatically. This is most useful
          when presenting the picker from a bottom popup.
        </p>

        <div class="bg-gray-50 rounded-lg p-4 border border-gray-200">
          <pre class="text-sm overflow-x-auto"><code>{{ imperativeCode }}</code></pre>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Styling</h2>
        <p class="text-fg-secondary mb-4">
          Control the overall picker size by applying <code>width</code> / <code>height</code> via <code>style</code> or
          <code>class</code>. If omitted, the intrinsic Cupertino height is used.
        </p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="space-y-3">
            <flutter-cupertino-button variant="filled" @click="openPicker('styledDate')">
              Open Styled Date Picker
            </flutter-cupertino-button>
            <div class="text-sm text-fg-secondary">
              In the popup, the date picker uses <code>style=&quot;height: 220px&quot;</code> to constrain its height
              while the modal controls the overall sheet size via the <code>height</code> prop.
            </div>
          </div>
        </div>

        <div class="bg-gray-50 rounded-lg p-4 border border-gray-200">
          <pre class="text-sm overflow-x-auto"><code>{{ stylingCode }}</code></pre>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Notes</h2>
        <div class="bg-blue-50 border-l-4 border-blue-500 p-4 rounded space-y-2 text-sm text-gray-700">
          <p>
            <code>flutter-cupertino-date-picker</code> migrates Flutter&apos;s <code>CupertinoDatePicker</code> into a
            WebF custom element that always works with ISO8601 string values.
          </p>
          <p>
            For time-only pickers, use <code>mode=&quot;time&quot;</code> and parse <code>event.detail</code> in your
            application logic as needed.
          </p>
          <p>
            Use <code>minute-interval</code> to limit selections to specific steps (e.g., 5 minutes) and specify
            <code>minimum-date</code> / <code>maximum-date</code> when you need bounded ranges.
          </p>
        </div>
      </section>
    </webf-list-view>

    <flutter-cupertino-modal-popup ref="modalRef" :height="260" @close="onModalClose">
      <div class="p-4">
        <div class="text-sm font-semibold text-fg-primary mb-2">{{ modalTitle }}</div>

        <flutter-cupertino-date-picker
          v-if="activeMode === 'dateAndTime'"
          mode="dateAndTime"
          style="height: 220px"
          :value="dateTimeValue ?? new Date().toISOString()"
          @change="(event) => (dateTimeValue = event.detail)"
        />

        <flutter-cupertino-date-picker
          v-else-if="activeMode === 'date'"
          mode="date"
          :minimum-date="minDateIso"
          :maximum-date="maxDateIso"
          :minimum-year="2000"
          :maximum-year="2030"
          show-day-of-week
          style="height: 220px"
          :value="dateValue ?? today.toISOString()"
          @change="(event) => (dateValue = event.detail)"
        />

        <flutter-cupertino-date-picker
          v-else-if="activeMode === 'time'"
          mode="time"
          :minute-interval="5"
          use-24-h
          style="height: 220px"
          :value="timeValue ?? today.toISOString()"
          @change="(event) => (timeValue = event.detail)"
        />

        <flutter-cupertino-date-picker
          v-else-if="activeMode === 'monthYear'"
          mode="monthYear"
          :minimum-year="2000"
          :maximum-year="2030"
          style="height: 220px"
          :value="monthYearValue ?? today.toISOString()"
          @change="(event) => (monthYearValue = event.detail)"
        />

        <flutter-cupertino-date-picker
          v-else-if="activeMode === 'styledDate'"
          mode="date"
          style="height: 220px; width: 100%;"
          :value="dateValue ?? today.toISOString()"
          @change="(event) => (dateValue = event.detail)"
        />
      </div>
    </flutter-cupertino-modal-popup>
  </div>
</template>
