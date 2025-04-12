<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Cupertino Components</div>
        <div class="component-block">
          <!-- Button -->
          <div class="component-item" @click="navigateTo('/button')">
            <div class="item-content">
              <div class="item-title">Button</div>
              <div class="item-desc">A button component for triggering actions</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Input -->
          <div class="component-item" @click="navigateTo('/input')">
            <div class="item-content">
              <div class="item-title">Input</div>
              <div class="item-desc">A form component for text input</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Switch -->
          <div class="component-item" @click="navigateTo('/switch')">
            <div class="item-content">
              <div class="item-title">Switch</div>
              <div class="item-desc">A toggle component for switching states</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Icon -->
          <div class="component-item" @click="navigateTo('/icon')">
            <div class="item-content">
              <div class="item-title">Icon</div>
              <div class="item-desc">iOS-style icon component</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Search Input -->
          <div class="component-item" @click="navigateTo('/search_input')">
            <div class="item-content">
              <div class="item-title">Search Input</div>
              <div class="item-desc">A search input component for content searching</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Textarea -->
          <div class="component-item" @click="navigateTo('/textarea')">
            <div class="item-content">
              <div class="item-title">Textarea</div>
              <div class="item-desc">A textarea component for multi-line text input</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Segmented Tab -->
          <div class="component-item" @click="navigateTo('/segmented_tab')">
            <div class="item-content">
              <div class="item-title">Segmented Tab</div>
              <div class="item-desc">A tab component with segmented control style</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Alert -->
          <div class="component-item" @click="navigateTo('/alert')">
            <div class="item-content">
              <div class="item-title">Alert</div>
              <div class="item-desc">A modal dialog component for showing alerts</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Date Picker -->
          <div class="component-item" @click="navigateTo('/date_picker')">
            <div class="item-content">
              <div class="item-title">Date Picker</div>
              <div class="item-desc">A component for selecting date and time</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Loading -->
          <div class="component-item" @click="navigateTo('/loading')">
            <div class="item-content">
              <div class="item-title">Loading</div>
              <div class="item-desc">A loading indicator component</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Modal Popup -->
          <div class="component-item" @click="navigateTo('/modal_popup')">
            <div class="item-content">
              <div class="item-title">Modal Popup</div>
              <div class="item-desc">A modal popup component for bottom sheets</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Picker -->
          <div class="component-item" @click="navigateTo('/picker')">
            <div class="item-content">
              <div class="item-title">Picker</div>
              <div class="item-desc">A component for selecting from a list of options</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Slider -->
          <div class="component-item" @click="navigateTo('/slider')">
            <div class="item-content">
              <div class="item-title">Slider</div>
              <div class="item-desc">An iOS-style slider for selecting values from a range</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Context Menu -->
          <div class="component-item" @click="navigateTo('/context_menu')">
            <div class="item-content">
              <div class="item-title">Context Menu</div>
              <div class="item-desc">A context menu component for showing actions</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Checkbox -->
          <div class="component-item" @click="navigateTo('/checkbox')">
            <div class="item-content">
              <div class="item-title">Checkbox</div>
              <div class="item-desc">A macOS-style checkbox component</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Radio -->
          <div class="component-item" @click="navigateTo('/radio')">
            <div class="item-content">
              <div class="item-title">Radio</div>
              <div class="item-desc">A macOS-style radio button component</div>
            </div>
            <div class="item-arrow">></div>
          </div>

          <!-- Timer Picker -->
          <div class="component-item" @click="navigateTo('/timer_picker')">
            <div class="item-content">
              <div class="item-title">Timer Picker</div>
              <div class="item-desc">A countdown timer picker component</div>
            </div>
            <div class="item-arrow">></div>
          </div>
        </div>
      </div>
    </webf-listview>
  </div>
</template>

<script>
export default {
  methods: {
    navigateTo(path) {
      window.webf.hybridHistory.pushState({}, path);
    }
  }
}
</script>

<style lang="scss" scoped>
#list {
  padding: 10px 0;
  height: 100vh;
  width: 100vw;
  background-color: var(--background-primary);
}

.component-section {
  padding: 16px;
  margin-bottom: 8px;

  .section-title {
    font-size: 20px;
    font-weight: 600;
    color: var(--font-color-primary);
    margin-bottom: 16px;
  }

  .component-block {
    background-color: var(--background-secondary);
    border-radius: 12px;
    padding: 16px;

    .component-item {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 16px;
      margin: -16px;
      cursor: pointer;
      transition: background-color 0.2s;

      &:active {
        background-color: var(--background-active);
      }

      &:not(:last-child) {
        border-bottom: 1px solid var(--border-color);
        margin-bottom: 16px;
        padding-bottom: 16px;
      }

      .item-content {
        flex: 1;

        .item-title {
          font-size: 16px;
          font-weight: 500;
          color: var(--font-color-primary);
          margin-bottom: 4px;
        }

        .item-desc {
          font-size: 14px;
          color: var(--font-color-secondary);
        }
      }

      .item-arrow {
        margin-left: 8px;
        color: var(--font-color-secondary);
        font-size: 16px;
      }
    }
  }
}
</style>