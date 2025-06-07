describe('ES Modules', () => {
  it('should support script type="module"', async (done) => {
    const div = document.createElement('div');
    document.body.appendChild(div);

    const script = document.createElement('script');
    script.type = 'module';
    script.textContent = `
      const message = 'Hello from module';
      window.moduleMessage = message;
    `;
    
    script.onload = () => {
      expect(window.moduleMessage).toBe('Hello from module');
      done();
    };
    
    script.onerror = () => {
      done.fail('Module script failed to load');
    };
    
    document.body.appendChild(script);
  });

  it('should evaluate module scripts with module scope', async (done) => {
    const script = document.createElement('script');
    script.type = 'module';
    script.textContent = `
      // In module scope, 'this' is undefined
      window.moduleThis = this;
    `;
    
    script.onload = () => {
      expect(window.moduleThis).toBeUndefined();
      done();
    };
    
    document.body.appendChild(script);
  });
});