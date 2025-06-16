<template>
  <div id="main" @onscreen="onScreen">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Context Menu</div>
        <div class="component-block">
          <!-- Example 0: No setActions called (initially no menu) -->
          <div class="component-item">
            <div class="item-label">No setActions called (initially no menu)</div>
            <div class="menu-container">
              <flutter-cupertino-context-menu ref="menu0">
                <div class="preview-box">
                  <flutter-cupertino-icon type="star" style="font-size: 48px;" />
                  <div class="preview-text">Initial no menu</div>
                </div>
              </flutter-cupertino-context-menu>
            </div>
          </div>

          <!-- Example 1: Controlled by Switch -->
          <div class="component-item">
            <div class="item-label">Switch controls menu configuration</div>
            <div class="control-row">
              <span>Configure menu:</span>
              <flutter-cupertino-switch 
                :checked="menu1HasActions" 
                @change="handleMenu1SwitchChange" 
              />
            </div>
            <div class="menu-container">
              <flutter-cupertino-context-menu ref="menu1" @defaultAction="onDefaultAction" @delete="onDelete">
                <div class="preview-box">
                  <flutter-cupertino-icon type="photo" style="font-size: 48px;" />
                  <div class="preview-text">Switch controlled</div>
                </div>
              </flutter-cupertino-context-menu>
            </div>
          </div>

          <!-- Example 2: Custom Menu Items -->
          <div class="component-item">
            <div class="item-label">Custom Menu Items</div>
            <div class="menu-container">
              <flutter-cupertino-context-menu ref="menu2" @share="onShare" @favorite="onFavorite">
                <div class="preview-box">
                  <flutter-cupertino-icon type="heart" style="font-size: 48px;" />
                  <div class="preview-text">Custom menu item</div>
                </div>
              </flutter-cupertino-context-menu>
            </div>
          </div>

          <!-- Example 3: With Destructive Action -->
          <div class="component-item">
            <div class="item-label">With Destructive Action</div>
            <div class="menu-container">
              <flutter-cupertino-context-menu ref="menu3" enable-haptic-feedback @open="onOpen" @edit="onEdit"
                @delete="onDelete">
                <div class="preview-box">
                  <flutter-cupertino-icon type="doc_text" style="font-size: 48px;" />
                  <div class="preview-text">Document action</div>
                </div>
              </flutter-cupertino-context-menu>
            </div>
          </div>

          <!-- Example 4: With Default Action -->
          <div class="component-item">
            <div class="item-label">With Default Action</div>
            <div class="menu-container">
              <flutter-cupertino-context-menu ref="menu4" enable-haptic-feedback @call="onCall" @message="onMessage"
                @email="onEmail">
                <div class="preview-box">
                  <flutter-cupertino-icon type="person_circle" style="font-size: 48px;" />
                  <div class="preview-text">Contact</div>
                </div>
              </flutter-cupertino-context-menu>
            </div>
          </div>

          <!-- Example 5: setActions called with empty array -->
          <div class="component-item">
            <div class="item-label">setActions([]) (no menu)</div>
            <div class="menu-container">
              <flutter-cupertino-context-menu ref="menu5">
                <div class="preview-box">
                  <flutter-cupertino-icon type="xmark_circle" style="font-size: 48px;" />
                  <div class="preview-text">Empty menu (no functionality)</div>
                </div>
              </flutter-cupertino-context-menu>
            </div>
          </div>

        </div>
      </div>
    </webf-listview>
  </div>
</template>

<script>
export default {
  data() {
    return {
      menu1HasActions: true, // Controls whether menu1 has actions
      // Define menu1's default actions
      menu1DefaultActions: [
        { text: 'Default Action (menu1)', icon: 'share', event: 'defaultAction' },
        { text: 'Delete (menu1)', icon: 'delete', event: 'delete', destructive: true }
      ]
    };
  },
  methods: {
    setMenu1Actions() {
      if (this.$refs.menu1) {
        const actionsToSet = this.menu1HasActions ? this.menu1DefaultActions : [];
        console.log(`Setting actions for menu1 (hasActions: ${this.menu1HasActions}):`, actionsToSet);
        this.$refs.menu1.setActions(actionsToSet);
      }
    },
    handleMenu1SwitchChange(event) {
      const newValue = event.detail; // Get the new state of the switch
      console.log('Menu 1 Switch changed:', newValue);
      this.menu1HasActions = newValue;
      this.setMenu1Actions(); // Update menu1's actions based on the new state
    },
    onScreen() {
      this.$nextTick(() => {
        // Example 0: No setActions called, initially no menu
        // (No action needed for menu0)

        // Example 1: Switch controls, set initial state
        this.setMenu1Actions(); 

        // Example 2: Custom menu items 
        if (this.$refs.menu2) {
          this.$refs.menu2.setActions([
            { text: "Share", icon: "share", event: "share" },
            { text: "Favorite", icon: "heart", event: "favorite" }
          ]);
        }

        // Example 3: With destructive action
        if (this.$refs.menu3) {
          this.$refs.menu3.setActions([
            { text: "Open", icon: "doc", event: "open" },
            { text: "Edit", icon: "pencil", event: "edit" },
            { text: "Delete", icon: "delete", event: "delete", destructive: true }
          ]);
        }

        // Example 4: With default action
        if (this.$refs.menu4) {
          this.$refs.menu4.setActions([
            { text: "Call", icon: "phone", event: "call", default: true },
            { text: "Message", icon: "chat_bubble", event: "message" },
            { text: "Email", icon: "mail", event: "email" }
          ]);
        }

        // Example 5: Set empty actions (previously menu6)
        if (this.$refs.menu5) { 
          console.log('Setting empty actions for menu5');
          this.$refs.menu5.setActions([]);
        }
      });
    },
    // --- Event Handlers ---
    onShare() { console.log('Share pressed'); },
    onFavorite() { console.log('Favorite pressed'); },
    onOpen() { console.log('Open pressed'); },
    onDelete() { console.log('Delete pressed (menu0, menu1, or menu3)'); },
    onCall() { console.log('Call pressed'); },
    onMessage() { console.log('Message pressed'); },
    onEmail() { console.log('Email pressed'); },
    onDefaultAction() { console.log('Default action pressed (menu1)'); },
    onEdit() { console.log('Edit pressed'); }
  },
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
      margin-bottom: 24px;

      &:last-child {
        margin-bottom: 0;
      }

      .item-label {
        font-size: 14px;
        color: var(--font-color-secondary);
        margin-bottom: 12px;
      }
      
      .control-row {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 12px;
        font-size: 14px;
        color: var(--font-color-primary);
      }

      .menu-container {
        display: flex;
        justify-content: center;
        padding: 16px;
      }
    }
  }
}

.preview-box {
  width: 120px;
  height: 120px;
  background-color: var(--background-primary);
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 16px;
  user-select: none; 

  .preview-text {
    margin-top: 8px;
    font-size: 14px;
    color: var(--font-color-primary);
    text-align: center;
  }
}
</style>