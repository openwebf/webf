/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

/**
 * Test for CSS logical properties in LTR mode
 * Tests inline-start, inline-end, block-start, and block-end properties
 *
 * These tests verify that CSS logical properties are correctly mapped to their physical
 * counterparts in LTR mode, following the CSS Logical Properties specification:
 * - inline-start → left
 * - inline-end → right
 * - block-start → top
 * - block-end → bottom
 */
describe('CSS Logical Properties', () => {
  // ================ INLINE-START PROPERTIES (maps to LEFT side in LTR) ================

  // Tests that margin-inline-start: 20px maps to margin-left: 20px in LTR mode
  // The coral div should have a 20px margin on its left side
  it('should map margin-inline-start to margin-left in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; margin-inline-start: 20px;';
    container.appendChild(child);

    await snapshot();
  });

  // Tests that padding-inline-start: 20px maps to padding-left: 20px in LTR mode
  // The coral div should have 20px padding on its left side
  it('should map padding-inline-start to padding-left in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; padding-inline-start: 20px;';
    container.appendChild(child);

    await snapshot();
  });

  // Tests that border-inline-start: 5px solid black maps to border-left: 5px solid black in LTR mode
  // The coral div should have a 5px black border on its left side
  it('should map border-inline-start to border-left in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; border-inline-start: 5px solid black;';
    container.appendChild(child);

    await snapshot();
  });

  // Tests that border-inline-start-* properties map to border-left-* properties in LTR mode
  // Tests individual border properties: width, style, and color
  // The coral div should have a 5px solid black border on its left side
  it('should map border-inline-start-* properties to border-left-* in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = `
      width: 100px;
      height: 100px;
      background-color: coral;
      border-inline-start-width: 5px;
      border-inline-start-style: solid;
      border-inline-start-color: black;
    `;
    container.appendChild(child);

    await snapshot();
  });

  // Tests that inset-inline-start: 20px maps to left: 20px in LTR mode
  // The absolutely positioned coral div should be 20px from the left edge of its container
  it('should map inset-inline-start to left in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; position: absolute; inset-inline-start: 20px;';
    container.appendChild(child);

    await snapshot();
  });

  // ================ BLOCK-START PROPERTIES (maps to TOP in LTR) ================

  // Tests that margin-block-start: 20px maps to margin-top: 20px in LTR mode
  // The coral div should have a 20px margin on its top side
  it('should map margin-block-start to margin-top in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; margin-block-start: 20px;';
    container.appendChild(child);

    await snapshot();
  });

  // Tests that padding-block-start: 20px maps to padding-top: 20px in LTR mode
  // The coral div should have 20px padding on its top side
  it('should map padding-block-start to padding-top in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; padding-block-start: 20px;';
    container.appendChild(child);

    await snapshot();
  });

  // Tests that border-block-start: 5px solid black maps to border-top: 5px solid black in LTR mode
  // The coral div should have a 5px black border on its top side
  it('should map border-block-start to border-top in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; border-block-start: 5px solid black;';
    container.appendChild(child);

    await snapshot();
  });

  // Tests that inset-block-start: 20px maps to top: 20px in LTR mode
  // The absolutely positioned coral div should be 20px from the top edge of its container
  it('should map inset-block-start to top in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; position: absolute; inset-block-start: 20px;';
    container.appendChild(child);

    await snapshot();
  });

  // ================ INLINE-END PROPERTIES (maps to RIGHT side in LTR) ================

  // Tests that margin-inline-end: 20px maps to margin-right: 20px in LTR mode
  // The coral div should have a 20px margin on its right side
  it('should map margin-inline-end to margin-right in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; margin-inline-end: 20px;';
    container.appendChild(child);

    await snapshot();
  });

  // Tests that padding-inline-end: 20px maps to padding-right: 20px in LTR mode
  // The coral div should have 20px padding on its right side
  it('should map padding-inline-end to padding-right in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; padding-inline-end: 20px;';
    container.appendChild(child);

    await snapshot();
  });

  // Tests that border-inline-end: 5px solid black maps to border-right: 5px solid black in LTR mode
  // The coral div should have a 5px black border on its right side
  it('should map border-inline-end to border-right in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; border-inline-end: 5px solid black;';
    container.appendChild(child);

    await snapshot();
  });

  // Tests that inset-inline-end: 20px maps to right: 20px in LTR mode
  // The absolutely positioned coral div should be 20px from the right edge of its container
  it('should map inset-inline-end to right in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; position: absolute; inset-inline-end: 20px;';
    container.appendChild(child);

    await snapshot();
  });

  // ================ BLOCK-END PROPERTIES (maps to BOTTOM in LTR) ================

  // Tests that margin-block-end: 20px maps to margin-bottom: 20px in LTR mode
  // The coral div should have a 20px margin on its bottom side
  it('should map margin-block-end to margin-bottom in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; margin-block-end: 20px;';
    container.appendChild(child);

    await snapshot();
  });

  // Tests that padding-block-end: 20px maps to padding-bottom: 20px in LTR mode
  // The coral div should have 20px padding on its bottom side
  it('should map padding-block-end to padding-bottom in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; padding-block-end: 20px;';
    container.appendChild(child);

    await snapshot();
  });

  // Tests that border-block-end: 5px solid black maps to border-bottom: 5px solid black in LTR mode
  // The coral div should have a 5px black border on its bottom side
  it('should map border-block-end to border-bottom in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; border-block-end: 5px solid black;';
    container.appendChild(child);

    await snapshot();
  });

  // Tests that inset-block-end: 20px maps to bottom: 20px in LTR mode
  // The absolutely positioned coral div should be 20px from the bottom edge of its container
  it('should map inset-block-end to bottom in LTR mode', async () => {
    const container = document.createElement('div');
    container.style.cssText = 'width: 200px; height: 200px; background-color: lightblue; position: relative;';
    document.body.appendChild(container);

    const child = document.createElement('div');
    child.style.cssText = 'width: 100px; height: 100px; background-color: coral; position: absolute; inset-block-end: 20px;';
    container.appendChild(child);

    await snapshot();
  });
});
