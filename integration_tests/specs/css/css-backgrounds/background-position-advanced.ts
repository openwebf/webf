describe('Background-position advanced syntax', () => {
  // Advanced 3/4-value grammar checks; mark skipped until full support.

  xit('right 10px bottom 20px', async () => {
    const div = createElement('div', {
      style: {
        width: '180px',
        height: '120px',
        background: 'url(assets/cat.png) no-repeat yellow',
        backgroundPosition: 'right 10px bottom 20px'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });

  xit('left 12px top 13px (computed)', async (done) => {
    const target = createElement('div', { style: { 'background-image': 'url(assets/cat.png)' } });
    append(BODY, target);
    target.ononscreen = () => {
      test_computed_value('background-position', 'left 12px top 13px', '12px 13px');
      done();
    };
  });

  xit('center right 7% (computed)', async (done) => {
    const target = createElement('div', { style: { 'background-image': 'url(assets/cat.png)' } });
    append(BODY, target);
    target.ononscreen = () => {
      test_computed_value('background-position', 'center right 7%', '93% 50%');
      done();
    };
  });

  xit('right 11% bottom (computed)', async (done) => {
    const target = createElement('div', { style: { 'background-image': 'url(assets/cat.png)' } });
    append(BODY, target);
    target.ononscreen = () => {
      test_computed_value('background-position', 'right 11% bottom', '89% 100%');
      done();
    };
  });
});

