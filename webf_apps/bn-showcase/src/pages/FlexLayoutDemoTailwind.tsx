import { WebFListView } from '@openwebf/react-core-ui';
import React from 'react';
// import DemoNavbar from '../components/DemoNavbar';

const FlexLayoutDemoTailwind: React.FC = () => {
  return (
    <WebFListView shrinkWrap={false}>
      <div className="bg-white rounded-xl mb-5" style={{ boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)' }}>
        <div className="text-white py-4 px-5 text-lg font-bold" style={{ background: 'linear-gradient(90deg, #4facfe 0%, #00f2fe 100%)' }}>
          Flex布局演示
        </div>
        <div className="p-5">
          <h3 className="text-[#333] m-0 mb-4 text-base border-l-4 border-[#4facfe] pl-3">
            1.1 水平对齐布局
          </h3>
          <div className="mb-6 border border-[#e9ecef] rounded-lg overflow-hidden">
            <div className="bg-[#6c757d] text-white py-2 px-3 text-sm font-medium">
              justify-content: space-between
            </div>
            <div className="p-4">
              <div className="flex justify-between items-center p-4 rounded-lg mb-3" style={{ background: 'linear-gradient(45deg, #ffeaa7, #fab1a0)' }}>
                <div className="bg-white/90 py-3 px-3 rounded-md font-medium" style={{ boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)' }}>左侧内容</div>
                <div className="bg-white/90 py-3 px-3 rounded-md font-medium" style={{ boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)' }}>中间内容</div>
                <div className="bg-white/90 py-3 px-3 rounded-md font-medium" style={{ boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)' }}>右侧内容</div>
              </div>
            </div>
          </div>

          <h3 className="text-[#333] m-0 mb-4 text-base border-l-4 border-[#4facfe] pl-3">
            1.2 垂直居中布局
          </h3>
          <div className="mb-6 border border-[#e9ecef] rounded-lg overflow-hidden">
            <div className="bg-[#6c757d] text-white py-2 px-3 text-sm font-medium">
              flex-direction: column + align-items: center
            </div>
            <div className="p-4">
              <div className="flex flex-col items-center p-4 rounded-lg mb-3" style={{ background: 'linear-gradient(135deg, #a8edea, #fed6e3)' }}>
                <div className="bg-white/90 py-3 px-3 rounded-md font-medium" style={{ boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)' }}>标题</div>
                <div className="bg-white/90 py-3 px-3 rounded-md font-medium" style={{ boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)' }}>副标题</div>
                <div className="bg-white/90 py-3 px-3 rounded-md font-medium" style={{ boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)' }}>内容区域</div>
              </div>
            </div>
          </div>

          <h3 className="text-[#333] m-0 mb-4 text-base border-l-4 border-[#4facfe] pl-3">
            1.3 弹性换行布局
          </h3>
          <div className="mb-6 border border-[#e9ecef] rounded-lg overflow-hidden">
            <div className="bg-[#6c757d] text-white py-2 px-3 text-sm font-medium">
              flex-wrap: wrap + gap
            </div>
            <div className="p-4">
              <div className="flex flex-wrap gap-3 p-4 rounded-lg" style={{ background: 'linear-gradient(45deg, #d299c2, #fef9d7)' }}>
                {['标签1', '标签2', '标签3', '长标签内容', '标签5', '标签6', '超长标签内容展示'].map((tag, index) => (
                  <div key={index} className="bg-white/90 py-3 px-3 rounded-md font-medium" style={{ boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)' }}>
                    {tag}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-xl mb-5" style={{ boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)' }}>
        <div className="text-white py-4 px-5 text-lg font-bold" style={{ background: 'linear-gradient(90deg, #4facfe 0%, #00f2fe 100%)' }}>
          文字样式演示
        </div>
        <div className="p-5">
          <h3 className="text-[#333] m-0 mb-4 text-base border-l-4 border-[#4facfe] pl-3">
            1.4 文字样式展示
          </h3>
          <div className="mb-6 border border-[#e9ecef] rounded-lg overflow-hidden">
            <div className="bg-[#6c757d] text-white py-2 px-3 text-sm font-medium">
              多行文本样式 + 伪类选择器
            </div>
            <div className="p-4">
              <div className="text-white p-5 rounded-lg mb-3" style={{ background: 'linear-gradient(135deg, #667eea, #764ba2)' }}>
                <p className="leading-[1.6] mb-3 text-lg font-bold">这是标题文字 - 加粗18px</p>
                <p className="leading-[1.6] mb-3 italic opacity-90">这是斜体副标题文字 - 90%透明度</p>
                <p className="leading-[1.6] mb-3 text-center underline">这是居中下划线文字</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </WebFListView>
  );
};

export default FlexLayoutDemoTailwind;