<script setup lang="ts">
import { computed, ref } from 'vue';

const username = ref('john.appleseed');
const email = ref('');
const emailError = ref<string | null>(null);
const primaryNotifications = ref(true);
const marketingEmails = ref(false);
const rememberMe = ref(true);

function handleEmailBlur() {
  if (email.value && !email.value.includes('@')) {
    emailError.value = 'Please enter a valid email address.';
  } else {
    emailError.value = null;
  }
}

const primaryNotificationsHint = computed(() => (primaryNotifications.value ? 'Enabled for this account.' : 'Notifications are off.'));
</script>

<template>
  <div id="main" class="min-h-screen w-full bg-surface">
    <webf-list-view class="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
      <h1 class="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Form Section</h1>
      <p class="text-fg-secondary mb-6">iOS-style grouped form sections and rows built with WebF and Flutter.</p>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Quick Start</h2>
        <p class="text-fg-secondary mb-4">
          Use <code>&lt;flutter-cupertino-form-section&gt;</code> with nested <code>&lt;flutter-cupertino-form-row&gt;</code> to build settings-style forms.
        </p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-2xl overflow-hidden">
            <flutter-cupertino-form-section inset-grouped>
              <div slot="header" class="px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">Account Settings</div>

              <flutter-cupertino-form-row>
                <span slot="prefix" class="text-sm text-gray-700">Username</span>
                <input
                  class="flex-1 px-3 py-2 text-sm rounded-lg border border-line bg-surface focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Enter username"
                  :value="username"
                  @input="(e) => (username = (e.target as HTMLInputElement).value)"
                />
              </flutter-cupertino-form-row>

              <flutter-cupertino-form-row>
                <span slot="prefix" class="text-sm text-gray-700">Email</span>
                <input
                  class="flex-1 px-3 py-2 text-sm rounded-lg border border-line bg-surface focus:outline-none focus:ring-2 focus:ring-blue-500"
                  type="email"
                  placeholder="Enter email"
                  :value="email"
                  @input="(e) => (email = (e.target as HTMLInputElement).value)"
                  @blur="handleEmailBlur"
                />
                <span slot="helper" class="block mt-1 text-xs text-gray-500">We'll send a verification link.</span>
                <span v-if="emailError" slot="error" class="block mt-1 text-xs text-red-600">{{ emailError }}</span>
              </flutter-cupertino-form-row>

              <flutter-cupertino-form-row>
                <span slot="prefix" class="text-sm text-gray-700">Notifications</span>
                <flutter-cupertino-switch :checked="primaryNotifications" @change="(e) => (primaryNotifications = e.detail)" />
                <span slot="helper" class="block mt-1 text-xs text-gray-500">{{ primaryNotificationsHint }}</span>
              </flutter-cupertino-form-row>

              <div slot="footer" class="px-4 py-2 text-xs text-gray-500">These settings apply to your main WebF account.</div>
            </flutter-cupertino-form-section>
          </div>
        </div>
      </section>

      <section class="mb-8">
        <h2 class="text-xl font-semibold text-fg-primary mb-3">Row Slots</h2>
        <p class="text-fg-secondary mb-4">Rows support slots for prefix, helper, and error text.</p>

        <div class="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
          <div class="bg-white rounded-2xl overflow-hidden">
            <flutter-cupertino-form-section inset-grouped>
              <div slot="header" class="px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">Profile Details</div>

              <flutter-cupertino-form-row>
                <span slot="prefix" class="text-sm text-gray-700">Language</span>
                <span class="text-sm text-gray-800">English</span>
              </flutter-cupertino-form-row>

              <flutter-cupertino-form-row>
                <span slot="prefix" class="text-sm text-gray-700">Two‑Factor Auth</span>
                <flutter-cupertino-switch :checked="marketingEmails" @change="(e) => (marketingEmails = e.detail)" />
                <span slot="helper" class="block mt-1 text-xs text-gray-500">Adds an extra layer of security to your account.</span>
              </flutter-cupertino-form-row>

              <flutter-cupertino-form-row>
                <span slot="prefix" class="text-sm text-gray-700">Password</span>
                <span class="text-sm text-blue-600 cursor-pointer select-none" @click="rememberMe = !rememberMe">Change...</span>
                <span slot="helper" class="block mt-1 text-xs text-gray-500">Use at least 8 characters with a number and a symbol.</span>
                <span v-if="!rememberMe" slot="error" class="block mt-1 text-xs text-red-600">Remember me is disabled; you may be signed out more often.</span>
              </flutter-cupertino-form-row>

              <flutter-cupertino-form-row>
                <span slot="prefix" class="text-sm text-gray-700">Remember Me</span>
                <flutter-cupertino-switch :checked="rememberMe" @change="(e) => (rememberMe = e.detail)" />
              </flutter-cupertino-form-row>
            </flutter-cupertino-form-section>
          </div>
        </div>
      </section>
    </webf-list-view>
  </div>
</template>

