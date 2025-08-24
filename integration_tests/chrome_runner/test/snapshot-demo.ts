// Demo test to show snapshot functionality
describe('Snapshot API Demo', () => {
  it('should capture snapshot with default naming', async () => {
    const div = document.createElement('div');
    div.style.cssText = `
      width: 200px;
      height: 100px;
      background: linear-gradient(45deg, blue, red);
      color: white;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 20px;
    `;
    div.textContent = 'Hello WebF!';
    document.body.appendChild(div);

    // Capture snapshot with default naming
    await snapshot();
    
    document.body.removeChild(div);
  });

  it('should capture snapshot with custom filename', async () => {
    const div = document.createElement('div');
    div.style.cssText = `
      width: 300px;
      height: 150px;
      background: #333;
      color: #0f0;
      padding: 20px;
      font-family: monospace;
    `;
    div.innerHTML = '<h1>Custom Snapshot</h1><p>With custom filename</p>';
    document.body.appendChild(div);

    // Capture snapshot with custom filename
    await snapshot(null, 'my_custom_snapshot');
    
    document.body.removeChild(div);
  });

  it('should capture snapshot with timestamp postfix', async () => {
    const div = document.createElement('div');
    div.style.cssText = `
      width: 250px;
      height: 100px;
      border: 3px solid orange;
      padding: 10px;
      text-align: center;
    `;
    div.textContent = 'Snapshot with timestamp';
    document.body.appendChild(div);

    // Capture snapshot with timestamp postfix
    await snapshot(null, 'timestamped', true);
    
    document.body.removeChild(div);
  });

  it('should capture element snapshot using toBlob', async () => {
    const div = document.createElement('div');
    div.id = 'special-element';
    div.style.cssText = `
      width: 150px;
      height: 150px;
      background: radial-gradient(circle, yellow, orange);
      border-radius: 50%;
      box-shadow: 0 0 20px rgba(0,0,0,0.3);
    `;
    document.body.appendChild(div);

    // Use toBlob with toMatchSnapshot (WebF-specific API)
    // In Chrome, this will mark the element and capture it
    await expectAsync(div.toBlob(1.0)).toMatchSnapshot('circular_element');
    
    document.body.removeChild(div);
  });

  it('should capture multiple snapshots in one test', async () => {
    const container = document.createElement('div');
    
    // First state
    container.style.cssText = 'width: 200px; height: 100px; background: blue;';
    container.textContent = 'State 1';
    document.body.appendChild(container);
    await snapshot(null, 'state', '1');
    
    // Second state
    container.style.background = 'red';
    container.textContent = 'State 2';
    await snapshot(null, 'state', '2');
    
    // Third state
    container.style.background = 'green';
    container.textContent = 'State 3';
    await snapshot(null, 'state', '3');
    
    document.body.removeChild(container);
  });

  it('should capture snapshot after delay', async () => {
    const div = document.createElement('div');
    div.style.cssText = `
      width: 200px;
      height: 100px;
      background: purple;
      color: white;
      text-align: center;
      line-height: 100px;
      transition: all 0.3s ease;
    `;
    div.textContent = 'Will change';
    document.body.appendChild(div);

    // Change style
    setTimeout(() => {
      div.style.background = 'teal';
      div.style.transform = 'scale(1.2)';
      div.textContent = 'Changed!';
    }, 100);

    // Capture snapshot after delay (0.5 seconds)
    await snapshot(0.5, 'after_animation');
    
    document.body.removeChild(div);
  });
});