/**
 * Test DOM API for
 * - document.createElement
 * - document.createTextNode
 * - document.createComment
 * - document.documentElement
 */
describe('Document api async', () => {
  it('document.domain', async (done) => {
      // @ts-ignore
      let domain = await document.domain_async
      expect(domain).not.toBeUndefined();
      done();
    });

  it('document.compatMode', async (done) => {
      // @ts-ignore
      let compatMode = await document.compatMode_async
      expect(compatMode).not.toBeUndefined();
      done();
    });

  it('document.readyState', async (done) => {
      // @ts-ignore
      let readyState = await document.readyState_async
      expect(readyState).not.toBeUndefined();
      done();
    });

  it('document.visibilityState', async (done) => {
      // @ts-ignore
      let visibilityState = document.visibilityState_async
      expect(visibilityState).not.toBeUndefined();
      done();
    }); 

  it('document.hidden', (done) => {
      // @ts-ignore
      let hidden = document.hidden_async
      expect(hidden).not.toBeUndefined();
      done();
    });

  it('document.elementFromPoint should work', async (done) => {
    const ele = document.createElement('div')
    ele.style.width = '100px';
    ele.style.height = '100px';
    ele.style.backgroundColor = 'blue';
    document.body.appendChild(ele);
    // @ts-ignore
    const findEle = await document.elementFromPoint_async(50, 50);
    findEle.style.backgroundColor = 'yellow';
    await snapshot();
    done();
  });
});
