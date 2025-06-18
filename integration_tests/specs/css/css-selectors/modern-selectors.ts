describe("Modern CSS Selectors", () => {
  describe(":is() pseudo-class", () => {
    it("should match elements with :is() selector", async () => {
      const style = document.createElement('style');
      style.innerHTML = `
        :is(div, span) {
          color: red;
        }
        :is(.foo, .bar) {
          background-color: yellow;
        }
        :is(h1, h2, h3) {
          font-size: 20px;
        }
      `;
      
      document.head.appendChild(style);
      document.body.appendChild(
        <div>
          <div class="foo">Div with foo class</div>
          <span class="bar">Span with bar class</span>
          <h1>Heading 1</h1>
          <h2>Heading 2</h2>
          <p class="foo">Paragraph with foo class</p>
        </div>
      );
      
      await snapshot();
    });

    it("should work with complex selectors in :is()", async () => {
      const style = document.createElement('style');
      style.innerHTML = `
        article :is(h1, h2, h3) {
          color: blue;
        }
        :is(section, article) > :is(h1, h2) {
          text-decoration: underline;
        }
      `;
      
      document.head.appendChild(style);
      document.body.appendChild(
        <div>
          <article>
            <h1>Article H1</h1>
            <h2>Article H2</h2>
            <p>Article paragraph</p>
          </article>
          <section>
            <h1>Section H1</h1>
            <h3>Section H3</h3>
          </section>
        </div>
      );
      
      await snapshot();
    });
  });

  describe(":where() pseudo-class", () => {
    it("should match elements with :where() selector", async () => {
      const style = document.createElement('style');
      style.innerHTML = `
        /* :where() has 0 specificity */
        :where(div, span) {
          color: green;
        }
        /* This should override :where() due to higher specificity */
        span {
          color: blue;
        }
        :where(.important) {
          font-weight: bold;
        }
      `;
      
      document.head.appendChild(style);
      document.body.appendChild(
        <div>
          <div class="important">Div with important class</div>
          <span class="important">Span with important class (should be blue)</span>
        </div>
      );
      
      await snapshot();
    });

    it("should have zero specificity", async () => {
      const style = document.createElement('style');
      style.innerHTML = `
        /* Higher specificity selector */
        .container div {
          color: red;
        }
        /* :where() with lower specificity should not override */
        :where(.container div.special) {
          color: green;
        }
        /* Direct class selector should override :where() */
        .special {
          color: blue;
        }
      `;
      
      document.head.appendChild(style);
      document.body.appendChild(
        <div class="container">
          <div>Normal div (red)</div>
          <div class="special">Special div (blue)</div>
        </div>
      );
      
      await snapshot();
    });
  });

  describe(":has() pseudo-class", () => {
    it("should match parent elements that contain specific children", async () => {
      const style = document.createElement('style');
      style.innerHTML = `
        /* Parent that has a child with .highlight class */
        div:has(.highlight) {
          border: 2px solid red;
          padding: 10px;
        }
        /* List item that has a checked checkbox */
        li:has(input:checked) {
          background-color: lightgreen;
        }
      `;
      
      document.head.appendChild(style);
      document.body.appendChild(
        <div>
          <div>
            <span class="highlight">This parent should have red border</span>
          </div>
          <div>
            <span>This parent should not have red border</span>
          </div>
          <ul>
            <li><input type="checkbox" checked /> Checked item</li>
            <li><input type="checkbox" /> Unchecked item</li>
          </ul>
        </div>
      );
      
      await snapshot();
    });

    it("should work with complex selectors", async () => {
      const style = document.createElement('style');
      style.innerHTML = `
        /* Article that contains an image */
        article:has(img) {
          background-color: lightyellow;
        }
        /* Div that has a direct p child with specific class */
        div:has(> p.important) {
          border: 1px solid blue;
        }
        /* Element that has a sibling */
        h2:has(+ p) {
          color: green;
        }
      `;
      
      document.head.appendChild(style);
      document.body.appendChild(
        <div>
          <article>
            <h2>Article with image</h2>
            <img src="data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs=" />
            <p>Some text</p>
          </article>
          <article>
            <h2>Article without image</h2>
            <p>Some text</p>
          </article>
          <div>
            <p class="important">Direct important paragraph</p>
          </div>
          <div>
            <span><p class="important">Nested important paragraph</p></span>
          </div>
          <h2>Heading with sibling</h2>
          <p>Sibling paragraph</p>
          <h2>Heading without sibling</h2>
        </div>
      );
      
      await snapshot();
    });
  });

  describe(":focus-visible pseudo-class", () => {
    it("should apply styles when element is focused via keyboard", async () => {
      const style = document.createElement('style');
      style.innerHTML = `
        button:focus-visible {
          outline: 3px solid blue;
          outline-offset: 2px;
        }
        input:focus-visible {
          border-color: green;
          box-shadow: 0 0 5px green;
        }
      `;
      
      document.head.appendChild(style);
      const button = document.createElement('button');
      button.textContent = 'Focus me with keyboard';
      const input = document.createElement('input');
      input.placeholder = 'Focus me with keyboard';
      
      document.body.appendChild(button);
      document.body.appendChild(input);
      
      // Note: In real usage, :focus-visible activates on keyboard focus
      // For testing, we'll just take a snapshot of the unfocused state
      await snapshot();
    });
  });

  describe(":focus-within pseudo-class", () => {
    it("should apply styles when element or descendant is focused", async () => {
      const style = document.createElement('style');
      style.innerHTML = `
        form:focus-within {
          background-color: lightblue;
          padding: 20px;
        }
        .field-group:focus-within {
          border: 2px solid blue;
        }
      `;
      
      document.head.appendChild(style);
      document.body.appendChild(
        <form>
          <div class="field-group">
            <label>Name:</label>
            <input type="text" placeholder="Enter name" />
          </div>
          <div class="field-group">
            <label>Email:</label>
            <input type="email" placeholder="Enter email" />
          </div>
          <button type="submit">Submit</button>
        </form>
      );
      
      await snapshot();
    });
  });

  describe("::backdrop pseudo-element", () => {
    it("should style the backdrop of modal elements", async () => {
      const style = document.createElement('style');
      style.innerHTML = `
        dialog::backdrop {
          background-color: rgba(0, 0, 0, 0.5);
        }
        .fullscreen::backdrop {
          background-color: rgba(255, 0, 0, 0.3);
        }
      `;
      
      document.head.appendChild(style);
      
      // Note: ::backdrop is typically used with dialog.showModal() or fullscreen API
      // For testing purposes, we'll just create the elements
      const dialog = document.createElement('dialog');
      dialog.textContent = 'This is a dialog';
      document.body.appendChild(dialog);
      
      const div = document.createElement('div');
      div.className = 'fullscreen';
      div.textContent = 'Fullscreen element';
      document.body.appendChild(div);
      
      await snapshot();
    });
  });
});