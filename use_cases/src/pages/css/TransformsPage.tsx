import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

type CSSProps = React.CSSProperties;

const SectionHeader: React.FC<{ title: string }>= ({ title }) => (
  <div className="mt-5 font-semibold text-[#2c3e50]">{title}</div>
);

const TransformBox: React.FC<{ label: string; transform: string; origin?: string; className?: string; style?: CSSProps }>= ({ label, transform, origin, className, style }) => (
  <div className="flex flex-col mt-3">
    <div className="text-sm text-[#374151]">{label}</div>
    <div className={[ 'mt-2 mb-4 w-[140px] h-[140px] rounded-md bg-white border border-dashed border-[#bdbdbd] flex items-center justify-center', className ?? '' ].join(' ')}>
      <div
        className="w-[80px] h-[80px] bg-yellow-200 text-xs text-[#111827] rounded flex items-center justify-center"
        style={{ transform, transformOrigin: origin, ...style }}
      >
        Box
      </div>
    </div>
  </div>
);

export const TransformsPage: React.FC = () => {
  const translateCases: { label: string; transform: string }[] = [
    { label: 'translateX(20px)', transform: 'translateX(20px)' },
    { label: 'translateY(20px)', transform: 'translateY(20px)' },
    { label: 'translate(10px, 10px)', transform: 'translate(10px, 10px)' },
    { label: 'translate(50%, -50%)', transform: 'translate(50%, -50%)' },
  ];

  const scaleCases: { label: string; transform: string; origin?: string }[] = [
    { label: 'scale(1.2)', transform: 'scale(1.2)' },
    { label: 'scaleX(1.5)', transform: 'scaleX(1.5)' },
    { label: 'scaleY(0.6)', transform: 'scaleY(0.6)' },
    { label: 'scale(-1, 1) (flip X)', transform: 'scale(-1, 1)' },
  ];

  const rotateCases: { label: string; transform: string }[] = [
    { label: 'rotate(15deg)', transform: 'rotate(15deg)' },
    { label: 'rotate(-30deg)', transform: 'rotate(-30deg)' },
    { label: 'rotateZ(45deg)', transform: 'rotateZ(45deg)' },
  ];

  const skewCases: { label: string; transform: string }[] = [
    { label: 'skewX(10deg)', transform: 'skewX(10deg)' },
    { label: 'skewY(10deg)', transform: 'skewY(10deg)' },
    { label: 'skew(10deg, 5deg)', transform: 'skew(10deg, 5deg)' },
  ];

  const originCases: { label: string; transform: string; origin: string }[] = [
    { label: 'rotate(25deg) origin center', transform: 'rotate(25deg)', origin: 'center' },
    { label: 'rotate(25deg) origin top left', transform: 'rotate(25deg)', origin: 'top left' },
    { label: 'rotate(25deg) origin bottom right', transform: 'rotate(25deg)', origin: 'bottom right' },
    { label: 'scale(1.2) origin left', transform: 'scale(1.2)', origin: 'left' },
  ];

  const orderMatters: { label: string; transform: string }[] = [
    { label: 'translate(40px,0) rotate(30deg)', transform: 'translate(40px, 0) rotate(30deg)' },
    { label: 'rotate(30deg) translate(40px,0)', transform: 'rotate(30deg) translate(40px, 0)' },
  ];

  const matrixCases: { label: string; transform: string }[] = [
    { label: 'matrix(1, 0.2, -0.2, 1, 10, 0)', transform: 'matrix(1, 0.2, -0.2, 1, 10, 0)' },
    { label: 'matrix(0.866, 0.5, -0.5, 0.866, 0, 0)', transform: 'matrix(0.866, 0.5, -0.5, 0.866, 0, 0)' },
  ];

  // 3D transforms: perspective is applied on the outer wrapper of the transformed element.
  const threeD: { label: string; transform: string; extra?: CSSProps }[] = [
    { label: 'rotateX(30deg)', transform: 'rotateX(30deg)' },
    { label: 'rotateY(30deg)', transform: 'rotateY(30deg)' },
    { label: 'translateZ(40px)', transform: 'translateZ(40px)' },
  ];

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-5xl mx-auto py-6">
          <div className="w-full flex justify-center items-center">
            <div className="bg-gradient-to-tr from-indigo-500 to-purple-600 p-4 rounded-2xl text-white shadow">
              <h1 className="text-[22px] font-bold mb-1 drop-shadow">Transforms</h1>
              <p className="text-[14px]/[1.5] opacity-90">Translate, scale, rotate, skew, origin, matrix and 3D</p>
            </div>
          </div>

          <SectionHeader title="Translate" />
          <div className="flex flex-wrap gap-4 items-start">
            {translateCases.map((o, i) => (
              <TransformBox key={`t-${i}`} label={o.label} transform={o.transform} />
            ))}
          </div>

          <SectionHeader title="Scale" />
          <div className="flex flex-wrap gap-4 items-start">
            {scaleCases.map((o, i) => (
              <TransformBox key={`s-${i}`} label={o.label} transform={o.transform} origin={o.origin} />
            ))}
          </div>

          <SectionHeader title="Rotate" />
          <div className="flex flex-wrap gap-4 items-start">
            {rotateCases.map((o, i) => (
              <TransformBox key={`r-${i}`} label={o.label} transform={o.transform} />
            ))}
          </div>

          <SectionHeader title="Skew" />
          <div className="flex flex-wrap gap-4 items-start">
            {skewCases.map((o, i) => (
              <TransformBox key={`k-${i}`} label={o.label} transform={o.transform} />
            ))}
          </div>

          <SectionHeader title="Transform origin" />
          <div className="flex flex-wrap gap-4 items-start">
            {originCases.map((o, i) => (
              <TransformBox key={`o-${i}`} label={o.label} transform={o.transform} origin={o.origin} />
            ))}
          </div>

          <SectionHeader title="Order matters" />
          <div className="flex flex-wrap gap-4 items-start">
            {orderMatters.map((o, i) => (
              <TransformBox key={`om-${i}`} label={o.label} transform={o.transform} />
            ))}
          </div>

          <SectionHeader title="Matrix" />
          <div className="flex flex-wrap gap-4 items-start">
            {matrixCases.map((o, i) => (
              <TransformBox key={`m-${i}`} label={o.label} transform={o.transform} />
            ))}
          </div>

          <SectionHeader title="3D (with perspective)" />
          <div className="flex flex-wrap gap-4 items-start">
            {threeD.map((o, i) => (
              <div key={`3d-${i}`} className="flex flex-col mt-3">
                <div className="text-sm text-[#374151]">{o.label}</div>
                <div className="mt-2 mb-4 w-[160px] h-[160px] rounded-md bg-white border border-dashed border-[#bdbdbd] flex items-center justify-center" style={{ perspective: '600px' }}>
                  <div className="w-[80px] h-[80px] bg-yellow-200 text-xs text-[#111827] rounded flex items-center justify-center" style={{ transform: o.transform }}>
                    Box
                  </div>
                </div>
              </div>
            ))}
          </div>

          <SectionHeader title="Combined" />
          <div className="flex flex-wrap gap-4 items-start">
            <TransformBox label="translate + scale + rotate" transform={'translate(10px, 10px) scale(0.9) rotate(10deg)'} />
            <TransformBox label="skew + rotate + scale" transform={'skew(8deg, 5deg) rotate(15deg) scale(1.1)'} />
          </div>
      </WebFListView>
    </div>
  );
};
