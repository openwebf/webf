/**
 * Test DOM API for
 * - document.createElement
 * - document.createTextNode
 * - document.createComment
 * - document.documentElement
 */
describe('Document api async', () => {
  

  it('document.all', () => {
    expect(document.all).not.toBeUndefined();
    expect(document.all.length).toBeGreaterThan(0);
  });

  it('document.domain', async () => {
      // @ts-ignore
      let domain = await document.domain_async
      expect(domain).not.toBeUndefined();
    });

  it('document.compatMode', async () => {
      // @ts-ignore
      let compatMode = await document.compatMode_async
      expect(compatMode).not.toBeUndefined();
    });

  it('document.readyState', async () => {
      // @ts-ignore
      let readyState = await document.readyState_async
      expect(readyState).not.toBeUndefined();
    });

  it('document.visibilityState', async () => {
      // @ts-ignore
      let visibilityState = document.visibilityState_async
      expect(visibilityState).not.toBeUndefined();
    }); 

  it('document.hidden', () => {
      // @ts-ignore
      let hidden = document.hidden_async
      expect(hidden).not.toBeUndefined();
    });

  it('document.elementFromPoint should work', async () => {
    const ele = document.createElement('div')
    ele.style.width = '100px';
    ele.style.height = '100px';
    ele.style.backgroundColor = 'blue';
    document.body.appendChild(ele);
    // @ts-ignore
    const findEle = await document.elementFromPoint_async(50, 50);
    findEle.style.backgroundColor = 'yellow';
    await snapshot();
  });
});
