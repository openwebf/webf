// Repro for https://github.com/openwebf/webf-enterprise/issues/66
// Wrapped multi-line text in a flex row with a leading dot icon should not overlap.

describe('flex text wrapping without overlap (enterprise #66)', () => {
  fit('items-start with bullet + break-words text wraps cleanly', async () => {
    document.body.style.margin = '0';

    // <div class="flex items-start" style="background:red">
    const row = document.createElement('div');
    row.style.display = 'flex';
    row.style.alignItems = 'flex-start';
    row.style.backgroundColor = 'red';
    row.style.padding = '8px';
    row.style.border = '1px solid #ccc';

    // <div class="bg-text-primary mr-2 mt-3 h-1.5 w-1.5 rounded-full" />
    const dot = document.createElement('div');
    dot.style.marginRight = '8px'; // mr-2
    dot.style.marginTop = '12px';  // mt-3
    dot.style.width = '6px';       // w-1.5
    dot.style.height = '6px';      // h-1.5
    dot.style.borderRadius = '9999px';
    dot.style.backgroundColor = '#222';

    // <span class="min-w-0 break-words">...</span>
    const text = document.createElement('span');
    text.style.minWidth = '0';
    // Tailwind break-words -> overflow-wrap: anywhere;
    (text.style as any).overflowWrap = 'anywhere';
    text.textContent = '若您已付款：请第一时间提交订单申诉并联系 ';

    // <span class="text-primary-blue inline pr-1">MEXC 客服</span>
    const link = document.createElement('span');
    link.style.color = '#0969da';
    link.style.display = 'inline';
    link.style.paddingRight = '4px';
    link.textContent = 'MEXC 客服';

    // trailing text to ensure multiple lines
    const tail = document.createTextNode(' 进行处理，与此同时您可以联系卖方沟通补充下单或协商退款。');

    text.appendChild(link);
    text.appendChild(tail);

    row.appendChild(dot);
    row.appendChild(text);
    document.body.appendChild(row);

    // Helper to assert no overlap between dot and text rects
    const assertNoOverlap = () => {
      const r1 = dot.getBoundingClientRect();
      const r2 = text.getBoundingClientRect();
      // No horizontal overlap expected
      expect(r1.right <= r2.left + 0.5).toBe(true);
      // Vertical positions should be reasonable
      expect(r2.top >= row.getBoundingClientRect().top).toBe(true);
    };

    // Wide: should be single-line or two lines w/o overlap
    row.style.width = '360px';
    await snapshot();
    assertNoOverlap();

    // Constrain width: enforce wrapping
    row.style.width = '260px';
    await snapshot();
    assertNoOverlap();

    // Narrower
    row.style.width = '200px';
    await snapshot();
    assertNoOverlap();
  });
});

