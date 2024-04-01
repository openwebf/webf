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


var goBtn = document.createElement('div');
goBtn.innerHTML = 'go';
goBtn.style.width = '100px';
goBtn.style.height = '40px';
goBtn.style.borderRadius = '4px';
goBtn.style.margin = '10px';
goBtn.style.lineHeight = '40px';
goBtn.style.textAlign = 'center';
goBtn.style.color = '#FFFFFF';
goBtn.style.backgroundColor = '#2196F3';
goBtn.style.verticalAlign = 'middle';
goBtn.addEventListener('click', (e) => {
    console.log('go' , window.history)
    window.hybridHistory.go(-1)
})

var backBtn = document.createElement('div');
backBtn.innerHTML = 'back';
backBtn.style.width = '100px';
backBtn.style.height = '40px';
backBtn.style.borderRadius = '4px';
backBtn.style.margin = '10px';
backBtn.style.lineHeight = '40px';
backBtn.style.textAlign = 'center';
backBtn.style.color = '#FFFFFF';
backBtn.style.backgroundColor = '#2196F3';
backBtn.style.verticalAlign = 'middle';
backBtn.addEventListener('click', (e) => {
    console.log('backBtn');
    // window.history.back()
    window.hybridHistory.back()
})

var forwardBtn = document.createElement('div');
forwardBtn.innerHTML = 'forwardBtn';
forwardBtn.style.width = '100px';
forwardBtn.style.height = '40px';
forwardBtn.style.borderRadius = '4px';
forwardBtn.style.margin = '10px';
forwardBtn.style.lineHeight = '40px';
forwardBtn.style.textAlign = 'center';
forwardBtn.style.color = '#FFFFFF';
forwardBtn.style.backgroundColor = '#2196F3';
forwardBtn.style.verticalAlign = 'middle';
forwardBtn.addEventListener('click', (e) => {
    console.log('forwardBtn');
    // window.history.back()
    window.hybridHistory.forward()
})

var pushStateBtn = document.createElement('div');
pushStateBtn.innerHTML = 'pushState';
pushStateBtn.style.width = '100px';
pushStateBtn.style.height = '40px';
pushStateBtn.style.borderRadius = '4px';
pushStateBtn.style.margin = '10px';
pushStateBtn.style.lineHeight = '40px';
pushStateBtn.style.textAlign = 'center';
pushStateBtn.style.color = '#FFFFFF';
pushStateBtn.style.backgroundColor = '#2196F3';
pushStateBtn.style.verticalAlign = 'middle';
pushStateBtn.addEventListener('click', (e) => {
    console.log('pushStateBtn', window.hybridHistory);
    // window.history.pushState({}, '', '/home')
    window.hybridHistory.pushState({}, '', '/home')
})

var replaceStateBtn = document.createElement('div');
replaceStateBtn.innerHTML = 'replaceState';
replaceStateBtn.style.width = '100px';
replaceStateBtn.style.height = '40px';
replaceStateBtn.style.borderRadius = '4px';
replaceStateBtn.style.margin = '10px';
replaceStateBtn.style.lineHeight = '40px';
replaceStateBtn.style.textAlign = 'center';
replaceStateBtn.style.color = '#FFFFFF';
replaceStateBtn.style.backgroundColor = '#2196F3';
replaceStateBtn.style.verticalAlign = 'middle';
replaceStateBtn.addEventListener('click', (e) => {
    console.log('replaceStateBtn', window.hybridHistory);
    // window.history.pushState({}, '', '/home')
    window.hybridHistory.replaceState({}, '', '/other')
})

document.body.appendChild(p);
document.body.appendChild(goBtn);
document.body.appendChild(backBtn);
document.body.appendChild(forwardBtn);
document.body.appendChild(pushStateBtn);
document.body.appendChild(replaceStateBtn);

window.addEventListener('popstate', (e) => {
    console.log('onPopstate', e);
    console.log('hybridHistory Length', window.hybridHistory.length);
})