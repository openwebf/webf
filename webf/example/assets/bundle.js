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

document.body.appendChild(p);

let count = 0;
document.getElementById('logo').addEventListener('click',()=>{
  text2.textContent = `你好，webf！${count++}`
})
document.getElementById('logo2').addEventListener('click',()=>{
  webf.methodChannel.invokeMethod('openPage')
})