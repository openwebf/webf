import React, { useRef, useState, useCallback } from 'react';

// 20 张纯色占位图，直接返回 PNG 不做重定向
const COLORS = [
  '1677ff', 'ff4d4f', '52c41a', 'fa8c16', '722ed1',
  '13c2c2', 'eb2f96', 'faad14', 'a0d911', '1890ff',
  'f5222d', 'fa541c', 'fadb14', '52c41a', '2f54eb',
  '722ed1', 'eb2f96', '13c2c2', '096dd9', 'd4380d',
];
const DEMO_IMAGES = COLORS.map(c => `https://dummyimage.com/120x80/${c}/fff.png`);
const TOTAL = DEMO_IMAGES.length;

interface ImgState {
  loaded: boolean;
  error: boolean;
}

export default function AsyncImgSrcDemo() {
  const imgRefs = useRef<(HTMLImageElement | null)[]>(Array(TOTAL).fill(null));
  const [status, setStatus] = useState('点击「批量加载 20 张图片」开始测试。');
  const [imgStates, setImgStates] = useState<ImgState[]>(
    Array(TOTAL).fill({ loaded: false, error: false })
  );

  // 非响应式计数器，避免放进 state 导致额外渲染
  const loadedCount = useRef(0);
  const errorCount = useRef(0);
  const startTime = useRef(0);

  const handleLoad = useCallback((index: number) => {
    loadedCount.current++;
    const total = loadedCount.current + errorCount.current;
    const elapsed = Date.now() - startTime.current;

    setImgStates(prev => {
      const next = [...prev];
      next[index] = { ...next[index], loaded: true };
      return next;
    });

    if (total === TOTAL) {
      setStatus(`✅ 全部 ${TOTAL} 张完成（${loadedCount.current} 成功，${errorCount.current} 失败），耗时 ${elapsed}ms`);
    } else {
      setStatus(`已加载 ${loadedCount.current} / ${TOTAL}（${errorCount.current} 失败）— 距批量赋值 ${elapsed}ms`);
    }
  }, []);

  const handleError = useCallback((index: number) => {
    errorCount.current++;
    const total = loadedCount.current + errorCount.current;
    const elapsed = Date.now() - startTime.current;

    setImgStates(prev => {
      const next = [...prev];
      next[index] = { ...next[index], error: true };
      return next;
    });

    if (total === TOTAL) {
      setStatus(`⚠️ 全部 ${TOTAL} 张完成（${loadedCount.current} 成功，${errorCount.current} 失败），耗时 ${elapsed}ms`);
    } else {
      setStatus(`已加载 ${loadedCount.current} / ${TOTAL}（${errorCount.current} 失败）— 距批量赋值 ${elapsed}ms`);
    }
  }, []);

  const handleBatchLoad = useCallback(() => {
    // 重置计数器和状态
    loadedCount.current = 0;
    errorCount.current = 0;
    setImgStates(Array(TOTAL).fill({ loaded: false, error: false }));
    setStatus('正在给 20 个 <img> 元素赋值 src…');

    // 记录批量赋值开始时间
    startTime.current = Date.now();

    // 同步 for 循环批量赋值
    // 异步路径：每次赋值只写 UICommand buffer，不触发 FlushUICommand
    // JS 线程不阻塞，循环几乎瞬间完成
    for (let i = 0; i < TOTAL; i++) {
      const el = imgRefs.current[i];
      if (el) {
        el.src = DEMO_IMAGES[i];
      }
    }

    const elapsed = Date.now() - startTime.current;
    setStatus(`src 已批量赋值完成，耗时 ${elapsed}ms（JS 线程未阻塞）。等待图片加载…`);
  }, []);

  const handleClear = useCallback(() => {
    loadedCount.current = 0;
    errorCount.current = 0;
    // 不清空 src，避免触发 native codec dispose 导致崩溃
    setImgStates(Array(TOTAL).fill({ loaded: false, error: false }));
    setStatus('已重置。点击「批量加载 20 张图片」重新开始。');
  }, []);

  return (
    <div style={styles.container}>
      <div style={styles.title}>Async img.src 性能验证</div>
      <div style={styles.desc}>
        批量给 20 个 img 元素赋值 src。异步路径下 JS 线程不阻塞，
        赋值耗时应接近 0ms；图片随后在下一帧 flush 时统一加载。
      </div>

      {/* 操作按钮 */}
      <div style={styles.buttonRow}>
        <div style={styles.btnPrimary} onClick={handleBatchLoad}>
          批量加载 20 张图片
        </div>
        <div style={styles.btnDanger} onClick={handleClear}>
          重置
        </div>
      </div>

      {/* 状态文字 */}
      <div style={styles.status}>{status}</div>

      {/* 图片网格 */}
      <div style={styles.grid}>
        {imgStates.map((state, index) => (
          <img
            key={index}
            ref={el => { imgRefs.current[index] = el; }}
            style={{
              ...styles.imgItem,
              opacity: state.loaded ? 1 : 0.3,
              borderColor: state.error ? '#ff4d4f' : state.loaded ? '#52c41a' : '#e8e8e8',
            }}
            onLoad={() => handleLoad(index)}
            onError={() => handleError(index)}
            alt={`img-${index}`}
          />
        ))}
      </div>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  container: {
    padding: 16,
    backgroundColor: '#fff',
    minHeight: '100vh',
  },
  title: {
    fontSize: 20,
    fontWeight: 600,
    color: '#1a1a1a',
    marginBottom: 8,
  },
  desc: {
    fontSize: 13,
    color: '#666',
    marginBottom: 16,
    lineHeight: 1.6,
  },
  buttonRow: {
    display: 'flex',
    flexDirection: 'row',
    marginBottom: 12,
  },
  btnPrimary: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '8px 16px',
    borderRadius: 8,
    backgroundColor: '#1677ff',
    color: '#fff',
    fontSize: 14,
    fontWeight: 500,
    marginRight: 12,
  },
  btnDanger: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '8px 16px',
    borderRadius: 8,
    backgroundColor: '#ff4d4f',
    color: '#fff',
    fontSize: 14,
    fontWeight: 500,
  },
  status: {
    fontSize: 13,
    color: '#555',
    marginBottom: 16,
    minHeight: 18,
  },
  grid: {
    display: 'flex',
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  imgItem: {
    width: 120,
    height: 80,
    borderRadius: 6,
    backgroundColor: '#e8e8e8',
    marginRight: 8,
    marginBottom: 8,
    objectFit: 'cover',
    borderWidth: 2,
    borderStyle: 'solid',
    transition: 'opacity 0.2s, border-color 0.2s',
  },
};
