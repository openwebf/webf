describe('Negative horizontal margins full-bleed block (issue #240)', () => {
  it('width:auto with negative left/right margins equals container width', async () => {
    // Outer container with horizontal padding
    const container = createElement(
      'div',
      {
        className: 'container',
        style: {
          display: 'flex',
          flexDirection: 'column',
          flexShrink: '0',
          boxSizing: 'border-box',
          zIndex: '0',
          paddingLeft: '16px',
          paddingRight: '16px',
          width: '300px',
          backgroundColor: '#fafafa',
        },
      }
    );

    // Nested container (no extra padding)
    const container2 = createElement('div', {
      className: 'container2',
      style: {
        display: 'flex',
        flexDirection: 'column',
        flexShrink: '0',
        boxSizing: 'border-box',
        zIndex: '0',
      }
    });

    // The static block with no explicit width and negative horizontal margins
    const container3 = createElement('div', {
      className: 'container3',
      style: {
        display: 'flex',
        flexDirection: 'column',
        flexShrink: '0',
        boxSizing: 'border-box',
        zIndex: '0',
        marginTop: '8px',
        marginLeft: '-16px',
        marginRight: '-16px',
        paddingLeft: '16px',
        paddingRight: '16px',
        backgroundColor: 'rgba(238, 240, 246, 0.996)',
      }
    });

    const content = createElement('span', {
      className: 'content',
      style: {
        zIndex: '0',
        paddingTop: '8px',
        color: 'rgba(0,0,0,0.996)',
        whiteSpace: 'normal',
        wordBreak: 'break-all',
        textOverflow: 'ellipsis',
      }
    }, [
      createText('【点赞+留言】这条动态，从评论区抽100个牛魔秒杀皮肤红包。抽奖说明:多次留言只计算一人获奖，人数不足100人无需抽奖直接中奖，1月23日开奖！')
    ]);

    container3.appendChild(content);
    container2.appendChild(container3);
    container.appendChild(container2);
    append(BODY, container);

    await snapshot();
  });
});

