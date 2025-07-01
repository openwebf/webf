import React from 'react';
import { useNavigate } from '@openwebf/react-router';

const DemoTailwind: React.FC = () => {
  const { navigate } = useNavigate();

  const menuItems = [
    {
      id: 'flex-layout',
      title: 'Flex布局与文字样式',
      description: '展示各种Flex布局方式和文字样式，包括水平对齐、垂直居中、弹性换行等常见布局模式',
      icon: '📐',
      tags: ['flexbox', 'justify-content', 'align-items', 'flex-wrap', 'text-style'],
      path: '/demo/flex-layout'
    },
    // {
    //   id: 'grid-sticky',
    //   title: 'Grid布局与Sticky定位',
    //   description: '演示CSS Grid的强大布局能力和Sticky粘性定位效果，包括自适应网格和粘性标题',
    //   icon: '🎯',
    //   tags: ['css-grid', 'position-sticky', 'auto-fit', 'minmax', 'responsive'],
    //   path: '/demo/grid-sticky'
    // },
    {
      id: 'nested-scroll',
      title: '嵌套滚动场景',
      description: '测试复杂嵌套滚动场景，包括垂直水平滚动并存和多层嵌套滚动的交互效果',
      icon: '📜',
      tags: ['overflow', 'nested-scroll', 'scroll-behavior', 'multi-direction'],
      path: '/demo/nested-scroll'
    }
  ];

  return (
    <div className="h-full flex flex-col" style={{
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'
    }}>
      <div className="text-white py-[30px] px-5 text-center">
        <h1 className="text-[28px] font-bold m-0 mb-[10px]">WebF 能力验证</h1>
        <p className="text-base opacity-90 m-0">选择下方模块开始测试 WebF 的渲染能力</p>
      </div>

      <div className="flex-1 p-5 flex flex-col gap-5">
        {menuItems.map((item) => (
          <div
            key={item.id}
            className="bg-white rounded-2xl p-6 shadow-[0_8px_32px_rgba(0,0,0,0.1)] cursor-pointer transition-all duration-300 ease-in-out border-2 border-transparent mt-5"
          onClick={() => navigate(item.path)}
          >
            <div className="flex items-center mb-3">
              <div className="text-2xl mr-3 w-10 h-10 flex items-center justify-center rounded-lg" style={{
                background: 'linear-gradient(135deg, #4facfe, #00f2fe)'
              }}>
                {item.icon}
              </div>
              <h3 className="text-xl font-bold text-[#333] m-0">{item.title}</h3>
            </div>
            <p className="text-[#666] text-sm leading-[1.5] m-0 mb-4">
              {item.description}
            </p>
            <div className="flex flex-wrap gap-2">
              {item.tags.map((tag) => (
                <span key={tag} className="bg-[#f8f9fa] text-[#495057] py-1 px-2 rounded-xl text-xs font-medium">
                  {tag}
                </span>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default DemoTailwind;