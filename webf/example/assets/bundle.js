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
var button = document.getElementById('button');

function testBlobArrayBufferDataView() {  
    const output = document.getElementById('output');  
    console.log(1);
    // 测试 Blob  
    const blob = new Blob(['Hello, Blob!']);  
    console.log(2);
    // const reader = new FileReader();  
    // console.log(3);
    // reader.onload = function(e) {  
    //     output.textContent += 'Blob content: ' + e.target.result + '\n';  
    //     console.log(4);
    // };  
    // console.log(5);
    // reader.readAsText(blob);  
    // console.log(6);
    // 测试 ArrayBuffer 和 DataView  
    const buffer = new ArrayBuffer(16); // 创建一个 16 字节的 ArrayBuffer  
    console.log('buffer',typeof buffer,buffer.constructor.name);
    const view = new DataView(buffer);  console.log(7);
  
    // 设置 ArrayBuffer 中的一些数据  
    view.setInt32(0, 25, true); // 在位置 0 写入一个 32 位整数，小端字节序  
    console.log(8);
    view.setFloat32(4, Math.PI, true); // 在位置 4 写入一个 32 位浮点数，小端字节序  
    console.log(9);
    // 读取 ArrayBuffer 中的数据  
    output.textContent += 'Int32 at position 0 (little-endian): ' + view.getInt32(0, true) + '\n';  
    console.log(10);
    output.textContent += 'Float32 at position 4 (little-endian): ' + view.getFloat32(4, true) + '\n';  
    console.log(11);
    // 展示 ArrayBuffer 的类型信息  
    output.textContent += 'ArrayBuffer byte length: ' + buffer.byteLength + '\n';  
    console.log(12);
}  

function testFormData(){
    // 创建一个 FormData 实例
    const formData = new FormData();
    console.log('formData',formData,'type=',formData.constructor.name)
    // 添加一些数据
    formData.append('key1', 'value1');
    formData.append('key1', 'value1.1');
    formData.append('key2', 'value2');
    formData.set('key2', 'new-value2');

    // 测试 get 方法
    console.log('Getting key1:', formData.get('key1'));
    console.log('Getting key2:', formData.get('key2'));

    // 测试 getAll 方法
    console.log('Getting all key1:', formData.getAll('key1'));

    console.log('Getting all key2:', formData.getAll('key2'));

    // 测试 has 方法
    console.log('Checking has key1:', formData.has('key1'));
    console.log('Checking has key2:', formData.has('key2'));

    // 测试 del 方法
    formData.delete('key1');
    console.log('Deleting key1: has key1 after delete:', formData.has('key1'));

    // 测试 forEach 方法
    formData.forEach((value, key) => {
        console.log(`Iterating: Key: ${key}, Value: ${value}`);
    });
}
  
// 当文档加载完成时，为按钮添加点击事件监听器（可选，因为已经在 HTML 中通过 onclick 添加了）  
document.addEventListener('DOMContentLoaded', function() {  
    testFormData();
    const button = document.querySelector('button');  
    button.addEventListener('click', testBlobArrayBufferDataView);  
});


