import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

// Helper function to create inline SVG data URLs
const createSvgDataUrl = (svgContent: string) =>
  `data:image/svg+xml;utf8,${encodeURIComponent(svgContent)}`;

export const SvgImagePage: React.FC = () => {
  const [customColor, setCustomColor] = useState('#10b981');
  const [customSize, setCustomSize] = useState(150);

  // Basic SVG examples
  const basicShapesSvg = createSvgDataUrl(`
    <svg xmlns='http://www.w3.org/2000/svg' width='300' height='100' viewBox='0 0 300 100'>
      <rect x='10' y='10' width='80' height='80' fill='#3b82f6' rx='8'/>
      <circle cx='150' cy='50' r='40' fill='#10b981'/>
      <polygon points='240,10 280,90 200,90' fill='#f59e0b'/>
    </svg>
  `);

  const gradientSvg = createSvgDataUrl(`
    <svg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'>
      <defs>
        <linearGradient id='grad1' x1='0%' y1='0%' x2='100%' y2='100%'>
          <stop offset='0%' style='stop-color:#667eea;stop-opacity:1' />
          <stop offset='100%' style='stop-color:#764ba2;stop-opacity:1' />
        </linearGradient>
      </defs>
      <rect width='200' height='200' fill='url(#grad1)' rx='16'/>
      <text x='100' y='110' font-size='32' text-anchor='middle' fill='white' font-weight='bold'>Gradient</text>
    </svg>
  `);

  const pathSvg = createSvgDataUrl(`
    <svg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'>
      <path d='M100,20 Q150,50 150,100 T100,180 Q50,150 50,100 T100,20 Z'
            fill='#ec4899' stroke='#be185d' stroke-width='3'/>
      <circle cx='100' cy='100' r='8' fill='white'/>
    </svg>
  `);

  const starSvg = createSvgDataUrl(`
    <svg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'>
      <defs>
        <radialGradient id='starGrad' cx='50%' cy='50%' r='50%'>
          <stop offset='0%' style='stop-color:#fbbf24;stop-opacity:1' />
          <stop offset='100%' style='stop-color:#f59e0b;stop-opacity:1' />
        </radialGradient>
      </defs>
      <path d='M100,30 L115,75 L165,75 L125,105 L140,150 L100,120 L60,150 L75,105 L35,75 L85,75 Z'
            fill='url(#starGrad)' stroke='#d97706' stroke-width='2'/>
    </svg>
  `);

  const iconsSvg = createSvgDataUrl(`
    <svg xmlns='http://www.w3.org/2000/svg' width='400' height='100' viewBox='0 0 400 100'>
      <!-- Heart Icon -->
      <path d='M50,70 C35,30 10,30 10,50 C10,70 30,85 50,95 C70,85 90,70 90,50 C90,30 65,30 50,70 Z'
            fill='#ef4444'/>

      <!-- Check Icon -->
      <circle cx='150' cy='50' r='40' fill='#10b981'/>
      <path d='M135,50 L145,60 L165,35' stroke='white' stroke-width='6'
            stroke-linecap='round' stroke-linejoin='round' fill='none'/>

      <!-- Warning Icon -->
      <path d='M250,20 L290,80 L210,80 Z' fill='#f59e0b'/>
      <text x='250' y='60' font-size='24' text-anchor='middle' fill='white' font-weight='bold'>!</text>

      <!-- Info Icon -->
      <circle cx='350' cy='50' r='40' fill='#3b82f6'/>
      <text x='350' y='65' font-size='32' text-anchor='middle' fill='white' font-weight='bold'>i</text>
    </svg>
  `);

  const customSvg = createSvgDataUrl(`
    <svg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'>
      <rect x='10' y='10' width='180' height='180' rx='20' ry='20' fill='${customColor}'
            stroke='#1f2937' stroke-width='3'/>
      <text x='100' y='110' font-size='28' text-anchor='middle' fill='white'
            font-family='sans-serif' font-weight='bold'>Custom</text>
    </svg>
  `);

  const patternSvg = createSvgDataUrl(`
    <svg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'>
      <defs>
        <pattern id='grid' x='0' y='0' width='20' height='20' patternUnits='userSpaceOnUse'>
          <rect x='0' y='0' width='20' height='20' fill='#e5e7eb'/>
          <rect x='0' y='0' width='10' height='10' fill='#d1d5db'/>
          <rect x='10' y='10' width='10' height='10' fill='#d1d5db'/>
        </pattern>
      </defs>
      <rect width='200' height='200' fill='url(#grid)' rx='12'/>
    </svg>
  `);

  const complexShapeSvg = createSvgDataUrl(`
    <svg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'>
      <defs>
        <linearGradient id='complexGrad' x1='0%' y1='0%' x2='100%' y2='0%'>
          <stop offset='0%' style='stop-color:#8b5cf6;stop-opacity:1' />
          <stop offset='50%' style='stop-color:#ec4899;stop-opacity:1' />
          <stop offset='100%' style='stop-color:#f59e0b;stop-opacity:1' />
        </linearGradient>
      </defs>
      <path d='M100,10 C120,10 140,20 150,40 C160,60 160,80 150,100 C140,120 120,130 100,130
               C80,130 60,120 50,100 C40,80 40,60 50,40 C60,20 80,10 100,10 Z
               M100,50 C90,50 80,60 80,70 C80,80 90,90 100,90 C110,90 120,80 120,70 C120,60 110,50 100,50 Z'
            fill='url(#complexGrad)' stroke='#4c1d95' stroke-width='2'/>
    </svg>
  `);

  return (
    <div id="main">
      <WebFListView className="flex-1 p-0 m-0">
        <div className="p-5 bg-gray-100 dark:bg-gray-900 min-h-screen max-w-7xl mx-auto">
          <div className="text-2xl font-bold text-gray-800 dark:text-white mb-6 text-center">
            SVG via &lt;img&gt; Showcase
          </div>
          <div className="flex flex-col">

            {/* Basic Shapes */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Basic SVG Shapes</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                Rectangle, circle, and polygon rendered as inline SVG data URLs
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full flex items-center justify-center">
                <img src={basicShapesSvg} alt="Basic shapes" className="w-full max-w-md h-auto" />
              </div>
            </div>

            {/* Gradient SVG */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Linear Gradient</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                SVG with linear gradient fill from purple to violet
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full flex items-center justify-center">
                <img src={gradientSvg} alt="Gradient SVG" className="w-[200px] h-[200px]" />
              </div>
            </div>

            {/* SVG Path */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">SVG Paths</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                Complex shapes created using SVG path commands with quadratic curves
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full flex items-center justify-center">
                <img src={pathSvg} alt="Path SVG" className="w-[200px] h-[200px]" />
              </div>
            </div>

            {/* Star with Radial Gradient */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Radial Gradient Star</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                Star shape with radial gradient fill
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full flex items-center justify-center">
                <img src={starSvg} alt="Star SVG" className="w-[200px] h-[200px]" />
              </div>
            </div>

            {/* Icons */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">SVG Icons</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                Common UI icons created with SVG: heart, check, warning, and info
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full flex items-center justify-center">
                <img src={iconsSvg} alt="SVG Icons" className="w-full max-w-lg h-auto" />
              </div>
            </div>

            {/* Pattern Fill */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Pattern Fill</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                SVG pattern with repeating checkerboard design
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full flex items-center justify-center">
                <img src={patternSvg} alt="Pattern SVG" className="w-[200px] h-[200px]" />
              </div>
            </div>

            {/* Complex Shape */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Complex Shape with Cutout</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                Multi-color gradient with complex path and inner cutout
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full flex items-center justify-center">
                <img src={complexShapeSvg} alt="Complex shape" className="w-[200px] h-[200px]" />
              </div>
            </div>

            {/* Interactive Custom SVG */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Interactive Custom SVG</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                Customize the color and size of the SVG dynamically
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                {/* Controls */}
                <div className="flex flex-col md:flex-row gap-4 mb-6">
                  <div className="flex-1">
                    <label className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2 block">
                      Color
                    </label>
                    <input
                      type="text"
                      className="w-full rounded-lg border border-gray-300 dark:border-gray-600 px-4 py-2 bg-white dark:bg-gray-800 text-gray-900 dark:text-white"
                      value={customColor}
                      onChange={(e) => setCustomColor(e.target.value)}
                      placeholder="#10b981"
                    />
                  </div>
                  <div className="w-full md:w-40">
                    <label className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2 block">
                      Size (px)
                    </label>
                    <input
                      type="number"
                      className="w-full rounded-lg border border-gray-300 dark:border-gray-600 px-4 py-2 bg-white dark:bg-gray-800 text-gray-900 dark:text-white"
                      value={customSize}
                      onChange={(e) => setCustomSize(Number(e.target.value) || 0)}
                      min="50"
                      max="300"
                    />
                  </div>
                </div>

                {/* Preview */}
                <div className="bg-white dark:bg-gray-800 rounded-lg p-8 border border-gray-300 dark:border-gray-600 flex items-center justify-center">
                  <img
                    src={customSvg}
                    alt="Custom SVG"
                    style={{ width: customSize, height: customSize }}
                  />
                </div>
              </div>
            </div>

            {/* Responsive SVG Sizing */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Responsive SVG Sizing</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
                Same SVG displayed at different sizes demonstrating scalability
              </div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="flex flex-wrap items-end justify-center gap-6">
                  <div className="flex flex-col items-center">
                    <img src={starSvg} alt="Small star" className="w-[80px] h-[80px] mb-2" />
                    <span className="text-xs text-gray-600 dark:text-gray-400">80×80</span>
                  </div>
                  <div className="flex flex-col items-center">
                    <img src={starSvg} alt="Medium star" className="w-[120px] h-[120px] mb-2" />
                    <span className="text-xs text-gray-600 dark:text-gray-400">120×120</span>
                  </div>
                  <div className="flex flex-col items-center">
                    <img src={starSvg} alt="Large star" className="w-[160px] h-[160px] mb-2" />
                    <span className="text-xs text-gray-600 dark:text-gray-400">160×160</span>
                  </div>
                  <div className="flex flex-col items-center">
                    <img src={starSvg} alt="XL star" className="w-[200px] h-[200px] mb-2" />
                    <span className="text-xs text-gray-600 dark:text-gray-400">200×200</span>
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>
      </WebFListView>
    </div>
  );
};
