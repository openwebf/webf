import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterLucideIcon, LucideIcons } from '@openwebf/react-lucide-icons';

import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuSub,
  DropdownMenuSubContent,
  DropdownMenuSubTrigger,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Input } from '@/components/ui/input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';

export const ShadcnSpikePage: React.FC = () => {
  const [bookmarksBar, setBookmarksBar] = useState(true);
  const [position, setPosition] = useState('bottom');

  return (
    <div className="min-h-screen bg-[linear-gradient(180deg,#f6f4ef_0%,#ffffff_48%,#f3f6fb_100%)] text-foreground">
      <WebFListView className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-4 py-8">
        <section className="rounded-3xl border border-black/5 bg-white/90 p-6 shadow-[0_20px_60px_rgba(15,23,42,0.08)]">
          <div className="mb-4 flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-primary text-primary-foreground">
              <FlutterLucideIcon name={LucideIcons.sparkles} className="text-xl text-primary-foreground" />
            </div>
            <div>
              <h1 className="text-2xl font-semibold tracking-tight">Official shadcn/ui Spike</h1>
              <p className="text-sm text-muted-foreground">
                First compatibility pass for source-based shadcn components in `use_cases`.
              </p>
            </div>
          </div>

          <div className="grid gap-3 rounded-2xl border border-dashed border-border bg-muted/40 p-4 text-sm text-muted-foreground">
            <div>Targets in this spike: button, input, dialog, dropdown-menu, tabs.</div>
            <div>What to validate next in WebF: portal mount, focus handling, keyboard nav, overlay positioning.</div>
          </div>
        </section>

        <section className="rounded-3xl border border-border bg-card p-6 shadow-sm">
          <h2 className="mb-4 text-lg font-semibold">Button + Input</h2>
          <div className="flex flex-wrap gap-3">
            <Button>Primary Action</Button>
            <Button variant="secondary">Secondary</Button>
            <Button variant="outline">Outline</Button>
            <Button variant="ghost">Ghost</Button>
            <Button variant="destructive">Delete</Button>
          </div>

          <div className="mt-5 grid gap-3">
            <Input placeholder="Official shadcn input in WebF" />
            <Input type="email" placeholder="team@openwebf.com" />
          </div>
        </section>

        <section className="rounded-3xl border border-border bg-card p-6 shadow-sm">
          <h2 className="mb-4 text-lg font-semibold">Dialog</h2>
          <Dialog>
            <DialogTrigger asChild>
              <Button>Open Dialog</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Compatibility checkpoint</DialogTitle>
                <DialogDescription>
                  This dialog uses Radix portal and focus management instead of the legacy Flutter wrapper.
                </DialogDescription>
              </DialogHeader>
              <div className="grid gap-3 py-4">
                <Input placeholder="Name" />
                <Input placeholder="Project" />
              </div>
              <DialogFooter>
                <Button variant="outline">Cancel</Button>
                <Button>Save</Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </section>

        <section className="rounded-3xl border border-border bg-card p-6 shadow-sm">
          <h2 className="mb-4 text-lg font-semibold">Tabs</h2>
          <Tabs defaultValue="account" className="w-full">
            <TabsList>
              <TabsTrigger value="account">Account</TabsTrigger>
              <TabsTrigger value="integration">Integration</TabsTrigger>
              <TabsTrigger value="runtime">Runtime</TabsTrigger>
            </TabsList>
            <TabsContent value="account">
              <p className="text-sm text-muted-foreground">Baseline interaction and active-state rendering.</p>
            </TabsContent>
            <TabsContent value="integration">
              <p className="text-sm text-muted-foreground">Checks roving focus and tab switching semantics.</p>
            </TabsContent>
            <TabsContent value="runtime">
              <p className="text-sm text-muted-foreground">Used to confirm Radix state sync behaves in WebF.</p>
            </TabsContent>
          </Tabs>
        </section>

        <section className="rounded-3xl border border-border bg-card p-6 shadow-sm">
          <h2 className="mb-4 text-lg font-semibold">Dropdown Menu</h2>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline">
                Open Menu
                <FlutterLucideIcon name={LucideIcons.chevronDown} className="text-base" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="start">
              <DropdownMenuLabel>Display</DropdownMenuLabel>
              <DropdownMenuSeparator />
              <DropdownMenuCheckboxItem checked={bookmarksBar} onCheckedChange={(checked) => setBookmarksBar(checked === true)}>
                Bookmarks bar
              </DropdownMenuCheckboxItem>
              <DropdownMenuSeparator />
              <DropdownMenuLabel>Side</DropdownMenuLabel>
              <DropdownMenuRadioGroup value={position} onValueChange={setPosition}>
                <DropdownMenuRadioItem value="top">Top</DropdownMenuRadioItem>
                <DropdownMenuRadioItem value="right">Right</DropdownMenuRadioItem>
                <DropdownMenuRadioItem value="bottom">Bottom</DropdownMenuRadioItem>
              </DropdownMenuRadioGroup>
              <DropdownMenuSeparator />
              <DropdownMenuSub>
                <DropdownMenuSubTrigger>More actions</DropdownMenuSubTrigger>
                <DropdownMenuSubContent>
                  <DropdownMenuItem>Inspect overlay</DropdownMenuItem>
                  <DropdownMenuItem>Check keyboard navigation</DropdownMenuItem>
                </DropdownMenuSubContent>
              </DropdownMenuSub>
              <DropdownMenuSeparator />
              <DropdownMenuItem>Close</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </section>
      </WebFListView>
    </div>
  );
};
