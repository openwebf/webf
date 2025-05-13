/*auto generated*/
describe('position-fixed-click-test', () => {
  // Test click events on fixed position elements
  it('basic-click-test', async () => {
    let clickResult = createElement('div', {
      id: 'clickResult',
      style: {
        marginTop: '10px',
        padding: '10px',
        border: '1px solid #ccc',
        height: '30px',
        backgroundColor: '#f5f5f5',
      }
    }, [createText('No clicks detected yet')]);
    
    // Fixed element that will receive clicks
    let fixedElement = createElement('div', {
      id: 'fixedElement',
      style: {
        position: 'fixed',
        top: '100px',
        left: '100px',
        width: '100px',
        height: '100px',
        backgroundColor: 'green',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        color: 'white',
        fontWeight: 'bold',
      }
    }, [createText('Click Me')]);
    
    // Add click event listener to detect clicks
    let clickCount = 0;
    fixedElement.addEventListener('click', (event) => {
      clickCount++;
      clickResult.textContent = `Clicked ${clickCount} time(s)! Last click at x: ${event.clientX}, y: ${event.clientY}`;
    });
    
    // Element that appears below the fixed element in z-order
    let lowerElement = createElement('div', {
      id: 'lowerElement',
      style: {
        position: 'absolute',
        top: '120px',
        left: '120px',
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        zIndex: '5', // Lower than the fixed element
      }
    });
    
    // This element should never receive clicks as it's covered by the fixed element
    lowerElement.addEventListener('click', () => {
      clickResult.textContent = 'ERROR: Lower element clicked instead of fixed element!';
    });
    
    let instructions = createElement('p', {}, [
      createText('Test verifies click events on fixed position elements.')
    ]);
    
    // Add all elements to the document
    BODY.appendChild(instructions);
    BODY.appendChild(clickResult);
    BODY.appendChild(lowerElement);
    BODY.appendChild(fixedElement);
    
    // Take initial snapshot
    await snapshot();
    
    // Simulate click in the center of the fixed element
    await simulateClick(150, 150);
    
    // Take snapshot after first click
    await snapshot();
    
    // Simulate another click at a different position within the fixed element
    await simulateClick(120, 130);
    
    // Take final snapshot
    await snapshot();
  });
  
  // Test click events on stacked fixed elements with different z-indices
  it('z-index-click-test', async () => {
    let clickResult = createElement('div', {
      id: 'clickResult',
      style: {
        marginTop: '10px',
        padding: '10px',
        border: '1px solid #ccc',
        height: '30px',
        backgroundColor: '#f5f5f5',
      }
    }, [createText('No clicks detected yet')]);
    
    // Create three overlapping fixed elements with different z-indices
    let fixedElement1 = createElement('div', {
      id: 'fixedElement1',
      style: {
        position: 'fixed',
        top: '100px',
        left: '100px',
        width: '100px',
        height: '100px',
        backgroundColor: 'rgba(255, 0, 0, 0.7)',
        zIndex: '10',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        color: 'white',
      }
    }, [createText('z-index: 10')]);
    
    let fixedElement2 = createElement('div', {
      id: 'fixedElement2',
      style: {
        position: 'fixed',
        top: '130px',
        left: '130px',
        width: '100px',
        height: '100px',
        backgroundColor: 'rgba(0, 255, 0, 0.7)',
        zIndex: '20',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        color: 'white',
      }
    }, [createText('z-index: 20')]);
    
    let fixedElement3 = createElement('div', {
      id: 'fixedElement3',
      style: {
        position: 'fixed',
        top: '160px',
        left: '160px',
        width: '100px',
        height: '100px',
        backgroundColor: 'rgba(0, 0, 255, 0.7)',
        zIndex: '30',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        color: 'white',
      }
    }, [createText('z-index: 30')]);
    
    // Add click event listeners to all elements
    fixedElement1.addEventListener('click', () => {
      clickResult.textContent = 'Red element clicked (z-index: 10)';
    });
    
    fixedElement2.addEventListener('click', () => {
      clickResult.textContent = 'Green element clicked (z-index: 20)';
    });
    
    fixedElement3.addEventListener('click', () => {
      clickResult.textContent = 'Blue element clicked (z-index: 30)';
    });
    
    let instructions = createElement('p', {}, [
      createText('Test verifies click events on stacked fixed position elements with different z-indices.')
    ]);
    
    // Add all elements to the document
    BODY.appendChild(instructions);
    BODY.appendChild(clickResult);
    BODY.appendChild(fixedElement1);
    BODY.appendChild(fixedElement2);
    BODY.appendChild(fixedElement3);
    
    // Take initial snapshot
    await snapshot();
    
    // Simulate click on the overlapping area - should hit the top element (blue, z-index: 30)
    await simulateClick(180, 180);
    
    // Take snapshot after first click
    await snapshot();
    
    // Remove the top element and simulate another click on the same spot
    BODY.removeChild(fixedElement3);
    
    // Simulate click on the same position - should now hit the green element (z-index: 20)
    await simulateClick(180, 180);
    
    // Take snapshot after second click
    await snapshot();
    
    // Remove the middle element and simulate another click
    BODY.removeChild(fixedElement2);
    
    // Simulate click on the same position - should now hit the red element (z-index: 10)
    await simulateClick(180, 180);
    
    // Take final snapshot
    await snapshot();
  });
  
  // Test click events on fixed elements after scrolling
  it('scroll-click-test', async () => {
    // Create a tall content div to enable scrolling
    let tallContent = createElement('div', {
      style: {
        height: '2000px',
      }
    });
    
    let clickResult = createElement('div', {
      id: 'clickResult',
      style: {
        position: 'fixed',
        top: '10px',
        left: '10px',
        right: '10px',
        padding: '10px',
        border: '1px solid #ccc',
        height: '30px',
        backgroundColor: '#f5f5f5',
        zIndex: '100',
      }
    }, [createText('No clicks detected yet')]);
    
    // Fixed element that will receive clicks
    let fixedElement = createElement('div', {
      id: 'fixedElement',
      style: {
        position: 'fixed',
        top: '100px',
        left: '100px',
        width: '100px',
        height: '100px',
        backgroundColor: 'blue',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        color: 'white',
      }
    }, [createText('Fixed Button')]);
    
    let clickCount = 0;
    // Add click event listener to detect clicks
    fixedElement.addEventListener('click', () => {
      clickResult.textContent = 'Fixed element clicked after scrolling! click count:' + ++clickCount;
    });
    
    // Add marker at the bottom of the page to confirm scrolling
    let marker = createElement('div', {
      style: {
        marginTop: '1900px',
        height: '50px',
        backgroundColor: 'red',
        textAlign: 'center',
        color: 'white',
        padding: '10px',
      }
    }, [createText('Bottom Marker')]);
    
    tallContent.appendChild(marker);
    
    let instructions = createElement('p', {
      style: {
        marginTop: '50px',
      }
    }, [
      createText('Test verifies click events on fixed elements after scrolling.')
    ]);
    
    // Add all elements to the document
    BODY.appendChild(clickResult);
    BODY.appendChild(instructions);
    BODY.appendChild(fixedElement);
    BODY.appendChild(tallContent);
    
    // Take initial snapshot
    await snapshot();
    
    // Scroll the page down
    window.scroll(0, 500);
    
    // Simulate click on the fixed element (which should remain at the same position)
    await simulateClick(150, 150);
    
    // Take snapshot after click
    await snapshot();
    
    // Scroll even further
    window.scroll(0, 1000);
    
    // Simulate another click on the fixed element
    await simulateClick(150, 150);
    
    // Take final snapshot
    await snapshot();
  });
  
  // Test click events on fixed elements inside webf-listview
  it('listview-click-test', async () => {
    let clickResult = createElement('div', {
      id: 'clickResult',
      style: {
        marginTop: '10px',
        padding: '10px',
        border: '1px solid #ccc',
        backgroundColor: '#f5f5f5',
      }
    }, [createText('No clicks detected yet')]);
    
    // Create webf-listview with items
    let listview = createElement('webf-listview', {
      style: {
        height: '300px',
        width: '400px',
        border: '1px solid #ccc',
        position: 'relative',
      }
    });
    
    // Add 20 items to the listview
    for (let i = 0; i < 20; i++) {
      let item = createElement('div', {
        style: {
          height: '50px',
          borderBottom: '1px solid #eee',
          padding: '10px',
        }
      }, [createText(`List Item ${i + 1}`)]);
      
      listview.appendChild(item);
    }
    
    // Create fixed element that should stay in place when listview scrolls
    let fixedOverlay = createElement('div', {
      id: 'fixedOverlay',
      style: {
        position: 'fixed',
        top: '150px',
        right: '150px',
        width: '80px',
        height: '80px',
        backgroundColor: 'rgba(255, 0, 0, 0.7)',
        zIndex: '100',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        color: 'white',
        fontSize: '12px',
        textAlign: 'center',
      }
    }, [createText('Fixed Overlay')]);
   
    let clickeCount = 0;

    // Add click event listener to detect clicks
    fixedOverlay.addEventListener('click', () => {
      clickResult.textContent = 'Fixed overlay clicked while listview was scrolled! click count: ' + ++clickeCount;
    });
    
    // Create a standard element inside the listview that should scroll
    let scrollingElement = createElement('div', {
      id: 'scrollingElement',
      style: {
        position: 'absolute',
        top: '400px', // This will be scrolled into view
        left: '50px',
        width: '80px',
        height: '80px',
        backgroundColor: 'green',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        color: 'white',
        fontSize: '12px',
        textAlign: 'center',
      }
    }, [createText('Scrolling Element')]);
    
    // Add click event listener to detect clicks
    scrollingElement.addEventListener('click', () => {
      clickResult.textContent = 'Scrolling element clicked!';
    });
    
    listview.appendChild(scrollingElement);
    
    let instructions = createElement('p', {}, [
      createText('Test verifies click events on fixed elements with webf-listview scrolling.')
    ]);
    
    // Add all elements to the document
    BODY.appendChild(instructions);
    BODY.appendChild(clickResult);
    BODY.appendChild(listview);
    BODY.appendChild(fixedOverlay);
    
    // Take initial snapshot
    await snapshot();
    
    // Simulate click on the fixed overlay
    await simulateClick(190, 190);
    
    // Take snapshot after first click
    await snapshot();
    
    // Scroll the listview down to bring the green element into view
    await listview.scroll(0, 350);
    
    // Take snapshot after scrolling
    await snapshot();
    
    // Simulate click on the fixed overlay again (should still work)
    await simulateClick(190, 190);
    
    // Take snapshot after second click
    await snapshot();
  });
  
  // Test click events on fixed elements inside webf-router-link
  it('router-link-click-test', async () => {
    let clickResult = createElement('div', {
      id: 'clickResult',
      style: {
        marginTop: '10px',
        padding: '10px',
        border: '1px solid #ccc',
        height: '30px',
        backgroundColor: '#f5f5f5',
      }
    }, [createText('No clicks detected yet')]);
    
    // Create webf-router-link with a fixed element inside
    let routerLink = createElement('webf-router-link', {
      style: {
        display: 'block',
        position: 'relative',
        height: '200px',
        width: '300px',
        border: '1px solid blue',
        margin: '50px',
        backgroundColor: '#f0f0f0',
      }
    });
    routerLink.setAttribute('path', '/');
    
    // Add a label to identify the router link
    routerLink.appendChild(
      createElement('div', {
        style: {
          padding: '5px',
          backgroundColor: '#e0e0e0',
        }
      }, [createText('Router Link Container')])
    );
    
    // Add fixed element inside router link
    let fixedInsideRouter = createElement('div', {
      id: 'fixedInsideRouter',
      style: {
        position: 'fixed',
        top: '100px',
        left: '100px',
        width: '80px',
        height: '80px',
        backgroundColor: 'purple',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        color: 'white',
        fontSize: '12px',
        textAlign: 'center',
      }
    }, [createText('Fixed Inside Router Link')]);
    
    // Add click event listener to detect clicks
    fixedInsideRouter.addEventListener('click', () => {
      clickResult.textContent = 'Fixed element inside router link clicked!';
    });
    
    // Add another fixed element outside of the router link
    let fixedOutsideRouter = createElement('div', {
      id: 'fixedOutsideRouter',
      style: {
        position: 'fixed',
        bottom: '50px',
        right: '50px',
        width: '80px',
        height: '80px',
        backgroundColor: 'orange',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        color: 'white',
        fontSize: '12px',
        textAlign: 'center',
      }
    }, [createText('Fixed Outside Router Link')]);
    
    // Add click event listener to detect clicks
    fixedOutsideRouter.addEventListener('click', (e) => {
      clickResult.textContent = 'Fixed element outside router link clicked!';
    });
    
    // Add the fixed element to the router link
    routerLink.appendChild(fixedInsideRouter);
    
    let instructions = createElement('p', {}, [
      createText('Test verifies click events on fixed elements inside and outside webf-router-link.')
    ]);
    
    // Add all elements to the document
    BODY.appendChild(instructions);
    BODY.appendChild(clickResult);
    BODY.appendChild(routerLink);
    BODY.appendChild(fixedOutsideRouter);
    
    // Take initial snapshot
    await snapshot();
    
    // Simulate click on the fixed element inside router link
    await simulateClick(170, 260);
    
    // Take snapshot after first click
    await snapshot();
    
    // Simulate click on the fixed element outside router link
    // Assuming the viewport is large enough to show this element
    await simulateClick(240, 525);

    // Take final snapshot
    await snapshot();
  });
  
  // Test click events on fixed elements with complex nesting and scrolling
  it('complex-nesting-click-test', async () => {
    let clickResult = createElement('div', {
      id: 'clickResult',
      style: {
        position: 'fixed',
        top: '60px',
        left: '10px',
        right: '10px',
        padding: '10px',
        border: '1px solid #ccc',
        backgroundColor: '#f5f5f5',
        zIndex: '1000',
      }
    }, [createText('No clicks detected yet')]);
    
    // Create a scrollable container
    let scrollableContainer = createElement('div', {
      id: 'scrollableContainer',
      style: {
        height: '300px',
        width: '400px',
        overflow: 'auto',
        border: '1px solid #ccc',
        position: 'relative',
        margin: '0 auto',
      }
    });
    
    // Add content to make it scrollable
    let scrollContent = createElement('div', {
      style: {
        height: '800px',
        backgroundColor: '#f0f0f0',
        position: 'relative',
      }
    });
    
    // Add a webf-listview inside the scrollable container
    let listview = createElement('webf-listview', {
      style: {
        height: '200px',
        width: '300px',
        border: '1px solid blue',
        margin: '50px',
      }
    });
    
    // Add items to the listview
    for (let i = 0; i < 10; i++) {
      let item = createElement('div', {
        style: {
          height: '50px',
          borderBottom: '1px solid #eee',
          padding: '10px',
        }
      }, [createText(`List Item ${i + 1}`)]);
      
      listview.appendChild(item);
    }
    
    // Add router link inside a listview item
    let routerLink = createElement('webf-router-link', {
      style: {
        display: 'block',
        height: '80px',
        border: '1px solid purple',
        margin: '10px',
        backgroundColor: '#e0e0ff',
      }
    }, [createText('Route Link Content')]);
    routerLink.setAttribute('path', '/')
    // Add a fixed element inside the router link
    let fixedInRouterLink = createElement('div', {
      id: 'fixedInRouterLink',
      style: {
        position: 'fixed',
        top: '150px',
        left: '150px',
        width: '60px',
        height: '60px',
        backgroundColor: 'purple',
        color: 'white',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        fontSize: '10px',
        textAlign: 'center',
      }
    }, [createText('Fixed in Router Link')]);
    
    // Add click event listener
    fixedInRouterLink.addEventListener('click', (e) => {
        console.log(e.clientX, e.clientY)
      clickResult.textContent = 'Fixed element in router link clicked!';
    });
    
    // Add a fixed element relative to the main viewport
    let globalFixedElement = createElement('div', {
      id: 'globalFixedElement',
      style: {
        position: 'fixed',
        top: '100px',
        right: '50px',
        width: '70px',
        height: '70px',
        backgroundColor: 'red',
        color: 'white',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        fontSize: '10px',
        textAlign: 'center',
        zIndex: '500',
      }
    }, [createText('Global Fixed')]);
    
    let clickCount = 0;
    // Add click event listener
    globalFixedElement.addEventListener('click', (e) => {
      clickResult.textContent = 'Global fixed element clicked! count: ' + ++clickCount;
    });
    
    // Add a scrollable element's clickable item
    let scrollableItem = createElement('div', {
      id: 'scrollableItem',
      style: {
        position: 'absolute',
        top: '500px',
        left: '50px',
        width: '100px',
        height: '50px',
        backgroundColor: 'green',
        color: 'white',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
      }
    }, [createText('Scrollable Item')]);
    
    // Add click event listener
    scrollableItem.addEventListener('click', () => {
      clickResult.textContent = 'Scrollable item clicked!';
    });
    
    // Build the DOM structure
    routerLink.appendChild(fixedInRouterLink);
    
    scrollContent.appendChild(listview);
    scrollContent.appendChild(scrollableItem);
    scrollableContainer.appendChild(scrollContent);
    
    let instructions = createElement('p', {}, [
      createText('Test verifies click events on fixed elements with complex nesting and scrolling.')
    ]);
    
    // Add all elements to the document
    BODY.appendChild(instructions);
    BODY.appendChild(clickResult);
    BODY.appendChild(scrollableContainer);
    BODY.appendChild(globalFixedElement);
    BODY.appendChild(routerLink)
    
    // Take initial snapshot
    await snapshot();
    
    // Simulate click on the global fixed element
    await simulateClick(280, 130);
    
    // Take snapshot after first click
    await snapshot();
    
    // Scroll the container to see the fixed element inside router link
    await scrollableContainer.scroll(0, 100);

    // Simulate click on the global fixed element
    await simulateClick(280, 130);
    
    // Take snapshot after scrolling
    await snapshot();
    
    // Scroll the container to see the green scrollable item
    await scrollableContainer.scroll(0, 450);
  
    // Simulate click on the global fixed element
    await simulateClick(280, 130);
  
    // Take snapshot after scrolling more
    await snapshot();

    // Simulate click on the scrollable item
    await simulateClick(100, 200);
    
    // Take final snapshot
    await snapshot();

      // Simulate click on the scrollable item
    await simulateClick(200, 555);
  
    // Take final snapshot
    await snapshot();
  });
});