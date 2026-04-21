import React from 'react';
import { WebFRouter } from '../router';
import { Button } from '../components/ui/button';
import {
  Card,
  CardAction,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '../components/ui/card';
import { Input } from '../components/ui/input';
import {
  Field,
  FieldContent,
  FieldDescription,
  FieldGroup,
  FieldLegend,
  FieldLabel,
  FieldSet,
} from '../components/ui/field';
import { Badge } from '../components/ui/badge';
import { Textarea } from '../components/ui/textarea';
import { Separator } from '../components/ui/separator';
import { Skeleton } from '../components/ui/skeleton';
import {
  Alert,
  AlertAction,
  AlertDescription,
  AlertTitle,
} from '../components/ui/alert';
import {
  Avatar,
  AvatarBadge,
  AvatarFallback,
  AvatarImage,
} from '../components/ui/avatar';
import {
  Breadcrumb,
  BreadcrumbEllipsis,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from '../components/ui/breadcrumb';
import { Checkbox } from '../components/ui/checkbox';
import { Switch } from '../components/ui/switch';
import {
  Dialog,
  DialogBody,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '../components/ui/dialog';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuShortcut,
  DropdownMenuTrigger,
} from '../components/ui/dropdown-menu';
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectSeparator,
  SelectTrigger,
  SelectValue,
} from '../components/ui/select';
import { RadioGroup, RadioGroupItem } from '../components/ui/radio-group';
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from '../components/ui/tabs';
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '../components/ui/accordion';
import {
  Popover,
  PopoverContent,
  PopoverDescription,
  PopoverHeader,
  PopoverTitle,
  PopoverTrigger,
} from '../components/ui/popover';
import { Calendar } from '../components/ui/calendar';
import {
  Progress,
  ProgressLabel,
  ProgressValue,
} from '../components/ui/progress';
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '../components/ui/collapsible';
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../components/ui/table';
import webfLogo from '../resource/webf.png';
import { WebFListView } from '@openwebf/react-core-ui';

type LegacySection = {
  title: string;
  items: Array<{ label: string; to: string }>;
};

const legacySections: LegacySection[] = [
  {
    title: 'Form Controls',
    items: [
      { label: 'Buttons', to: '/shadcn/buttons' },
      { label: 'Icon Button', to: '/shadcn/icon-button' },
      { label: 'Input', to: '/shadcn/input' },
      { label: 'Checkbox & Switch', to: '/shadcn/checkbox-switch' },
      { label: 'Select & Combobox', to: '/shadcn/select' },
      { label: 'Slider & Progress', to: '/shadcn/slider' },
      { label: 'Radio Group', to: '/shadcn/radio' },
      { label: 'Form', to: '/shadcn/form' },
    ],
  },
  {
    title: 'Display & Layout',
    items: [
      { label: 'Card', to: '/shadcn/card' },
      { label: 'Alert & Badge', to: '/shadcn/alert-badge' },
      { label: 'Avatar', to: '/shadcn/avatar' },
      { label: 'Tabs', to: '/shadcn/tabs' },
      { label: 'Accordion', to: '/shadcn/accordion' },
      { label: 'Dialog & Sheet', to: '/shadcn/dialog' },
      { label: 'Popover & Tooltip', to: '/shadcn/popover' },
      { label: 'Skeleton', to: '/shadcn/skeleton' },
    ],
  },
  {
    title: 'Data & Navigation',
    items: [
      { label: 'Table', to: '/shadcn/table' },
      { label: 'Breadcrumb', to: '/shadcn/breadcrumb' },
      { label: 'Calendar', to: '/shadcn/calendar' },
      { label: 'Dropdown Menu', to: '/shadcn/dropdown' },
      { label: 'Context Menu', to: '/shadcn/context-menu' },
      { label: 'Progress', to: '/shadcn/progress' },
    ],
  },
];

const invoices = [
  { id: 'INV001', status: 'Paid', method: 'Credit Card', amount: '$250.00' },
  { id: 'INV002', status: 'Pending', method: 'PayPal', amount: '$150.00' },
  { id: 'INV003', status: 'Review', method: 'Apple Pay', amount: '$320.00' },
  { id: 'INV004', status: 'Unpaid', method: 'Bank Transfer', amount: '$450.00' },
];

const capabilityRows = [
  {
    name: 'Phase 1',
    summary: '基础组件迁移',
    detail: 'Button / Input / Card / Dialog / Dropdown Menu / Table 直接在 use_cases 中按官网方式重建。',
  },
  {
    name: 'Phase 2',
    summary: '交互组件补齐',
    detail: '本地组件层已覆盖 Phase 2，并继续补齐 Alert、Avatar、Breadcrumb、Checkbox、Switch、Radio Group、Progress 和 Collapsible。',
  },
  {
    name: 'Phase 3',
    summary: 'WebF 能力审计',
    detail: '针对官方新组件里高频出现的 sticky、overlay、viewport units、复杂 focus 状态做专项验证，缺口再下沉到 WebF 内核。',
  },
];

const SectionTitle: React.FC<{
  eyebrow: string;
  title: string;
  description: string;
}> = ({ eyebrow, title, description }) => (
  <div className="mb-4 grid gap-1">
    <div className="text-xs font-semibold uppercase tracking-[0.24em] text-zinc-500">
      {eyebrow}
    </div>
    <h2 className="text-xl font-semibold text-zinc-950">{title}</h2>
    <p className="text-sm text-zinc-500">{description}</p>
  </div>
);

export const ShadcnShowcasePage: React.FC = () => {
  const [profileDialogOpen, setProfileDialogOpen] = React.useState(false);
  const [alertDialogOpen, setAlertDialogOpen] = React.useState(false);
  const [stickyDialogOpen, setStickyDialogOpen] = React.useState(false);
  const [framework, setFramework] = React.useState('next');
  const [timezone, setTimezone] = React.useState('utc');
  const [selectedDate, setSelectedDate] = React.useState<Date | undefined>(
    new Date(2026, 2, 31),
  );
  const [agreeToAlerts, setAgreeToAlerts] = React.useState(true);
  const [releaseNotifications, setReleaseNotifications] = React.useState(false);
  const [deploymentPlan, setDeploymentPlan] = React.useState('pro');
  const [uploadProgress, setUploadProgress] = React.useState(64);

  const go = (path: string) => WebFRouter.pushState({}, path);
  const selectedDateLabel = selectedDate
    ? selectedDate.toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
      })
    : 'Pick a date';

  return (
    <div id="main" className="min-h-screen w-full bg-zinc-50">
      <WebFListView
        id="showcase-webf-listview"
        className="mx-auto w-full max-w-6xl px-4 py-6 md:px-6"
      >
        <section className="mb-6 overflow-hidden rounded-3xl border border-zinc-200 bg-white shadow-sm">
          <div className="grid gap-6 border-b border-zinc-100 bg-[linear-gradient(135deg,#fafafa,#f4f4f5)] px-6 py-8 md:grid-cols-[1.2fr,0.8fr]">
            <div className="grid gap-4">
              <Badge variant="secondary" className="w-fit">
                shadcn/ui docs-aligned
              </Badge>
              <div className="grid gap-2">
                <h1 className="text-3xl font-semibold tracking-tight text-zinc-950">
                  Shadcn Use Cases
                </h1>
                <p className="max-w-2xl text-sm leading-6 text-zinc-600">
                  这个入口已经切换为官网 shadcn 组件风格的 React + Tailwind 示例。
                  旧的 `@openwebf/react-shadcn-ui` 页面不再作为主展示入口，只保留为
                  deprecated 路由，方便回归和对比。
                </p>
              </div>
              <div className="flex flex-wrap gap-3">
                <Button onClick={() => go('/tailwind')}>Tailwind Runtime Check</Button>
                <Button variant="outline" onClick={() => go('/css/grid-layout')}>
                  CSS Grid Capability
                </Button>
              </div>
            </div>

            <Card className="border-zinc-200 shadow-none">
              <CardHeader>
                <CardTitle>Migration Notes</CardTitle>
                <CardDescription>
                  先在 `use_cases` 里按照官网方式建立本地组件层，再逐步评估哪些能力需要继续下沉到 WebF。
                </CardDescription>
              </CardHeader>
              <CardContent className="grid gap-3 text-sm text-zinc-600">
                <div className="rounded-lg border border-zinc-200 bg-zinc-50 px-3 py-2">
                  新示例优先使用本地 `components/ui/*`，保持官网 shadcn 的组合方式。
                </div>
                <div className="rounded-lg border border-zinc-200 bg-zinc-50 px-3 py-2">
                  旧页保留但不再默认暴露，避免新旧两套实现继续混用。
                </div>
                <div className="rounded-lg border border-zinc-200 bg-zinc-50 px-3 py-2">
                  目前本地层已覆盖 24 个 docs-style 基础块，开始进入更细的 route-by-route 替换阶段。
                </div>
              </CardContent>
            </Card>
          </div>
        </section>

        <section className="mb-6 grid gap-6 md:grid-cols-2 xl:grid-cols-3">
          <Card id="showcase-dropdown-card">
            <CardHeader>
              <CardTitle>Dropdown Menu</CardTitle>
              <CardDescription>
                官网常见的账号菜单结构，保留 label、shortcut、separator 等层级。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid grid-cols-1 gap-4">
              <DropdownMenu>
                <DropdownMenuTrigger>
                  <Button id="showcase-dropdown-trigger" variant="outline">Open account menu</Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent id="showcase-dropdown-content">
                  <DropdownMenuLabel>my account</DropdownMenuLabel>
                  <DropdownMenuGroup>
                    <DropdownMenuItem>
                      Profile
                      <DropdownMenuShortcut>⇧⌘P</DropdownMenuShortcut>
                    </DropdownMenuItem>
                    <DropdownMenuItem>
                      Billing
                      <DropdownMenuShortcut>⌘B</DropdownMenuShortcut>
                    </DropdownMenuItem>
                    <DropdownMenuItem>
                      Settings
                      <DropdownMenuShortcut>⌘S</DropdownMenuShortcut>
                    </DropdownMenuItem>
                  </DropdownMenuGroup>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem>
                    Team
                    <DropdownMenuShortcut>⌘T</DropdownMenuShortcut>
                  </DropdownMenuItem>
                  <DropdownMenuItem>
                    Log out
                    <DropdownMenuShortcut>⇧⌘Q</DropdownMenuShortcut>
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>

              <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-4">
                <div className="mb-1 text-sm font-medium text-zinc-900">
                  Why local ui first
                </div>
                <div className="text-sm text-zinc-500">
                  这样可以把官方 shadcn 结构直接带进 `use_cases`，后续只把真正需要的能力缺口下沉到 WebF。
                </div>
              </div>
            </CardContent>
          </Card>

          <Card id="showcase-development-plan-card">
            <CardHeader>
              <CardTitle>Button</CardTitle>
              <CardDescription>
                对齐官网的 variant 和 size 组合，用本地组件层驱动 use case。
              </CardDescription>
              <CardAction>
                <Badge variant="outline">official style</Badge>
              </CardAction>
            </CardHeader>
            <CardContent className="grid min-w-0 grid-cols-1 gap-4">
              <div className="min-w-0 flex flex-wrap gap-2">
                <Button>Continue</Button>
                <Button variant="secondary">Secondary</Button>
                <Button variant="outline">Outline</Button>
                <Button variant="ghost">Ghost</Button>
                <Button variant="destructive">Delete</Button>
                <Button size="icon-sm" aria-label="More">
                  +
                </Button>
              </div>
              <div className="min-w-0 w-full rounded-lg border border-zinc-200 bg-zinc-50 p-3 text-sm leading-7 text-zinc-600">
                新示例不再依赖旧的 Flutter custom element 按钮包装，而是直接保持 shadcn 官方推荐的组件组合方式。
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Input + Field</CardTitle>
              <CardDescription>
                使用官网当前的 field 组织方式，保留 label、description 和表单节奏。
              </CardDescription>
            </CardHeader>
            <CardContent>
              <FieldGroup>
                <Field>
                  <FieldLabel htmlFor="project-name">Project name</FieldLabel>
                  <Input id="project-name" placeholder="enterprise-canvas" />
                  <FieldDescription>
                    用于展示 WebF 内的 shadcn 组件迁移案例。
                  </FieldDescription>
                </Field>
                <Field>
                  <FieldLabel htmlFor="registry-url">Registry URL</FieldLabel>
                  <Input id="registry-url" placeholder="https://ui.shadcn.com" />
                </Field>
              </FieldGroup>
            </CardContent>
            <CardFooter className="justify-end">
              <Button variant="outline">Cancel</Button>
              <Button>Create</Button>
            </CardFooter>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Card</CardTitle>
              <CardDescription>
                Header / Action / Content / Footer 结构直接对齐官网文档的组合习惯。
              </CardDescription>
              <CardAction>
                <Button variant="ghost" size="sm">
                  Manage
                </Button>
              </CardAction>
            </CardHeader>
            <CardContent className="grid grid-cols-1 gap-3">
              <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-4">
                <div className="mb-1 text-sm font-medium text-zinc-900">
                  Current rollout
                </div>
                <div className="text-sm text-zinc-500">
                  The new shadcn use cases live in local `components/ui/*`.
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div className="rounded-lg border border-zinc-200 p-3">
                  <div className="text-xs uppercase tracking-wide text-zinc-500">
                    Runtime
                  </div>
                  <div className="mt-1 text-lg font-semibold">WebF</div>
                </div>
                <div className="rounded-lg border border-zinc-200 p-3">
                  <div className="text-xs uppercase tracking-wide text-zinc-500">
                    UI Layer
                  </div>
                  <div className="mt-1 text-lg font-semibold">Tailwind + React</div>
                </div>
              </div>
            </CardContent>
            <CardFooter className="justify-between">
              <span className="text-sm text-zinc-500">docs-inspired shell</span>
              <Button variant="outline">Open PRD</Button>
            </CardFooter>
          </Card>
        </section>

        <section className="mb-6 grid gap-6 xl:grid-cols-[1.05fr,0.95fr]">
          <Card>
            <CardHeader>
              <CardTitle>Alert + Breadcrumb</CardTitle>
              <CardDescription>
                补齐官网常见的状态提醒和层级导航组合，便于后续把更多详情页迁移到本地组件层。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-5">
              <Breadcrumb>
                <BreadcrumbList>
                  <BreadcrumbItem>
                    <BreadcrumbLink
                      href="/"
                      onClick={(event) => {
                        event.preventDefault();
                        go('/');
                      }}
                    >
                      Home
                    </BreadcrumbLink>
                  </BreadcrumbItem>
                  <BreadcrumbSeparator />
                  <BreadcrumbItem>
                    <BreadcrumbLink
                      href="/shadcn-showcase"
                      onClick={(event) => {
                        event.preventDefault();
                        go('/shadcn-showcase');
                      }}
                    >
                      Shadcn
                    </BreadcrumbLink>
                  </BreadcrumbItem>
                  <BreadcrumbSeparator />
                  <BreadcrumbItem>
                    <BreadcrumbEllipsis />
                  </BreadcrumbItem>
                  <BreadcrumbSeparator />
                  <BreadcrumbItem>
                    <BreadcrumbPage>Expanded showcase</BreadcrumbPage>
                  </BreadcrumbItem>
                </BreadcrumbList>
              </Breadcrumb>

              <Separator />

              <Alert>
                <AlertTitle>Migration checkpoint ready</AlertTitle>
                <AlertDescription>
                  The local showcase now carries enough docs-style primitives to start replacing legacy detail pages one by one.
                </AlertDescription>
                <AlertAction>
                  <Button size="sm" variant="outline">
                    Review diff
                  </Button>
                </AlertAction>
              </Alert>

              <Alert variant="destructive">
                <AlertTitle>Legacy/native drift risk</AlertTitle>
                <AlertDescription className="text-red-700">
                  Deprecated routes still exist. If they diverge from the local showcase, regression comparisons become noisy fast.
                </AlertDescription>
              </Alert>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Checkbox + Switch</CardTitle>
              <CardDescription>
                这些控件是表单类页面里最常见的剩余缺口，优先用 docs 风格组合补齐。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-5">
              <FieldSet>
                <FieldLegend>Release preferences</FieldLegend>
                <Field orientation="horizontal" className="justify-between rounded-lg border border-zinc-200 p-4">
                  <FieldContent className="flex-1">
                    <FieldLabel>Enable rollout alerts</FieldLabel>
                    <FieldDescription>
                      Keep destructive changes gated behind explicit alerts while migrating old pages.
                    </FieldDescription>
                  </FieldContent>
                  <Checkbox
                    checked={agreeToAlerts}
                    onCheckedChange={setAgreeToAlerts}
                  />
                </Field>
                <Field orientation="horizontal" className="justify-between rounded-lg border border-zinc-200 p-4">
                  <FieldContent className="flex-1">
                    <FieldLabel>Send release notifications</FieldLabel>
                    <FieldDescription>
                      Surface status changes when docs-style routes replace deprecated ones.
                    </FieldDescription>
                  </FieldContent>
                  <Switch
                    checked={releaseNotifications}
                    onCheckedChange={setReleaseNotifications}
                  />
                </Field>
              </FieldSet>

              <Separator />

              <div className="grid gap-3 md:grid-cols-2">
                <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-4 text-sm text-zinc-600">
                  Alerts enabled: <span className="font-medium text-zinc-950">{agreeToAlerts ? 'Yes' : 'No'}</span>
                </div>
                <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-4 text-sm text-zinc-600">
                  Notifications: <span className="font-medium text-zinc-950">{releaseNotifications ? 'On' : 'Off'}</span>
                </div>
              </div>
            </CardContent>
          </Card>
        </section>

        <section className="mb-6 grid gap-6 xl:grid-cols-[1.05fr,0.95fr]">
          <Card>
            <CardHeader>
              <CardTitle>Radio Group + Progress</CardTitle>
              <CardDescription>
                对齐官网常见的选项组和进度条结构，用来表达 rollout 策略和执行状态。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-5">
              <FieldSet>
                <FieldLegend>Deployment plan</FieldLegend>
                <RadioGroup
                  value={deploymentPlan}
                  onValueChange={setDeploymentPlan}
                >
                  {[
                    {
                      value: 'starter',
                      title: 'Starter',
                      detail: 'Keep legacy pages longer and migrate only the high-traffic routes first.',
                    },
                    {
                      value: 'pro',
                      title: 'Pro',
                      detail: 'Use the local showcase as the main reference and retire legacy pages incrementally.',
                    },
                    {
                      value: 'enterprise',
                      title: 'Enterprise',
                      detail: 'Push route-by-route replacement faster and reserve native pages purely for regression probes.',
                    },
                  ].map((item) => (
                    <Field
                      key={item.value}
                      orientation="horizontal"
                      className="rounded-lg border border-zinc-200 p-4"
                    >
                      <RadioGroupItem value={item.value} />
                      <FieldContent className="flex-1">
                        <FieldLabel>{item.title}</FieldLabel>
                        <FieldDescription>{item.detail}</FieldDescription>
                      </FieldContent>
                    </Field>
                  ))}
                </RadioGroup>
              </FieldSet>

              <Separator />

              <div className="grid gap-3">
                <div className="flex items-center justify-between gap-3">
                  <ProgressLabel>Upload progress</ProgressLabel>
                  <ProgressValue>{uploadProgress}%</ProgressValue>
                </div>
                <Progress value={uploadProgress} />
                <div className="flex flex-wrap gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setUploadProgress((value) => Math.max(0, value - 10))}
                  >
                    -10%
                  </Button>
                  <Button
                    size="sm"
                    onClick={() => setUploadProgress((value) => Math.min(100, value + 10))}
                  >
                    +10%
                  </Button>
                </div>
                <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-4 text-sm text-zinc-600">
                  Active plan: <span className="font-medium text-zinc-950">{deploymentPlan}</span>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Avatar + Collapsible</CardTitle>
              <CardDescription>
                补齐用户表征和可折叠细节面板，方便把 docs 风格的 profile/settings 片段直接带进 use cases。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-5">
              <div className="flex flex-wrap items-center gap-3">
                <Avatar className="h-12 w-12">
                  <AvatarImage src={webfLogo} alt="WebF" />
                </Avatar>
                <Avatar className="h-12 w-12">
                  <AvatarFallback>WF</AvatarFallback>
                  <AvatarBadge />
                </Avatar>
                <Avatar className="h-12 w-12 bg-zinc-900 text-white">
                  <AvatarFallback>CN</AvatarFallback>
                </Avatar>
                <Avatar className="h-12 w-12 bg-zinc-200">
                  <AvatarFallback>+3</AvatarFallback>
                </Avatar>
              </div>

              <Separator />

              <Collapsible defaultOpen>
                <div className="flex items-center justify-between gap-3 rounded-lg border border-zinc-200 p-4">
                  <div className="grid gap-1">
                    <div className="text-sm font-medium text-zinc-950">
                      Route migration checklist
                    </div>
                    <div className="text-sm text-zinc-500">
                      Keep this compact by default and expand only when a page needs detailed parity notes.
                    </div>
                  </div>
                  <CollapsibleTrigger>
                    <Button variant="outline" size="sm">
                      Toggle
                    </Button>
                  </CollapsibleTrigger>
                </div>
                <CollapsibleContent>
                  {[
                    'Replace legacy route shells with local docs-style cards and fields.',
                    'Keep overlay interactions consistent with the new dialog, dropdown, and popover primitives.',
                    'Leave native fallback pages available only for regression comparison.',
                  ].map((item) => (
                    <div
                      key={item}
                      className="rounded-lg border border-zinc-200 bg-zinc-50 px-4 py-3 text-sm text-zinc-600"
                    >
                      {item}
                    </div>
                  ))}
                </CollapsibleContent>
              </Collapsible>
            </CardContent>
          </Card>
        </section>

        <section className="mb-6 grid gap-6 xl:grid-cols-[1.05fr,0.95fr]">
          <Card>
            <CardHeader>
              <CardTitle>Select + Textarea</CardTitle>
              <CardDescription>
                对齐官网常见的 trigger/content/item 组合，同时补齐 textarea、separator 这些高频基础块。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-5">
              <FieldGroup>
                <Field>
                  <FieldLabel>Framework</FieldLabel>
                  <Select value={framework} onValueChange={setFramework}>
                    <SelectTrigger className="w-full">
                      <SelectValue placeholder="Select a framework" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectGroup>
                        <SelectLabel>Recommended</SelectLabel>
                        <SelectItem value="next">Next.js</SelectItem>
                        <SelectItem value="vite">Vite</SelectItem>
                        <SelectItem value="astro">Astro</SelectItem>
                      </SelectGroup>
                      <SelectSeparator />
                      <SelectGroup>
                        <SelectLabel>Interop</SelectLabel>
                        <SelectItem value="nuxt">Nuxt</SelectItem>
                        <SelectItem value="sveltekit">SvelteKit</SelectItem>
                      </SelectGroup>
                    </SelectContent>
                  </Select>
                  <FieldDescription>
                    当前选中的迁移基线会驱动后续 use case 的默认模板。
                  </FieldDescription>
                </Field>

                <Field>
                  <FieldLabel htmlFor="release-notes">Release notes</FieldLabel>
                  <Textarea
                    id="release-notes"
                    rows={5}
                    defaultValue="Phase 2 expands the docs-aligned local shadcn layer and keeps the deprecated native routes only for regression comparison."
                  />
                </Field>
              </FieldGroup>

              <Separator />

              <div className="grid gap-3 md:grid-cols-3">
                <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-3">
                  <div className="text-xs uppercase tracking-wide text-zinc-500">
                    Active stack
                  </div>
                  <div className="mt-1 text-sm font-semibold text-zinc-950">
                    {framework === 'next'
                      ? 'Next.js'
                      : framework === 'vite'
                        ? 'Vite'
                        : framework === 'astro'
                          ? 'Astro'
                          : framework === 'nuxt'
                            ? 'Nuxt'
                            : 'SvelteKit'}
                  </div>
                </div>
                <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-3">
                  <div className="text-xs uppercase tracking-wide text-zinc-500">
                    Textarea mode
                  </div>
                  <div className="mt-1 text-sm font-semibold text-zinc-950">
                    Multi-line review
                  </div>
                </div>
                <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-3">
                  <div className="text-xs uppercase tracking-wide text-zinc-500">
                    Separator
                  </div>
                  <div className="mt-1 text-sm font-semibold text-zinc-950">
                    Section rhythm
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Tabs</CardTitle>
              <CardDescription>
                复刻官网最常见的账号设置 tab 结构，同时验证横向与纵向分组都能在 WebF 里稳定渲染。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-6">
              <Tabs defaultValue="account">
                <TabsList>
                  <TabsTrigger value="account">Account</TabsTrigger>
                  <TabsTrigger value="password">Password</TabsTrigger>
                  <TabsTrigger value="notifications">Notifications</TabsTrigger>
                </TabsList>
                <TabsContent value="account">
                  <Card className="shadow-none">
                    <CardHeader>
                      <CardTitle>Account</CardTitle>
                      <CardDescription>
                        Make changes to your account here.
                      </CardDescription>
                    </CardHeader>
                    <CardContent className="grid gap-4">
                      <Field>
                        <FieldLabel htmlFor="tabs-name">Name</FieldLabel>
                        <Input id="tabs-name" defaultValue="OpenWebF" />
                      </Field>
                      <Field>
                        <FieldLabel htmlFor="tabs-username">Username</FieldLabel>
                        <Input id="tabs-username" defaultValue="@webf" />
                      </Field>
                    </CardContent>
                  </Card>
                </TabsContent>
                <TabsContent value="password">
                  <Card className="shadow-none">
                    <CardHeader>
                      <CardTitle>Password</CardTitle>
                      <CardDescription>
                        Rotate credentials before exposing the showcase externally.
                      </CardDescription>
                    </CardHeader>
                    <CardContent className="grid gap-4">
                      <Input type="password" defaultValue="super-secret" />
                      <Input type="password" placeholder="Confirm password" />
                    </CardContent>
                  </Card>
                </TabsContent>
                <TabsContent value="notifications">
                  <Card className="shadow-none">
                    <CardHeader>
                      <CardTitle>Notifications</CardTitle>
                      <CardDescription>
                        Keep migration probes noisy while overlay work is still being audited.
                      </CardDescription>
                    </CardHeader>
                    <CardContent className="grid gap-2 text-sm text-zinc-600">
                      <div>Build failures</div>
                      <div>Layout regressions</div>
                      <div>Focus-state mismatches</div>
                    </CardContent>
                  </Card>
                </TabsContent>
              </Tabs>

              <Separator />

              <Tabs defaultValue="queued" orientation="vertical">
                <TabsList className="w-full" variant="line">
                  <TabsTrigger value="queued" className="justify-start px-0">
                    Queued
                  </TabsTrigger>
                  <TabsTrigger value="review" className="justify-start px-0">
                    In review
                  </TabsTrigger>
                  <TabsTrigger value="done" className="justify-start px-0">
                    Done
                  </TabsTrigger>
                </TabsList>
                <div className="grid gap-3">
                  <TabsContent value="queued">
                    <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-4 text-sm text-zinc-600">
                      Waiting on deeper WebF capability probes for overlay positioning and sticky affordances.
                    </div>
                  </TabsContent>
                  <TabsContent value="review">
                    <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-4 text-sm text-zinc-600">
                      Visual parity checks for docs-style layouts are running against the showcase route.
                    </div>
                  </TabsContent>
                  <TabsContent value="done">
                    <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-4 text-sm text-zinc-600">
                      Base components, dialogs, menus, tables, and the new Phase 2 batch are now local.
                    </div>
                  </TabsContent>
                </div>
              </Tabs>
            </CardContent>
          </Card>
        </section>

        <section className="mb-6 grid gap-6 xl:grid-cols-[1.05fr,0.95fr]">
          <Card>
            <CardHeader>
              <CardTitle>Accordion</CardTitle>
              <CardDescription>
                使用官网常见 FAQ 形式组织迁移说明，覆盖 `single` 和 `multiple` 两种展开模式。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-5">
              <Accordion type="single" collapsible defaultValue="item-1">
                <AccordionItem value="item-1">
                  <AccordionTrigger>Why move to local components first?</AccordionTrigger>
                  <AccordionContent>
                    因为这样能直接复刻 shadcn 官方组合方式，再按真实缺口决定哪些能力需要下沉到 WebF。
                  </AccordionContent>
                </AccordionItem>
                <AccordionItem value="item-2">
                  <AccordionTrigger>What stays on the legacy routes?</AccordionTrigger>
                  <AccordionContent>
                    旧的 `@openwebf/react-shadcn-ui` 页面仅保留给回归和行为对比，不再作为主入口继续扩展。
                  </AccordionContent>
                </AccordionItem>
                <AccordionItem value="item-3">
                  <AccordionTrigger>What is still risky?</AccordionTrigger>
                  <AccordionContent>
                    Overlay stacking、focus trapping、sticky 区块以及更复杂的 viewport 单位仍需要专项验证。
                  </AccordionContent>
                </AccordionItem>
              </Accordion>

              <Separator />

              <Accordion type="multiple" defaultValue={['check-1', 'check-2']}>
                <AccordionItem value="check-1">
                  <AccordionTrigger>Completed in this batch</AccordionTrigger>
                  <AccordionContent>
                    Select, Tabs, Accordion, Popover, Calendar, Textarea, Separator, Skeleton.
                  </AccordionContent>
                </AccordionItem>
                <AccordionItem value="check-2">
                  <AccordionTrigger>Next review pass</AccordionTrigger>
                  <AccordionContent>
                    Compare the local showcase against the deprecated routes and keep only the patterns that hold up in WebF.
                  </AccordionContent>
                </AccordionItem>
              </Accordion>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Popover + Calendar</CardTitle>
              <CardDescription>
                使用 popover 承载 docs 风格的 date-picker 组合，并补齐一个独立 calendar 展示块。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-5">
              <div className="flex flex-wrap gap-3">
                <Popover>
                  <PopoverTrigger>
                    <Button variant="outline">{selectedDateLabel}</Button>
                  </PopoverTrigger>
                  <PopoverContent align="start" className="w-[320px]">
                    <PopoverHeader>
                      <PopoverTitle>Schedule rollout</PopoverTitle>
                      <PopoverDescription>
                        Pick the next date to verify the expanded shadcn showcase in WebF.
                      </PopoverDescription>
                    </PopoverHeader>
                    <div className="mt-4">
                      <Calendar
                        selected={selectedDate}
                        onSelect={setSelectedDate}
                        className="border-0 p-0 shadow-none"
                      />
                    </div>
                  </PopoverContent>
                </Popover>

                <Popover>
                  <PopoverTrigger>
                    <Button variant="ghost">Why this matters</Button>
                  </PopoverTrigger>
                  <PopoverContent align="end">
                    <PopoverHeader>
                      <PopoverTitle>Overlay audit</PopoverTitle>
                      <PopoverDescription>
                        Popover is a compact way to validate trigger wiring, outside-click dismissal, and layered content positioning.
                      </PopoverDescription>
                    </PopoverHeader>
                  </PopoverContent>
                </Popover>
              </div>

              <Separator />

              <div className="grid gap-4 lg:grid-cols-[auto,1fr]">
                <Calendar
                  selected={selectedDate}
                  onSelect={setSelectedDate}
                  captionLayout="dropdown"
                  showWeekNumber
                />
                <div className="grid gap-3">
                  <Field>
                    <FieldLabel>Timezone</FieldLabel>
                    <Select value={timezone} onValueChange={setTimezone}>
                      <SelectTrigger className="w-full">
                        <SelectValue placeholder="Select timezone" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="utc">UTC</SelectItem>
                        <SelectItem value="pst">Pacific Time</SelectItem>
                        <SelectItem value="cet">Central European Time</SelectItem>
                        <SelectItem value="cst-cn">China Standard Time</SelectItem>
                      </SelectContent>
                    </Select>
                  </Field>
                  <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-4 text-sm text-zinc-600">
                    Selected date: <span className="font-medium text-zinc-950">{selectedDateLabel}</span>
                  </div>
                  <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-4 text-sm text-zinc-600">
                    Active timezone preset: <span className="font-medium text-zinc-950">{timezone}</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </section>

        <section className="mb-6 grid gap-6 md:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle>Skeleton</CardTitle>
              <CardDescription>
                覆盖官网里最常见的 avatar、text、form 三种 loading 占位用法。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-6">
              <div className="flex items-center gap-4">
                <Skeleton className="h-12 w-12 rounded-full" />
                <div className="grid flex-1 gap-2">
                  <Skeleton className="h-4 w-32" />
                  <Skeleton className="h-4 w-full max-w-56" />
                </div>
              </div>

              <Separator />

              <div className="grid gap-3">
                <Skeleton className="h-9 w-full" />
                <Skeleton className="h-9 w-full" />
                <Skeleton className="h-20 w-full" />
                <div className="flex justify-end gap-2">
                  <Skeleton className="h-9 w-20" />
                  <Skeleton className="h-9 w-24" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Coverage Snapshot</CardTitle>
              <CardDescription>
                这块用更接近 docs landing 的摘要方式展示当前 local shadcn 覆盖面。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-4">
              <div className="grid gap-3 sm:grid-cols-2">
                <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-4">
                  <div className="text-xs uppercase tracking-wide text-zinc-500">
                    Base layer
                  </div>
                  <div className="mt-1 text-lg font-semibold text-zinc-950">
                    24 local primitives
                  </div>
                </div>
                <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-4">
                  <div className="text-xs uppercase tracking-wide text-zinc-500">
                    Deprecated fallback
                  </div>
                  <div className="mt-1 text-lg font-semibold text-zinc-950">
                    Legacy routes kept
                  </div>
                </div>
              </div>
              <Separator />
              <div className="flex flex-wrap gap-2">
                {[
                  'Alert',
                  'Avatar',
                  'Breadcrumb',
                  'Button',
                  'Card',
                  'Checkbox',
                  'Collapsible',
                  'Dialog',
                  'Dropdown Menu',
                  'Input',
                  'Field',
                  'Badge',
                  'Progress',
                  'Radio Group',
                  'Switch',
                  'Table',
                  'Select',
                  'Tabs',
                  'Accordion',
                  'Popover',
                  'Calendar',
                  'Textarea',
                  'Separator',
                  'Skeleton',
                ].map((item) => (
                  <Badge key={item} variant="outline">
                    {item}
                  </Badge>
                ))}
              </div>
            </CardContent>
          </Card>
        </section>

        <section className="mb-6 grid gap-6 xl:grid-cols-[1.05fr,0.95fr]">
          <Card>
            <CardHeader>
              <CardTitle>Dialog</CardTitle>
              <CardDescription>
                同一套对话框组件演示默认、无关闭按钮和长内容 sticky footer 三种常见官网案例。
              </CardDescription>
            </CardHeader>
            <CardContent className="flex flex-wrap gap-3">
              <Dialog
                open={profileDialogOpen}
                onOpenChange={setProfileDialogOpen}
              >
                <DialogTrigger>
                  <Button>Edit profile</Button>
                </DialogTrigger>
                <DialogContent>
                  <DialogHeader>
                    <DialogTitle>Edit profile</DialogTitle>
                    <DialogDescription>
                      Make changes to your profile here. Click save when you are
                      done.
                    </DialogDescription>
                  </DialogHeader>
                  <DialogBody className="grid gap-4">
                    <Field>
                      <FieldLabel htmlFor="dialog-name">Name</FieldLabel>
                      <Input id="dialog-name" defaultValue="OpenWebF" />
                    </Field>
                    <Field>
                      <FieldLabel htmlFor="dialog-username">Username</FieldLabel>
                      <Input id="dialog-username" defaultValue="@webf" />
                    </Field>
                  </DialogBody>
                  <DialogFooter>
                    <Button
                      variant="outline"
                      onClick={() => setProfileDialogOpen(false)}
                    >
                      Cancel
                    </Button>
                    <Button onClick={() => setProfileDialogOpen(false)}>
                      Save changes
                    </Button>
                  </DialogFooter>
                </DialogContent>
              </Dialog>

              <Dialog open={alertDialogOpen} onOpenChange={setAlertDialogOpen}>
                <DialogTrigger>
                  <Button variant="destructive">Danger zone</Button>
                </DialogTrigger>
                <DialogContent showCloseButton={false}>
                  <DialogHeader>
                    <DialogTitle>Are you absolutely sure?</DialogTitle>
                    <DialogDescription>
                      This will permanently remove the current showcase config.
                    </DialogDescription>
                  </DialogHeader>
                  <DialogBody>
                    <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
                      This action is irreversible and is intentionally rendered
                      without a top-right close button.
                    </div>
                  </DialogBody>
                  <DialogFooter>
                    <Button
                      variant="outline"
                      onClick={() => setAlertDialogOpen(false)}
                    >
                      Cancel
                    </Button>
                    <Button
                      variant="destructive"
                      onClick={() => setAlertDialogOpen(false)}
                    >
                      Confirm delete
                    </Button>
                  </DialogFooter>
                </DialogContent>
              </Dialog>

              <Dialog
                open={stickyDialogOpen}
                onOpenChange={setStickyDialogOpen}
              >
                <DialogTrigger>
                  <Button variant="outline">Sticky footer</Button>
                </DialogTrigger>
                <DialogContent className="max-h-[80vh]">
                  <DialogHeader className="border-b border-zinc-100 bg-white">
                    <DialogTitle>Long-form migration checklist</DialogTitle>
                    <DialogDescription>
                      这个案例用来模拟官网文档里常见的长内容弹窗。
                    </DialogDescription>
                  </DialogHeader>
                  <DialogBody className="grid gap-3 py-4">
                    {Array.from({ length: 8 }, (_, index) => (
                      <div
                        key={index}
                        className="rounded-lg border border-zinc-200 bg-zinc-50 px-4 py-3 text-sm text-zinc-600"
                      >
                        Step {index + 1}: 迁移一个 shadcn 官方组件示例，确认布局、
                        hover、focus、overlay 和滚动行为在 WebF 中一致。
                      </div>
                    ))}
                  </DialogBody>
                  <DialogFooter className="sticky bottom-0 border-zinc-200">
                    <Button
                      variant="outline"
                      onClick={() => setStickyDialogOpen(false)}
                    >
                      Later
                    </Button>
                    <Button onClick={() => setStickyDialogOpen(false)}>
                      Continue rollout
                    </Button>
                  </DialogFooter>
                </DialogContent>
              </Dialog>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Dropdown Menu</CardTitle>
              <CardDescription>
                官网常见的账号菜单结构，保留 label、shortcut、separator 等层级。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid grid-cols-1 gap-4">
              <DropdownMenu>
                <DropdownMenuTrigger>
                  <Button
                    id="showcase-dropdown-trigger"
                    variant="outline"
                    onClick={() => {
                      const listView = document.getElementById('showcase-webf-listview') as any;
                      setTimeout(() => {
                        listView?.debugDumpRenderTree?.('showcase-dropdown-open-0');
                        listView?.debugDumpPaintOrder?.('showcase-dropdown-open-0');
                      }, 0);
                      setTimeout(() => {
                        listView?.debugDumpRenderTree?.('showcase-dropdown-open-80');
                        listView?.debugDumpPaintOrder?.('showcase-dropdown-open-80');
                      }, 80);
                    }}
                  >
                    Open account menu
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent id="showcase-dropdown-content">
                  <DropdownMenuLabel>my account</DropdownMenuLabel>
                  <DropdownMenuGroup>
                    <DropdownMenuItem>
                      Profile
                      <DropdownMenuShortcut>⇧⌘P</DropdownMenuShortcut>
                    </DropdownMenuItem>
                    <DropdownMenuItem>
                      Billing
                      <DropdownMenuShortcut>⌘B</DropdownMenuShortcut>
                    </DropdownMenuItem>
                    <DropdownMenuItem>
                      Settings
                      <DropdownMenuShortcut>⌘S</DropdownMenuShortcut>
                    </DropdownMenuItem>
                  </DropdownMenuGroup>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem>
                    Team
                    <DropdownMenuShortcut>⌘T</DropdownMenuShortcut>
                  </DropdownMenuItem>
                  <DropdownMenuItem>
                    Log out
                    <DropdownMenuShortcut>⇧⌘Q</DropdownMenuShortcut>
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>

              <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-4">
                <div className="mb-1 text-sm font-medium text-zinc-900">
                  Why local ui first
                </div>
                <div className="text-sm text-zinc-500">
                  这样可以把官方 shadcn 结构直接带进 `use_cases`，后续只把真正需要的能力缺口下沉到 WebF。
                </div>
              </div>
            </CardContent>
          </Card>
        </section>

        <section className="mb-6 grid gap-6 xl:grid-cols-[1.05fr,0.95fr]">
          {/* <Card>
            <CardHeader>
              <CardTitle>Table</CardTitle>
              <CardDescription>
                使用官网 table 组织方式表达迁移节奏和组件状态，而不是沿用旧的 native slot API。
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Table>
                <TableCaption>A list of the current shadcn migration checkpoints.</TableCaption>
                <TableHeader>
                  <TableRow>
                    <TableHead>Checkpoint</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Owner</TableHead>
                    <TableHead className="text-right">ETA</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {invoices.map((invoice) => (
                    <TableRow key={invoice.id}>
                      <TableCell className="font-medium">{invoice.id}</TableCell>
                      <TableCell>
                        <Badge
                          variant={
                            invoice.status === 'Paid'
                              ? 'default'
                              : invoice.status === 'Pending'
                                ? 'secondary'
                                : invoice.status === 'Review'
                                  ? 'outline'
                                  : 'destructive'
                          }
                        >
                          {invoice.status}
                        </Badge>
                      </TableCell>
                      <TableCell>{invoice.method}</TableCell>
                      <TableCell className="text-right">{invoice.amount}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card> */}

          <Card>
            <CardHeader>
              <CardTitle>Development Plan</CardTitle>
              <CardDescription>
                当前迁移以 `use_cases` 先落地为主，CSS 能力审计和更复杂组件在后续阶段推进。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid grid-cols-1 gap-3">
              {capabilityRows.map((row) => (
                <div
                  key={row.name}
                  className="rounded-lg border border-zinc-200 bg-zinc-50 p-4"
                >
                  <div className="mb-1 flex items-center justify-between gap-3">
                    <div className="text-sm font-semibold text-zinc-900">
                      {row.name}
                    </div>
                    <Badge variant="outline">{row.summary}</Badge>
                  </div>
                  <div className="text-sm leading-6 text-zinc-600">
                    {row.detail}
                  </div>
                </div>
              ))}
            </CardContent>
            <CardFooter className="justify-between">
              <span className="text-sm text-zinc-500">
                Detailed plan lives in `use_cases/SHADCN_COMPONENT_MIGRATION_PLAN.md`.
              </span>
              <Button
                variant="outline"
                onClick={() => go('/css/values-units')}
              >
                Check CSS Units
              </Button>
            </CardFooter>
          </Card>
        </section>

        {/* <section>
          <SectionTitle
            eyebrow="Deprecated"
            title="Legacy shadcn routes"
            description="下面这些页面保留给回归测试和对比使用，但已经不再作为新版 shadcn use case 的主入口。"
          />

          <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
            {legacySections.map((section) => (
              <Card key={section.title}>
                <CardHeader>
                  <CardTitle>{section.title}</CardTitle>
                  <CardDescription>
                    Existing pages backed by `@openwebf/react-shadcn-ui`.
                  </CardDescription>
                  <CardAction>
                    <Badge variant="destructive">deprecated</Badge>
                  </CardAction>
                </CardHeader>
                <CardContent className="grid grid-cols-1 gap-2">
                  {section.items.map((item) => (
                    <button
                      key={item.to}
                      type="button"
                      className="flex items-center justify-between rounded-lg border border-zinc-200 px-3 py-2 text-left text-sm text-zinc-700 transition-colors hover:bg-zinc-50 hover:text-zinc-950"
                      onClick={() => go(item.to)}
                    >
                      <span>{item.label}</span>
                      <span className="text-zinc-400">&gt;</span>
                    </button>
                  ))}
                </CardContent>
              </Card>
            ))}
          </div>
        </section> */}
      </WebFListView>
    </div>
  );
};
