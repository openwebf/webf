import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import webfLogo from '../../resource/webf.png';

interface FilterDemoProps {
  title: string;
  filterClass: string;
  description?: string;
}

const FilterDemo: React.FC<FilterDemoProps> = ({ title, filterClass, description }) => {
  return (
    <div className="bg-white p-4 rounded-xl shadow-sm flex flex-col items-center gap-4 w-full shrink-0">
      <div className="text-gray-800 font-semibold text-lg self-start">{title}</div>
      <div className="w-full flex justify-center bg-gray-50 rounded-lg p-6 border border-gray-100">
         <img 
            src={webfLogo} 
            alt={`Filter ${title}`} 
            className={`w-32 h-32 object-contain transition-all duration-300 ${filterClass}`} 
         />
      </div>
      <div className="w-full text-xs text-gray-500 font-mono bg-gray-100 px-3 py-2 rounded border border-gray-200">
        {description || filterClass}
      </div>
    </div>
  );
};

export const FilterPage: React.FC = () => {
  return (
    <div className="w-full h-full bg-gray-50">
      <WebFListView className="p-5 flex flex-col gap-6 w-full box-border pb-10">
        <FilterDemo title="Original" filterClass="" description="No filter" />
        
        <FilterDemo title="Blur" filterClass="blur-sm" description="blur(4px)" />
        <FilterDemo title="Blur (Heavy)" filterClass="blur-md" description="blur(12px)" />
        
        <FilterDemo title="Grayscale" filterClass="grayscale" description="grayscale(100%)" />
        <FilterDemo title="Grayscale (Partial)" filterClass="grayscale-[0.5]" description="grayscale(50%)" />
        
        <FilterDemo title="Sepia" filterClass="sepia" description="sepia(100%)" />
        
        <FilterDemo title="Brightness (Dim)" filterClass="brightness-50" description="brightness(0.5)" />
        <FilterDemo title="Brightness (Bright)" filterClass="brightness-150" description="brightness(1.5)" />
        
        <FilterDemo title="Contrast (Low)" filterClass="contrast-50" description="contrast(0.5)" />
        <FilterDemo title="Contrast (High)" filterClass="contrast-150" description="contrast(1.5)" />
        
        <FilterDemo title="Hue Rotate" filterClass="hue-rotate-90" description="hue-rotate(90deg)" />
        <FilterDemo title="Hue Rotate (180)" filterClass="hue-rotate-180" description="hue-rotate(180deg)" />
        
        <FilterDemo title="Invert" filterClass="invert" description="invert(100%)" />
        
        <FilterDemo title="Saturate (Muted)" filterClass="saturate-0" description="saturate(0)" />
        <FilterDemo title="Saturate (Vibrant)" filterClass="saturate-200" description="saturate(2)" />
        
        <FilterDemo title="Opacity" filterClass="opacity-50" description="opacity(0.5)" />
        
        <FilterDemo title="Drop Shadow" filterClass="drop-shadow-xl" description="drop-shadow(...)" />
        <FilterDemo title="Drop Shadow (Color)" filterClass="drop-shadow-[0_10px_8px_rgba(255,0,0,0.5)]" description="drop-shadow(0 10px 8px rgba(255,0,0,0.5))" />
      </WebFListView>
    </div>
  );
};