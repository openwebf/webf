/*auto generated*/
describe('position-fixed-listview', () => {
  // Test fixed element outside WebF ListView
  it('fixed-outside-listview', async () => {
    const listview = createElement('webf-listview', {
      style: {
        height: '400px',
        width: '80%',
        border: '1px solid #ccc',
        margin: '0 auto',
      }
    });
    
    // Create 50 list items to make it scrollable
    for (let i = 0; i < 50; i++) {
      const item = createElement('div', {
        style: {
          height: '50px',
          padding: '10px',
          borderBottom: '1px solid #eee',
          backgroundColor: i % 2 === 0 ? '#f9f9f9' : '#ffffff',
        }
      }, [createText(`List Item ${i + 1}`)]);
      
      listview.appendChild(item);
    }
    
    // Create a fixed element at the top right corner
    const fixedIndicator = createElement('div', {
      style: {
        position: 'fixed',
        top: '10px',
        right: '10px',
        width: '80px',
        height: '40px',
        backgroundColor: 'rgba(255, 0, 0, 0.7)',
        color: 'white',
        textAlign: 'center',
        lineHeight: '40px',
        borderRadius: '4px',
        zIndex: '100',
      }
    }, [createText('Fixed')]);
    
    const instructions = createElement('p', {}, [
      createText('Scroll the list. Test passes if the red "Fixed" indicator remains in the top right corner.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(listview);
    BODY.appendChild(fixedIndicator);
    
    await snapshot();
    
    // Scroll the listview and verify fixed element stays in place
    await listview.scroll(0, 300);
    await snapshot();
    
    // Scroll more
    await listview.scroll(0, 800);
    await snapshot();
  });
  
  // Test fixed element inside WebF ListView
  it('fixed-inside-listview', async () => {
    const listview = createElement('webf-listview', {
      style: {
        height: '400px',
        width: '80%',
        border: '1px solid #ccc',
        margin: '0 auto',
        position: 'relative',
      }
    });
    
    // Create a container for all content
    const contentContainer = createElement('div', {
      style: {
        position: 'relative',
      }
    });
    
    // Create list items
    for (let i = 0; i < 30; i++) {
      const item = createElement('div', {
        style: {
          height: '60px',
          padding: '10px',
          borderBottom: '1px solid #eee',
          backgroundColor: i % 2 === 0 ? '#f9f9f9' : '#ffffff',
          position: 'relative',
        }
      }, [createText(`List Item ${i + 1}`)]);
      
      contentContainer.appendChild(item);
    }
    
    // Create fixed element inside the listview
    const fixedInsideListview = createElement('div', {
      style: {
        position: 'fixed',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
        width: '150px',
        height: '50px',
        backgroundColor: 'rgba(0, 128, 255, 0.8)',
        color: 'white',
        textAlign: 'center',
        lineHeight: '50px',
        borderRadius: '4px',
        zIndex: '10',
      }
    }, [createText('Fixed in ListView')]);
    
    contentContainer.appendChild(fixedInsideListview);
    listview.appendChild(contentContainer);
    
    const instructions = createElement('p', {}, [
      createText('Scroll the list. Test passes if the blue "Fixed in ListView" indicator remains fixed in the center of the listview container.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(listview);
    
    await snapshot();
    
    // Scroll the listview and check if the fixed element behaves correctly
    await listview.scroll(0, 200);
    await snapshot();
    
    // Scroll more
    await listview.scroll(0, 500);
    await snapshot();
  });
  
  // Test fixed element with margin inside WebF ListView
  it('fixed-with-margin-in-listview', async () => {
    const listview = createElement('webf-listview', {
      style: {
        height: '400px',
        width: '80%',
        border: '1px solid #ccc',
        margin: '0 auto',
      }
    });
    
    // Create 30 list items
    for (let i = 0; i < 30; i++) {
      const item = createElement('div', {
        style: {
          height: '60px',
          padding: '10px',
          borderBottom: '1px solid #eee',
          backgroundColor: i % 2 === 0 ? '#f9f9f9' : '#ffffff',
        }
      }, [createText(`List Item ${i + 1}`)]);
      
      // Add a fixed element to the 5th item
      if (i === 4) {
        const fixedWithMargin = createElement('div', {
          style: {
            position: 'fixed',
            top: '120px',
            left: '120px',
            width: '120px',
            height: '60px',
            backgroundColor: 'green',
            margin: '15px',
            border: '5px solid black',
            zIndex: '20',
          }
        });
        
        item.appendChild(fixedWithMargin);
      }
      
      listview.appendChild(item);
    }
    
    // Add a marker at the expected position accounting for margins
    const positionMarker = createElement('div', {
      style: {
        position: 'absolute',
        top: '135px', // 120px + 15px margin
        left: '135px', // 120px + 15px margin
        width: '10px',
        height: '10px',
        backgroundColor: 'red',
        borderRadius: '50%',
        zIndex: '30',
      }
    });
    
    const instructions = createElement('p', {}, [
      createText('Test passes if the red dot appears at the top-left corner of the green box with margins applied.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(listview);
    BODY.appendChild(positionMarker);
    
    await snapshot();
    
    // Scroll and check if margins are correctly applied
    await listview.scroll(0, 100);
    await snapshot();
  });
  
  // Test fixed element with percentages in WebF ListView
  it('fixed-with-percentages-in-listview', async () => {
    const listview = createElement('webf-listview', {
      style: {
        height: '400px',
        width: '80%',
        border: '1px solid #ccc',
        margin: '0 auto',
      }
    });
    
    // Create some list content
    for (let i = 0; i < 20; i++) {
      const item = createElement('div', {
        style: {
          height: '70px',
          padding: '10px',
          borderBottom: '1px solid #eee',
        }
      }, [createText(`List Item ${i + 1}`)]);
      
      listview.appendChild(item);
    }
    
    // Create a fixed element with percentage values
    const fixedWithPercentages = createElement('div', {
      style: {
        position: 'fixed',
        top: '20%',
        left: '20%',
        width: '30%',
        height: '20%',
        backgroundColor: 'rgba(128, 0, 128, 0.7)', // purple
        color: 'white',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: '15',
      }
    }, [createText('Fixed with percentages')]);
    
    listview.appendChild(fixedWithPercentages);
    
    const instructions = createElement('p', {}, [
      createText('Test passes if the purple box is positioned at 20% from top and left, with 30% width and 20% height of the viewport.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(listview);
    
    await snapshot();
    
    // Scroll and verify fixed element with percentages
    await listview.scroll(0, 300);
    await snapshot();
  });
  
  // Test multiple fixed elements in the same WebF ListView
  it('multiple-fixed-elements-in-listview', async () => {
    const listview = createElement('webf-listview', {
      style: {
        height: '400px',
        width: '80%',
        border: '1px solid #ccc',
        margin: '0 auto',
      }
    });
    
    // Create some list content
    for (let i = 0; i < 30; i++) {
      const item = createElement('div', {
        style: {
          height: '60px',
          padding: '10px',
          borderBottom: '1px solid #eee',
        }
      }, [createText(`List Item ${i + 1}`)]);
      
      listview.appendChild(item);
    }
    
    // Create multiple fixed elements
    const fixedHeader = createElement('div', {
      style: {
        position: 'fixed',
        top: '0',
        left: '0',
        right: '0',
        height: '40px',
        backgroundColor: 'rgba(0, 0, 0, 0.8)',
        color: 'white',
        textAlign: 'center',
        lineHeight: '40px',
        zIndex: '100',
      }
    }, [createText('Fixed Header')]);
    
    const fixedLeftSidebar = createElement('div', {
      style: {
        position: 'fixed',
        top: '40px',
        left: '0',
        width: '80px',
        bottom: '40px',
        backgroundColor: 'rgba(0, 0, 255, 0.3)',
        zIndex: '90',
      }
    });
    
    const fixedRightSidebar = createElement('div', {
      style: {
        position: 'fixed',
        top: '40px',
        right: '0',
        width: '80px',
        bottom: '40px',
        backgroundColor: 'rgba(0, 128, 0, 0.3)',
        zIndex: '90',
      }
    });
    
    const fixedFooter = createElement('div', {
      style: {
        position: 'fixed',
        bottom: '0',
        left: '0',
        right: '0',
        height: '40px',
        backgroundColor: 'rgba(0, 0, 0, 0.8)',
        color: 'white',
        textAlign: 'center',
        lineHeight: '40px',
        zIndex: '100',
      }
    }, [createText('Fixed Footer')]);
    
    const fixedCenter = createElement('div', {
      style: {
        position: 'fixed',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
        width: '120px',
        height: '120px',
        backgroundColor: 'rgba(255, 0, 0, 0.5)',
        borderRadius: '50%',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: 'white',
        zIndex: '110',
      }
    }, [createText('Center')]);
    
    BODY.appendChild(fixedHeader);
    BODY.appendChild(fixedLeftSidebar);
    BODY.appendChild(fixedRightSidebar);
    BODY.appendChild(fixedFooter);
    listview.appendChild(fixedCenter);
    
    const instructions = createElement('p', {
      style: {
        marginTop: '50px',
      }
    }, [
      createText('Scroll the list. Test passes if all fixed elements stay in their respective positions.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(listview);
    
    await snapshot();
    
    // Scroll the listview
    await listview.scroll(0, 200);
    await snapshot();
    
    // Scroll the window
    await window.scroll(0, 50);
    await snapshot();
  });
  
  // Test fixed element with hit testing in WebF ListView
  it('fixed-hit-testing-in-listview', async () => {
    const resultDisplay = createElement('div', {
      id: 'resultDisplay',
      style: {
        padding: '10px',
        border: '1px solid #ccc',
        marginBottom: '20px',
        backgroundColor: '#f5f5f5',
      }
    }, [createText('Click result will appear here')]);
    
    const listview = createElement('webf-listview', {
      style: {
        height: '400px',
        width: '80%',
        border: '1px solid #ccc',
        margin: '0 auto',
      }
    });
    
    // Add some content to the listview
    for (let i = 0; i < 20; i++) {
      const item = createElement('div', {
        style: {
          height: '60px',
          padding: '10px',
          borderBottom: '1px solid #eee',
        }
      }, [createText(`List Item ${i + 1}`)]);
      
      // Make every 5th item have a different background
      if (i % 5 === 0) {
        item.style.backgroundColor = '#e0f7fa';
      }
      
      listview.appendChild(item);
    }
    
    // Create a clickable fixed button
    const fixedButton = createElement('div', {
      id: 'fixedButton',
      style: {
        position: 'fixed',
        bottom: '80px',
        right: '80px',
        width: '120px',
        height: '50px',
        backgroundColor: '#2196F3',
        color: 'white',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        borderRadius: '4px',
        boxShadow: '0 2px 5px rgba(0,0,0,0.2)',
        cursor: 'pointer',
        zIndex: '100',
      }
    }, [createText('Click Me')]);
    
    // Add click event
    let clickCount = 0;
    fixedButton.addEventListener('click', (e) => {
      resultDisplay.textContent = 'Fixed button was clicked successfully! clickCount: ' + ++clickCount + ' x: ' + e.clientX + " y: " + e.clientY;
      resultDisplay.style.backgroundColor = '#e8f5e9';
    });
    
    // Create overlapping elements to test hit testing
    const overlappingDiv = createElement('div', {
      style: {
        position: 'absolute',
        bottom: '60px',
        right: '60px',
        width: '80px',
        height: '80px',
        backgroundColor: 'rgba(255,0,0,0.3)',
        zIndex: '50', // Lower than fixed button
      }
    });
    
    const instructions = createElement('p', {}, [
      createText('Click on the blue "Click Me" button. Test passes if the result shows the button was clicked successfully.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(resultDisplay);
    BODY.appendChild(listview);
    BODY.appendChild(fixedButton);
    BODY.appendChild(overlappingDiv);

    await simulateClick(215, 550);
    
    await snapshot();

    // Scroll the listview and test hit testing still works
    await listview.scroll(0, 150);

    await simulateClick(215, 550);

    await snapshot();
  });
  
  // Test fixed elements with nested WebF ListViews
  it('nested-listviews-with-fixed', async () => {
    const outerListview = createElement('webf-listview', {
      style: {
        height: '500px',
        width: '80%',
        border: '1px solid #333',
        margin: '0 auto',
      }
    });
    
    // Create content for the outer listview
    for (let i = 0; i < 10; i++) {
      const outerItem = createElement('div', {
        style: {
          padding: '10px',
          borderBottom: '1px solid #ccc',
          backgroundColor: i % 2 === 0 ? '#f0f0f0' : '#ffffff',
        }
      });
      
      const itemTitle = createElement('h3', {
        style: {
          margin: '5px 0',
        }
      }, [createText(`Section ${i + 1}`)]);
      
      outerItem.appendChild(itemTitle);
      
      // Add an inner listview to the 3rd item
      if (i === 2) {
        const innerListview = createElement('webf-listview', {
          style: {
            height: '200px',
            border: '1px solid #007ACC',
            margin: '10px 0',
          }
        });
        
        // Add content to the inner listview
        for (let j = 0; j < 15; j++) {
          const innerItem = createElement('div', {
            style: {
              height: '40px',
              padding: '10px',
              borderBottom: '1px solid #e0e0e0',
              backgroundColor: j % 2 === 0 ? '#e3f2fd' : '#ffffff',
            }
          }, [createText(`Nested Item ${j + 1}`)]);
          
          innerListview.appendChild(innerItem);
        }
        
        // Add a fixed element to the inner listview
        const innerFixedElement = createElement('div', {
          style: {
            position: 'fixed',
            top: '10px',
            right: '10px',
            width: '100px',
            height: '40px',
            backgroundColor: 'rgba(233, 30, 99, 0.8)',
            color: 'white',
            textAlign: 'center',
            lineHeight: '40px',
            borderRadius: '20px',
            zIndex: '200',
          }
        }, [createText('Inner Fixed')]);
        
        innerListview.appendChild(innerFixedElement);
        outerItem.appendChild(innerListview);
      }
      
      outerListview.appendChild(outerItem);
    }
    
    // Add a fixed element to the outer listview
    const outerFixedElement = createElement('div', {
      style: {
        position: 'fixed',
        bottom: '20px',
        left: '20px',
        width: '100px',
        height: '40px',
        backgroundColor: 'rgba(0, 150, 136, 0.8)',
        color: 'white',
        textAlign: 'center',
        lineHeight: '40px',
        borderRadius: '4px',
        zIndex: '100',
      }
    }, [createText('Outer Fixed')]);
    
    outerListview.appendChild(outerFixedElement);
    
    const instructions = createElement('p', {}, [
      createText('Test passes if both fixed elements stay in position when scrolling either the outer or inner listview.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(outerListview);
    
    await snapshot();
    
    // Scroll the outer listview
    await outerListview.scroll(0, 100);
    await snapshot();
    
    // Find the inner listview and scroll it
    const innerListview = document.querySelector('webf-listview webf-listview');
    
    if (innerListview) {
      await innerListview.scroll(0, 50);
      await snapshot();
    }
  });
});