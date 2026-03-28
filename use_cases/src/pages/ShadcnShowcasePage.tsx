import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
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
  FieldDescription,
  FieldGroup,
  FieldLabel,
} from '../components/ui/field';
import { Badge } from '../components/ui/badge';
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
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../components/ui/table';

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
    detail: '继续迁移 Select、Calendar、Tabs、Popover、Context Menu，并复用同一套本地 ui 基础层。',
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

  const go = (path: string) => WebFRouter.pushState({}, path);

  return (
    <div id="main" className="min-h-screen w-full bg-zinc-50">
      <WebFListView className="w-full max-w-6xl px-4 py-6 md:px-6">
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
                  Phase 2 开始再逐个对齐 Calendar、Popover、Select 等更复杂组件。
                </div>
              </CardContent>
            </Card>
          </div>
        </section>

        <section className="mb-6 grid gap-6 md:grid-cols-2 xl:grid-cols-3">
          <Card>
            <CardHeader>
              <CardTitle>Button</CardTitle>
              <CardDescription>
                对齐官网的 variant 和 size 组合，用本地组件层驱动 use case。
              </CardDescription>
              <CardAction>
                <Badge variant="outline">official style</Badge>
              </CardAction>
            </CardHeader>
            <CardContent className="grid gap-4">
              <div className="flex flex-wrap gap-2">
                <Button>Continue</Button>
                <Button variant="secondary">Secondary</Button>
                <Button variant="outline">Outline</Button>
                <Button variant="ghost">Ghost</Button>
                <Button variant="destructive">Delete</Button>
                <Button size="icon-sm" aria-label="More">
                  +
                </Button>
              </div>
              <div className="rounded-lg border border-zinc-200 bg-zinc-50 p-3 text-sm text-zinc-600">
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
            <CardContent className="grid gap-3">
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
            <CardContent className="grid gap-4">
              <DropdownMenu>
                <DropdownMenuTrigger>
                  <Button variant="outline">Open account menu</Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent>
                  <DropdownMenuLabel>my account</DropdownMenuLabel>
                  <DropdownMenuSeparator />
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
          <Card>
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
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Development Plan</CardTitle>
              <CardDescription>
                当前迁移以 `use_cases` 先落地为主，CSS 能力审计和更复杂组件在后续阶段推进。
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-3">
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

        <section>
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
                <CardContent className="grid gap-2">
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
        </section>
      </WebFListView>
    </div>
  );
};
