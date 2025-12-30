import React, { useEffect, useMemo, useRef, useState } from 'react';
import { WebFTouchArea } from '@openwebf/react-core-ui';

const list: string[] = [
  'IPSUM',
  'DOLOR',
  'LOREM',
  'SIT',
  'AMET',
  'CONSECTRTUR',
  'ADIPISICING',
  'ELIT',
];

const clamp = (n: number, min: number, max: number) => Math.max(Math.min(n, max), min);

function reinsert<T>(arr: T[], from: number, to: number): T[] {
  const _arr = arr.slice(0);
  const val = _arr[from];
  _arr.splice(from, 1);
  _arr.splice(to, 0, val);
  return _arr;
}

function DragHandle(props: React.HTMLAttributes<HTMLDivElement>) {
  const lineStyle: React.CSSProperties = {
    width: 10,
    height: 2,
    marginBottom: 2,
    backgroundColor: '#ffffff',
  };
  return (
    <div {...props}>
      <div style={lineStyle} />
      <div style={lineStyle} />
      <div style={lineStyle} />
    </div>
  );
}

export function DragableListPage() {
  const itemsCount = list.length;
  const initialWidth = typeof window !== 'undefined' ? window.innerWidth : 750;
  const [itemGap, setItemGap] = useState(() => Math.round((initialWidth * 110) / 750));

  const [order, setOrder] = useState<number[]>(() => Array.from({ length: itemsCount }, (_, i) => i));
  const [mouseY, setMouseY] = useState(0);
  const [isPressed, setIsPressed] = useState(false);
  const [originalPosOfLastPressed, setOriginalPosOfLastPressed] = useState(0);

  // Refs to avoid stale closures for document-level handlers
  const topDeltaYRef = useRef(0);
  const orderRef = useRef(order);
  const isPressedRef = useRef(isPressed);
  const originalRef = useRef(originalPosOfLastPressed);

  useEffect(() => { orderRef.current = order; }, [order]);
  useEffect(() => { isPressedRef.current = isPressed; }, [isPressed]);
  useEffect(() => { originalRef.current = originalPosOfLastPressed; }, [originalPosOfLastPressed]);

  useEffect(() => {
    const onResize = () => setItemGap(Math.round((window.innerWidth * 110) / 750));
    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, []);

  const onTouchMove = (e: Touch) => {
    if (!isPressedRef.current) return;
    const pageY = (e).pageY;
    const mouseYVal = pageY - topDeltaYRef.current;
    const currentRow = clamp(Math.round(mouseYVal / itemGap), 0, itemsCount - 1);
    let newOrder = orderRef.current;
    const fromIndex = orderRef.current.indexOf(originalRef.current);
    if (currentRow !== fromIndex) {
      newOrder = reinsert(orderRef.current, fromIndex, currentRow);
      orderRef.current = newOrder;
      setOrder(newOrder);
    }
    setMouseY(mouseYVal);
  };

  const onMouseUp = () => {
    setIsPressed(false);
    topDeltaYRef.current = 0;
  };

  const onTouchDown = (pos: number, pressY: number, pageY: number) => {
    topDeltaYRef.current = pageY - pressY;
    setMouseY(pressY);
    setIsPressed(true);
    setOriginalPosOfLastPressed(pos);
  };

  const itemHeight = Math.round(itemGap * (80 / 110));
  const containerHeight = (itemsCount - 1) * itemGap + itemHeight;

  return (
    <div className="dragable-list-demo" style={{
      position: 'relative',
      margin: 0,
      width: '100vw',
      height: containerHeight,
      touchAction: 'none',
      userSelect: 'none',
      paddingTop: 24,
    }}>
      {useMemo(() => Array.from({ length: itemsCount }, (_, i) => i), [itemsCount]).map((i) => {
        const isActive = originalPosOfLastPressed === i && isPressed;
        const y = isActive ? mouseY : order.indexOf(i) * itemGap;
        const scale = isActive ? 1.1 : 1;
        return (
          <WebFTouchArea
            key={i}
            onTouchStart={(e) => onTouchDown(i, y, e.touches[0].pageY)}
            onTouchMove={(e) => onTouchMove(e.touches[0])}
            onTouchEnd={(e) => onMouseUp()}
            className={`dragable-item dragable-item-${i % 4}`}
            style={{
              position: 'absolute',
              left: '10vw',
              width: '80vw',
              height: 'calc(10.6667vw)',
              padding: '0 16px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              boxSizing: 'border-box',
              borderRadius: 13,
              color: '#fff',
              willChange: 'transform',
              transformOrigin: '40vw 45px',
              boxShadow: '0 2px 4px rgba(0,0,0,0.1), 0 10px 20px rgba(0,0,0,0.15)',
              transform: `translate3d(0px, ${y}px, 0px) scale(${scale})`,
              zIndex: i === originalPosOfLastPressed ? 99 : i,
              transition: isActive ? 'none' : 'transform 200ms cubic-bezier(0.23, 1, 0.32, 1)',
              backgroundColor: i % 4 === 0 ? '#6c5ce7' : i % 4 === 1 ? '#0984e3' : i % 4 === 2 ? '#00b894' : '#fdcb6e',
            }}
          >
            <div style={{
              pointerEvents: 'none',
              position: 'relative',
              width: '100%',
              display: 'flex',
              alignItems: 'center'
            }}>
              <span style={{
                fontWeight: 600,
                letterSpacing: '0.5px',
                color: i % 4 === 3 ? '#222' : '#fff',
              }}>
                Items {i + 1}. {list[i]}
              </span>
            </div>
            <DragHandle style={{
              position: 'absolute',
              right: 16,
              top: '50%',
              transform: 'translateY(-50%)',
              display: 'flex',
              flexDirection: 'column',
            }} />
          </WebFTouchArea>
        );
      })}
    </div>
  );
}
