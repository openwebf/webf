// Repro for https://github.com/openwebf/webf-enterprise/issues/55
// background-clip: text with linear-gradient should render correctly even when
// the element is centered in the page via flex layout.

describe('background-clip:text with gradient centered (enterprise #55)', () => {
  it('renders gradient text when centered in a flex container', async () => {
    document.body.style.margin = '0';

    const style = document.createElement('style');
    style.textContent = `
      .content {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        width: 100%;
        margin-bottom: 24px;
      }
      .App-header {
        background-color: #282c34;
        min-height: 100vh;
        display: flex;
        width: 100%;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: white;
        margin: auto;
      }
      .taskTitle { font-size: 14px; font-weight: 500; line-height: 20px; color: #87909f; margin-bottom: 4px; }
      .taskSubDescription { font-size: 14px; font-weight: 500; line-height: 20px; color: #f2f4f6; }
      .taskDescription {
        font-size: 50px;
        font-weight: 600;
        line-height: 28px;
        background-image: linear-gradient(rgba(123,22,2), rgba(23,12,222));
        /* include both properties to maximize support */
        background-clip: text;
        -webkit-background-clip: text;
        color: transparent;
        margin-bottom: 16px;
      }
    `;
    document.head.appendChild(style);

    const content = document.createElement('div');
    content.className = 'content';

    const header = document.createElement('div');
    header.className = 'App-header';

    const taskInfo = document.createElement('div');
    taskInfo.className = 'taskInfo';

    const title = document.createElement('div');
    title.className = 'taskTitle';
    title.textContent = '1';

    const desc = document.createElement('div');
    desc.className = 'taskDescription';
    desc.textContent = 'B';

    const sub = document.createElement('div');
    sub.className = 'taskSubDescription';
    sub.textContent = 'AAA';

    taskInfo.appendChild(title);
    taskInfo.appendChild(desc);
    taskInfo.appendChild(sub);
    header.appendChild(taskInfo);
    content.appendChild(header);
    document.body.appendChild(content);

    // Basic sanity checks (not sufficient to prove paint) but helpful
    const cs = getComputedStyle(desc);
    expect(cs.getPropertyValue('background-image')).not.toBe('none');
    expect(cs.getPropertyValue('color')).toBe('rgba(0, 0, 0, 0)');

    await snapshot();
  });
});

