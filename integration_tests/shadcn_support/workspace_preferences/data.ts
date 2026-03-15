import type { PreferenceItem } from './types';

export const defaultContactEmail = 'ops@canvas.dev';

export const deliveryChannels = ['Email', 'Slack'];

export const initialPreferences: PreferenceItem[] = [
  {
    id: 'mentions',
    title: 'Team mentions',
    description: 'Ping the channel owner when teammates mention the workspace in a thread.',
    enabled: true,
  },
  {
    id: 'incidents',
    title: 'Incident alerts',
    description: 'Send a high-priority update when an incident changes severity.',
    enabled: true,
  },
  {
    id: 'weekly_digest',
    title: 'Weekly digest',
    description: 'Bundle low-priority reminders into one Friday summary.',
    enabled: false,
  },
];
