import { WebFListView } from '@openwebf/react-core-ui';
import React from 'react';
// import DemoNavbar from '../components/DemoNavbar';

const NestedScrollDemoTailwind: React.FC = () => {
  return (
    <WebFListView shrinkWrap={false}>
      <div className="bg-white rounded-xl mb-5" style={{ boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)' }}>
        <div className="text-white py-4 px-5 text-lg font-bold" style={{ background: 'linear-gradient(90deg, #4facfe 0%, #00f2fe 100%)' }}>
          垂直与水平滚动并存
        </div>
        <div className="p-5">
          <h3 className="text-[#333] m-0 mb-4 text-base border-l-4 border-[#4facfe] pl-3">
            3.1 垂直与水平滚动并存
          </h3>
          <div className="mb-6 border border-[#e9ecef] rounded-lg overflow-hidden">
            <div className="bg-[#6c757d] text-white py-2 px-3 text-sm font-medium">
              overflow-y: auto + overflow-x: auto
            </div>
            <div className="p-4">
              <div className="h-[400px] flex gap-4">
                <div className="flex-1 h-full overflow-y-auto border-2 border-[#6c757d] rounded-lg p-3 bg-white">
                  <h4 className="text-[#6c757d] mt-0">垂直滚动区域</h4>
                  {Array.from({ length: 15 }, (_, i) => (
                    <div key={i} className="min-w-[200px] p-4 rounded-lg mb-3 text-[#333] font-medium" style={{ background: 'linear-gradient(135deg, #84fab0, #8fd3f4)' }}>
                      垂直滚动卡片 {i + 1}
                      <br />
                      支持长文本内容换行显示
                      <br />
                      这是第{i + 1}张卡片的详细内容
                    </div>
                  ))}
                </div>

                <div className="flex-1 h-full overflow-x-auto border-2 border-[#28a745] rounded-lg p-3 bg-white">
                  <h4 className="text-[#28a745] mt-0">水平滚动区域</h4>
                  <div className="flex gap-3 w-max pb-3">
                    {Array.from({ length: 10 }, (_, i) => (
                      <div key={i} className="min-w-[200px] p-4 rounded-lg mb-3 text-[#333] font-medium" style={{ background: 'linear-gradient(135deg, #84fab0, #8fd3f4)' }}>
                        水平卡片 {i + 1}
                        <br />
                        固定宽度200px
                        <br />
                        可以水平滚动
                        <br />
                        卡片内容 #{i + 1}
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-xl mb-5" style={{ boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)' }}>
        <div className="text-white py-4 px-5 text-lg font-bold" style={{ background: 'linear-gradient(90deg, #4facfe 0%, #00f2fe 100%)' }}>
          多层嵌套滚动
        </div>
        <div className="p-5">
          <h3 className="text-[#333] m-0 mb-4 text-base border-l-4 border-[#4facfe] pl-3">
            3.2 多层嵌套滚动
          </h3>
          <div className="mb-6 border border-[#e9ecef] rounded-lg overflow-hidden">
            <div className="bg-[#6c757d] text-white py-2 px-3 text-sm font-medium">
              外层滚动容器包含内层滚动容器
            </div>
            <div className="p-4">
              <div className="h-[200px] overflow-y-auto border border-[#dee2e6] rounded-md my-2">
                <div className="p-3">
                  <h5 className="text-[#495057] m-0 mb-2">外层滚动容器</h5>
                  <p>这是外层容器的内容，可以垂直滚动</p>

                  <div className="h-[120px] overflow-y-auto border border-[#dee2e6] rounded-md my-2 bg-[#e9ecef]">
                    <div className="p-2">
                      <h6 className="text-[#6c757d] m-0 mb-2">内层嵌套滚动</h6>
                      {Array.from({ length: 8 }, (_, i) => (
                        <p key={i} className="my-1 py-1 px-2 bg-white rounded">
                          内层内容 {i + 1} - 这是嵌套在内层的滚动内容
                        </p>
                      ))}
                    </div>
                  </div>

                  <p className="mt-3">外层容器的更多内容</p>
                  {Array.from({ length: 5 }, (_, i) => (
                    <p key={i} className="my-2 p-2 bg-[#f8f9fa] rounded">
                      外层段落 {i + 1} - 测试嵌套滚动的交互效果，外层和内层滚动应该能独立工作
                    </p>
                  ))}
                </div>
              </div>
            </div>
          </div>

          <h3 className="text-[#333] m-0 mb-4 text-base border-l-4 border-[#4facfe] pl-3">
            3.3 复杂嵌套滚动示例
          </h3>
          <div className="mb-6 border border-[#e9ecef] rounded-lg overflow-hidden">
            <div className="bg-[#6c757d] text-white py-2 px-3 text-sm font-medium">
              三层嵌套滚动 + 不同方向滚动
            </div>
            <div className="p-4">
              <div className="h-[300px] overflow-auto border-2 border-[#007bff] rounded-lg p-3">
                <h5 className="text-[#007bff] mt-0">第一层：主容器滚动</h5>
                <p>这是最外层的滚动容器，包含各种复杂的嵌套滚动场景</p>

                <div className="flex gap-3 h-[180px]">
                  <div className="flex-1 overflow-auto border border-[#28a745] rounded-md p-2">
                    <h6 className="text-[#28a745] mt-0">第二层：左侧垂直滚动</h6>
                    {Array.from({ length: 12 }, (_, i) => (
                      <div key={i} className="p-2 my-1 bg-[#d4edda] rounded">
                        左侧内容 {i + 1}
                      </div>
                    ))}
                  </div>

                  <div className="flex-1 overflow-auto border border-[#ffc107] rounded-md p-2">
                    <h6 className="text-[#ffc107] mt-0">第二层：右侧水平滚动</h6>
                    <div className="flex gap-2 w-max">
                      {Array.from({ length: 8 }, (_, i) => (
                        <div key={i} className="min-w-[120px] p-3 bg-[#fff3cd] rounded">
                          水平项 {i + 1}
                        </div>
                      ))}
                    </div>

                    <div className="mt-3 h-20 overflow-auto border border-[#dc3545] rounded p-1">
                      <div className="text-xs text-[#dc3545] font-bold">第三层：嵌套垂直滚动</div>
                      {Array.from({ length: 10 }, (_, i) => (
                        <div key={i} className="p-1 my-0.5 bg-[#f8d7da] rounded-sm text-xs">
                          深层内容 {i + 1}
                        </div>
                      ))}
                    </div>
                  </div>
                </div>

                <div className="mt-4">
                  <h6>底部补充内容</h6>
                  {Array.from({ length: 6 }, (_, i) => (
                    <p key={i} className="p-2 bg-[#e2e3e5] rounded my-1">
                      主容器底部内容 {i + 1} - 用于测试最外层容器的滚动效果
                    </p>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </WebFListView>
  );
};

export default NestedScrollDemoTailwind;