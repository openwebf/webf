describe('CSS1 rounding', () => {
  xit('handles fractional em padding without gaps', async () => {
    const style = document.createElement('style');
    style.textContent = `
    body, div {
        margin: 0;
        padding: 0;
        border: 0;
    }
    #top, #bottom {
        line-height: 1.5;
        font-size: 70%;
        background: green;
        color: white;
        width: 100%;
    }
    #top {
        padding: .6em 0 .7em;
    }
    #bottom {
      position: absolute;
      top: 2.8em;
    }
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <div id="top">no gap below</div>
      <div id="bottom">no gap above</div>
      <div id="description"></div>
      <div id="console"></div>
    `;

    try {
      await snapshot();
    } finally {
      document.body.innerHTML = '';
      style.remove();
    }
  });
});
