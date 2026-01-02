<script setup lang="ts">
const listItems = [1, 2, 3, 4, 5];
</script>

<template>
  <div id="main" class="w-full h-full bg-gray-50">
    <webf-list-view class="p-5 flex flex-col gap-6 w-full box-border pb-20">
      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">1. User Actions</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <div class="grid grid-cols-2 gap-4">
            <button class="p-3 rounded bg-blue-500 text-white hover:bg-blue-700 hover:shadow-lg transition-all text-center">Hover Me</button>
            <button class="p-3 rounded bg-emerald-500 text-white active:bg-emerald-800 active:scale-95 transition-all text-center">Click (Active)</button>
            <input
              type="text"
              placeholder="Focus Me"
              class="p-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent w-full"
            />
            <button class="p-3 rounded border-2 border-gray-200 text-gray-400 disabled:opacity-50 disabled:cursor-not-allowed" disabled>Disabled</button>
          </div>
          <div class="flex flex-wrap gap-2 mt-2">
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">:hover</span>
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">:active</span>
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">:focus</span>
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">:disabled</span>
          </div>
        </div>
      </div>

      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">2. Structural (First/Last/Nth)</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-500 mb-2">Items styled based on their position in the list.</p>
          <div class="flex flex-col gap-2">
            <div
              v-for="i in listItems"
              :key="i"
              class="p-2 rounded border border-gray-200 first:bg-indigo-100 first:text-indigo-700 first:border-indigo-200 last:bg-rose-100 last:text-rose-700 last:border-rose-200 even:bg-gray-50 odd:bg-white"
            >
              Item {{ i }}
              <span v-if="i === 1" class="float-right text-xs opacity-60">first-child</span>
              <span v-else-if="i === 5" class="float-right text-xs opacity-60">last-child</span>
              <span v-else-if="i % 2 === 0" class="float-right text-xs opacity-60">even</span>
              <span v-else class="float-right text-xs opacity-60">odd</span>
            </div>
          </div>
          <div class="flex flex-wrap gap-2 mt-2">
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">:first-child</span>
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">:last-child</span>
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">:nth-child(odd/even)</span>
          </div>
        </div>
      </div>

      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">3. Attribute Selectors</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-500 mb-2">Styling based on data attributes (often used for state).</p>
          <div class="flex gap-3">
            <div
              class="flex-1 p-4 rounded text-center border transition-colors data-[status=success]:bg-green-100 data-[status=success]:text-green-800 data-[status=success]:border-green-200"
              data-status="success"
            >
              Success
            </div>
            <div
              class="flex-1 p-4 rounded text-center border transition-colors data-[status=error]:bg-red-100 data-[status=error]:text-red-800 data-[status=error]:border-red-200"
              data-status="error"
            >
              Error
            </div>
            <div
              class="flex-1 p-4 rounded text-center border transition-colors data-[active=true]:bg-blue-100 data-[active=true]:border-blue-300 data-[active=true]:font-bold"
              data-active="true"
            >
              Active
            </div>
          </div>
          <div class="flex flex-wrap gap-2 mt-2">
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">[data-status="..."]</span>
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">[data-active="true"]</span>
          </div>
        </div>
      </div>

      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">4. Sibling Combinators (Peer)</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-500 mb-2">Style an element based on the state of a previous sibling.</p>
          <div class="p-4 border border-gray-100 rounded-lg bg-gray-50">
            <label class="flex items-center gap-3 cursor-pointer">
              <input type="checkbox" class="peer sr-only" />
              <div
                class="w-6 h-6 border-2 border-gray-300 rounded bg-white peer-checked:bg-blue-500 peer-checked:border-blue-500 peer-focus:ring-2 peer-focus:ring-blue-200 transition-all flex items-center justify-center"
              >
                <span class="text-white opacity-0 peer-checked:opacity-100 text-sm">✓</span>
              </div>
              <span
                class="text-gray-500 peer-checked:text-blue-700 peer-checked:font-bold peer-checked:line-through decoration-blue-500/50 transition-all"
              >
                Check me to style siblings
              </span>
            </label>
            <div class="mt-3 p-2 text-sm text-gray-400 bg-gray-100 rounded hidden peer-checked:block peer-checked:bg-blue-50 peer-checked:text-blue-600">
              I am a general sibling that appears when checked!
            </div>
          </div>
          <div class="flex flex-wrap gap-2 mt-2">
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">input + label (Adjacent)</span>
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">input ~ div (General)</span>
          </div>
        </div>
      </div>

      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">5. Parent State (Group)</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <p class="text-sm text-gray-500 mb-2">Style a child based on the parent's state (e.g. hover).</p>
          <div class="group p-4 rounded-lg border border-gray-200 bg-white hover:bg-indigo-50 hover:border-indigo-200 cursor-pointer transition-all">
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-full bg-gray-200 group-hover:bg-indigo-500 text-gray-500 group-hover:text-white flex items-center justify-center transition-colors">
                <span class="font-bold text-xl">★</span>
              </div>
              <div>
                <h3 class="font-bold text-gray-700 group-hover:text-indigo-700 transition-colors">Hover this Card</h3>
                <p class="text-sm text-gray-500 group-hover:text-indigo-500/80 transition-colors">
                  The icon and text change color when the *card* is hovered.
                </p>
              </div>
            </div>
          </div>
          <div class="flex flex-wrap gap-2 mt-2">
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">.group:hover .child</span>
          </div>
        </div>
      </div>

      <div class="flex flex-col gap-2">
        <h2 class="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">6. Pseudo-elements</h2>
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4">
          <div class="flex flex-col gap-4">
            <div class="p-3 bg-slate-50 border border-slate-200 rounded relative">
              <p class="text-slate-600 first-letter:text-3xl first-letter:font-bold first-letter:text-slate-900 first-letter:mr-1 first-letter:float-left leading-relaxed">
                This paragraph demonstrates the first-letter pseudo-element. It makes the first letter larger and bolder, like in a book or magazine.
              </p>
            </div>

            <ul class="list-none space-y-2">
              <li class="text-gray-600 before:content-['•'] before:text-blue-500 before:mr-2 before:font-bold">
                List item using <code class="text-xs bg-gray-100 p-1 rounded">before:content-['•']</code>
              </li>
              <li class="text-gray-600 after:content-['→'] after:text-red-500 after:ml-2">
                List item using <code class="text-xs bg-gray-100 p-1 rounded">after:content-['→']</code>
              </li>
            </ul>

            <input type="text" placeholder="Custom placeholder color" class="p-2 border border-gray-300 rounded placeholder:text-pink-400 placeholder:italic w-full" />
          </div>
          <div class="flex flex-wrap gap-2 mt-2">
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">::first-letter</span>
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">::before</span>
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">::after</span>
            <span class="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">::placeholder</span>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
