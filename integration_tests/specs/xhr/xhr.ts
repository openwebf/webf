describe('XMLHttpRequest', () => {
  it('Get method success', (done) => {
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        expect(xhr.readyState).toBe(4);
        const status = xhr.status;
        expect(status).toBe(200);
        if ((status >= 200 && status < 300) || status == 304) {
          expect(JSON.parse(xhr.responseText)).toEqual({
            method: 'GET',
            data: { userName: "12345" }
          });
        }
        done();
      }
    };
    xhr.open('GET', `${LOCAL_HTTP_SERVER}/json_with_content_length_expires_etag_and_last_modified`, true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send();
  });

  it('Get method fail', (done) => {
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        expect(xhr.readyState).toBe(4);
        const status = xhr.status;
        expect(status).toBe(404);
        done();
      }
    };
    xhr.open('GET', 'https://andycall.oss-cn-beijing.aliyuncs.com/data/foo.json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send();
  });

  it('POST method success', (done) => {
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        expect(xhr.readyState).toBe(4);
        const status = xhr.status;
        expect(status).toBe(200);
        if ((status >= 200 && status < 300) || status == 304) {
          expect(xhr.responseText).not.toBeNull();
        }
        done();
      }
    };
    xhr.open('POST', 'http://h5api.m.taobao.com/h5/mtop.common.gettimestamp/1.0/?api=mtop.common.gettimestamp&v=1.0&dataType=json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send('foobar');
  });

  it('POST method fail', (done) => {
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        expect(xhr.readyState).toBe(4);
        const status = xhr.status;
        expect(status).toBe(405);
        done();
      }
    };
    xhr.open('POST', 'https://andycall.oss-cn-beijing.aliyuncs.com/data/data.json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send('foobar');
  });

  it('should works when setting responseType to arraybuffer',  (done) => {
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = async function() {
      if (xhr.readyState == 4) {
        let arrayBuffer = xhr.response;
        assert_true(arrayBuffer instanceof ArrayBuffer);
        let blob = new Blob([arrayBuffer]);
        let text = await blob.text();
        expect(text).toEqual(`{
    "method": "GET",
    "data": {
        "userName": "12345"
    }
}`);
        done();
      }
    };
    xhr.responseType = 'arraybuffer';
    xhr.open('GET', 'https://andycall.oss-cn-beijing.aliyuncs.com/data/data.json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send();
  });

  it('should works when setting responseType to blob',  (done) => {
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = async function() {
      if (xhr.readyState == 4) {
        let blob = xhr.response;
        assert_true(blob instanceof Blob);
        let text = await blob.text();
        expect(text).toEqual(`{
    "method": "GET",
    "data": {
        "userName": "12345"
    }
}`);
        done();
      }
    };
    xhr.responseType = 'blob';
    xhr.open('GET', 'https://andycall.oss-cn-beijing.aliyuncs.com/data/data.json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send();
  });

  it('should works when setting responseType to blob',  (done) => {
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = async function() {
      if (xhr.readyState == 4) {
        let text = xhr.response;
        expect(xhr.responseText).toEqual(text);
        expect(text).toEqual(`{
    "method": "GET",
    "data": {
        "userName": "12345"
    }
}`);
        done();
      }
    };
    xhr.responseType = '';
    xhr.open('GET', 'https://andycall.oss-cn-beijing.aliyuncs.com/data/data.json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send();
  });

  it('should works when setting responseType to json',  (done) => {
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = async function() {
      if (xhr.readyState == 4) {
        let json = xhr.response;
        expect(json).toEqual({
          "method": "GET",
          "data": {
            "userName": "12345"
          }
        });
        done();
      }
    };
    xhr.responseType = 'json';
    xhr.open('GET', 'https://andycall.oss-cn-beijing.aliyuncs.com/data/data.json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send();
  });
});
