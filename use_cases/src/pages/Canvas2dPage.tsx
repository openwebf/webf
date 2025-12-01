import React, { useEffect, useRef } from 'react';
import { WebFListView, useFlutterAttached } from '@openwebf/react-core-ui';
import { isWebFEnvironment } from '../router';

const SectionTitle: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <h2 className="text-lg font-bold text-gray-800 mt-6 mb-3 px-1 border-b border-gray-200 pb-2">{children}</h2>
);

const CanvasCard: React.FC<{ title: string; draw: (ctx: CanvasRenderingContext2D) => void; animated?: boolean }> = ({ title, draw, animated = false }) => {

  let rafId = 0;
  const onAttached = (element: HTMLCanvasElement | Event) => {
    // Handle both HTMLCanvasElement (direct ref) and Event (onAttached callback)
    const canvasEl = (element instanceof Event ? element.target : element) as HTMLCanvasElement;

    const ctx = canvasEl.getContext('2d');
    if (!ctx) return;

    // Handle high DPI displays
    const dpr = window.devicePixelRatio || 1;
    const rect = canvasEl.getBoundingClientRect();

    // Set actual size in memory (scaled to account for extra pixel density)
    canvasEl.width = rect.width * dpr;
    canvasEl.height = rect.height * dpr;

    // Normalize coordinate system to use css pixels.
    ctx.scale(dpr, dpr);

    if (animated) {
      const render = () => {
        ctx.clearRect(0, 0, canvasEl.width / dpr, canvasEl.height / dpr);
        draw(ctx);
        rafId = requestAnimationFrame(render);
      };
      render();
      // return () => cancelAnimationFrame(animationFrameId);
    } else {
      draw(ctx);
    }
  };

  const onDetached = (event: Event) => {
    // Optional: Add specific cleanup if needed
    cancelAnimationFrame(rafId);
  };

  const flutterCanvasRef = useFlutterAttached<HTMLCanvasElement>(onAttached, onDetached);
  const browserCanvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    if (!isWebFEnvironment && browserCanvasRef.current) {
      return onAttached(browserCanvasRef.current) as (() => void) | undefined;
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const canvasRef = isWebFEnvironment ? flutterCanvasRef : browserCanvasRef;

  return (
    <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-3">
      <h3 className="text-sm font-semibold text-gray-700">{title}</h3>
      <div className="w-full flex justify-center bg-gray-50 rounded border border-gray-100 overflow-hidden">
        <canvas
          ref={canvasRef}
          style={{ width: '300px', height: '200px' }}
          className="w-[300px] h-[200px]"
        />
      </div>
    </div>
  );
};

export const Canvas2dPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-gray-50">
      <WebFListView className="w-full px-4 max-w-4xl mx-auto py-6 flex flex-col gap-4">
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Canvas 2D Context</h1>
        <p className="text-gray-600 mb-4">
          The HTML &lt;canvas&gt; element is used to draw graphics, on the fly, via JavaScript.
        </p>

        <SectionTitle>Basic Shapes & Styles</SectionTitle>
        <div className="flex flex-wrap justify-center gap-4">
          <CanvasCard
            title="Rectangles (Fill & Stroke)"
            draw={(ctx) => {
              ctx.fillStyle = 'rgb(200, 0, 0)';
              ctx.fillRect(20, 20, 100, 100);

              ctx.fillStyle = 'rgba(0, 0, 200, 0.5)';
              ctx.fillRect(60, 60, 100, 100);

              ctx.strokeStyle = 'green';
              ctx.lineWidth = 5;
              ctx.strokeRect(100, 30, 80, 80);

              ctx.clearRect(80, 80, 40, 40);
            }}
          />
          <CanvasCard
            title="Paths (Lines & Arcs)"
            draw={(ctx) => {
              // Triangle
              ctx.beginPath();
              ctx.moveTo(50, 50);
              ctx.lineTo(150, 50);
              ctx.lineTo(100, 150);
              ctx.closePath();
              ctx.fillStyle = '#FFCD56';
              ctx.fill();
              ctx.stroke();

              // Arc (Smile)
              ctx.beginPath();
              ctx.arc(220, 80, 40, 0, Math.PI * 2, true); // Outer circle
              ctx.moveTo(255, 80);
              ctx.arc(220, 80, 35, 0, Math.PI, false);  // Mouth (clockwise)
              ctx.moveTo(210, 70);
              ctx.arc(205, 70, 5, 0, Math.PI * 2, true);  // Left eye
              ctx.moveTo(240, 70);
              ctx.arc(235, 70, 5, 0, Math.PI * 2, true);  // Right eye
              ctx.strokeStyle = '#36A2EB';
              ctx.stroke();
            }}
          />
        </div>

        <SectionTitle>Styles & Text</SectionTitle>
        <div className="flex flex-wrap justify-center gap-4">
          <CanvasCard
            title="Gradients & Patterns"
            draw={(ctx) => {
               // Linear Gradient
               const lingrad = ctx.createLinearGradient(0, 0, 0, 150);
               lingrad.addColorStop(0, '#00ABEB');
               lingrad.addColorStop(0.5, '#fff');
               lingrad.addColorStop(0.5, '#26C000');
               lingrad.addColorStop(1, '#fff');
               ctx.fillStyle = lingrad;
               ctx.fillRect(10, 10, 130, 130);

               // Radial Gradient
               const radgrad = ctx.createRadialGradient(220, 75, 10, 220, 75, 60);
               radgrad.addColorStop(0, '#A7D30C');
               radgrad.addColorStop(0.9, '#019F62');
               radgrad.addColorStop(1, 'rgba(1, 159, 98, 0)');
               ctx.fillStyle = radgrad;
               ctx.fillRect(150, 0, 150, 150);
            }}
          />
          <CanvasCard
            title="Text Rendering"
            draw={(ctx) => {
              ctx.font = '24px serif';
              ctx.fillStyle = 'black';
              ctx.fillText('Fill Text', 20, 50);

              ctx.font = 'bold 30px sans-serif';
              ctx.lineWidth = 1;
              ctx.strokeStyle = 'red';
              ctx.strokeText('Stroke Text', 20, 100);

              ctx.font = 'italic 20px monospace';
              ctx.fillStyle = 'blue';
              ctx.fillText('Monospace', 20, 140);
            }}
          />
        </div>

        <SectionTitle>Transformations</SectionTitle>
        <div className="flex flex-wrap justify-center gap-4">
           <CanvasCard
            title="Rotate & Translate"
            draw={(ctx) => {
              ctx.save();
              ctx.translate(150, 100); // Move to center

              for (let i = 0; i < 6; i++) {
                ctx.fillStyle = `rgba(${255 - 40 * i}, ${40 * i}, 255, 0.5)`;
                for (let j = 0; j < i * 6; j++) {
                  ctx.rotate(Math.PI * 2 / (i * 6));
                  ctx.beginPath();
                  ctx.arc(0, i * 12.5, 5, 0, Math.PI * 2, true);
                  ctx.fill();
                }
              }
              ctx.restore();
            }}
          />
           <CanvasCard
            title="Scale"
            draw={(ctx) => {
              ctx.save();
              ctx.translate(20, 20);
              ctx.strokeStyle = 'purple';
              ctx.strokeRect(0, 0, 50, 50);

              ctx.scale(2, 2);
              ctx.strokeStyle = 'orange';
              ctx.strokeRect(0, 0, 50, 50);

              ctx.scale(1.5, 1.5);
              ctx.strokeStyle = 'green';
              ctx.strokeRect(0, 0, 50, 50);
              ctx.restore();
            }}
          />
        </div>

        <SectionTitle>Animation</SectionTitle>
        <div className="flex flex-wrap justify-center gap-4">
          <CanvasCard
            title="Animated Solar System"
            animated={true}
            draw={(ctx) => {
              const time = new Date();
              ctx.clearRect(0, 0, 300, 200);

              ctx.save();
              ctx.translate(150, 100);

              // Sun
              ctx.beginPath();
              ctx.arc(0, 0, 20, 0, Math.PI * 2);
              ctx.fillStyle = 'yellow';
              ctx.fill();
              ctx.shadowBlur = 20;
              ctx.shadowColor = 'orange';
              ctx.stroke();

              // Earth Orbit
              ctx.strokeStyle = 'rgba(0, 153, 255, 0.4)';
              ctx.beginPath();
              ctx.arc(0, 0, 70, 0, Math.PI * 2);
              ctx.stroke();

              // Earth
              ctx.rotate(((2 * Math.PI) / 60) * time.getSeconds() + ((2 * Math.PI) / 60000) * time.getMilliseconds());
              ctx.translate(70, 0);
              ctx.beginPath();
              ctx.arc(0, 0, 10, 0, Math.PI * 2);
              ctx.fillStyle = 'blue';
              ctx.fill();

              // Moon Orbit
              ctx.strokeStyle = 'rgba(200, 200, 200, 0.4)';
              ctx.beginPath();
              ctx.arc(0, 0, 20, 0, Math.PI * 2);
              ctx.stroke();

              // Moon
              ctx.rotate(((2 * Math.PI) / 6) * time.getSeconds() + ((2 * Math.PI) / 6000) * time.getMilliseconds());
              ctx.translate(0, 20);
              ctx.beginPath();
              ctx.arc(0, 0, 4, 0, Math.PI * 2);
              ctx.fillStyle = 'gray';
              ctx.fill();

              ctx.restore();

              console.log('draw canvas');
            }}
          />
        </div>

      </WebFListView>
    </div>
  );
};
