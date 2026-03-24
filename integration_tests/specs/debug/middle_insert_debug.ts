describe('middle insert debug', () => {
  it('logs geometry after insertBefore in middle position', async () => {
    let containerStyle = {
      backgroundColor: 'fuchsia',
      color: 'black',
      font: '20px',
      margin: '10px'
    };

    let innerDivStyle = {
      margin: '10px 0'
    };

    let insertedStyle = {
      borderLeft: '5px solid yellow',
      borderRight: '5px solid yellow'
    };

    let insertPoint = createElementWithStyle('span', {}, createText('FourthInline'));
    let insertBlock = createElementWithStyle('span', insertedStyle, createText('Inserted new inline'));

    let container = createElementWithStyle('div', containerStyle, [
      createElementWithStyle('span', {}, createText('1stInline')),
      createElementWithStyle('span', {}, createText('ScndInline')),
      createElementWithStyle('div', innerDivStyle, createText('1stBlock')),
      insertPoint,
      createElementWithStyle('span', {}, createText('Fifth55Inline')),
      createElementWithStyle('div', innerDivStyle, createText('SecondBlock')),
      createElementWithStyle('span', {}, createText('Seven777Inline')),
    ]);

    append(BODY, container);

    await snapshot();

    container.insertBefore(insertBlock, insertPoint);
    await new Promise(resolve => requestAnimationFrame(() => resolve(null)));

    const childSummary = Array.from(container.childNodes).map((child: Node) => {
      if (child.nodeType === Node.TEXT_NODE) {
        return `#text:${child.textContent}`;
      }
      const el = child as HTMLElement;
      return `${el.tagName}:${el.textContent}`;
    });

    console.log('childSummary', JSON.stringify(childSummary));
    console.log('insertConnected', insertBlock.isConnected);
    console.log('insertParent', insertBlock.parentNode === container);
    console.log('insertText', insertBlock.textContent);
    console.log('insertDisplay', getComputedStyle(insertBlock).display);
    console.log('insertRect', JSON.stringify(insertBlock.getBoundingClientRect()));
    console.log('insertPointRect', JSON.stringify(insertPoint.getBoundingClientRect()));
    console.log('containerRect', JSON.stringify(container.getBoundingClientRect()));

    await snapshot();
  });
});
