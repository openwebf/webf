import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';

class NetworkTestPage extends StatefulWidget {
  @override
  _NetworkTestPageState createState() => _NetworkTestPageState();
}

class _NetworkTestPageState extends State<NetworkTestPage> {
  late WebFController controller;

  @override
  void initState() {
    super.initState();
    controller = WebFController(
      viewportWidth: 360,
      viewportHeight: 640,
      bundle: WebFBundle.fromContent('''
        <!DOCTYPE html>
        <html>
        <head>
          <title>Network Panel Test</title>
          <style>
            body {
              font-family: Arial, sans-serif;
              padding: 20px;
            }
            button {
              margin: 10px;
              padding: 10px 20px;
              font-size: 16px;
              cursor: pointer;
            }
            #status {
              margin-top: 20px;
              padding: 10px;
              background: #f0f0f0;
              border-radius: 5px;
            }
            .request-item {
              margin: 5px 0;
              padding: 5px;
              background: white;
              border: 1px solid #ddd;
              border-radius: 3px;
            }
          </style>
        </head>
        <body>
          <h1>Network Panel Test</h1>
          <p>Click the buttons below to make different types of network requests:</p>
          
          <button onclick="makeGetRequest()">GET Request</button>
          <button onclick="makePostRequest()">POST Request</button>
          <button onclick="make404Request()">404 Error</button>
          <button onclick="makeDelayedRequest()">Delayed Request</button>
          <button onclick="makeImageRequest()">Image Request</button>
          <button onclick="makeMultipleRequests()">Multiple Requests</button>
          
          <div id="status">
            <h3>Request Status:</h3>
            <div id="requests"></div>
          </div>
          
          <script>
            const requestsDiv = document.getElementById('requests');
            
            function addStatus(message, type = 'info') {
              const item = document.createElement('div');
              item.className = 'request-item';
              item.style.borderColor = type === 'error' ? '#ff0000' : '#0066cc';
              item.textContent = message;
              requestsDiv.appendChild(item);
            }
            
            async function makeGetRequest() {
              addStatus('Making GET request...');
              try {
                const response = await fetch('https://jsonplaceholder.typicode.com/posts/1');
                const data = await response.json();
                addStatus('GET completed: ' + data.title);
              } catch (error) {
                addStatus('GET failed: ' + error.message, 'error');
              }
            }
            
            async function makePostRequest() {
              addStatus('Making POST request...');
              try {
                const response = await fetch('https://jsonplaceholder.typicode.com/posts', {
                  method: 'POST',
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  body: JSON.stringify({
                    title: 'WebF Test Post',
                    body: 'Testing network panel',
                    userId: 1,
                  }),
                });
                const data = await response.json();
                addStatus('POST completed: ID ' + data.id);
              } catch (error) {
                addStatus('POST failed: ' + error.message, 'error');
              }
            }
            
            async function make404Request() {
              addStatus('Making 404 request...');
              try {
                const response = await fetch('https://jsonplaceholder.typicode.com/posts/9999');
                if (!response.ok) {
                  addStatus('404 Error: ' + response.status + ' ' + response.statusText, 'error');
                } else {
                  addStatus('404 test failed - got success response');
                }
              } catch (error) {
                addStatus('404 request failed: ' + error.message, 'error');
              }
            }
            
            async function makeDelayedRequest() {
              addStatus('Making delayed request (3s)...');
              const startTime = Date.now();
              try {
                const response = await fetch('https://httpbin.org/delay/3');
                const duration = Date.now() - startTime;
                addStatus('Delayed request completed in ' + duration + 'ms');
              } catch (error) {
                addStatus('Delayed request failed: ' + error.message, 'error');
              }
            }
            
            async function makeImageRequest() {
              addStatus('Making image request...');
              try {
                const response = await fetch('https://via.placeholder.com/150');
                const blob = await response.blob();
                addStatus('Image loaded: ' + blob.size + ' bytes');
              } catch (error) {
                addStatus('Image request failed: ' + error.message, 'error');
              }
            }
            
            async function makeMultipleRequests() {
              addStatus('Making multiple parallel requests...');
              const urls = [
                'https://jsonplaceholder.typicode.com/posts/1',
                'https://jsonplaceholder.typicode.com/posts/2',
                'https://jsonplaceholder.typicode.com/posts/3',
                'https://jsonplaceholder.typicode.com/users/1',
                'https://jsonplaceholder.typicode.com/comments/1',
              ];
              
              const promises = urls.map(url => fetch(url));
              try {
                const responses = await Promise.all(promises);
                addStatus('All ' + responses.length + ' requests completed');
              } catch (error) {
                addStatus('Multiple requests failed: ' + error.message, 'error');
              }
            }
          </script>
        </body>
        </html>
      ''', contentType: ContentType.html),
      devToolsService: ChromeDevToolsService(),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Panel Test'),
      ),
      body: Stack(
        children: [
          WebF(controller: controller),
          // Add the inspector floating panel
          WebFInspectorFloatingPanel(visible: true),
        ],
      ),
    );
  }
}

// Add this page to your app's routes
void main() {
  runApp(MaterialApp(
    home: NetworkTestPage(),
  ));
}