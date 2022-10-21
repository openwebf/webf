var text1 = document.createTextNode('Hello webf!');
var br = document.createElement('br');
var text2 = document.createTextNode('你好，webf！');
var bn = BigInt(10000);
var text3 = document.createTextNode(`${typeof bn} is enabled`);
var p = document.createElement('p');
p.className = 'p';
p.style.display = 'inline-block';
p.style.textAlign = 'center';
p.style.animation = '3s ease-in 1s 1 reverse both running example';
p.appendChild(text1);
p.appendChild(br);
p.appendChild(text2);
p.appendChild(br);
p.appendChild(text3);

document.body.appendChild(p);
