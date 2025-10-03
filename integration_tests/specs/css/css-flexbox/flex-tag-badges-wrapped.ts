describe('flex badges wrap layout', () => {
  function createTagItem(): HTMLDivElement {
    const tagItem = document.createElement('div');
    tagItem.className = 'tagItem';

    const wrapper = document.createElement('div');
    wrapper.className = 'wrapper wrapperMargin';
    wrapper.setAttribute('style', 'display: flex; justify-content: space-between;');

    const borderLeft = document.createElement('div');
    borderLeft.className = 'borderLeft';
    borderLeft.setAttribute('style', 'background-color: #fff; border-color: #FC8C8A;');

    const middleWrapper = document.createElement('div');
    middleWrapper.className = 'wrapper middleWrapper';
    middleWrapper.setAttribute('style', 'border-color: #FC8C8A; background-color: transparent; padding-right: 2px;');

    const inner = document.createElement('div');
    inner.setAttribute('style', 'border-right-color: transparent; background-color: transparent;');

    const spanOuter = document.createElement('span');
    spanOuter.setAttribute('style', 'color: #FF1E19;');

    const spanHidden = document.createElement('span');
    spanHidden.setAttribute('style', 'display:none;');
    spanHidden.textContent = '领400元叠加券';

    const spanShown = document.createElement('span');
    spanShown.textContent = '领400元叠加券';

    spanOuter.appendChild(spanHidden);
    spanOuter.appendChild(spanShown);
    inner.appendChild(spanOuter);
    middleWrapper.appendChild(inner);

    const borderRight = document.createElement('div');
    borderRight.className = 'borderRight';
    borderRight.setAttribute('style', 'background-color: #fff; border-color: #FC8C8A;');

    wrapper.appendChild(borderLeft);
    wrapper.appendChild(middleWrapper);
    wrapper.appendChild(borderRight);

    tagItem.appendChild(wrapper);
    return tagItem;
  }

  it('renders complex container with wrapped tags and decorative borders', async () => {
    const style = document.createElement('style');
    style.textContent = `
      *{
        margin: 0;
        padding: 0;
        font-size: 12px;
      }
      .container{
        margin: 10px;
        background-color: white;
      }
      .container_s {
        flex-direction: row;
        background-color: #fff;
        overflow: hidden;
        position: relative;
      }
      .container_n {
        display: flex;
        margin-right: 11px;
        flex-direction: row;
        flex-wrap: wrap;
        padding-bottom: 1px;
        border-width: 0;
      }
      .tagItem, .tag {
        margin-top: 5px;
        margin-right: 5px;
        overflow: hidden;
      }
      .wrapper {
        flex: 1;
        height: 19px;
        flex-direction: row;
        align-items: center;
        position: relative;
        overflow: hidden;
        box-sizing: border-box;
      }
      .wrapperMargin {
        margin-right: 4px;
      }
      .borderLeft, .borderRight {
        width: 9px;
        height: 9px;
        top: 4px;
        z-index: 9;
        position: absolute;
        border-width: 1px;
        border-radius: 9px;
        border-style: solid;
        border-color: #FC8C8A
      }
      .borderLeft {
        left: -7px;
      }
      .borderRight {
        right: -7px;
      }
      .middleWrapper {
        border-radius: 2px;
        padding-left: 4px;
        border-width: 1px;
        border-style: solid;
      }
    `;
    document.head.appendChild(style);

    // First standalone tag item with margin
    const standaloneTag = createTagItem();
    standaloneTag.setAttribute('style', 'margin: 10px');
    document.body.appendChild(standaloneTag);

    // Second complex container structure
    const container = document.createElement('div');
    container.className = 'container';

    const containerS = document.createElement('div');
    containerS.className = 'container_s';

    const flexChild = document.createElement('div');
    flexChild.setAttribute('style', 'flex: 1 1 auto;');

    const testHeight = document.createElement('div');
    testHeight.id = 'testHeight';
    testHeight.setAttribute('style', 'overflow: hidden; max-height: 24px;');

    const containerN = document.createElement('div');
    containerN.className = 'container_n';
    containerN.setAttribute('style', 'max-height: 24px;');

    // Append multiple tag items
    for (let i = 0; i < 6; i++) {
      containerN.appendChild(createTagItem());
    }

    testHeight.appendChild(containerN);
    flexChild.appendChild(testHeight);
    containerS.appendChild(flexChild);
    container.appendChild(containerS);
    document.body.appendChild(container);

    await snapshot();
  });
});

