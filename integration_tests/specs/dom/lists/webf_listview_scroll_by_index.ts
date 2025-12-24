describe('WebFListView.scrollByIndex', () => {
  fit('should scroll to the last item by index', async (done) => {
    const listview = document.createElement('webf-listview') as any;
    listview.style.width = '300px';
    listview.style.height = '200px';
    listview.style.border = '1px solid black';
    listview.style.margin = '20px';

    const itemCount = 60;
    for (let i = 0; i < itemCount; i++) {
      const item = document.createElement('div');
      item.id = `scroll-by-index-item-${i}`;
      item.style.height = '50px';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.paddingLeft = '8px';
      item.style.boxSizing = 'border-box';
      item.style.borderBottom = '1px solid #eee';
      item.textContent = `Item ${i}`;
      listview.appendChild(item);
    }

    document.body.appendChild(listview);

    await snapshot();

    // @ts-ignore
    listview.ononscreen = async () => {
      await sleep(0.1);

      expect(typeof listview.scrollByIndex).toBe('function');

      const lastIndex = itemCount - 1;
      const ok = await listview.scrollByIndex(lastIndex, { animated: false, duration: 0, alignment: 1 });
      expect(ok).toBeTrue();

      await sleep(0.1);

      const lastItem = document.getElementById(`scroll-by-index-item-${lastIndex}`)!;
      const listRect = listview.getBoundingClientRect();
      const lastRect = lastItem.getBoundingClientRect();

      expect(lastRect.height).toBeGreaterThan(0);
      expect(lastRect.bottom).toBeLessThanOrEqual(listRect.bottom + 2);
      expect(lastRect.top).toBeGreaterThanOrEqual(listRect.top - 2);

      await snapshot();

      done();
    };
  });
});

