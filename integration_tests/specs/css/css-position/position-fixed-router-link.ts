/*auto generated*/
fdescribe('position-fixed-router-link', () => {
  // Basic test with fixed element inside router link
  it('fixed-inside-router-link', async () => {
    const routerLink = createElement('webf-router-link', {
      style: {
        display: 'block',
        position: 'relative',
        width: '300px',
        height: '200px',
        border: '1px solid #333',
        backgroundColor: '#f5f5f5',
        margin: '20px auto',
      }
    });

    routerLink.setAttribute('path', '/');
    
    const fixedElement = createElement('div', {
      style: {
        position: 'fixed',
        top: '20px',
        left: '20px',
        width: '100px',
        height: '50px',
        backgroundColor: 'blue',
        color: 'white',
        textAlign: 'center',
        lineHeight: '50px',
      }
    }, [createText('Fixed Element')]);
    
    routerLink.appendChild(fixedElement);
    
    const normalElement = createElement('div', {
      style: {
        margin: '70px 20px',
        padding: '10px',
        backgroundColor: '#ddd',
      }
    }, [createText('Normal element inside router-link')]);
    
    routerLink.appendChild(normalElement);
    
    const instructions = createElement('p', {}, [
      createText('Test passes if the blue fixed element is positioned relative to the router link container instead of the viewport.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(routerLink);
    
    await snapshot();
  });
  
  // Compare fixed positioning inside and outside router link
  it('fixed-inside-vs-outside-router-link', async () => {
    const routerLink = createElement('webf-router-link', {
      style: {
        display: 'block',
        position: 'relative',
        width: '300px',
        height: '200px',
        border: '1px solid #333',
        backgroundColor: '#f0f0f0',
        margin: '20px auto',
      }
    });
    
    routerLink.setAttribute('path', '/');
    
    
    const fixedInsideRouterLink = createElement('div', {
      style: {
        position: 'fixed',
        top: '50px',
        left: '50px',
        width: '80px',
        height: '50px',
        backgroundColor: 'red',
        color: 'white',
        textAlign: 'center',
        lineHeight: '50px',
        zIndex: '10',
      }
    }, [createText('Inside')]);
    
    routerLink.appendChild(fixedInsideRouterLink);
    
    const fixedOutsideRouterLink = createElement('div', {
      style: {
        position: 'fixed',
        top: '50px',
        right: '50px',
        width: '80px',
        height: '50px',
        backgroundColor: 'green',
        color: 'white',
        textAlign: 'center',
        lineHeight: '50px',
        zIndex: '10',
      }
    }, [createText('Outside')]);
    
    const instructions = createElement('p', {}, [
      createText('Test passes if the red "Inside" element is positioned relative to the router link container, while the green "Outside" element is positioned relative to the viewport.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(routerLink);
    BODY.appendChild(fixedOutsideRouterLink);
    
    await snapshot();
    
    // Window scroll to see if positioning is affected
    await window.scroll(0, 20);
    await snapshot();
  });
  
  // Test fixed elements with margins in router links
  it('fixed-with-margins-in-router-link', async () => {
    const routerLink = createElement('webf-router-link', {
      style: {
        display: 'block',
        position: 'relative',
        width: '300px',
        height: '200px',
        border: '1px solid #333',
        backgroundColor: '#f5f5f5',
        margin: '20px auto',
      }
    });

    routerLink.setAttribute('path', '/');
    
    
    const fixedWithMargins = createElement('div', {
      style: {
        position: 'fixed',
        top: '20px',
        left: '20px',
        width: '100px',
        height: '60px',
        backgroundColor: 'purple',
        color: 'white',
        textAlign: 'center',
        lineHeight: '60px',
        margin: '10px',
        border: '3px solid black',
      }
    }, [createText('With Margins')]);
    
    routerLink.appendChild(fixedWithMargins);
    
    // Add marker at the expected position accounting for margins
    const positionMarker = createElement('div', {
      style: {
        position: 'absolute',
        top: '30px', // 20px + 10px margin
        left: '30px', // 20px + 10px margin
        width: '10px',
        height: '10px',
        backgroundColor: 'red',
        borderRadius: '50%',
        zIndex: '30',
      }
    });
    
    routerLink.appendChild(positionMarker);
    
    const instructions = createElement('p', {}, [
      createText('Test passes if the red dot is positioned at the top-left corner of the purple box, accounting for its margins.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(routerLink);
    
    await snapshot();
  });
  
  // Test fixed element with percentage values in router link
  it('fixed-with-percentages-in-router-link', async () => {
    const routerLink = createElement('webf-router-link', {
      style: {
        display: 'block',
        position: 'relative',
        width: '400px',
        height: '300px',
        border: '1px solid #333',
        backgroundColor: '#f5f5f5',
        margin: '20px auto',
      }
    });

    routerLink.setAttribute('path', '/');
    
    
    const fixedWithPercentages = createElement('div', {
      style: {
        position: 'fixed',
        top: '20%',
        left: '20%',
        width: '50%',
        height: '30%',
        backgroundColor: 'teal',
        color: 'white',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
      }
    }, [createText('Percentage Based')]);
    
    routerLink.appendChild(fixedWithPercentages);
    
    // Calculate expected position markers based on router link dimensions
    const topLeftMarker = createElement('div', {
      style: {
        position: 'absolute',
        top: '50px', // 20% of 300px
        left: '80px', // 20% of 400px
        width: '10px',
        height: '10px',
        backgroundColor: 'red',
        borderRadius: '50%',
        zIndex: '10',
      }
    });
    
    const rightMarker = createElement('div', {
      style: {
        position: 'absolute',
        top: '60px', // 20% of 300px
        left: '280px', // 20% + 50% of 400px
        width: '10px',
        height: '10px',
        backgroundColor: 'red',
        borderRadius: '50%',
        zIndex: '10',
      }
    });
    
    const bottomMarker = createElement('div', {
      style: {
        position: 'absolute',
        top: '150px', // 20% + 30% of 300px
        left: '80px', // 20% of 400px
        width: '10px',
        height: '10px',
        backgroundColor: 'red',
        borderRadius: '50%',
        zIndex: '10',
      }
    });
    
    routerLink.appendChild(topLeftMarker);
    routerLink.appendChild(rightMarker);
    routerLink.appendChild(bottomMarker);
    
    const instructions = createElement('p', {}, [
      createText('Test passes if the red dots mark the corners of the teal box, which should be positioned using percentages relative to the router link.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(routerLink);
    
    await snapshot();
  });
  
  // Test hit testing of fixed elements in router links
  it('hit-testing-fixed-in-router-link', async () => {
    const resultDisplay = createElement('div', {
      id: 'resultDisplay',
      style: {
        padding: '10px',
        height: '30px',
        border: '1px solid #ccc',
        marginBottom: '20px',
        backgroundColor: '#f5f5f5',
      }
    }, [createText('Click result will appear here')]);
    
    const routerLink = createElement('webf-router-link', {
      style: {
        display: 'block',
        position: 'relative',
        width: '350px',
        height: '250px',
        border: '1px solid #333',
        backgroundColor: '#f0f0f0',
        margin: '20px auto',
        padding: '20px',
      }
    });
    routerLink.setAttribute('path', '/');
    
    const fixedButton = createElement('div', {
      id: 'fixedButton',
      style: {
        position: 'fixed',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
        width: '150px',
        height: '50px',
        backgroundColor: '#2196F3',
        color: 'white',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        borderRadius: '4px',
        boxShadow: '0 2px 5px rgba(0,0,0,0.2)',
        cursor: 'pointer',
      }
    }, [createText('Click Me')]);
    
    // Add click event
    fixedButton.addEventListener('click', (e) => {
      resultDisplay.textContent = 'Fixed button inside router-link was clicked! x: ' + e.clientX + " y: " + e.clientY;
      resultDisplay.style.backgroundColor = '#e8f5e9';
    });
    
    routerLink.appendChild(fixedButton);
    
    const instructions = createElement('p', {}, [
      createText('Click on the blue "Click Me" button inside the router link. Test passes if the result shows the button was clicked successfully.')
    ]);
    
    BODY.appendChild(instructions);
    BODY.appendChild(resultDisplay);
    BODY.appendChild(routerLink);
    
    await simulateClick(170, 250);
    
    await snapshot();
  });
});