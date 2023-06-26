var text1 = document.createTextNode('Hello webf!');
var br = document.createElement('br');
var text2 = document.createTextNode('你好，webf！');
var p = document.createElement('p');
p.className = 'p';
p.style.display = 'inline-block';
p.style.textAlign = 'center';
p.style.animation = '3s ease-in 1s 1 reverse both running example';
p.appendChild(text1);
p.appendChild(br);
p.appendChild(text2);

const ws = new WebSocket('ws://127.0.0.1:8080');
ws.onopen = () => {
  setInterval(()=>{
    ws.send('{"type":"heartbeat"}')
  }, 2000)
};
ws.onmessage = (event) => {
  console.log('ws.onmessage:', event);
}

document.body.appendChild(p);
