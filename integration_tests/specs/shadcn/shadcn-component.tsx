/** @jsxImportSource react */
import * as React from 'react';
import { Alert, AlertAction, AlertDescription, AlertTitle } from '../../../use_cases/src/components/ui/alert';
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '../../../use_cases/src/components/ui/accordion';
import { Avatar, AvatarFallback, AvatarImage } from '../../../use_cases/src/components/ui/avatar';
import { Badge } from '../../../use_cases/src/components/ui/badge';
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from '../../../use_cases/src/components/ui/breadcrumb';
import { Calendar } from '../../../use_cases/src/components/ui/calendar';
import {
  Card,
  CardAction,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '../../../use_cases/src/components/ui/card';
import { Checkbox } from '../../../use_cases/src/components/ui/checkbox';
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '../../../use_cases/src/components/ui/collapsible';
import { Button } from '../../../use_cases/src/components/ui/button';
import {
  Dialog,
  DialogBody,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '../../../use_cases/src/components/ui/dialog';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuShortcut,
  DropdownMenuTrigger,
} from '../../../use_cases/src/components/ui/dropdown-menu';
import { Field, FieldDescription, FieldGroup, FieldLabel } from '../../../use_cases/src/components/ui/field';
import { Input } from '../../../use_cases/src/components/ui/input';
import {
  Popover,
  PopoverContent,
  PopoverDescription,
  PopoverHeader,
  PopoverTitle,
  PopoverTrigger,
} from '../../../use_cases/src/components/ui/popover';
import { Progress, ProgressLabel, ProgressValue } from '../../../use_cases/src/components/ui/progress';
import { RadioGroup, RadioGroupItem } from '../../../use_cases/src/components/ui/radio-group';
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectSeparator,
  SelectTrigger,
  SelectValue,
} from '../../../use_cases/src/components/ui/select';
import { Separator } from '../../../use_cases/src/components/ui/separator';
import { Skeleton } from '../../../use_cases/src/components/ui/skeleton';
import { Switch } from '../../../use_cases/src/components/ui/switch';
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../../../use_cases/src/components/ui/table';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../../../use_cases/src/components/ui/tabs';
import { Textarea } from '../../../use_cases/src/components/ui/textarea';

function Surface({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-zinc-50 p-6">
      <div className="mx-auto grid max-w-3xl gap-4 rounded-2xl border border-zinc-200 bg-white p-6 shadow-sm">
        <h1 className="text-xl font-semibold text-zinc-950">{title}</h1>
        {children}
      </div>
    </div>
  );
}

export { Button };

function formatDate(date: Date | null) {
  if (!date) {
    return 'none';
  }

  const year = date.getFullYear();
  const month = `${date.getMonth() + 1}`.padStart(2, '0');
  const day = `${date.getDate()}`.padStart(2, '0');
  return `${year}-${month}-${day}`;
}

export function InputFixture() {
  return (
    <Surface title="shadcn_input">
      <FieldGroup>
        <Field>
          <FieldLabel htmlFor="repo-name">Repository</FieldLabel>
          <Input id="repo-name" placeholder="webf-enterprise-canvas" />
          <FieldDescription>Use the project slug for generated examples.</FieldDescription>
        </Field>
      </FieldGroup>
    </Surface>
  );
}

export function CardFixture() {
  return (
    <Surface title="shadcn_card">
      <Card>
        <CardHeader>
          <CardTitle>Official card sample</CardTitle>
          <CardDescription>Header, action, content, and footer stay aligned.</CardDescription>
          <CardAction>
            <Badge variant="outline">Live</Badge>
          </CardAction>
        </CardHeader>
        <CardContent>Migration status: ready for verification.</CardContent>
        <CardFooter>
          <Button variant="outline">Cancel</Button>
          <Button>Continue</Button>
        </CardFooter>
      </Card>
    </Surface>
  );
}

export function BadgeFixture() {
  return (
    <Surface title="shadcn_badge">
      <div className="flex flex-wrap gap-2">
        <Badge>Default badge</Badge>
        <Badge variant="secondary">Secondary badge</Badge>
        <Badge variant="destructive">Destructive badge</Badge>
        <Badge variant="outline">Outline badge</Badge>
      </div>
    </Surface>
  );
}

export function FieldFixture() {
  return (
    <Surface title="shadcn_field">
      <FieldGroup>
        <Field>
          <FieldLabel htmlFor="registry-url">Registry URL</FieldLabel>
          <Input id="registry-url" placeholder="https://ui.shadcn.com" />
          <FieldDescription>Use the official registry as the default source.</FieldDescription>
        </Field>
      </FieldGroup>
    </Surface>
  );
}

export function DialogFixture() {
  const [open, setOpen] = React.useState(false);

  return (
    <Surface title="shadcn_dialog">
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogTrigger>
          <Button>Open dialog</Button>
        </DialogTrigger>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Migration profile</DialogTitle>
            <DialogDescription>Update the rollout owner before shipping.</DialogDescription>
          </DialogHeader>
          <DialogBody className="grid gap-4">
            <Field>
              <FieldLabel htmlFor="owner-name">Owner</FieldLabel>
              <Input id="owner-name" defaultValue="OpenWebF" />
            </Field>
          </DialogBody>
          <DialogFooter>
            <Button variant="outline" onClick={() => setOpen(false)}>
              Cancel
            </Button>
            <Button onClick={() => setOpen(false)}>Save changes</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </Surface>
  );
}

export function DropdownMenuFixture() {
  return (
    <Surface title="shadcn_dropdown_menu">
      <DropdownMenu>
        <DropdownMenuTrigger key="trigger">
          <Button variant="outline">Open menu</Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent key="content">
          <DropdownMenuLabel>My Account</DropdownMenuLabel>
          <DropdownMenuSeparator />
          <DropdownMenuGroup>
            <DropdownMenuItem>
              Profile
              <DropdownMenuShortcut>⇧⌘P</DropdownMenuShortcut>
            </DropdownMenuItem>
            <DropdownMenuItem>Billing</DropdownMenuItem>
            <DropdownMenuItem>Team</DropdownMenuItem>
          </DropdownMenuGroup>
        </DropdownMenuContent>
      </DropdownMenu>
    </Surface>
  );
}

export function TableFixture() {
  return (
    <Surface title="shadcn_table">
      <Table>
        <TableCaption>Official table sample</TableCaption>
        <TableHeader>
          <TableRow>
            <TableHead>Invoice</TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Amount</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow>
            <TableCell>INV001</TableCell>
            <TableCell>Paid</TableCell>
            <TableCell>$250.00</TableCell>
          </TableRow>
          <TableRow>
            <TableCell>INV002</TableCell>
            <TableCell>Pending</TableCell>
            <TableCell>$150.00</TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </Surface>
  );
}

export function AlertFixture() {
  return (
    <Surface title="shadcn_alert">
      <Alert>
        <AlertTitle>Heads up</AlertTitle>
        <AlertDescription>Calendar and overlay behaviors are under active verification.</AlertDescription>
        <AlertAction>
          <Button size="sm" variant="outline">
            Review
          </Button>
        </AlertAction>
      </Alert>
    </Surface>
  );
}

export function AvatarFixture() {
  return (
    <Surface title="shadcn_avatar">
      <div className="flex items-center gap-3">
        <Avatar>
          <AvatarFallback>JD</AvatarFallback>
        </Avatar>
        <div className="grid gap-1">
          <div className="font-medium text-zinc-950">Jane Doe</div>
          <div className="text-sm text-zinc-500">jane@example.com</div>
        </div>
      </div>
    </Surface>
  );
}

export function AvatarImageFixture() {
  return (
    <Surface title="shadcn_avatar_image">
      <div className="flex items-center gap-3">
        <Avatar className="h-12 w-12">
          <AvatarImage
            alt="OpenWebF avatar"
            src={`data:image/svg+xml;utf8,${encodeURIComponent(
              '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48"><rect width="48" height="48" rx="24" fill="#18181b"/><circle cx="24" cy="18" r="9" fill="#fafafa"/><path d="M10 41c3-8 11-12 14-12s11 4 14 12" fill="#d4d4d8"/></svg>',
            )}`}
          />
          <AvatarFallback>OW</AvatarFallback>
        </Avatar>
        <div className="grid gap-1">
          <div className="font-medium text-zinc-950">OpenWebF</div>
          <div className="text-sm text-zinc-500">Image avatar fixture</div>
        </div>
      </div>
    </Surface>
  );
}

export function BreadcrumbFixture() {
  return (
    <Surface title="shadcn_breadcrumb">
      <Breadcrumb>
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbLink href="#home">Home</BreadcrumbLink>
          </BreadcrumbItem>
          <BreadcrumbSeparator />
          <BreadcrumbItem>
            <BreadcrumbLink href="#projects">Projects</BreadcrumbLink>
          </BreadcrumbItem>
          <BreadcrumbSeparator />
          <BreadcrumbItem>
            <BreadcrumbPage>Official shadcn rollout</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>
    </Surface>
  );
}

export function CheckboxFixture() {
  const [checked, setChecked] = React.useState(false);

  return (
    <Surface title="shadcn_checkbox">
      <div className="flex items-center gap-3">
        <Checkbox checked={checked} onCheckedChange={setChecked} />
        <span className="text-sm text-zinc-950">Enable migration gate</span>
      </div>
      <p className="text-sm text-zinc-500">Checked: {checked ? 'yes' : 'no'}</p>
    </Surface>
  );
}

export function SwitchFixture() {
  const [checked, setChecked] = React.useState(true);

  return (
    <Surface title="shadcn_switch">
      <div className="flex items-center gap-3">
        <Switch checked={checked} onCheckedChange={setChecked} />
        <span className="text-sm text-zinc-950">Enable nightly verification</span>
      </div>
      <p className="text-sm text-zinc-500">Enabled: {checked ? 'yes' : 'no'}</p>
    </Surface>
  );
}

export function RadioGroupFixture() {
  const [value, setValue] = React.useState('starter');

  return (
    <Surface title="shadcn_radio_group">
      <RadioGroup value={value} onValueChange={setValue}>
        <div className="flex items-center gap-3">
          <RadioGroupItem value="starter" />
          <span className="text-sm text-zinc-950">Starter</span>
        </div>
        <div className="flex items-center gap-3">
          <RadioGroupItem value="pro" />
          <span className="text-sm text-zinc-950">Pro</span>
        </div>
      </RadioGroup>
      <p className="text-sm text-zinc-500">Selected tier: {value}</p>
    </Surface>
  );
}

export function ProgressFixture() {
  return (
    <Surface title="shadcn_progress">
      <div className="grid gap-2">
        <div className="flex items-center justify-between">
          <ProgressLabel>Migration progress</ProgressLabel>
          <ProgressValue>66% complete</ProgressValue>
        </div>
        <Progress value={66} />
      </div>
    </Surface>
  );
}

export function SkeletonFixture() {
  return (
    <Surface title="shadcn_skeleton">
      <div className="grid gap-3">
        <div className="text-sm text-zinc-500">Loading card preview</div>
        <Skeleton data-testid="skeleton-avatar" className="h-10 w-10 rounded-full" />
        <Skeleton data-testid="skeleton-line" className="h-4 w-40" />
        <Skeleton data-testid="skeleton-block" className="h-24 w-full" />
      </div>
    </Surface>
  );
}

export function TextareaFixture() {
  return (
    <Surface title="shadcn_textarea">
      <Textarea placeholder="Describe the rollout status" />
    </Surface>
  );
}

export function SeparatorFixture() {
  return (
    <Surface title="shadcn_separator">
      <div className="grid gap-3">
        <div className="text-sm text-zinc-950">Account</div>
        <Separator data-testid="separator-horizontal" />
        <div className="text-sm text-zinc-950">Settings</div>
      </div>
    </Surface>
  );
}

export function TabsFixture() {
  return (
    <Surface title="shadcn_tabs">
      <Tabs defaultValue="account">
        <TabsList>
          <TabsTrigger value="account">Account</TabsTrigger>
          <TabsTrigger value="security">Security</TabsTrigger>
        </TabsList>
        <TabsContent value="account">Account settings panel</TabsContent>
        <TabsContent value="security">Security settings panel</TabsContent>
      </Tabs>
    </Surface>
  );
}

export function AccordionFixture() {
  return (
    <Surface title="shadcn_accordion">
      <Accordion type="single" collapsible defaultValue="item-1">
        <AccordionItem value="item-1">
          <AccordionTrigger>What shipped?</AccordionTrigger>
          <AccordionContent>Button, input, and card are already aligned.</AccordionContent>
        </AccordionItem>
        <AccordionItem value="item-2">
          <AccordionTrigger>What changed?</AccordionTrigger>
          <AccordionContent>Overlay and selection primitives now use local official components.</AccordionContent>
        </AccordionItem>
      </Accordion>
    </Surface>
  );
}

export function PopoverFixture() {
  return (
    <Surface title="shadcn_popover">
      <Popover>
        <PopoverTrigger key="trigger">
          <Button variant="outline">Open popover</Button>
        </PopoverTrigger>
        <PopoverContent key="content">
          <PopoverHeader>
            <PopoverTitle>Popover title</PopoverTitle>
            <PopoverDescription>Popover body for official shadcn coverage.</PopoverDescription>
          </PopoverHeader>
        </PopoverContent>
      </Popover>
    </Surface>
  );
}

export function CalendarFixture() {
  const [selected, setSelected] = React.useState<Date | null>(new Date(2024, 3, 14));

  return (
    <Surface title="shadcn_calendar">
      <Calendar selected={selected ?? undefined} onSelect={setSelected} />
      <div className="text-sm text-zinc-500">Selected: {formatDate(selected)}</div>
    </Surface>
  );
}

export function SelectFixture() {
  const [value, setValue] = React.useState('starter');

  return (
    <Surface title="shadcn_select">
      <Select value={value} onValueChange={setValue}>
        <SelectTrigger key="trigger">
          <SelectValue placeholder="Pick a tier" />
        </SelectTrigger>
        <SelectContent key="content">
          <SelectGroup>
            <SelectLabel>Plans</SelectLabel>
            <SelectItem value="starter">Starter</SelectItem>
            <SelectItem value="pro">Pro</SelectItem>
            <SelectSeparator />
            <SelectItem value="enterprise">Enterprise</SelectItem>
          </SelectGroup>
        </SelectContent>
      </Select>
      <div className="text-sm text-zinc-500">Selected: {value}</div>
    </Surface>
  );
}

export function CollapsibleFixture() {
  return (
    <Surface title="shadcn_collapsible">
      <Collapsible defaultOpen={false}>
        <CollapsibleTrigger>
          <Button variant="outline">Toggle details</Button>
        </CollapsibleTrigger>
        <CollapsibleContent>
          <div className="rounded-lg border border-zinc-200 p-3 text-sm text-zinc-600">
            Hidden rollout details now use the official local collapsible primitive.
          </div>
        </CollapsibleContent>
      </Collapsible>
    </Surface>
  );
}
