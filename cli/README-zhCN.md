# WebF CLI

一个用于生成 Flutter 类和 Vue/React 组件声明文件的命令行工具。

## 安装

```bash
npm install -g @openwebf/webf
```

## 使用方法

WebF CLI 提供三个主要命令：

### 1. 初始化类型定义

在项目中初始化 WebF 类型定义：

```bash
webf init <目标目录>
```

这将在指定目录中创建必要的类型定义文件。

### 2. 创建新项目

创建一个新的 Vue 或 React 项目：

```bash
webf create <目标目录> --framework <框架> --package-name <包名>
```

选项：
- `--framework`：选择 'vue' 或 'react'
- `--package-name`：指定包名

示例：
```bash
webf create my-webf-app --framework react --package-name @myorg/my-webf-app
```

### 3. 生成代码

生成 Flutter 类和组件声明文件：

```bash
webf generate <目标路径> --flutter-package-src <Flutter源码路径> --framework <框架>
```

选项：
- `--flutter-package-src`：Flutter 包源码路径
- `--framework`：选择 'vue' 或 'react'

示例：
```bash
webf generate ./src --flutter-package-src ./flutter_package --framework react
```

## 实现细节

### 类型系统

CLI 使用复杂的类型系统来处理各种数据类型：

- 基本类型：
  - `string`（DOM 字符串）
  - `number`（整数/浮点数）
  - `boolean`（布尔值）
  - `any`（任意类型）
  - `void`（空类型）
  - `null`（空值）
  - `undefined`（未定义）

- 复杂类型：
  - 数组：`Type[]`
  - 函数：`Function`
  - Promise：`Promise<Type>`
  - 自定义事件：`CustomEvent`
  - 布局依赖类型：`DependentsOnLayout<Type>`

### 命名约定和文件结构

#### 接口命名模式

CLI 遵循特定的接口命名模式：

1. **组件接口**：
   - 属性接口：`{组件名称}Properties`
   - 事件接口：`{组件名称}Events`
   - 示例：`ButtonProperties`、`ButtonEvents`

2. **生成的文件名**：
   - React 组件：`{组件名称}.tsx`
   - Vue 组件：`{组件名称}.vue`
   - Flutter 类：`{组件名称}.dart`
   - 类型定义：`{组件名称}.d.ts`

3. **名称转换**：
   - 组件名称提取：
     - 从 `{名称}Properties` → `{名称}`
     - 从 `{名称}Events` → `{名称}`
   - 示例：`ButtonProperties` → `Button`

#### 生成的组件名称

1. **React 组件**：
   - 标签名：`<{组件名称} />`
   - 文件名：`{组件名称}.tsx`
   - 示例：`ButtonProperties` → `<Button />` 在 `button.tsx` 中

2. **Vue 组件**：
   - 标签名：`<{组件名称}-component />`
   - 文件名：`{组件名称}.vue`
   - 示例：`ButtonProperties` → `<button-component />` 在 `button.vue` 中

3. **Flutter 类**：
   - 类名：`{组件名称}`
   - 文件名：`{组件名称}.dart`
   - 示例：`ButtonProperties` → `Button` 类在 `button.dart` 中

#### 类型定义文件

1. **文件位置**：
   - React：`src/components/{组件名称}.d.ts`
   - Vue：`src/components/{组件名称}.d.ts`
   - Flutter：`lib/src/{组件名称}.dart`

2. **接口结构**：
   ```typescript
   interface {组件名称}Properties {
     // 属性
   }

   interface {组件名称}Events {
     // 事件
   }
   ```

3. **组件注册**：
   - React：在 `index.ts` 中导出
   - Vue：在组件声明文件中注册
   - Flutter：在库文件中导出

### 组件生成

#### React 组件
- 生成带有适当类型定义的 TypeScript React 组件
- 处理带有正确事件类型的事件绑定
- 支持带有基于 Promise 返回类型的异步方法
- 将事件名称转换为 React 约定（如 `onClick`、`onChange`）

#### Vue 组件
- 生成 Vue 组件类型声明
- 支持 Vue 的事件系统
- 使用适当的 TypeScript 类型处理属性和事件
- 生成组件注册代码

#### Flutter 类
- 生成带有适当类型映射的 Dart 类
- 使用正确的参数类型处理方法声明
- 支持异步操作
- 生成适当的事件处理器类型

### 类型分析

CLI 使用 TypeScript 的编译器 API 来分析和处理类型定义：

1. 解析 TypeScript 接口声明
2. 分析类关系和继承
3. 处理方法签名和参数类型
4. 处理联合类型和复杂类型表达式
5. 为每个目标平台生成适当的类型映射

### 代码生成约定

1. **命名约定**：
   - 属性：camelCase
   - 事件：带 'on' 前缀的 camelCase
   - 方法：camelCase
   - 类：PascalCase

2. **类型映射**：
   - TypeScript → Dart：
     - `string` → `String`
     - `number` → `int`/`double`
     - `boolean` → `bool`
     - `any` → `dynamic`
     - `void` → `void`

   - TypeScript → React/Vue：
     - `string` → `string`
     - `number` → `number`
     - `boolean` → `boolean`
     - `any` → `any`
     - `void` → `void`

3. **事件处理**：
   - React：`EventHandler<SyntheticEvent<Element>>`
   - Vue：`Event`/`CustomEvent`
   - Flutter：`EventHandler<Event>`

## 项目结构

运行命令后，您的项目将具有以下结构：

### React 项目
```
my-webf-app/
├── src/
│   ├── components/
│   │   ├── button.tsx
│   │   ├── button.d.ts
│   │   └── index.ts
│   ├── utils/
│   │   └── createComponent.ts
│   └── index.ts
├── package.json
├── tsconfig.json
└── tsup.config.ts
```

### Vue 项目
```
my-webf-app/
├── src/
│   ├── components/
│   │   ├── button.vue
│   │   └── button.d.ts
├── package.json
└── tsconfig.json
```

## 依赖项

CLI 会自动为所选框架安装必要的依赖项：
- React：React 及相关类型定义
- Vue：Vue 及相关类型定义

## 开发

### 从源码构建

```bash
npm install
npm run build
```

### 测试

```bash
npm test
```

## 许可证

ISC
