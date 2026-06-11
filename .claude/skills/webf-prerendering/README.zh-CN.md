# WebF 预渲染模式 — 前端开发指南

> 简体中文版。英文原文见 [`SKILL.md`](./SKILL.md)(同时也是 Claude 加载的技能文件)。

## 概述

WebF 的预渲染模式会在 **Flutter widget 挂载之前**执行页面的 JavaScript。layout 和 paint 会被推迟到挂载时刻,因此所有读取视口或几何信息的 API(`clientWidth`、`clientHeight`、`innerWidth`、`innerHeight`、`getBoundingClientRect()`)在你的顶层脚本运行期间都会返回 `0`。当 widget 最终挂载时,`window` 上会按固定顺序触发四个事件:**`resize` → `DOMContentLoaded` → `load` → `prerendered`**。这就是你需要遵守的全部契约。

遵守它的回报是最高约 90% 的启动加速:当 Flutter 准备好展示像素时,页面的 JS 和样式都已经评估完毕。

## 何时使用本指南

适用场景:

- 为一个由宿主以 `preRendering()` / `addWithPrerendering()` 启动的 WebF 页面编写前端代码(JS/HTML/CSS)
- 调试 WebF 页面内 `clientWidth` / `clientHeight` / `getBoundingClientRect()` 返回 `0` 的问题
- 不明白为什么 `prerendered` 事件监听器从不触发
- 把现有 WebF 页面从标准模式迁移到预渲染模式
- 从前端视角在 WebF 的标准/预加载/预渲染三种启动模式之间做选择

**不适用场景:**

- 配置宿主端(Dart/Flutter 侧 —— `WebFController.preRendering()`、`WebFControllerManager`)。这是宿主端的职责,相关文档见 `webf/lib/src/launcher/controller.dart`。
- 浏览器平台的预渲染(Chrome Speculation Rules、`document.prerendering`、`prerenderingchange`)。这些 API 在 WebF 中**不存在** —— 下文的 `prerendered` 事件是 WebF 特有的。

## 三种 WebF 启动模式速览

| 模式 | 你的 JS 何时运行 | JS 运行期间是否有 layout/paint | 挂载前的 `clientWidth` | 代码约束 |
|---|---|---|---|---|
| **标准模式** | widget 挂载之后 | 是 | 不适用 —— JS 尚未运行 | 无 |
| **预加载模式** | widget 挂载之后(资源提前拉取) | 是 | 不适用 —— JS 尚未运行 | 无 |
| **预渲染模式** | widget 挂载**之前** | **否** | 返回 `0` | 依赖几何尺寸的代码必须延迟到 window 事件中执行 |

为预渲染模式编写的页面在标准模式和预加载模式中也能不加修改地运行。这个约束是**单向**的:兼容预渲染的代码总是向后兼容。

## 前端契约

四条规则。请牢记。

1. **预渲染期间几何 API 返回 0。** `clientWidth`、`clientHeight`、`innerWidth`、`innerHeight`、`getBoundingClientRect()`,以及任何由 layout 派生出的属性,在你的顶层脚本运行期间都返回 `0`(或零尺寸的矩形)。CSS 仍会被解析,级联仍会被计算 —— 只有 layout 和 paint 被推迟。

2. **挂载时 `window` 上按以下顺序触发四个事件:**
   ```
   resize  →  DOMContentLoaded  →  load  →  prerendered
   ```
   它们中任何一个触发时,layout 都已经完成,几何信息已经真实可用。

3. **`prerendered` 只触发一次。** WebF 内部使用一个"已派发"标志位来防止重复。如果你在事件已经触发**之后**才挂上监听器,它就永远不会再为你触发。

4. **预渲染期间 animation frame 和 timeline 都被暂停。** 预渲染期间排入队列的 `requestAnimationFrame` 回调要等到 widget 挂载之后才会执行。CSS 动画和 transition 也被冻结。不要把 `rAF` 当成"等待 layout 就绪"的技巧来用。

## 速查表 —— 我的代码应该放在哪里?

| 我想要... | 放在... |
|---|---|
| 拉取数据、准备状态、构建 DOM | 顶层 —— 预渲染期间立刻执行,这就是加速的来源 |
| 在 `window` / `document` / 元素上注册事件监听器 | 顶层 —— 必须在挂载时事件触发**之前**就挂上 |
| 首次读取 `clientWidth` / `getBoundingClientRect()` | `prerendered`、`load` 或 `DOMContentLoaded` 回调中 |
| 把 `<canvas>` 初始化为视口大小 | `prerendered`(最终 layout 已稳定) |
| 启动入场动画 | `load` 或 `prerendered` |
| 自动聚焦某个输入框 | `load` 或 `prerendered` |
| 建立 IntersectionObserver / ResizeObserver | 顶层即可;observer 的回调本来就在挂载后才触发 |
| 恢复滚动位置 | `prerendered` |

**如果你明确需要"预渲染完成后"的语义,请用 `prerendered`;如果你希望同一份代码在标准模式下也能不加修改地工作,请用 `load`。** `load` 在每种模式下都会触发;`prerendered` 只在预渲染模式下触发。

## 迁移示例 —— 改造前 / 改造后

### 示例 1:读取容器尺寸的图表

```javascript
// ❌ 改造前 —— 在预渲染模式下失效(width = 0)
import { Chart } from './chart-lib.js';

const container = document.getElementById('chart-container');
const chart = new Chart(container, {
  width:  container.clientWidth,
  height: container.clientHeight,
});
chart.render();
```

```javascript
// ✅ 改造后 —— 在标准、预加载、预渲染三种模式下都能工作
import { Chart } from './chart-lib.js';

const container = document.getElementById('chart-container');
let chart;

// 在顶层注册监听器,以确保它在事件触发之前已挂上。
window.addEventListener('load', () => {
  chart = new Chart(container, {
    width:  container.clientWidth,
    height: container.clientHeight,
  });
  chart.render();
});
```

为什么用 `load` 而不是 `prerendered`?因为 `load` 在每种启动模式下都会触发,同一份代码无论宿主如何启动页面都能工作。只有当你确实希望代码**仅**在预渲染模式下执行时,才使用 `prerendered`。

### 示例 2:滚动位置恢复

```javascript
// ❌ 改造前 —— 在预渲染期间执行,此时 layout 还不存在,scroll 是空操作
const savedY = sessionStorage.getItem('scrollY');
if (savedY) window.scrollTo(0, Number(savedY));
```

```javascript
// ✅ 改造后 —— 等 layout 真实存在后再恢复
const savedY = sessionStorage.getItem('scrollY');
window.addEventListener('prerendered', () => {
  if (savedY) window.scrollTo(0, Number(savedY));
}, { once: true });
```

## 常见错误

| 错误做法 | 失败原因 | 正确做法 |
|---|---|---|
| 在模块顶层读取 `clientWidth` / `getBoundingClientRect()` | 预渲染期间 layout 尚未运行,结果为 `0` | 移到 `load` 或 `prerendered` 监听器内 |
| 在初始化代码(本应触发 `prerendered` 的代码)**之后**才执行 `addEventListener('prerendered', …)` | 监听器挂上时事件已经触发;该事件只触发一次,不会重放 | 在模块顶层注册监听器,且要在任何 `await` 或异步工作之前 |
| 把 WebF 的 `prerendered` 事件与浏览器 Speculation Rules(`document.prerendering`、`prerenderingchange`)混为一谈 | 这些浏览器 API 在 WebF 中根本不存在 —— `document.prerendering` 是 `undefined`,`prerenderingchange` 永远不会触发 | 改用 WebF 的 `window` 事件 `prerendered` |
| 用 `setTimeout(fn, 0)` 或 `setTimeout(fn, 100)` "等 layout 就绪" | 定时器在预渲染期间同样会触发,此时尺寸仍是 `0`。更长的延迟也只是在和挂载赛跑 | 改用 `load` 或 `prerendered` 事件 |
| 用 `requestAnimationFrame` 等 layout | 预渲染期间 animation frame 是暂停的;回调会进队列但要到挂载之后才会执行,那时 `load` 已经触发过了 | 改用 `load` 或 `prerendered` 事件 |
| 在 `document` 而不是 `window` 上监听 | `prerendered` 只在 `window` 上派发 | `window.addEventListener('prerendered', …)` |
| 依赖 `document.visibilityState === 'prerender'` 来判断 | WebF 并未实现 Speculation Rules 的 visibility 扩展 | 目前没有同步的"我现在是不是在预渲染"的 JS 判断方式;假设你是(如果你的 bundle 以预渲染方式发布),或通过其他方式做特性检测 |

## 排查清单

按顺序逐项检查。

- **widget 挂载之后 dimensions 还是 0?** 宿主端很可能没有启用预渲染模式。从宿主的 Dart 代码确认 `WebFController.preRenderingStatus` 是否能到达 `PreRenderingStatus.done`。如果状态是 `none`,那就是标准模式启动,本指南的规则不适用。
- **`prerendered` 事件从未触发?** 最可能的两个原因:
  1. 监听器是在事件已经触发**之后**才挂上的(最常见 —— 把 `addEventListener` 移到顶层)。
  2. 页面是以标准模式或预加载模式启动的,这两种模式下 `prerendered` 根本不会触发。改用 `load` 作为模式无关的钩子。
- **页面一直卡在"加载中"?** 预渲染默认有 **20 秒**超时(可通过 `preRendering()` 的 `timeout` 参数配置)。超时后 `PreRenderingStatus` 会变成 `fail`,页面永远不会挂载。看看 evaluate 阶段是什么花了 20 秒以上(同步网络请求、过大的 bundle 等),要么加速要么由宿主端延长超时。
- **动画没有运行?** 它们是在预渲染期间启动的,但当时 animation timeline 是暂停的。把动画触发逻辑移到 `load` 或 `prerendered` 中。
- **`load` 触发了但 `prerendered` 没有?** 说明页面在标准/预加载模式中。要么接受现状只依赖 `load`,要么让宿主端改用 `addWithPrerendering()`。
- **首屏短暂闪过错误尺寸后才修正?** 说明顶层代码先渲染了一次,之后才挂上 `load` 监听器。把初始渲染调用也移到 `load` 监听器内。

## React 使用指南

在用 React 编写的 WebF 应用中,核心心智模型是:**"React 已挂载" ≠ "Flutter widget 已挂载"**。React 会在预渲染阶段就完成树的提交 —— `useEffect` 和 `useLayoutEffect` 都已执行、ref 已设上、DOM 节点确实存在 —— 但 WebF 元素这时还没有被挂入 Flutter 的渲染树,所以 layout 还没发生,任何几何读取都返回 `0`。

WebF 在元素级别上为这个状态切换提供了一个精确的信号:**`onscreen`** 和 **`offscreen`** 这两个 DOM 事件。它们由 Flutter 元素的生命周期钩子直接派发(见 `webf/lib/src/dom/element_widget_adapter.dart` 中 `WebFReplacedElementWidgetState` 和 `WebRenderLayoutRenderObjectElement` 的 `mount()` / `unmount()`),因此语义非常明确:

- **`onscreen` 在 Flutter 挂载该元素对应的 widget 的那一刻在该元素上触发** —— 也就是说,该元素的 layout 已经完成,`clientWidth`、`getBoundingClientRect()` 等值此刻是真实的。
- **`offscreen` 在 Flutter 卸载这个 widget 时触发** —— 例如元素从 DOM 中移除,或所在的路由/Tab 被切走。

每一个 WebF 元素,在每一种启动模式下,都会触发这两个事件。预渲染模式下,它们在预渲染阶段结束之后触发;标准模式下,它们在 widget 首次挂载时触发;对那些更晚才挂载的元素(懒加载路由、虚拟列表、Tab 切换),它们在元素真正被挂入渲染树时触发。

WebF 官方 React 包 **`@openwebf/react-core-ui`** 把这个信号封装成了两个工具:**`useFlutterAttached`** 和 **`WebFLazyRender`**。**优先使用它们**。只有当你**确实**需要页面级的信号时,才退回到直接监听 `load`/`prerendered`。

### 生命周期一览

| 阶段 | 此时发生了什么 | 你能读到什么 |
|---|---|---|
| 预渲染 — React 提交 | DOM 节点已创建、ref 已设、`useEffect` / `useLayoutEffect` 已运行 | DOM 存在;`clientWidth` 是 **0** |
| **─── 边界 ───** | Flutter 为该元素挂载 widget | — |
| 边界之后 | 元素触发 `onscreen`;`useFlutterAttached` 的回调执行 | `clientWidth`、`getBoundingClientRect()` 返回**真实**值 |
| 元素被卸载 | 元素触发 `offscreen`;`useFlutterAttached` 的清理回调执行 | — |

陷阱就是在 `useEffect`(边界**左侧**)里读 `ref.current.clientWidth`。修复就是把这个读取动作放到 `onscreen`(边界**右侧**),而这正是 `useFlutterAttached` 给你的。

### useEffect 陷阱

```tsx
// ❌ 错误 —— useEffect 在边界的 React 这一侧执行,
//   此时 Flutter 还没挂载这个元素,clientWidth 是 0。
useEffect(() => {
  const { clientWidth, clientHeight } = ref.current!;
  new Chart(ref.current!, { width: clientWidth, height: clientHeight }).render();
}, []);
```

**`useLayoutEffect` 也救不了你** —— 它在 React 生命周期里比 `useEffect` **更早**,而不是更晚。你等的事情发生在**边界的 Flutter 那一侧**,没有任何 React 级别的 hook 能越过这条线看到。

### 模式 A —— `useFlutterAttached`(canonical:"该元素现在已渲染")

`useFlutterAttached(onAttached, onDetached?)` 返回一个 ref 回调,把它绑到你关心的元素上 —— 可以是普通 `<div>`,也可以是 WebF 自定义标签(`<WebFListView>`、`<WebFTable>` 等)。`onAttached` 在 `onscreen` 时触发 —— 此刻该元素已有真实几何。可选的 `onDetached` 在 `offscreen` 时触发 —— 这是释放 chart/canvas/observer 等资源的正确位置。

```tsx
import { useFlutterAttached } from '@openwebf/react-core-ui';
import { useRef } from 'react';
import { Chart } from 'chart-lib';

export function ChartCard() {
  const chartRef = useRef<Chart | null>(null);

  const attachedRef = useFlutterAttached(
    (event) => {
      // 已越过边界 —— 元素现在有真实的 layout。
      const el = event.currentTarget as HTMLDivElement;
      chartRef.current = new Chart(el, {
        width: el.clientWidth,
        height: el.clientHeight,
      });
      chartRef.current.render();
    },
    () => {
      // Flutter 已经卸载该元素 —— 释放原生资源。
      chartRef.current?.destroy();
      chartRef.current = null;
    },
  );

  return <div ref={attachedRef} style={{ width: '100%', height: 300 }} />;
}
```

来自仓库内真实 WebF 应用(见 `webf_apps/bn-showcase`)的惯用法说明:

- **两个回调都传**,即便其中一个目前是空的 —— 这能表达意图,后续要加清理逻辑也很顺手。真实代码就是这种风格(`webf_apps/bn-showcase/src/pages/BitcoinPriceTailwind.tsx:34`)。
- hook 内部的监听器就挂在你赋了 ref 的那个元素上,所以回调里的 `event.currentTarget` 就是那个节点本身 —— **不需要再维护第二个 ref**。
- 同样可以把 ref 挂在 WebF 自定义元素而不是 measure 目标本身:`<WebFListView ref={attachedRef}>` 是常见模式,当 listview 包裹一个尺寸依赖视口的虚拟化区域时尤其合适。

### 模式 B —— `WebFLazyRender`(占位符 → 真实内容,直到上屏)

如果某个子树很重,而你希望它在用户**真正**导航到那里之前根本不要挂载(隐藏的 Tab、隐藏的路由),把它包进 `WebFLazyRender`。组件在它的容器触发 `onscreen` 之前显示占位符,之后再切换到真实子组件。切换之后,子组件里的每一个 `useEffect` 和 `useFlutterAttached` 回调都运行在**边界之后**,几何读取自然正常。

来自真实代码的惯用法(改写自 `webf_apps/bn-showcase/src/AppTailwind.tsx`):

```tsx
import { WebFLazyRender } from '@openwebf/react-core-ui';
import {
  FlutterCupertinoTabBar,
  FlutterCupertinoTabBarItem,
} from '@openwebf/react-cupertino-ui';

<FlutterCupertinoTabBar>
  <FlutterCupertinoTabBarItem title="Bitcoin" path="/bitcoin">
    <WebFLazyRender className="h-full" placeholder={<Skeleton />}>
      <BitcoinPricePage />
    </WebFLazyRender>
  </FlutterCupertinoTabBarItem>

  <FlutterCupertinoTabBarItem title="Demo" path="/demo">
    <WebFLazyRender className="h-full">
      <DemoPage />
    </WebFLazyRender>
  </FlutterCupertinoTabBarItem>
</FlutterCupertinoTabBar>
```

非当前 Tab 的子树要等用户切到那里才会构造 —— 用户也许根本不会去的那些页面,就不会浪费在预渲染阶段。

### 模式 C —— 页面级信号(罕见)

模式 A 和模式 B 几乎覆盖了所有组件级需求。**只有**当你确实需要一个页面级信号时(比如等整个页面交互就绪后做一次全局埋点)才考虑这个模式。这时:在**模块顶层**注册监听器,**不要**放进 `useEffect`;再通过 `useSyncExternalStore` 或基于模块级订阅的 `useState` 把状态桥接进 React。window 事件顺序是 `resize → DOMContentLoaded → load → prerendered`(详见上文"前端契约")。

### React 特有的常见错误

| 错误做法 | 失败原因 | 正确做法 |
|---|---|---|
| 在 `useEffect` 里读取 `ref.current.clientWidth` | `useEffect` 在边界的 React 这一侧执行,此时 Flutter 还没挂载该元素 | 使用 `useFlutterAttached`(模式 A) |
| 想用 `useLayoutEffect` "等 layout 就绪" | `useLayoutEffect` 在 React 生命周期里比 `useEffect` **更早**,而不是更晚。你等的事情在边界的 Flutter 那一侧,React 级别的 hook 都越不过去 | 使用 `useFlutterAttached`(模式 A) |
| 自己在 `useEffect` 里 `element.addEventListener('onscreen', …)` | 能跑,但是在重新发明这个 hook —— 而且很容易把清理、ref 绑定、StrictMode 韧性搞错 | 直接用 `useFlutterAttached` |
| 在 `useEffect` 里订阅 `window.prerendered` | `prerendered` 每个页面只触发一次;如果你的组件挂载得太晚(懒加载路由、code-split chunk),监听器挂上时事件已经触发过了,永远不会再触发 | 组件级问题不要用 `window.prerendered`。模式 A 是元素级且抗这种竞态的 —— 每个元素的 `onscreen` 都是在它自己被挂载时触发,与挂载时机无关 |
| 在 `useEffect` 里用 `requestAnimationFrame` 等 layout | 预渲染期间 rAF 是暂停的;回调进队列后要等 widget 挂载才执行 —— 那时 `useFlutterAttached` 早就已经触发了 | 使用 `useFlutterAttached`(模式 A) |
| 用一个"等待就绪"门控把整个 app 包起来 | 把预渲染的好处全部抵消 —— 你让整棵树在挂载时再渲染一次,而不是让 React 在预渲染期间就提交它 | **每个需要几何信息的组件**使用模式 A;**每个应整体延迟构造的路由/Tab** 使用模式 B |
| 忘记传 `onDetached` 回调 | 路由切换、Tab 切换时,charts、canvas、observer 会泄漏 | 把第二个回调传给 `useFlutterAttached`,在那里释放资源 |

### React + WebF 资源

- 包:`@openwebf/react-core-ui` —— 源码位于 `packages/react-core-ui/`
- `useFlutterAttached`:`packages/react-core-ui/src/hooks/useFlutterAttached.ts`
- `WebFLazyRender`:`packages/react-core-ui/src/components/WebFLazyRender.tsx`
- `webf codegen --framework=react` 使用的自定义元素包装工厂:`packages/react-core-ui/src/utils/createWebFComponent.tsx`
- 事件派发源码(Dart):`webf/lib/src/dom/element_widget_adapter.dart` 第 474–477 行(onscreen)与第 492–495 行(offscreen)
- 事件名常量:`webf/lib/src/dom/event.dart`(`EVENT_ON_SCREEN`、`EVENT_OFF_SCREEN`)
- 真实代码示例:`webf_apps/bn-showcase/src/AppTailwind.tsx`、`webf_apps/bn-showcase/src/pages/BitcoinPriceTailwind.tsx`、`webf_apps/bn-showcase/src/pages/ChatRoomTailwind.tsx`
- 支持所有 React ≥ 16.8 版本

## 延伸阅读

- 现有的图文教程:`website/docs/tutorials/performance_optimization/prerendering_and_preload_mode.md`
- Dart 源码:`webf/lib/src/launcher/controller.dart` —— `preRendering()` 方法与 `PreRenderingStatus` 枚举
- 事件派发顺序源码:`webf/lib/src/widget/webf.dart` —— `_loadingInPreRenderingMode()`
- 宿主端更高层的控制器管理 API:`webf/lib/src/launcher/controller_manager.dart` —— `addWithPrerendering()`
