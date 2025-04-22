/*auto generated*/
describe('position-fixed-comprehensive', () => {
  // Basic positioning and z-index tests
  it('basic-positioning', async () => {
    let fixedDiv = createElement('div', {
      style: {
        position: 'fixed',
        top: '50px',
        left: '50px',
        width: '100px',
        height: '100px',
        backgroundColor: 'green',
        zIndex: '10',
      }
    });
    
    let overlappingDiv = createElement('div', {
      style: {
        position: 'absolute',
        top: '75px',
        left: '75px',
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        zIndex: '5',
      }
    });
    
    let instructions = createElement('p', {}, [
      createText('Test passes if there is a green square that is not covered by the red square.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(fixedDiv);
    BODY.appendChild(overlappingDiv);
    
    await snapshot();
  });
  
  // Test with percentage values for positioning
  it('percentage-positioning', async () => {
    let container = createElement('div', {
      style: {
        position: 'relative',
        width: '400px',
        height: '400px',
        border: '1px solid black',
      }
    });
    
    let fixedDiv = createElement('div', {
      style: {
        position: 'fixed',
        top: '10%',
        left: '10%',
        width: '20%',
        height: '20%',
        backgroundColor: 'blue',
      }
    });
    
    let instructions = createElement('p', {}, [
      createText('Test passes if there is a blue square positioned at 10% from the top and left of the viewport.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(container);
    BODY.appendChild(fixedDiv);
    
    await snapshot();
  });
  
  // Test with margin on fixed element
  xit('with-margins', async () => {
    let fixedDiv = createElement('div', {
      style: {
        position: 'fixed',
        top: '100px',
        left: '50px',
        width: '100px',
        height: '100px',
        backgroundColor: 'green',
        margin: '20px',
      }
    });
    
    let marker = createElement('div', {
      style: {
        position: 'absolute',
        top: '120px',
        left: '70px',
        width: '5px',
        height: '5px',
        backgroundColor: 'red',
        zIndex: '20',
      }
    });
    
    let instructions = createElement('p', {}, [
      createText('Test passes if the red dot is positioned at the top-left corner of the green square with margins applied.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(fixedDiv);
    BODY.appendChild(marker);
    
    await snapshot();
  });
  
  // Test with scrolling
  it('with-scroll', async () => {
    let spacer = createElement('div', {
      style: {
        height: '2000px',
      }
    });
    
    let fixedHeader = createElement('div', {
      id: 'fixedHeader',
      style: {
        position: 'fixed',
        top: '0',
        left: '0',
        right: '0',
        height: '50px',
        backgroundColor: 'blue',
        color: 'white',
        textAlign: 'center',
        lineHeight: '50px',
      }
    }, [createText('Fixed Header')]);
    
    let fixedFooter = createElement('div', {
      id: 'fixedFooter',
      style: {
        position: 'fixed',
        bottom: '0',
        left: '0',
        right: '0',
        height: '50px',
        backgroundColor: 'green',
        color: 'white',
        textAlign: 'center',
        lineHeight: '50px',
      }
    }, [createText('Fixed Footer')]);
    
    let instructions = createElement('p', {
      style: {
        marginTop: '60px',
      }
    }, [
      createText('Scroll down. Test passes if the blue header stays at the top and the green footer stays at the bottom.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(fixedHeader);
    BODY.appendChild(fixedFooter);
    BODY.appendChild(spacer);
    
    await snapshot();
    
    // Scroll down and take another snapshot
    await window.scroll(0, 500);
    await snapshot();
  });
  
  // Test position fixed with webf-listview
  it('with-listview', async () => {
    let listview = createElement('webf-listview', {
      style: {
        height: '300px',
        border: '1px solid #ccc',
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
    
    let fixedOverlay = createElement('div', {
      style: {
        position: 'fixed',
        top: '100px',
        right: '20px',
        width: '100px',
        height: '100px',
        backgroundColor: 'rgba(255, 0, 0, 0.5)',
        zIndex: '100',
      }
    });
    
    let instructions = createElement('p', {}, [
      createText('Test passes if the red overlay stays fixed when scrolling the list.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(listview);
    BODY.appendChild(fixedOverlay);
    
    await snapshot();
    
    // Simulate scrolling the listview
    await listview.scroll(0, 200);
    await snapshot();
  });
  
  // Test fixed position inside webf-listview
  it('inside-listview', async () => {
    let listview = createElement('webf-listview', {
      style: {
        height: '300px',
        border: '1px solid #ccc',
        position: 'relative',
      }
    });
    
    // Add items to the listview with a fixed element inside
    for (let i = 0; i < 10; i++) {
      let item = createElement('div', {
        style: {
          height: '100px',
          borderBottom: '1px solid #eee',
          padding: '10px',
          position: 'relative',
        }
      }, [createText(`List Item ${i + 1}`)]);
      
      listview.appendChild(item);
      
      // Add a fixed element to the 5th item
      if (i === 4) {
        let fixedElement = createElement('div', {
          style: {
            position: 'fixed',
            top: '150px',
            right: '50%',
            width: '80px',
            height: '80px',
            backgroundColor: 'blue',
            zIndex: '10',
          }
        });
        
        item.appendChild(fixedElement);
      }
    }
    
    let instructions = createElement('p', {}, [
      createText('Test passes if the blue square stays fixed when scrolling the list.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(listview);
    
    await snapshot();
    
    // Simulate scrolling the listview
    await listview.scroll(0, 200);
    await snapshot();
  });
  
  // Test fixed position with overflow container
  it('with-overflow', async () => {
    let overflowContainer = createElement('div', {
      style: {
        height: '300px',
        width: '300px',
        overflow: 'auto',
        border: '1px solid #ccc',
        position: 'relative',
      }
    });
    
    let contentContainer = createElement('div', {
      style: {
        height: '1000px',
        width: '100%',
        backgroundColor: '#f5f5f5',
      }
    });
    
    let fixedInOverflow = createElement('div', {
      style: {
        position: 'fixed',
        top: '150px',
        left: '150px',
        width: '100px',
        height: '100px',
        backgroundColor: 'green',
        zIndex: '10',
      }
    });
    
    overflowContainer.appendChild(contentContainer);
    overflowContainer.appendChild(fixedInOverflow);
    
    let instructions = createElement('p', {}, [
      createText('Test passes if the green square stays fixed when scrolling the overflow container.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(overflowContainer);
    
    await snapshot();
    
    // Simulate scrolling the overflow container
    await overflowContainer.scroll(0, 200);
    await snapshot();
  });
  
  // Test fixed position with webf-router-link
  it('with-router-link', async () => {
    let routerLink = createElement('webf-router-link', {
      style: {
        display: 'block',
        position: 'relative',
        height: '200px',
        width: '400px',
        border: '1px solid #ccc',
      }
    });
    routerLink.setAttribute('path', '/');
    
    let fixedInLink = createElement('div', {
      style: {
        position: 'fixed',
        top: '20px',
        left: '20px',
        width: '100px',
        height: '100px',
        backgroundColor: 'purple',
      }
    });
    
    routerLink.appendChild(fixedInLink);
    
    let normalFixedElement = createElement('div', {
      style: {
        position: 'fixed',
        bottom: '20px',
        right: '20px',
        width: '100px',
        height: '100px',
        backgroundColor: 'orange',
      }
    });
    
    let instructions = createElement('p', {}, [
      createText('Test passes if the purple square is positioned relative to the router link and the orange square is fixed to the viewport.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(routerLink);
    BODY.appendChild(normalFixedElement);
    
    await snapshot();
  });
  
  // Test hit testing on fixed elements
  xit('hit-testing', async () => {
    let recordDiv = createElement('div', {
      id: 'recordDiv',
      style: {
        marginTop: '20px',
        height: '30px',
        border: '1px solid #ccc',
      }
    }, [createText('Click results will appear here')]);
    
    let fixedButton = createElement('div', {
      id: 'fixedButton',
      style: {
        position: 'fixed',
        top: '100px',
        left: '100px',
        width: '120px',
        height: '40px',
        backgroundColor: 'blue',
        color: 'white',
        textAlign: 'center',
        lineHeight: '40px',
        cursor: 'pointer',
      }
    }, [createText('Fixed Button')]);
    
    fixedButton.addEventListener('click', () => {
      recordDiv.textContent = 'Fixed button clicked!';
    });
    
    let overlappingDiv = createElement('div', {
      style: {
        position: 'absolute',
        top: '90px',
        left: '90px',
        width: '60px',
        height: '60px',
        backgroundColor: 'rgba(255, 0, 0, 0.5)',
        zIndex: '5', // Lower than fixed element
      }
    });
    
    let instructions = createElement('p', {}, [
      createText('Click on the blue button. Test passes if "Fixed button clicked!" appears in the result box.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(recordDiv);
    BODY.appendChild(overlappingDiv);
    BODY.appendChild(fixedButton);
    
    await snapshot();
  });
  
  // Test fixed positioning combined with transforms
  it('with-transforms', async () => {
    let fixedTransformedDiv = createElement('div', {
      style: {
        position: 'fixed',
        top: '100px',
        left: '100px',
        width: '100px',
        height: '100px',
        backgroundColor: 'green',
        transform: 'rotate(45deg)',
      }
    });
    
    let instructions = createElement('p', {}, [
      createText('Test passes if there is a green square rotated 45 degrees that remains fixed during scrolling.')
    ]);
    
    let spacer = createElement('div', {
      style: {
        height: '2000px',
      }
    });
    
    BODY.appendChild(instructions);
    BODY.appendChild(fixedTransformedDiv);
    BODY.appendChild(spacer);
    
    await snapshot();
    
    // Scroll down and take another snapshot
    await window.scroll(0, 300);
    await snapshot();
  });
  
  // Test fixed position with multiple nested scrollable areas
  it('nested-scrollable-areas', async () => {
    let outerScrollable = createElement('div', {
      id: 'outerScrollable',
      style: {
        height: '400px',
        width: '400px',
        overflow: 'auto',
        border: '1px solid black',
        position: 'relative',
      }
    });
    
    let innerContent = createElement('div', {
      style: {
        height: '1000px',
        width: '100%',
        backgroundColor: '#f0f0f0',
        position: 'relative',
      }
    });
    
    let innerScrollable = createElement('div', {
      id: 'innerScrollable',
      style: {
        height: '200px',
        width: '300px',
        overflow: 'auto',
        border: '1px solid blue',
        margin: '50px',
        position: 'relative',
      }
    });
    
    let deepestContent = createElement('div', {
      style: {
        height: '500px',
        width: '100%',
        backgroundColor: '#e0e0e0',
      }
    });
    
    let fixedElement = createElement('div', {
      style: {
        position: 'fixed',
        top: '150px',
        left: '250px',
        width: '80px',
        height: '80px',
        backgroundColor: 'red',
        zIndex: '100',
      }
    });
    
    innerScrollable.appendChild(deepestContent);
    innerScrollable.appendChild(fixedElement);
    innerContent.appendChild(innerScrollable);
    outerScrollable.appendChild(innerContent);
    
    let instructions = createElement('p', {}, [
      createText('Test passes if the red square stays fixed when scrolling both containers.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(outerScrollable);
    
    await snapshot();
    
    // Scroll the outer container
    await outerScrollable.scroll(0, 100);
    await snapshot();
    
    // Scroll the inner container
    await innerScrollable.scroll(0, 100);
    await snapshot();
  });
  
  // Test fixed position with webf-listview and webf-router-link combined
  it('listview-and-router-link-combined', async () => {
    let listview = createElement('webf-listview', {
      style: {
        height: '300px',
        border: '1px solid #ccc',
      }
    });
    
    // Add 10 items to the listview
    for (let i = 0; i < 10; i++) {
      let item = createElement('div', {
        style: {
          height: '80px',
          borderBottom: '1px solid #eee',
          padding: '10px',
        }
      }, [createText(`List Item ${i + 1}`)]);
      
      listview.appendChild(item);
      
      // Add a router link with fixed element to the 3rd item
      if (i === 2) {
        let routerLink = createElement('webf-router-link', {
          style: {
            display: 'block',
            height: '60px',
            border: '1px solid blue',
          }
        });
        routerLink.setAttribute('path', '/');
        
        let fixedInRouterLink = createElement('div', {
          style: {
            position: 'fixed',
            top: '10px',
            right: '10px',
            width: '60px',
            height: '60px',
            backgroundColor: 'purple',
          }
        });
        
        routerLink.appendChild(fixedInRouterLink);
        item.appendChild(routerLink);
      }
    }
    
    let globalFixedElement = createElement('div', {
      style: {
        position: 'fixed',
        bottom: '20px',
        left: '20px',
        width: '80px',
        height: '80px',
        backgroundColor: 'green',
        zIndex: '200',
      }
    });
    
    let instructions = createElement('p', {}, [
      createText('Test passes if the purple square is positioned relative to router link and the green square stays fixed at the bottom left when scrolling.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(listview);
    BODY.appendChild(globalFixedElement);
    
    await snapshot();
    
    // Scroll the listview
    await listview.scroll(0, 150);
    await snapshot();
  });
});