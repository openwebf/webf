export type PreferenceId = 'mentions' | 'incidents' | 'weekly_digest';

export type PreferenceItem = {
  id: PreferenceId;
  title: string;
  description: string;
  enabled: boolean;
};
