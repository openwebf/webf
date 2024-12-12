describe('ListView', () => {
  it('listview could adjust its height based on inner HTMLelements size', async () => {
    const container = createElement('listview', {
      style: {
        border: '1px solid #000'
      }
    }, [
      createElement('div', {
        style: {
          padding: '10px'
        }
      }, createText('ABC')),
      createText('\n \n \n TEXTTEXT TEXT \n \n \n'),
      createText('\n \n \n TEXTTEXT TEXT \n \n \n'),
      createText('\n \n \n TEXTTEXT TEXT \n \n \n'),
      createText('\n \n \n TEXTTEXT TEXT \n \n \n'),
      createText('\n \n \n TEXTTEXT TEXT \n \n \n'),
      createElement('div', {
        style: {
          border: '1px solid blue'
        }
      }, [ createText('END')])
    ]);

    BODY.append(container);
    BODY.append(createText('the TEXT AFTER CONTAINER'));
    await snapshot();
  });
});
