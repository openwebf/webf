describe('absolute flex column overlay', () => {
  it('should stretch top/right/bottom and shrink-to-fit width', async () => {
    // <div class="relative flex flex-col px-4 py-6 bg-[grey]">
    //   container
    //   <div class="absolute top-0 right-0 bottom-0 rounded-bl-lg bg-[skyblue] border-2">
    //     <div class="flex items-center">
    //       <span>tag</span>
    //     </div>
    //   </div>
    // </div>

    const outer = document.createElement('div');
    outer.style.position = 'relative';
    outer.style.display = 'flex';
    outer.style.flexDirection = 'column';
    outer.style.padding = '24px 16px'; // py-6 px-4
    outer.style.backgroundColor = 'grey';
    outer.style.width = '360px';
    outer.style.height = '72px';

    const label = document.createTextNode('container');

    const overlay = document.createElement('div');
    overlay.style.position = 'absolute';
    overlay.style.top = '0';
    overlay.style.right = '0';
    overlay.style.bottom = '0';
    overlay.style.backgroundColor = 'skyblue';
    overlay.style.border = '2px solid black';
    overlay.style.borderBottomLeftRadius = '0.75rem';

    const innerFlex = document.createElement('div');
    innerFlex.style.display = 'flex';
    innerFlex.style.alignItems = 'center';

    const span = document.createElement('span');
    span.textContent = 'tag';

    innerFlex.appendChild(span);
    overlay.appendChild(innerFlex);
    outer.appendChild(label);
    outer.appendChild(overlay);
    document.body.appendChild(outer);

    await snapshot();
  });
});

