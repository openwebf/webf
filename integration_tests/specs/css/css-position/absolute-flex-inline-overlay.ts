describe('absolute flex inline overlay', () => {
  it('should keep intrinsic width for abspos child under flex', async () => {
    // <div class="flex items-center justify-between bg-[skyblue]">
    //   container
    //   <div class="relative flex h-4 self-start">
    //     <div class="absolute top-1.5 right-0 flex items-center justify-center">
    //       <div class="h-full bg-[red]">another_tag</div>
    //     </div>
    //   </div>
    // </div>

    const outer = document.createElement('div');
    outer.style.display = 'flex';
    outer.style.alignItems = 'center';
    outer.style.justifyContent = 'space-between';
    outer.style.backgroundColor = 'skyblue';
    outer.style.width = '360px';
    outer.style.height = '40px';

    const label = document.createElement('span');
    label.textContent = 'container';

    const relFlex = document.createElement('div');
    relFlex.style.position = 'relative';
    relFlex.style.display = 'flex';
    relFlex.style.alignSelf = 'flex-start';
    relFlex.style.height = '16px'; // tailwind h-4

    const absWrapper = document.createElement('div');
    absWrapper.style.position = 'absolute';
    absWrapper.style.top = '0.375rem'; // tailwind top-1.5
    absWrapper.style.right = '0';
    absWrapper.style.display = 'flex';
    absWrapper.style.alignItems = 'center';
    absWrapper.style.justifyContent = 'center';

    const tag = document.createElement('div');
    tag.style.height = '100%';
    tag.style.backgroundColor = 'red';
    tag.textContent = 'another_tag';

    absWrapper.appendChild(tag);
    relFlex.appendChild(absWrapper);
    outer.appendChild(label);
    outer.appendChild(relFlex);
    document.body.appendChild(outer);

    await snapshot();
  });
});

