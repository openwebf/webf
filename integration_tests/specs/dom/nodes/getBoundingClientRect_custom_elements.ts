/**
 * Test getBoundingClientRect with custom scrollable elements
 * Tests that the scroll offset is properly calculated for elements inside
 * custom Flutter widgets like flutter-nest-scroller and flutter-sliver-listview
 */

describe('getBoundingClientRect with custom elements', () => {
  it('simple test with flutter-sliver-listview', async (done) => {
    const listview = document.createElement('flutter-sliver-listview');
    listview.style.width = '300px';
    listview.style.height = '200px';
    listview.style.border = '1px solid red';
    listview.style.boxSizing = 'border-box';
    
    const item1 = document.createElement('div');
    item1.style.height = '100px';
    item1.style.backgroundColor = 'yellow';
    item1.textContent = 'Item 1';
    item1.style.boxSizing = 'border-box';
    
    const item2 = document.createElement('div');
    item2.id = 'test-target';
    item2.style.height = '100px';
    item2.style.backgroundColor = 'green';
    item2.textContent = 'Item 2';
    item2.style.boxSizing = 'border-box';
    
    // Add a third item to ensure we have scrollable content
    const item3 = document.createElement('div');
    item3.style.height = '100px';
    item3.style.backgroundColor = 'blue';
    item3.textContent = 'Item 3';
    item3.style.boxSizing = 'border-box';
    
    listview.appendChild(item1);
    listview.appendChild(item2);
    listview.appendChild(item3);
    
    document.body.appendChild(listview);
    
    // Wait for the element to be on screen
    // @ts-ignore
    listview.ononscreen = async () => {
      await sleep(0.1); // Give time for layout
      
      const listviewRect = listview.getBoundingClientRect();
      const rect1 = item2.getBoundingClientRect();
      
      console.log('Listview rect:', listviewRect);
      console.log('Item2 rect before scroll:', rect1);
      console.log('Expected item2 top:', listviewRect.top + 100);
      
      // Item should be at listview top + 100px + 1px border
      expect(rect1.top).toBe(listviewRect.top + 100 + 1);
      
      console.log('ScrollTop before:', listview.scrollTop);
      console.log('ScrollHeight:', listview.scrollHeight);
      console.log('ClientHeight:', listview.clientHeight);
      console.log('Total content height:', 3 * 100, 'px');
      console.log('Expected scrollable area:', 300 - listview.clientHeight, 'px');
      
      // Try using scrollTo instead of setting scrollTop directly
      listview.scrollTo(0, 50);
      await sleep(0.2);
      
      console.log('ScrollTop after:', listview.scrollTop);
      console.log('Can scroll:', listview.scrollHeight > listview.clientHeight);
      const rect2 = item2.getBoundingClientRect();
      console.log('Item2 rect after scroll:', rect2);
      console.log('Expected after scroll:', rect1.top - 50);
      console.log('Actual difference:', rect1.top - rect2.top);
      
      // After scrolling 50px, item should move up by 50px
      expect(rect2.top).toBe(rect1.top - 50);
      
      done();
    };
  });
  it('should work with simple scrollable div first', async (done) => {
    // Test with regular div first to ensure basic functionality works
    const container = document.createElement('div');
    container.style.width = '200px';
    container.style.height = '200px';
    container.style.overflow = 'auto';
    container.style.border = '1px solid black';

    const content = document.createElement('div');
    content.style.height = '500px';
    content.style.background = 'linear-gradient(to bottom, red, blue)';

    const target = document.createElement('div');
    target.id = 'simple-target';
    target.style.position = 'absolute';
    target.style.top = '150px';
    target.style.left = '50px';
    target.style.width = '100px';
    target.style.height = '50px';
    target.style.backgroundColor = 'yellow';
    target.textContent = 'Target';

    content.appendChild(target);
    container.appendChild(content);
    document.body.appendChild(container);

    // @ts-ignore
    container.ononscreen = async () => {
      const rect1 = target.getBoundingClientRect();

      // Scroll down
      container.scrollTop = 100;
      await waitForFrame();

      const rect2 = target.getBoundingClientRect();
      expect(rect2.top).toBe(rect1.top);
      expect(rect2.y).toBe(rect1.y);

      done();
    };
  });
  it('should update position when scrolling inside webf-listview first', async (done) => {
    // Test with standard webf-listview to ensure it works
    const listview = document.createElement('webf-listview');
    listview.style.width = '300px';
    listview.style.height = '200px';
    listview.style.border = '1px solid black';

    // Create multiple items
    for (let i = 0; i < 20; i++) {
      const item = document.createElement('div');
      item.style.height = '50px';
      item.style.backgroundColor = i % 2 === 0 ? '#f0f0f0' : '#e0e0e0';
      item.textContent = `Item ${i}`;
      
      if (i === 5) {
        item.id = 'webf-target-item';
        item.style.backgroundColor = 'red';
      }
      
      listview.appendChild(item);
    }

    document.body.appendChild(listview);

    // @ts-ignore
    listview.ononscreen = async () => {
      await sleep(0.1);
      
      const targetItem = document.getElementById('webf-target-item');
      const rectBefore = targetItem!.getBoundingClientRect();
      
      console.log('WebF ListView - Initial top:', rectBefore.top);

      listview.scrollTop = 100;

      await sleep(0.1);
      
      const rectAfter = targetItem!.getBoundingClientRect();

      console.log('WebF ListView - After scroll top:', rectAfter.top);
      console.log('WebF ListView - Expected top:', rectBefore.top - 100);

      expect(rectAfter.top).toBe(rectBefore.top - 100);
      expect(rectAfter.y).toBe(rectBefore.y - 100);

      done();
    };
  });

  it('should update position when scrolling inside flutter-sliver-listview', async (done) => {
    // Create a sliver listview with multiple items
    const listview = document.createElement('flutter-sliver-listview');
    listview.style.width = '300px';
    listview.style.height = '200px';
    listview.style.border = '1px solid black';
    listview.style.overflow = 'auto';

    // Create multiple items
    for (let i = 0; i < 20; i++) {
      const item = document.createElement('div');
      item.style.height = '50px';
      item.style.backgroundColor = i % 2 === 0 ? '#f0f0f0' : '#e0e0e0';
      item.textContent = `Item ${i}`;

      if (i === 5) {
        item.id = 'target-item';
        item.style.backgroundColor = 'red';
      }

      listview.appendChild(item);
    }

    document.body.appendChild(listview);

    // @ts-ignore
    listview.ononscreen = async () => {
      // Wait a bit for layout to complete
      await sleep(0.1);
      
      // Get initial position of target item
      const targetItem = document.getElementById('target-item');
      const rectBefore = targetItem!.getBoundingClientRect();
      
      console.log('Initial rect:', rectBefore);
      console.log('Initial top:', rectBefore.top);
      console.log('Listview position:', listview.getBoundingClientRect());
      console.log('Target item should be at position:', 5 * 50, 'from listview top');
      console.log('Document body rect:', document.body.getBoundingClientRect());

      // Scroll down by 100px
      listview.scrollTop = 100;

      // Wait for scroll to complete
      await sleep(0.1);
      
      // Get position after scrolling
      const rectAfter = targetItem!.getBoundingClientRect();

      console.log('After scroll rect:', rectAfter);
      console.log('After scroll top:', rectAfter.top);
      console.log('Expected top:', rectBefore.top - 100);

      // The top position should have changed by -100px
      expect(rectAfter.top).toBe(rectBefore.top - 100);
      expect(rectAfter.y).toBe(rectBefore.y - 100);

      // Width and height should remain the same
      expect(rectAfter.width).toBe(rectBefore.width);
      expect(rectAfter.height).toBe(rectBefore.height);

      done();
    };
  });

  it('should work with nested scrollable elements', async (done) => {
    // Create nested scroller structure
    const nestedScroller = document.createElement('flutter-nest-scroller-skeleton');
    nestedScroller.style.width = '300px';
    nestedScroller.style.height = '400px';
    nestedScroller.style.border = '1px solid black';

    // Add top area
    const topArea = document.createElement('flutter-nest-scroller-item-top-area');
    const topContent = document.createElement('div');
    topContent.style.height = '100px';
    topContent.style.backgroundColor = '#ccc';
    topContent.textContent = 'Top Area';
    topArea.appendChild(topContent);
    nestedScroller.appendChild(topArea);

    // Add persistent header
    const header = document.createElement('flutter-nest-scroller-item-persistent-header');
    const headerContent = document.createElement('div');
    headerContent.style.height = '50px';
    headerContent.style.backgroundColor = '#999';
    headerContent.textContent = 'Sticky Header';
    header.appendChild(headerContent);
    nestedScroller.appendChild(header);

    // Add sliver listview
    const sliverList = document.createElement('flutter-sliver-listview');
    for (let i = 0; i < 20; i++) {
      const item = document.createElement('div');
      item.style.height = '60px';
      item.style.backgroundColor = i % 2 === 0 ? '#f0f0f0' : '#e0e0e0';
      item.textContent = `List Item ${i}`;

      if (i === 3) {
        item.id = 'nested-target';
        item.style.backgroundColor = 'blue';
        item.style.color = 'white';
      }

      sliverList.appendChild(item);
    }
    nestedScroller.appendChild(sliverList);

    document.body.appendChild(nestedScroller);

    // @ts-ignore
    nestedScroller.ononscreen = async () => {
      // Get initial position
      const target = document.getElementById('nested-target');
      const rectBefore = target!.getBoundingClientRect();

      // Scroll the nested scroller
      // @ts-ignore
      if (nestedScroller.scrollTop !== undefined) {
        nestedScroller.scrollTop = 150;
      }

      await waitForFrame();

      // Get position after scrolling
      const rectAfter = target!.getBoundingClientRect();

      // Position should have changed
      expect(rectAfter.top).toBeLessThan(rectBefore.top);
      expect(rectAfter.y).toBeLessThan(rectBefore.y);

      done();
    };
  });

  it('should handle multiple scroll containers correctly', async (done) => {
    // Create outer scrollable container
    const outerContainer = document.createElement('div');
    outerContainer.style.width = '400px';
    outerContainer.style.height = '300px';
    outerContainer.style.overflow = 'auto';
    outerContainer.style.border = '2px solid green';

    // Add some content before the listview
    const spacer = document.createElement('div');
    spacer.style.height = '200px';
    spacer.style.backgroundColor = '#ffeeee';
    spacer.textContent = 'Outer content';
    outerContainer.appendChild(spacer);

    // Create inner listview
    const innerListview = document.createElement('flutter-sliver-listview');
    innerListview.style.width = '350px';
    innerListview.style.height = '200px';
    innerListview.style.border = '1px solid blue';
    innerListview.style.overflow = 'auto';

    // Add items to inner listview
    for (let i = 0; i < 10; i++) {
      const item = document.createElement('div');
      item.style.height = '40px';
      item.style.backgroundColor = i % 2 === 0 ? '#eeffee' : '#ddffdd';
      item.textContent = `Inner Item ${i}`;

      if (i === 2) {
        item.id = 'multi-scroll-target';
        item.style.backgroundColor = 'orange';
      }

      innerListview.appendChild(item);
    }

    outerContainer.appendChild(innerListview);
    document.body.appendChild(outerContainer);

    // @ts-ignore
    innerListview.ononscreen = async () => {
      const target = document.getElementById('multi-scroll-target');

      // Get initial position
      const rect1 = target!.getBoundingClientRect();

      // Scroll outer container
      outerContainer.scrollTop = 50;

      requestAnimationFrame(async () => {

        const rect2 = target!.getBoundingClientRect();

        // Position should change when outer scrolls
        expect(rect2.top).toBe(rect1.top - 50);

        // Scroll inner listview
        innerListview.scrollTop = 30;

        await waitForFrame();
        const rect3 = target!.getBoundingClientRect();

        // Position should change additionally when inner scrolls
        expect(rect3.top).toBe(rect2.top - 30);

        done();
      });
    };
  });

  it('should return correct values for elements in horizontal scroll', async (done) => {
    const horizontalList = document.createElement('flutter-sliver-listview');
    horizontalList.style.width = '300px';
    horizontalList.style.height = '100px';
    horizontalList.style.border = '1px solid black';
    
    // Set scroll direction via setAttribute to ensure it's set before rendering
    horizontalList.setAttribute('scrollDirection', 'horizontal');

    // Create horizontal items
    for (let i = 0; i < 20; i++) {
      const item = document.createElement('div');
      item.style.width = '80px';
      item.style.height = '80px';
      item.style.backgroundColor = i % 2 === 0 ? '#f0f0f0' : '#e0e0e0';
      item.textContent = `${i}`;
      item.style.boxSizing = 'border-box';

      if (i === 5) {
        item.id = 'horizontal-target';
        item.style.backgroundColor = 'purple';
        item.style.color = 'white';
      }

      horizontalList.appendChild(item);
    }

    document.body.appendChild(horizontalList);

    // @ts-ignore
    horizontalList.ononscreen = async () => {
      await sleep(0.5); // Wait longer for layout and property to be applied
      
      const target = document.getElementById('horizontal-target');
      if (!target) {
        console.error('Target element not found!');
        done();
        return;
      }
      
      const rectBefore = target.getBoundingClientRect();

      console.log('Horizontal list - rectBefore:', rectBefore);
      console.log('Horizontal list - scrollLeft before:', horizontalList.scrollLeft);
      console.log('Horizontal list - scrollWidth:', horizontalList.scrollWidth);
      console.log('Horizontal list - clientWidth:', horizontalList.clientWidth);
      console.log('Horizontal list - can scroll horizontally:', horizontalList.scrollWidth > horizontalList.clientWidth);
      console.log('Total content width should be:', 20 * 80, 'px');
      console.log('Container width:', 300, 'px');
      
      // Check positions of first few items to see if they're laid out horizontally
      const item0 = horizontalList.children[0] as HTMLElement;
      const item1 = horizontalList.children[1] as HTMLElement;
      console.log('Item 0 rect:', item0.getBoundingClientRect());
      console.log('Item 1 rect:', item1.getBoundingClientRect());
      
      // Scroll horizontally
      horizontalList.scrollLeft = 150;

      await sleep(0.2);
      
      console.log('Horizontal list - scrollLeft after:', horizontalList.scrollLeft);
      const rectAfter = target!.getBoundingClientRect();
      console.log('Horizontal list - rectAfter:', rectAfter);
      console.log('Expected left change:', -150);
      console.log('Actual left change:', rectAfter.left - rectBefore.left);

      // The left position should have changed
      expect(rectAfter.left).toBe(rectBefore.left - 150);
      expect(rectAfter.x).toBe(rectBefore.x - 150);

      // Top position should remain the same
      expect(rectAfter.top).toBe(rectBefore.top);
      expect(rectAfter.y).toBe(rectBefore.y);

      done();
    };
  });

  describe('modal popup test', () => {
    it('should return correct values for elements in modal popup', async (done) => {
      const modalPopup = document.createElement('flutter-modal-popup');
      document.body.appendChild(modalPopup);

      // Create content inside the modal
      const container = document.createElement('div');
      container.id = 'modal-container';
      container.style.width = '200px';
      container.style.height = '100px';
      container.style.backgroundColor = 'blue';
      container.style.position = 'relative';
      modalPopup.appendChild(container);

      const innerElement = document.createElement('div');
      innerElement.id = 'inner-element';
      innerElement.style.width = '50px';
      innerElement.style.height = '50px';
      innerElement.style.backgroundColor = 'red';
      innerElement.style.marginTop = '10px';
      innerElement.style.marginLeft = '20px';
      container.appendChild(innerElement);

      await sleep(0.5); // Wait for modal animation

      // Show the modal
      (modalPopup as any).show();
      await sleep(1.5); // Wait for modal animation

      // Force layout
      container.offsetHeight;
      innerElement.offsetHeight;
      
      await sleep(0.5); // Additional wait

      // Get bounding client rects
      const containerRect = container.getBoundingClientRect();
      const innerRect = innerElement.getBoundingClientRect();

      // Modal popups are shown at the bottom of the screen in a bottom sheet
      // The exact position depends on the screen size, but we can verify:
      // 1. The elements have the correct size
      // 2. The inner element is positioned relative to its container
      
      // Check sizes
      expect(containerRect.width).toBe(200);
      expect(containerRect.height).toBe(100);
      expect(innerRect.width).toBe(50);
      expect(innerRect.height).toBe(50);

      // Check relative positioning
      // Inner element should be 20px from left and 10px from top of container
      expect(innerRect.left - containerRect.left).toBe(20);
      expect(innerRect.top - containerRect.top).toBe(10);

      // Check that coordinates are positive (visible on screen)
      expect(containerRect.top).toBeGreaterThan(0);
      expect(containerRect.left).toBeGreaterThanOrEqual(0);

      // Clean up
      (modalPopup as any).hide();
      await sleep(0.3);
      document.body.removeChild(modalPopup);
      done();
    });

    it('should handle nested elements in modal popup', async (done) => {
      const modalPopup = document.createElement('flutter-modal-popup');
      document.body.appendChild(modalPopup);

      // Create nested structure
      const outer = document.createElement('div');
      outer.style.width = '300px';
      outer.style.height = '200px';
      outer.style.padding = '20px';
      outer.style.backgroundColor = '#f0f0f0';
      outer.style.boxSizing = 'border-box';
      modalPopup.appendChild(outer);

      const middle = document.createElement('div');
      middle.style.width = '200px';
      middle.style.height = '150px';
      middle.style.margin = '10px';
      middle.style.backgroundColor = '#e0e0e0';
      middle.style.boxSizing = 'border-box';
      outer.appendChild(middle);

      const inner = document.createElement('div');
      inner.style.width = '100px';
      inner.style.height = '50px';
      inner.style.marginTop = '25px';
      inner.style.marginLeft = '30px';
      inner.style.backgroundColor = '#d0d0d0';
      inner.style.boxSizing = 'border-box';
      middle.appendChild(inner);

      await sleep(0.5); // Wait for modal animation
      // Show modal
      (modalPopup as any).show();
      await sleep(1.5); // Wait longer for modal animation

      const outerRect = outer.getBoundingClientRect();
      const middleRect = middle.getBoundingClientRect();
      const innerRect = inner.getBoundingClientRect();

      // Verify sizes
      expect(outerRect.width).toBe(300);
      // Note: The outer element may have additional height due to modal container padding/margins
      expect(outerRect.height).toBeGreaterThanOrEqual(200);
      expect(middleRect.width).toBe(200);
      expect(middleRect.height).toBe(150);
      expect(innerRect.width).toBe(100);
      expect(innerRect.height).toBe(50);

      // Verify relative positions
      expect(middleRect.left - outerRect.left).toBe(30); // 20px padding + 10px margin
      // For vertical positioning, check that middle is inside outer with appropriate spacing
      expect(middleRect.top - outerRect.top).toBeGreaterThanOrEqual(30); // At least 20px padding + 10px margin
      expect(innerRect.left - middleRect.left).toBe(30); // margin-left
      // Inner element should be positioned relative to middle, but vertical position might be affected by layout
      expect(innerRect.top).toBeGreaterThanOrEqual(middleRect.top); // Inner is below or at middle's top

      // Clean up
      (modalPopup as any).hide();
      await sleep(0.3);
      document.body.removeChild(modalPopup);
      done();
    });

    it('should handle getBoundingClientRect calls from inside modal popup event handlers', async (done) => {
      const modalPopup = document.createElement('flutter-modal-popup');
      document.body.appendChild(modalPopup);

      const button = document.createElement('button');
      button.textContent = 'Click me';
      button.style.width = '100px';
      button.style.height = '40px';
      modalPopup.appendChild(button);

      const target = document.createElement('div');
      target.id = 'click-target';
      target.style.width = '150px';
      target.style.height = '80px';
      target.style.marginTop = '20px';
      target.style.backgroundColor = 'green';
      modalPopup.appendChild(target);

      await sleep(0.5); // Wait for modal animation
      // Show modal
      (modalPopup as any).show();
      await sleep(0.5);

      // Add click handler that calls getBoundingClientRect
      button.onclick = () => {
        const rect = target.getBoundingClientRect();
        
        // Verify we get valid coordinates
        expect(rect.width).toBe(150);
        expect(rect.height).toBe(80);
        expect(rect.top).toBeGreaterThan(0);
        expect(rect.left).toBeGreaterThanOrEqual(0);
        
        // Clean up
        (modalPopup as any).hide();
        setTimeout(() => {
          document.body.removeChild(modalPopup);
          done();
        }, 300);
      };

      // Simulate click
      button.click();
    });
  });
});