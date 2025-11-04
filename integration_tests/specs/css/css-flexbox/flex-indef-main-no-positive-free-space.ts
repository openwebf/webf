// Ensure flex container with indefinite main size does not synthesize
// positive free space from its automatic minimum size (padding+border).
// Regression for a case where a single flex item with `flex: 1 100%`
// incorrectly grew from the container content width (e.g., 318) to the
// container border box width (e.g., 360) due to +42px free-space created
// from container padding+border.

describe('flex-indef-main-no-positive-free-space', () => {
  it('row nowrap: flex: 1 100% should not grow beyond container content box', async () => {
    // Viewport box to clamp total available width and detect overflow
    const viewport = createElement('div', {
      id: 'viewport',
      style: {
        width: '360px',
        height: '320px',
        border: '0',
        padding: '0',
        margin: '0',
        overflow: 'auto',
        background: '#f9f9f9',
        boxSizing: 'border-box',
      },
    });

    // The flex container from the repro: auto main-size, padding/border present
    const wrapper = createElement('div', {
      class: 'wrapper',
      style: {
        display: 'flex',
        flexDirection: 'row',
        flexWrap: 'wrap',
        rowGap: '20px',
        alignItems: 'center',
        backgroundColor: '#f4f4f4',
        padding: '20px',
        border: '1px solid #000',
        fontWeight: 'bold',
        boxSizing: 'content-box',
      },
    });

    const main = createElement('div', {
      class: 'main',
      style: {
        background: 'deepskyblue',
        border: '1px solid blue',
        padding: '10px',
        // Shorthand with grow + basis (shrink defaults to 1)
        flex: '1 100%'
      },
    }, [
      createText(
        'The flexible box layout module (usually referred to as flexbox) is a one-dimensional layout model for ' +
          'distributing space between items and includes numerous alignment capabilities. This article gives an outline ' +
          'of the main features of flexbox, which we will explore in more detail in the rest of these guides.'
      ),
    ]);

    wrapper.appendChild(main);
    viewport.appendChild(wrapper);
    BODY.appendChild(viewport);

    await waitForOnScreen(wrapper);

    // Programmatic assertions:
    // 1) No horizontal overflow of the viewport container
    expect(viewport.scrollWidth).toBe(viewport.clientWidth);

    // 2) The flex item should not expand beyond the wrapper's inner width.
    // Use clientWidth (includes padding, excludes border/scrollbar) to avoid
    // engine differences in computed style width reporting for auto.
    const wrapperInnerWidth = wrapper.clientWidth;
    const mainBoxWidth = main.getBoundingClientRect().width;
    expect(mainBoxWidth <= wrapperInnerWidth + 0.5).toBe(true);

    await snapshot();
  });
});
