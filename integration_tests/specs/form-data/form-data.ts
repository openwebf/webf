describe('FormData', () => {
  describe('constructor', () => {
    it('should create an empty FormData instance', () => {
      const formData = new FormData();
      expect(formData).toBeDefined();
    });
  });

  describe('append', () => {
    it('should append string values', () => {
      const formData = new FormData();
      formData.append('name', 'John Doe');
      formData.append('age', '30');

      expect(formData.get('name')).toBe('John Doe');
      expect(formData.get('age')).toBe('30');
    });

    it('should append multiple values with the same name', () => {
      const formData = new FormData();
      formData.append('fruit', 'apple');
      formData.append('fruit', 'banana');

      expect(formData.get('fruit')).toBe('apple');
      const all = formData.getAll('fruit');
      expect(all.length).toBe(2);
      expect(all[0]).toBe('apple');
      expect(all[1]).toBe('banana');
    });

    it('should append blob data', async () => {
      const formData = new FormData();
      const blob = new Blob(['test blob content'], { type: 'text/plain' });
      formData.append('file', blob, 'test.txt');

      const file = formData.get('file');
      expect(file instanceof Blob).toBe(true);

      // Verify content
      const text = await (file as Blob).text();
      expect(text).toBe('test blob content');
    });
  });

  describe('delete', () => {
    it('should delete entries by name', () => {
      const formData = new FormData();
      formData.append('name', 'John Doe');
      formData.append('age', '30');

      expect(formData.has('name')).toBe(true);
      formData.delete('name');
      expect(formData.has('name')).toBe(false);
      expect(formData.has('age')).toBe(true);
    });

    it('should delete all entries with the same name', () => {
      const formData = new FormData();
      formData.append('fruit', 'apple');
      formData.append('fruit', 'banana');

      expect(formData.getAll('fruit').length).toBe(2);
      formData.delete('fruit');
      expect(formData.has('fruit')).toBe(false);
      expect(formData.getAll('fruit').length).toBe(0);
    });
  });

  describe('get', () => {
    it('should return the first value for a given name', () => {
      const formData = new FormData();
      formData.append('fruit', 'apple');
      formData.append('fruit', 'banana');

      expect(formData.get('fruit')).toBe('apple');
    });

    it('should return null for non-existent names', () => {
      const formData = new FormData();
      expect(formData.get('nonexistent')).toBe(null);
    });
  });

  describe('getAll', () => {
    it('should return all values for a given name', () => {
      const formData = new FormData();
      formData.append('fruit', 'apple');
      formData.append('fruit', 'banana');
      formData.append('fruit', 'orange');

      const values = formData.getAll('fruit');
      expect(values.length).toBe(3);
      expect(values[0]).toBe('apple');
      expect(values[1]).toBe('banana');
      expect(values[2]).toBe('orange');
    });

    it('should return empty array for non-existent names', () => {
      const formData = new FormData();
      const values = formData.getAll('nonexistent');
      expect(Array.isArray(values)).toBe(true);
      expect(values.length).toBe(0);
    });
  });

  describe('has', () => {
    it('should return true if the FormData contains the given name', () => {
      const formData = new FormData();
      formData.append('name', 'John Doe');

      expect(formData.has('name')).toBe(true);
      expect(formData.has('age')).toBe(false);
    });
  });

  describe('set', () => {
    it('should set a new value, replacing any existing values', () => {
      const formData = new FormData();
      formData.append('fruit', 'apple');
      formData.append('fruit', 'banana');

      expect(formData.getAll('fruit').length).toBe(2);

      formData.set('fruit', 'orange');

      expect(formData.getAll('fruit').length).toBe(1);
      expect(formData.get('fruit')).toBe('orange');
    });

    it('should set a blob value with filename', async () => {
      const formData = new FormData();
      const blob = new Blob(['content'], { type: 'text/plain' });

      formData.set('file', blob, 'test.txt');

      const file = formData.get('file');
      expect(file instanceof Blob).toBe(true);

      const text = await (file as Blob).text();
      expect(text).toBe('content');
    });
  });

  describe('Integration with fetch', () => {
    it('should send FormData via fetch API and validate server response', async () => {
      const formData = new FormData();
      formData.append('name', 'John Doe');
      formData.append('age', '30');

      const blob = new Blob(['test file content'], { type: 'text/plain' });
      formData.append('file', blob, 'test.txt');

      // Test that FormData is correctly populated
      expect(formData.get('name')).toBe('John Doe');
      expect(formData.get('age')).toBe('30');

      const fileBlob = formData.get('file') as Blob;
      expect(fileBlob instanceof Blob).toBe(true);
      const fileText = await fileBlob.text();
      expect(fileText).toBe('test file content');

      // Send to server
      const response = await fetch('/upload', {
        method: 'POST',
        body: formData
      });

      // Check response and validate that server received the correct data
      const data = await response.json();
      expect(data.success).toBe(true);
      expect(data.message).toBe('FormData received and validated');

      // Verify form fields were correctly received
      expect(data.fields.name).toBe('John Doe');
      expect(data.fields.age).toBe('30');

      // Verify file was correctly received
      expect(data.files.length).toBe(1);
      expect(data.files[0].fieldname).toBe('file');
      expect(data.files[0].originalname).toBe('test.txt');
      expect(data.files[0].mimetype).toBe('text/plain');
      expect(data.files[0].contentPreview).toBe('test file content');
    });

    it('should handle multiple files in FormData', async () => {
      const formData = new FormData();

      // Add text fields
      formData.append('username', 'testuser');
      formData.append('email', 'test@example.com');

      // Add multiple files of different types
      const textBlob = new Blob(['This is a text file'], { type: 'text/plain' });
      formData.append('textFile', textBlob, 'document.txt');

      const jsonData = JSON.stringify({ key: 'value' });
      const jsonBlob = new Blob([jsonData], { type: 'application/json' });
      formData.append('jsonFile', jsonBlob, 'data.json');

      // Send to server
      const response = await fetch('/upload', {
        method: 'POST',
        body: formData
      });

      // Check response
      const data = await response.json();
      expect(data.success).toBe(true);

      // Verify form fields
      expect(data.fields.username).toBe('testuser');
      expect(data.fields.email).toBe('test@example.com');

      // Verify files
      expect(data.files.length).toBe(2);

      // Find files by fieldname
      const textFile = data.files.find(f => f.fieldname === 'textFile');
      const jsonFile = data.files.find(f => f.fieldname === 'jsonFile');

      // Verify text file
      expect(textFile).toBeDefined();
      expect(textFile.originalname).toBe('document.txt');
      expect(textFile.mimetype).toBe('text/plain');
      expect(textFile.contentPreview).toBe('This is a text file');

      // Verify JSON file
      expect(jsonFile).toBeDefined();
      expect(jsonFile.originalname).toBe('data.json');
      expect(jsonFile.mimetype).toBe('application/json');
      expect(jsonFile.contentPreview).toBe('{"key":"value"}');
    });
  });
});
