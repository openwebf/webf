import React, { useRef } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterShowcaseView, FlutterShowcaseDescription } from '@openwebf/react-ui-kit';
import {CupertinoIcons, FlutterCupertinoButton, FlutterCupertinoIcon} from '@openwebf/react-cupertino-ui';
import styles from './ShowCasePage.module.css';

export const ShowCasePage: React.FC = () => {
  const basicShowcaseRef = useRef<any>(null);
  const interactiveShowcaseRef = useRef<any>(null);
  const nonInteractiveShowcaseRef = useRef<any>(null);
  const topShowcaseRef = useRef<any>(null);
  const bottomShowcaseRef = useRef<any>(null);
  const autoShowcaseRef = useRef<any>(null);
  const step1ShowcaseRef = useRef<any>(null);
  const step2ShowcaseRef = useRef<any>(null);
  const step3ShowcaseRef = useRef<any>(null);
  const step1ShowcaseButtonRef = useRef<any>(null);
  const step2ShowcaseButtonRef = useRef<any>(null);
  const step3ShowcaseButtonRef = useRef<any>(null);
  const buttonShowcaseRef = useRef<any>(null);

  const startBasicShowcase = () => {
    basicShowcaseRef.current?.start();
  };

  const onBasicFinish = () => {
    console.log('Basic example completed');
  };

  const startInteractiveShowcase = () => {
    console.log('🚀 startInteractiveShowcase clicked!', interactiveShowcaseRef.current);
    interactiveShowcaseRef.current?.start();
  };

  const startNonInteractiveShowcase = () => {
    console.log('🚀 startNonInteractiveShowcase clicked!');
    nonInteractiveShowcaseRef.current?.start();
  };

  const onInteractiveFinish = () => {
    console.log('Interactive background example completed');
  };

  const onNonInteractiveFinish = () => {
    console.log('Non-interactive background example completed');
  };

  const closeNonInteractive = () => {
    nonInteractiveShowcaseRef.current?.dismiss();
  };

  const startMultistepShowcase = () => {
    step1ShowcaseRef.current?.start();
  };

  const onStep1Finish = () => {
    console.log('Step 1 completed');
    step2ShowcaseRef.current?.start();
  };

  const onStep2Finish = () => {
    console.log('Step 2 completed');
    step3ShowcaseRef.current?.start();
  };

  const onStep3Finish = () => {
    console.log('Step 3 completed');
    step3ShowcaseRef.current?.dismiss();
  };

  const startMultistepShowcaseButton = () => {
    step1ShowcaseButtonRef.current?.start();
  };

  const moveToStep2 = () => {
    step1ShowcaseButtonRef.current?.dismiss();
    step2ShowcaseButtonRef.current?.start();
  };

  const moveToStep3 = () => {
    step2ShowcaseButtonRef.current?.dismiss();
    step3ShowcaseButtonRef.current?.start();
  };

  const onStep3End = () => {
    step3ShowcaseButtonRef.current?.dismiss();
  };

  const startButtonDemo = () => {
    buttonShowcaseRef.current?.start();
  };

  const onButtonDemoFinish = () => {
    console.log('Button control example completed');
  };

  const onButtonDemoClose = () => {
    buttonShowcaseRef.current?.dismiss();
  };

  const startTopShowcase = () => {
    topShowcaseRef.current?.start();
  };

  const startBottomShowcase = () => {
    bottomShowcaseRef.current?.start();
  };

  const startAutoShowcase = () => {
    autoShowcaseRef.current?.start();
  };

  const onTopFinish = () => {
    console.log('Top tooltip example completed');
  };

  const onBottomFinish = () => {
    console.log('Bottom tooltip example completed');
  };

  const onAutoFinish = () => {
    console.log('Auto-position tooltip example completed');
  };

  return (
    <div id="main">
      <WebFListView className={`${styles.list} ${styles.componentSection}`}>
        <div className={styles.sectionTitle}>Showcase</div>
        <div className={styles.componentBlock}>
            {/* Basic Example */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Basic Example</div>
              <div className={styles.itemDesc}>Demonstrates the basic functionality of ShowcaseView</div>
              <div className={styles.showcaseContainer}>
                <FlutterCupertinoButton variant="filled" onClick={startBasicShowcase}>
                  Start Showcase
                </FlutterCupertinoButton>
                <FlutterShowcaseView ref={basicShowcaseRef} onFinish={onBasicFinish} className={styles.showcaseView}>
                  <div className={`${styles.targetElement} ${styles.blueBg} ${styles.basicTarget}`}>
                    <FlutterCupertinoIcon style={{fontSize: '30px', color: '#ffffff'}} type={CupertinoIcons.circle_fill} />
                    <span>Basic Target</span>
                  </div>
                  <FlutterShowcaseDescription>
                    <div className={styles.descriptionContainer}>
                      <h3>Welcome to ShowcaseView</h3>
                      <p>This is a simple tooltip to guide users in understanding interface features.</p>
                      <p>Click anywhere outside to close this tooltip.</p>
                    </div>
                  </FlutterShowcaseDescription>
                </FlutterShowcaseView>
              </div>
            </div>

            {/* Background Interaction Control */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Background Interaction Control</div>
              <div className={styles.itemDesc}>Control whether clicking the background closes the tooltip</div>
              <div className={styles.buttonGroup}>
                <FlutterCupertinoButton variant="filled" onClick={startInteractiveShowcase}>
                  Allow Background Click
                </FlutterCupertinoButton>
                <FlutterCupertinoButton variant="filled" onClick={startNonInteractiveShowcase}>
                  Disable Background Click
                </FlutterCupertinoButton>
              </div>
              <div className={styles.showcaseRow}>
                {/* Allow background click showcase */}
                <div className={styles.showcaseItem}>
                  <FlutterShowcaseView
                    ref={interactiveShowcaseRef}
                    onFinish={onInteractiveFinish}
                    className={styles.showcaseView}
                  >
                    <div className={`${styles.targetElement} ${styles.blueBg}`}>
                      <span>Allow Background Click</span>
                      <p className={styles.targetDesc}>Click mask to close</p>
                    </div>
                    <FlutterShowcaseDescription>
                      <div className={styles.descriptionContainer}>
                        <h3>Allow Background Click</h3>
                        <p>This showcase allows users to close by clicking the background.</p>
                        <p>Try clicking anywhere outside this tooltip.</p>
                      </div>
                    </FlutterShowcaseDescription>
                  </FlutterShowcaseView>
                </div>

                {/* Disable Background Click */}
                <div className={styles.showcaseItem}>
                  <FlutterShowcaseView
                    ref={nonInteractiveShowcaseRef}
                    disableBarrierInteraction={true}
                    onFinish={onNonInteractiveFinish}
                    className={styles.showcaseView}
                  >
                    <div className={`${styles.targetElement} ${styles.redBg}`}>
                      <span>Disable Background Click</span>
                      <p className={styles.targetDesc}>Mask clicks disabled</p>
                    </div>
                    <FlutterShowcaseDescription>
                      <div className={`${styles.descriptionContainer} ${styles.redContainer}`}>
                        <h3>Disable Background Click</h3>
                        <p>This showcase prevents users from closing by clicking the background.</p>
                        <p>Clicking outside this tooltip will have no effect.</p>
                        <div className={styles.buttonContainer}>
                          <FlutterCupertinoButton size="small" variant="filled" onClick={closeNonInteractive}>
                            Close
                          </FlutterCupertinoButton>
                        </div>
                      </div>
                    </FlutterShowcaseDescription>
                  </FlutterShowcaseView>
                </div>
              </div>
            </div>

            {/* Tooltip Position Control */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Tooltip Position Control</div>
              <div className={styles.itemDesc}>Tooltip position can be manually set or automatically determined</div>
              <div className={styles.buttonGroup}>
                <FlutterCupertinoButton variant="filled" onClick={startTopShowcase}>
                  Show At Top
                </FlutterCupertinoButton>
                <FlutterCupertinoButton variant="filled" onClick={startBottomShowcase}>
                  Show At Bottom
                </FlutterCupertinoButton>
                <FlutterCupertinoButton variant="filled" onClick={startAutoShowcase}>
                  Auto-Determine Position
                </FlutterCupertinoButton>
              </div>
              <div className={styles.showcaseRow}>
                {/* Tooltip at top */}
                <div className={styles.showcaseItem}>
                  <FlutterShowcaseView
                    ref={topShowcaseRef}
                    tooltipPosition="top"
                    onFinish={onTopFinish}
                    className={styles.showcaseView}
                  >
                    <div className={`${styles.targetElement} ${styles.blueBg}`}>
                      <span>Tooltip At Top</span>
                    </div>
                    <FlutterShowcaseDescription>
                      <div className={styles.descriptionContainer}>
                        <h3>Top Display</h3>
                        <p>This example uses tooltipPosition="top" to display the tooltip above the target element.</p>
                        <p>This is useful when the target element is near the bottom of the screen.</p>
                      </div>
                    </FlutterShowcaseDescription>
                  </FlutterShowcaseView>
                </div>

                {/* Tooltip At Bottom */}
                <div className={styles.showcaseItem}>
                  <FlutterShowcaseView
                    ref={bottomShowcaseRef}
                    tooltipPosition="bottom"
                    onFinish={onBottomFinish}
                    className={styles.showcaseView}
                  >
                    <div className={`${styles.targetElement} ${styles.greenBg}`}>
                      <span>Tooltip At Bottom</span>
                    </div>
                    <FlutterShowcaseDescription>
                      <div className={`${styles.descriptionContainer} ${styles.greenContainer}`}>
                        <h3>Bottom Display</h3>
                        <p>This example uses tooltipPosition="bottom" to display the tooltip below the target element.</p>
                        <p>This is useful when the target element is near the top of the screen.</p>
                      </div>
                    </FlutterShowcaseDescription>
                  </FlutterShowcaseView>
                </div>

                {/* Auto Position */}
                <div className={styles.showcaseItem}>
                  <FlutterShowcaseView
                    ref={autoShowcaseRef}
                    onFinish={onAutoFinish}
                    className={styles.showcaseView}
                  >
                    <div className={`${styles.targetElement} ${styles.orangeBg}`}>
                      <span>Auto Position</span>
                    </div>
                    <FlutterShowcaseDescription>
                      <div className={`${styles.descriptionContainer} ${styles.orangeContainer}`}>
                        <h3>Automatic Position</h3>
                        <p>This example doesn't set the tooltipPosition attribute, so the component automatically determines whether to display the tooltip above or below the target based on its position on screen.</p>
                        <p>When the target is in the top half of the screen, the tooltip appears below; when in the bottom half, it appears above.</p>
                      </div>
                    </FlutterShowcaseDescription>
                  </FlutterShowcaseView>
                </div>
              </div>
            </div>

            {/* Multi-Step Guide (Background Click) */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Multi-Step Guide (Background Click)</div>
              <div className={styles.itemDesc}>Multiple showcase items displayed in sequence</div>
              <FlutterCupertinoButton variant="filled" onClick={startMultistepShowcase}>
                Start Multi-Step Guide
              </FlutterCupertinoButton>
              <div className={styles.showcaseRow}>
                <div className={styles.showcaseItem}>
                  <FlutterShowcaseView ref={step1ShowcaseRef} onFinish={onStep1Finish} className={styles.showcaseView}>
                    <div className={`${styles.targetElement} ${styles.blueBg}`}>
                      <span>Step 1</span>
                    </div>
                    <FlutterShowcaseDescription>
                      <div className={styles.descriptionContainer}>
                        <h3>Step 1</h3>
                        <p>This is the first step of the multi-step guide.</p>
                        <p>Click the background to continue to the next step.</p>
                      </div>
                    </FlutterShowcaseDescription>
                  </FlutterShowcaseView>
                </div>

                <div className={styles.showcaseItem}>
                  <FlutterShowcaseView ref={step2ShowcaseRef} onFinish={onStep2Finish} className={styles.showcaseView}>
                    <div className={`${styles.targetElement} ${styles.greenBg}`}>
                      <span>Step 2</span>
                    </div>
                    <FlutterShowcaseDescription>
                      <div className={`${styles.descriptionContainer} ${styles.greenContainer}`}>
                        <h3>Step 2</h3>
                        <p>This is the second step of the multi-step guide.</p>
                        <p>Click the background to continue to the next step.</p>
                      </div>
                    </FlutterShowcaseDescription>
                  </FlutterShowcaseView>
                </div>

                <div className={styles.showcaseItem}>
                  <FlutterShowcaseView ref={step3ShowcaseRef} onFinish={onStep3Finish} className={styles.showcaseView}>
                    <div className={`${styles.targetElement} ${styles.orangeBg}`}>
                      <span>Step 3</span>
                    </div>
                    <FlutterShowcaseDescription>
                      <div className={`${styles.descriptionContainer} ${styles.orangeContainer}`}>
                        <h3>Step 3</h3>
                        <p>This is the final step of the multi-step guide.</p>
                        <p>Click the background to complete the guide.</p>
                      </div>
                    </FlutterShowcaseDescription>
                  </FlutterShowcaseView>
                </div>
              </div>
            </div>

            {/* Multi-Step Guide (Button Control) */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Multi-Step Guide (Button Control)</div>
              <div className={styles.itemDesc}>Multiple showcase items displayed in sequence with button navigation</div>
              <FlutterCupertinoButton variant="filled" onClick={startMultistepShowcaseButton}>
                Start Button-Controlled Guide
              </FlutterCupertinoButton>
              <div className={styles.showcaseRow}>
                <div className={styles.showcaseItem}>
                  <FlutterShowcaseView ref={step1ShowcaseButtonRef} disableBarrierInteraction={true} className={styles.showcaseView}>
                    <div className={`${styles.targetElement} ${styles.blueBg}`}>
                      <span>Step 1</span>
                    </div>
                    <FlutterShowcaseDescription>
                      <div className={styles.descriptionContainer}>
                        <h3>Step 1</h3>
                        <p>This is the first step of the button-controlled guide.</p>
                        <FlutterCupertinoButton variant="filled" onClick={moveToStep2}>
                          Continue
                        </FlutterCupertinoButton>
                      </div>
                    </FlutterShowcaseDescription>
                  </FlutterShowcaseView>
                </div>

                <div className={styles.showcaseItem}>
                  <FlutterShowcaseView ref={step2ShowcaseButtonRef} disableBarrierInteraction={true} className={styles.showcaseView}>
                    <div className={`${styles.targetElement} ${styles.greenBg}`}>
                      <span>Step 2</span>
                    </div>
                    <FlutterShowcaseDescription>
                      <div className={`${styles.descriptionContainer} ${styles.greenContainer}`}>
                        <h3>Step 2</h3>
                        <p>This is the second step of the button-controlled guide.</p>
                        <FlutterCupertinoButton variant="filled" onClick={moveToStep3}>
                          Continue
                        </FlutterCupertinoButton>
                      </div>
                    </FlutterShowcaseDescription>
                  </FlutterShowcaseView>
                </div>

                <div className={styles.showcaseItem}>
                  <FlutterShowcaseView ref={step3ShowcaseButtonRef} disableBarrierInteraction={true} className={styles.showcaseView}>
                    <div className={`${styles.targetElement} ${styles.orangeBg}`}>
                      <span>Step 3</span>
                    </div>
                    <FlutterShowcaseDescription>
                      <div className={`${styles.descriptionContainer} ${styles.orangeContainer}`}>
                        <h3>Step 3</h3>
                        <p>This is the final step of the button-controlled guide.</p>
                        <FlutterCupertinoButton variant="filled" onClick={onStep3End}>
                          Finish
                        </FlutterCupertinoButton>
                      </div>
                    </FlutterShowcaseDescription>
                  </FlutterShowcaseView>
                </div>
              </div>
            </div>

            {/* Button Event Control */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Button Event Control</div>
              <div className={styles.itemDesc}>Control showcase behavior using buttons</div>
              <div className={styles.showcaseContainer}>
                <FlutterCupertinoButton variant="filled" onClick={startButtonDemo}>
                  Start Showcase
                </FlutterCupertinoButton>
                <div className={styles.showcaseRow}>
                  <FlutterShowcaseView
                    ref={buttonShowcaseRef}
                    disableBarrierInteraction={true}
                    tooltipPosition="top"
                    onFinish={onButtonDemoFinish}
                    className={styles.showcaseView}
                  >
                    <div className={`${styles.targetElement} ${styles.purpleBg}`}>
                      <span>Button Control</span>
                    </div>
                    <FlutterShowcaseDescription>
                      <div className={`${styles.descriptionContainer} ${styles.purpleContainer} ${styles.buttonDemoContainer}`}>
                        <h3>Button Control Demo</h3>
                        <p>This example uses a button to control the showcase behavior instead of background clicks.</p>
                        <p>It also uses tooltipPosition="top" to ensure the tooltip appears above the target element to avoid extending beyond the screen.</p>
                        <div className={styles.buttonRow}>
                          <FlutterCupertinoButton size="small" variant="filled" onClick={onButtonDemoClose}>
                            Close
                          </FlutterCupertinoButton>
                        </div>
                      </div>
                    </FlutterShowcaseDescription>
                  </FlutterShowcaseView>
                </div>
              </div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
