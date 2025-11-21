import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
// Resolve asset URL via Vite without needing image module typings
const flower = new URL('../../resource/bg_flower.gif', import.meta.url).href;

type CSSProps = React.CSSProperties;

const SectionHeader: React.FC<{ title: string }>= ({ title }) => (
  <div className="mt-5 font-semibold text-[#2c3e50]">{title}</div>
);

const DemoItem: React.FC<{ label: string; style?: CSSProps; className?: string }>= ({ label, style, className }) => (
  <div className="flex flex-col mt-3">
    <div className="text-sm text-[#374151]">{label}</div>
    <div
      className={[
        'mt-2 mb-4 border border-dashed border-[#bdbdbd]',
        'w-[220px] h-[120px] bg-white',
        className ?? ''
      ].join(' ')}
      style={style}
    />
  </div>
);

export const BGPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen">
      <WebFListView className="px-3 md:px-6 bg-[#f8f9fa] max-w-5xl mx-auto py-4">
          <SectionHeader title="Linear gradient directions" />
          <div className="flex flex-wrap gap-4 items-start">
            <DemoItem label="linear-gradient(red, blue)" className="w-[100px] h-[100px]" style={{ background: 'red linear-gradient(red, blue)' }} />
            <DemoItem label="to top" className="w-[100px] h-[100px]" style={{ background: 'red linear-gradient(to top, red, blue)' }} />
            <DemoItem label="to bottom" className="w-[100px] h-[100px]" style={{ background: 'rgba(255,0,0,0.5) linear-gradient(to bottom, red, blue)' }} />
            <DemoItem label="to left" className="w-[100px] h-[100px]" style={{ background: 'rgba(255,0,0,0.5) linear-gradient(to left, red, blue)' }} />
            <DemoItem label="to right" className="w-[100px] h-[100px]" style={{ background: 'rgba(255,0,0,0.5) linear-gradient(to right, red, blue)' }} />
            <DemoItem label="to top-left alpha" className="w-[100px] h-[100px]" style={{ background: 'red linear-gradient(to top left, rgba(255,0,0,0.8), rgba(0,0,255,0.8))' }} />
            <DemoItem label="to top-right alpha" className="w-[100px] h-[100px]" style={{ background: 'red linear-gradient(to top right, rgba(255,0,0,0.8), rgba(0,0,255,0.8))' }} />
            <DemoItem label="to bottom-right alpha" className="w-[100px] h-[100px]" style={{ background: 'red linear-gradient(to bottom right, rgba(255,0,0,0.8), rgba(0,0,255,0.8))' }} />
            <DemoItem label="to bottom-left alpha" className="w-[100px] h-[100px]" style={{ background: 'red linear-gradient(to bottom left, rgba(255,0,0,0.8), rgba(0,0,255,0.8))' }} />
            <DemoItem label="linear-gradient(#ff0000, #0000ff)" className="w-[100px] h-[100px]" style={{ background: 'red linear-gradient(#ff0000, #0000ff)' }} />
            <DemoItem label="mix: img + gradients (1)" className="w-[300px] h-[100px]" style={{
              backgroundImage: `url(${flower}), linear-gradient(to bottom, green, pink), linear-gradient(to bottom left, red, yellow, blue)`,
              backgroundSize: '50px auto',
              backgroundRepeat: 'repeat, no-repeat',
            }} />
            <DemoItem label="mix: different angle + sizes" className="w-[300px] h-[100px]" style={{
              backgroundImage: `url(${flower}), linear-gradient(30deg, red, yellow, blue), linear-gradient(60deg, red, yellow, blue)`,
              backgroundSize: '150px, 100px, 100px',
              backgroundRepeat: 'repeat, no-repeat, repeat',
            }} />
          </div>

          <SectionHeader title="Background repeat" />
          <div className="flex flex-wrap gap-4 items-start">
            <DemoItem label="repeat" style={{ backgroundImage: `url(${flower})`, backgroundSize: '40px 40px', backgroundRepeat: 'repeat' }} />
            <DemoItem label="repeat-x" style={{ backgroundImage: `url(${flower})`, backgroundSize: '40px 40px', backgroundRepeat: 'repeat-x' }} />
            <DemoItem label="repeat-y" style={{ backgroundImage: `url(${flower})`, backgroundSize: '40px 40px', backgroundRepeat: 'repeat-y' }} />
            <DemoItem label="no-repeat" style={{ backgroundImage: `url(${flower})`, backgroundSize: '40px 40px', backgroundRepeat: 'no-repeat' }} />
            <DemoItem label="space" style={{ backgroundImage: `url(${flower})`, backgroundSize: '40px 40px', backgroundRepeat: 'space' }} />
            <DemoItem label="round" style={{ backgroundImage: `url(${flower})`, backgroundSize: '40px 40px', backgroundRepeat: 'round' }} />
          </div>

          <SectionHeader title="Background position" />
          <div className="flex flex-wrap gap-4 items-start">
            <DemoItem label="left top" style={{ backgroundImage: `url(${flower})`, backgroundSize: '50px 50px', backgroundRepeat: 'no-repeat', backgroundPosition: 'left top' }} />
            <DemoItem label="center center" style={{ backgroundImage: `url(${flower})`, backgroundSize: '50px 50px', backgroundRepeat: 'no-repeat', backgroundPosition: 'center center' }} />
            <DemoItem label="right 20px bottom 10px" style={{ backgroundImage: `url(${flower})`, backgroundSize: '50px 50px', backgroundRepeat: 'no-repeat', backgroundPosition: 'right 20px bottom 10px' }} />
            <DemoItem label="50% 10px" style={{ backgroundImage: `url(${flower})`, backgroundSize: '50px 50px', backgroundRepeat: 'no-repeat', backgroundPosition: '50% 10px' }} />
          </div>

          <SectionHeader title="Background size" />
          <div className="flex flex-wrap gap-4 items-start">
            <DemoItem label="auto (default)" style={{ backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'center' }} />
            <DemoItem label="cover" style={{ backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'center', backgroundSize: 'cover' }} />
            <DemoItem label="contain" style={{ backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'center', backgroundSize: 'contain' }} />
            <DemoItem label="50px auto" style={{ backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'center', backgroundSize: '50px auto' }} />
            <DemoItem label="auto 50px" style={{ backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'center', backgroundSize: 'auto 50px' }} />
          </div>

          <SectionHeader title="Background origin & clip" />
          <div className="flex flex-wrap gap-4 items-start">
            <DemoItem label="origin: border-box" className="w-[220px] h-[120px] border-[10px] border-solid border-gray-400 p-5 bg-[#fff7ed]" style={{ backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'top left', backgroundSize: '60px 60px', backgroundOrigin: 'border-box' }} />
            <DemoItem label="origin: padding-box" className="w-[220px] h-[120px] border-[10px] border-solid border-gray-400 p-5 bg-[#fff7ed]" style={{ backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'top left', backgroundSize: '60px 60px', backgroundOrigin: 'padding-box' }} />
            <DemoItem label="origin: content-box" className="w-[220px] h-[120px] border-[10px] border-solid border-gray-400 p-5 bg-[#fff7ed]" style={{ backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'top left', backgroundSize: '60px 60px', backgroundOrigin: 'content-box' }} />
            <DemoItem label="clip: border-box" className="w-[220px] h-[120px] border-[10px] border-solid border-gray-400 p-5 bg-[#fff7ed]" style={{ backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'top left', backgroundSize: '60px 60px', backgroundClip: 'border-box' }} />
            <DemoItem label="clip: padding-box" className="w-[220px] h-[120px] border-[10px] border-solid border-gray-400 p-5 bg-[#fff7ed]" style={{ backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'top left', backgroundSize: '60px 60px', backgroundClip: 'padding-box' }} />
            <DemoItem label="clip: content-box" className="w-[220px] h-[120px] border-[10px] border-solid border-gray-400 p-5 bg-[#fff7ed]" style={{ backgroundImage: `url(${flower})`, backgroundRepeat: 'no-repeat', backgroundPosition: 'top left', backgroundSize: '60px 60px', backgroundClip: 'content-box' }} />
          </div>

          <SectionHeader title="Multiple backgrounds & debug overlays" />
          <div className="flex flex-wrap gap-4 items-start">
            <DemoItem label="multiple images + positions" style={{
              backgroundColor: '#fef3c7',
              backgroundImage: `url(${flower}), url(${flower})`,
              backgroundRepeat: 'no-repeat, no-repeat',
              backgroundPosition: 'left 10px top 10px, right 10px bottom 10px',
              backgroundSize: '50px 50px, 70px 70px',
            }} />
            <DemoItem label="debug grid overlay" style={{
              backgroundColor: '#fff',
              backgroundImage: `url(${flower}), linear-gradient(#0000 24px, rgba(0,0,0,0.15) 25px), linear-gradient(90deg, #0000 24px, rgba(0,0,0,0.15) 25px)`,
              backgroundRepeat: 'no-repeat, repeat, repeat',
              backgroundPosition: 'center, top left, top left',
              backgroundSize: '60px 60px, 25px 25px, 25px 25px',
            }} />
          </div>

          <div className="mt-5">
            <div className="font-semibold text-[#2c3e50] mb-2">background-attachment</div>
            <div className="flex flex-col md:flex-row gap-3">
              <div className="relative h-40 w-full md:w-[360px] overflow-auto border border-gray-300">
                <div className="absolute top-1 left-2 text-xs text-gray-700 bg-white/70 px-2 py-0.5 rounded">scroll</div>
                <div
                  className="h-[320px] flex items-center justify-center text-sm text-gray-900"
                  style={{
                    backgroundImage: 'linear-gradient(45deg, rgba(59,130,246,0.15) 25%, transparent 25%, transparent 50%, rgba(59,130,246,0.15) 50%, rgba(59,130,246,0.15) 75%, transparent 75%, transparent)',
                    backgroundSize: '32px 32px',
                    backgroundAttachment: 'scroll' as CSSProps['backgroundAttachment'],
                  }}
                >
                  Scroll me
                </div>
              </div>
              <div className="relative h-40 w-full md:w-[360px] overflow-auto border border-gray-300">
                <div className="absolute top-1 left-2 text-xs text-gray-700 bg-white/70 px-2 py-0.5 rounded">fixed</div>
                <div
                  className="h-[320px] flex items-center justify-center text-sm text-gray-900"
                  style={{
                    backgroundImage: 'linear-gradient(45deg, rgba(59,130,246,0.15) 25%, transparent 25%, transparent 50%, rgba(59,130,246,0.15) 50%, rgba(59,130,246,0.15) 75%, transparent 75%, transparent)',
                    backgroundSize: '32px 32px',
                    backgroundAttachment: 'fixed' as CSSProps['backgroundAttachment'],
                  }}
                >
                  Scroll me
                </div>
              </div>
            </div>
          </div>

      </WebFListView>
    </div>
  );
};
