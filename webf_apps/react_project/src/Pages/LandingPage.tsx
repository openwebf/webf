import React from 'react';

interface DemoItem {
  title: string;
  description: string;
  path: string;
}

const demos: DemoItem[] = [
  {
    title: 'ArrayBuffer Demo',
    description: 'Demonstrates sending binary data from JavaScript to Dart using NativeByteData',
    path: '/array-buffer-demo'
  },
  {
    title: 'Modal Popup Demo',
    description: 'Demonstrates Flutter Cupertino modal popup integration with React',
    path: '/modal-popup-demo'
  },
  {
    title: 'Async img.src Demo',
    description: '验证 img.src 异步优化效果：批量赋值 20 张图片，JS 线程不阻塞，耗时接近 0ms',
    path: '/async-img-src-demo'
  },
  // Add more demos here as needed
];

export default function LandingPage() {
  const handleDemoClick = (path: string) => {
    // @ts-ignore
    window.webf.hybridHistory.pushNamed(path);
  };

  return (
    <div className="landing-page">
      <div className="demo-list">
        {demos.map((demo, index) => (
          <div 
            key={index} 
            className="demo-card"
            onClick={() => handleDemoClick(demo.path)}
          >
            <h2>{demo.title}</h2>
            <p>{demo.description}</p>
          </div>
        ))}
      </div>
    </div>
  );
}