describe('absolute positioned z-index inside webf-listview', () => {
  it('paints an abspos overlay above later list items', async () => {
    const listview = document.createElement('webf-listview');
    listview.style.width = '280px';
    listview.style.height = '220px';
    listview.style.border = '1px solid #d4d4d8';
    listview.style.position = 'relative';
    listview.style.backgroundColor = '#fafafa';

    const firstItem = document.createElement('div');
    firstItem.style.position = 'relative';
    firstItem.style.height = '72px';
    firstItem.style.padding = '12px';
    firstItem.style.backgroundColor = '#f4f4f5';
    firstItem.textContent = 'Account menu trigger';

    const overlay = document.createElement('div');
    overlay.id = 'listview-abspos-overlay';
    overlay.style.position = 'absolute';
    overlay.style.top = '40px';
    overlay.style.left = '12px';
    overlay.style.width = '180px';
    overlay.style.height = '120px';
    overlay.style.backgroundColor = 'rgba(239, 68, 68, 0.92)';
    overlay.style.color = '#fff';
    overlay.style.zIndex = '50';
    overlay.textContent = 'Overlay';
    firstItem.appendChild(overlay);

    listview.appendChild(firstItem);
    document.body.appendChild(listview);
    await snapshot();

    const secondItem = document.createElement('div');
    secondItem.id = 'listview-following-card';
    secondItem.style.height = '180px';
    secondItem.style.marginTop = '-56px';
    secondItem.style.padding = '16px';
    secondItem.style.backgroundColor = 'rgba(59, 130, 246, 0.96)';
    secondItem.style.color = '#fff';
    secondItem.textContent = 'Development Plan';

    listview.appendChild(secondItem);
    await waitForOnScreen(listview);
    await snapshot();

    const overlayRect = overlay.getBoundingClientRect();
    const secondRect = secondItem.getBoundingClientRect();
    const left = Math.max(overlayRect.left, secondRect.left);
    const right = Math.min(overlayRect.right, secondRect.right);
    const top = Math.max(overlayRect.top, secondRect.top);
    const bottom = Math.min(overlayRect.bottom, secondRect.bottom);

    expect(right).toBeGreaterThan(left);
    expect(bottom).toBeGreaterThan(top);

    const x = left + (right - left) / 2;
    const y = top + (bottom - top) / 2;
    expect(document.elementFromPoint(x, y)).toBe(overlay);

    listview.remove();
  });
});
