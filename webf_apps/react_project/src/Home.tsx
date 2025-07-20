import { FlutterCupertinoModalPopup, FlutterCupertinoModalPopupElement } from '@openwebf/react-cupertino-ui';
import { useEffect, useRef, useState } from 'react'

// import { FlutterPopup, FlutterPopupItem } from '@mx/mini-program-ui'
const Home = () => {
  const popUpRef = useRef<FlutterCupertinoModalPopupElement>(null);
  const ref = useRef<HTMLDivElement>(null)
  useEffect(() => {
    ref.current?.addEventListener('onscreen', () => {
      getStyle()
    })
  }, [])
  const getStyle = () => {
    console.log('get style');
    setTimeout(() => {
      // FIXME 拿不到样式
      console.log('home onscreen')
      console.log('getContainerStyle', document?.getElementById('container')?.getBoundingClientRect())
    }, 500)
  }
  return (
    <>
      <div>
        <button onClick={() => popUpRef.current?.show()}>open popup</button>
        <FlutterCupertinoModalPopup ref={popUpRef}>
          <div>
            <div
              id="container"
              ref={ref}
              style={{
                width: 100,
                background: 'blue'
              }}
            >
              container
              {/*
                FIXME 把 div 换成 button 会报错
              */}
              <div onClick={getStyle}>get style</div>
              <div
                style={{
                  background: 'red',
                  // FIXME 样式计算不生效
                  width: 'calc((100% - 20px) / 3)'
                }}
              >
                t1
              </div>
              <div
                style={{
                  background: 'red',
                  width: 'calc(80px / 3)'
                }}
              >
                t2
              </div>
            </div>
          </div>
        </FlutterCupertinoModalPopup>
      </div>
    </>
  )
}
export default Home