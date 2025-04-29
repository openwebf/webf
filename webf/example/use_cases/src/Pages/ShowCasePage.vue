<template>
  <div id="main">
    <webf-listview id="list">
      <div class="component-section">
        <div class="section-title">Showcase</div>
        <div class="component-block">
          <!-- Basic Example -->
          <div class="component-item">
            <div class="item-label">Basic Example</div>
            <div class="item-desc">Demonstrates the basic functionality of ShowcaseView</div>
            <div class="showcase-container">
              <flutter-cupertino-button variant="filled" @click="startBasicShowcase">Start Showcase</flutter-cupertino-button>
              <flutter-showcase-view ref="basicShowcase" @finish="onBasicFinish" class="showcase-view">
                <div class="target-element blue-bg basic-target">
                  <flutter-cupertino-icon type="info_circle_fill" color="#ffffff" size="30"></flutter-cupertino-icon>
                  <span>Basic Target</span>
                </div>
                <flutter-showcase-description>
                  <div class="description-container">
                    <h3>Welcome to ShowcaseView</h3>
                    <p>This is a simple tooltip to guide users in understanding interface features.</p>
                    <p>Click anywhere outside to close this tooltip.</p>
                  </div>
                </flutter-showcase-description>
              </flutter-showcase-view>
            </div>
          </div>

          <!-- Background Interaction Control -->
          <div class="component-item">
            <div class="item-label">Background Interaction Control</div>
            <div class="item-desc">Control whether clicking the background closes the tooltip</div>
            <div class="button-group">
              <flutter-cupertino-button variant="filled" @click="startInteractiveShowcase">Allow Background Click</flutter-cupertino-button>
              <flutter-cupertino-button variant="filled" @click="startNonInteractiveShowcase">Disable Background Click</flutter-cupertino-button>
            </div>
            <div class="showcase-row">
              <!-- 允许背景点击的 Showcase -->
              <div class="showcase-item">
                <flutter-showcase-view 
                  ref="interactiveShowcase" 
                  @finish="onInteractiveFinish" 
                  class="showcase-view"
                >
                  <div class="target-element blue-bg">
                    <span>Allow Background Click</span>
                    <p class="target-desc">Click mask to close</p>
                  </div>
                  <flutter-showcase-description>
                    <div class="description-container">
                      <h3>Allow Background Click</h3>
                      <p>This showcase allows users to close by clicking the background.</p>
                      <p>Try clicking anywhere outside this tooltip.</p>
                    </div>
                  </flutter-showcase-description>
                </flutter-showcase-view>
              </div>
              
              <!-- Disable Background Click -->
              <div class="showcase-item">
                <flutter-showcase-view 
                  ref="nonInteractiveShowcase" 
                  disableBarrierInteraction="true"
                  @finish="onNonInteractiveFinish" 
                  class="showcase-view"
                >
                  <div class="target-element red-bg">
                    <span>Disable Background Click</span>
                    <p class="target-desc">Mask clicks disabled</p>
                  </div>
                  <flutter-showcase-description>
                    <div class="description-container red-container">
                      <h3>Disable Background Click</h3>
                      <p>This showcase prevents users from closing by clicking the background.</p>
                      <p>Clicking outside this tooltip will have no effect.</p>
                      <div class="button-container">
                        <flutter-cupertino-button size="small" variant="filled" @click="closeNonInteractive">Close</flutter-cupertino-button>
                      </div>
                    </div>
                  </flutter-showcase-description>
                </flutter-showcase-view>
              </div>
            </div>
          </div>

          <!-- Tooltip Position Control -->
          <div class="component-item">
            <div class="item-label">Tooltip Position Control</div>
            <div class="item-desc">Tooltip position can be manually set or automatically determined</div>
            <div class="button-group">
              <flutter-cupertino-button variant="filled" @click="startTopShowcase">Show At Top</flutter-cupertino-button>
              <flutter-cupertino-button variant="filled" @click="startBottomShowcase">Show At Bottom</flutter-cupertino-button>
              <flutter-cupertino-button variant="filled" @click="startAutoShowcase">Auto-Determine Position</flutter-cupertino-button>
            </div>
            <div class="showcase-row">
              <!-- 提示框在上方 -->
              <div class="showcase-item">
                <flutter-showcase-view 
                  ref="topShowcase" 
                  tooltipPosition="top"
                  @finish="onTopFinish" 
                  class="showcase-view"
                >
                  <div class="target-element blue-bg">
                    <span>Tooltip At Top</span>
                  </div>
                  <flutter-showcase-description>
                    <div class="description-container">
                      <h3>Top Display</h3>
                      <p>This example uses tooltipPosition="top" to display the tooltip above the target element.</p>
                      <p>This is useful when the target element is near the bottom of the screen.</p>
                    </div>
                  </flutter-showcase-description>
                </flutter-showcase-view>
              </div>
              
              <!-- Tooltip At Bottom -->
              <div class="showcase-item">
                <flutter-showcase-view 
                  ref="bottomShowcase" 
                  tooltipPosition="bottom"
                  @finish="onBottomFinish" 
                  class="showcase-view"
                >
                  <div class="target-element green-bg">
                    <span>Tooltip At Bottom</span>
                  </div>
                  <flutter-showcase-description>
                    <div class="description-container green-container">
                      <h3>Bottom Display</h3>
                      <p>This example uses tooltipPosition="bottom" to display the tooltip below the target element.</p>
                      <p>This is useful when the target element is near the top of the screen.</p>
                    </div>
                  </flutter-showcase-description>
                </flutter-showcase-view>
              </div>
              
              <!-- Auto Position -->
              <div class="showcase-item">
                <flutter-showcase-view 
                  ref="autoShowcase"
                  @finish="onAutoFinish" 
                  class="showcase-view"
                >
                  <div class="target-element orange-bg">
                    <span>Auto Position</span>
                  </div>
                  <flutter-showcase-description>
                    <div class="description-container orange-container">
                      <h3>Automatic Position</h3>
                      <p>This example doesn't set the tooltipPosition attribute, so the component automatically determines whether to display the tooltip above or below the target based on its position on screen.</p>
                      <p>When the target is in the top half of the screen, the tooltip appears below; when in the bottom half, it appears above.</p>
                    </div>
                  </flutter-showcase-description>
                </flutter-showcase-view>
              </div>
            </div>
          </div>

          <!-- Multi-Step Guide (Background Click) -->
          <div class="component-item">
            <div class="item-label">Multi-Step Guide (Background Click)</div>
            <div class="item-desc">Multiple showcase items displayed in sequence</div>
            <flutter-cupertino-button variant="filled" @click="startMultistepShowcase">Start Multi-Step Guide</flutter-cupertino-button>
            <div class="showcase-row">
              <div class="showcase-item">
                <flutter-showcase-view ref="step1Showcase" @finish="onStep1Finish" class="showcase-view">
                  <div class="target-element blue-bg">
                    <span>Step 1</span>
                  </div>
                  <flutter-showcase-description>
                    <div class="description-container">
                      <h3>Step 1</h3>
                      <p>This is the first step of the multi-step guide.</p>
                      <p>Click the background to continue to the next step.</p>
                    </div>
                  </flutter-showcase-description>
                </flutter-showcase-view>
              </div>

              <div class="showcase-item">
                <flutter-showcase-view ref="step2Showcase" @finish="onStep2Finish" class="showcase-view">
                  <div class="target-element green-bg">
                    <span>Step 2</span>
                  </div>
                  <flutter-showcase-description>
                    <div class="description-container green-container">
                      <h3>Step 2</h3>
                      <p>This is the second step of the multi-step guide.</p>
                      <p>Click the background to continue to the next step.</p>
                    </div>
                  </flutter-showcase-description>
                </flutter-showcase-view>
              </div>

              <div class="showcase-item">
                <flutter-showcase-view ref="step3Showcase" @finish="onStep3Finish" class="showcase-view">
                  <div class="target-element orange-bg">
                    <span>Step 3</span>
                  </div>
                  <flutter-showcase-description>
                    <div class="description-container orange-container">
                      <h3>Step 3</h3>
                      <p>This is the final step of the multi-step guide.</p>
                      <p>Click the background to complete the guide.</p>
                    </div>
                  </flutter-showcase-description>
                </flutter-showcase-view>
              </div>
            </div>
          </div>

          <!-- Multi-Step Guide (Button Control) -->
          <div class="component-item">
            <div class="item-label">Multi-Step Guide (Button Control)</div>
            <div class="item-desc">Multiple showcase items displayed in sequence with button navigation</div>
            <flutter-cupertino-button variant="filled" @click="startMultistepShowcaseButton">Start Button-Controlled Guide</flutter-cupertino-button>
            <div class="showcase-row">
              <div class="showcase-item">
                <flutter-showcase-view ref="step1ShowcaseButton" disableBarrierInteraction class="showcase-view">
                  <div class="target-element blue-bg">
                    <span>Step 1</span>
                  </div>
                  <flutter-showcase-description>
                    <div class="description-container">
                      <h3>Step 1</h3>
                      <p>This is the first step of the button-controlled guide.</p>
                      <flutter-cupertino-button variant="filled" @click="moveToStep2">Continue</flutter-cupertino-button>
                    </div>
                  </flutter-showcase-description>
                </flutter-showcase-view>
              </div>

              <div class="showcase-item">
                <flutter-showcase-view ref="step2ShowcaseButton" disableBarrierInteraction class="showcase-view">
                  <div class="target-element green-bg">
                    <span>Step 2</span>
                  </div>
                  <flutter-showcase-description>
                    <div class="description-container green-container">
                      <h3>Step 2</h3>
                      <p>This is the second step of the button-controlled guide.</p>
                      <flutter-cupertino-button variant="filled" @click="moveToStep3">Continue</flutter-cupertino-button>
                    </div>
                  </flutter-showcase-description>
                </flutter-showcase-view>
              </div>

              <div class="showcase-item">
                <flutter-showcase-view ref="step3ShowcaseButton" disableBarrierInteraction class="showcase-view">
                  <div class="target-element orange-bg">
                    <span>Step 3</span>
                  </div>
                  <flutter-showcase-description>
                    <div class="description-container orange-container">
                      <h3>Step 3</h3>
                      <p>This is the final step of the button-controlled guide.</p>
                      <flutter-cupertino-button variant="filled" @click="onStep3End">Finish</flutter-cupertino-button>
                    </div>
                  </flutter-showcase-description>
                </flutter-showcase-view>
              </div>
            </div>
          </div>

          <!-- Button Event Control -->
          <div class="component-item">
            <div class="item-label">Button Event Control</div>
            <div class="item-desc">Control showcase behavior using buttons</div>
            <div class="showcase-container">
              <flutter-cupertino-button variant="filled" @click="startButtonDemo">Start Showcase</flutter-cupertino-button>
              <div class="showcase-row">
                <flutter-showcase-view 
                  ref="buttonShowcase" 
                  disableBarrierInteraction="true"
                  tooltipPosition="top"
                  @finish="onButtonDemoFinish" 
                  class="showcase-view"
                >
                  <div class="target-element purple-bg">
                    <span>Button Control</span>
                  </div>
                  <flutter-showcase-description>
                    <div class="description-container purple-container button-demo-container">
                      <h3>Button Control Demo</h3>
                      <p>This example uses a button to control the showcase behavior instead of background clicks.</p>
                      <p>It also uses tooltipPosition="top" to ensure the tooltip appears above the target element to avoid extending beyond the screen.</p>
                      <div class="button-row">
                        <flutter-cupertino-button size="small" variant="filled" @click="onButtonDemoClose">Close</flutter-cupertino-button>
                      </div>
                    </div>
                  </flutter-showcase-description>
                </flutter-showcase-view>
              </div>
            </div>
          </div>
        </div>
      </div>
    </webf-listview>
  </div>
</template>

<script>
export default {
  name: 'HighlightPage',
  methods: {
    startBasicShowcase() {
      console.log('startBasicShowcase', this.$refs.basicShowcase.start);
      this.$refs.basicShowcase.start();
    },
    onBasicFinish() {
      console.log('Basic example completed');
    },

    startInteractiveShowcase() {
      console.log('startInteractiveShowcase', this.$refs.interactiveShowcase);
      this.$refs.interactiveShowcase.start();
    },
    startNonInteractiveShowcase() {
      this.$refs.nonInteractiveShowcase.start();
    },
    onInteractiveFinish() {
      console.log('Interactive background example completed');
    },
    onNonInteractiveFinish() {
      console.log('Non-interactive background example completed');
    },
    closeNonInteractive() {
      this.$refs.nonInteractiveShowcase.dismiss();
    },

    startMultistepShowcase() {
      this.$refs.step1Showcase.start();
    },
    onStep1Finish() {
      console.log('Step 1 completed');
      this.$refs.step2Showcase.start();
    },
    onStep2Finish() {
      console.log('Step 2 completed');
      this.$refs.step3Showcase.start();
    },
    onStep3Finish() {
      console.log('Step 3 completed');
      this.$refs.step3Showcase.dismiss();
    },

    startMultistepShowcaseButton() {
      this.$refs.step1ShowcaseButton.start();
    },
    moveToStep2() {
      this.$refs.step1ShowcaseButton.dismiss();
      this.$refs.step2ShowcaseButton.start();
    },
    moveToStep3() {
      this.$refs.step2ShowcaseButton.dismiss();
      this.$refs.step3ShowcaseButton.start();
    },
    onStep3End() {
      this.$refs.step3ShowcaseButton.dismiss();
    },
    startButtonDemo() {
      this.$refs.buttonShowcase.start();
    },
    onButtonDemoFinish() {
      console.log('Button control example completed');
    },
    onButtonDemoClose() {
      this.$refs.buttonShowcase.dismiss();
    },

    startTopShowcase() {
      this.$refs.topShowcase.start();
    },
    startBottomShowcase() {
      this.$refs.bottomShowcase.start();
    },
    startAutoShowcase() {
      this.$refs.autoShowcase.start();
    },
    onTopFinish() {
      console.log('Top tooltip example completed');
    },
    onBottomFinish() {
      console.log('Bottom tooltip example completed');
    },
    onAutoFinish() {
      console.log('Auto-position tooltip example completed');
    }
  }
}
</script>

<style scoped>
#list {
  padding: 10px 0;
  height: 100vh;
  width: 100vw;
  background-color: var(--background-primary);
}

.component-section {
  padding: 16px;
  margin-bottom: 8px;
}

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
}

.component-item {
  margin-bottom: 32px;
}

.component-item:last-child {
  margin-bottom: 0;
}

.item-label {
  font-size: 16px;
  font-weight: 500;
  color: var(--font-color-primary);
  margin-bottom: 8px;
}

.item-desc {
  font-size: 14px;
  color: var(--font-color-secondary);
  margin-bottom: 16px;
}

.showcase-container {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.showcase-container > * {
  margin-bottom: 20px;
}

.showcase-container > *:last-child {
  margin-bottom: 0;
}

.showcase-row {
  display: flex;
  flex-wrap: wrap;
  flex-direction: row;
  margin-top: 20px;
  justify-content: flex-start;
}

.showcase-item {
  width: 140px;
  margin-right: 20px;
  margin-bottom: 20px;
}

.showcase-view {
  margin: 0 auto;
}

.target-element {
  width: 120px;
  height: 80px;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 500;
  margin: 10px;
}

.basic-target {
  flex-direction: row;
}

.target-desc {
  font-size: 12px;
  margin-top: 4px;
  font-weight: normal;
}

.blue-bg {
  background-color: #1677ff;
}

.red-bg {
  background-color: #ff4d4f;
}

.green-bg {
  background-color: #52c41a;
}

.orange-bg {
  background-color: #fa8c16;
}

.purple-bg {
  background-color: #722ed1;
}

.description-container {
  background-color: #f0f8ff;
  border: 1px solid #91caff;
  padding: 15px;
  border-radius: 8px;
  max-width: 300px;
}

.red-container {
  background-color: #fff1f0;
  border-color: #ffa39e;
}

.red-container h3 {
  color: #ff4d4f;
}

.green-container {
  background-color: #f6ffed;
  border-color: #b7eb8f;
}

.green-container h3 {
  color: #52c41a;
}

.orange-container {
  background-color: #fff7e6;
  border-color: #ffd591;
}

.orange-container h3 {
  color: #fa8c16;
}

.purple-container {
  background-color: #f9f0ff;
  border-color: #d3adf7;
}

.purple-container h3 {
  color: #722ed1;
}

h3 {
  margin-top: 0;
  margin-bottom: 10px;
  color: #1677ff;
}

.button-group {
  display: flex;
  flex-wrap: wrap;
}

.button-group > * {
  margin-right: 12px;
  margin-bottom: 12px;
}

.button-group > *:last-child {
  margin-right: 0;
}

.button-container, 
.button-row {
  margin-top: 12px;
  display: flex;
  justify-content: center;
}

.button-demo-container {
  min-width: 250px;
}
</style>