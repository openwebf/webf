describe('DevTools Network Panel', () => {
  it('should capture and display network requests', async (done) => {
    // Make several network requests to test the panel
    const testUrls = [
      'https://httpbin.org/get',
      'https://httpbin.org/post',
      'https://httpbin.org/status/404',
      'https://httpbin.org/delay/2'
    ];

    // GET request
    fetch(testUrls[0])
      .then(response => response.json())
      .then(data => console.log('GET response:', data))
      .catch(err => console.error('GET error:', err));

    // POST request with JSON body
    fetch(testUrls[1], {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: 'WebF Test',
        timestamp: Date.now()
      })
    })
      .then(response => response.json())
      .then(data => console.log('POST response:', data))
      .catch(err => console.error('POST error:', err));

    // 404 error request
    fetch(testUrls[2])
      .then(response => {
        console.log('404 status:', response.status);
        return response.text();
      })
      .then(data => console.log('404 response:', data))
      .catch(err => console.error('404 error:', err));

    // Delayed request (to test pending state)
    fetch(testUrls[3])
      .then(response => response.json())
      .then(data => console.log('Delayed response:', data))
      .catch(err => console.error('Delayed error:', err));

    // Wait a bit for requests to complete
    setTimeout(() => {
      console.log('Network panel test completed');
      done();
    }, 5000);
  });

  it('should display request details correctly', async (done) => {
    // Test with different content types
    const imageUrl = 'https://via.placeholder.com/150';
    const jsonUrl = 'https://jsonplaceholder.typicode.com/posts/1';
    
    // Image request
    fetch(imageUrl)
      .then(response => response.blob())
      .then(blob => console.log('Image size:', blob.size))
      .catch(err => console.error('Image error:', err));

    // JSON request
    fetch(jsonUrl)
      .then(response => response.json())
      .then(data => console.log('JSON data:', data))
      .catch(err => console.error('JSON error:', err));

    setTimeout(() => {
      done();
    }, 3000);
  });
});