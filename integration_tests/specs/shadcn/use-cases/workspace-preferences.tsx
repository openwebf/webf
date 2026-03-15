/** @jsxImportSource react */
import React from 'react';
import styles from '../_shared/globals.css';
import { withShadcnSpec } from '../_shared/test-utils';
import { defaultContactEmail, deliveryChannels, initialPreferences } from '../../../shadcn_support/workspace_preferences/data';
import { Button } from '../../../shadcn_support/workspace_preferences/components/button';
import { Card, CardDescription, CardHeader, CardTitle } from '../../../shadcn_support/workspace_preferences/components/card';
import { PreferenceRow } from '../../../shadcn_support/workspace_preferences/components/preference-row';
import type { PreferenceId, PreferenceItem } from '../../../shadcn_support/workspace_preferences/types';

function buildSignature(contactEmail: string, preferences: PreferenceItem[]) {
  return JSON.stringify({
    contactEmail,
    preferences: preferences.map((item) => ({ id: item.id, enabled: item.enabled })),
  });
}

function WorkspacePreferencesCase() {
  const [contactEmail, setContactEmail] = React.useState(defaultContactEmail);
  const [preferences, setPreferences] = React.useState<PreferenceItem[]>(initialPreferences);
  const [savedSignature, setSavedSignature] = React.useState(() => buildSignature(defaultContactEmail, initialPreferences));
  const [lastSavedLabel, setLastSavedLabel] = React.useState(`Saved for ${defaultContactEmail}`);

  const enabledCount = preferences.filter((item) => item.enabled).length;
  const dirty = buildSignature(contactEmail, preferences) !== savedSignature;

  const togglePreference = (id: PreferenceId) => {
    setPreferences((items) =>
      items.map((item) => (item.id === id ? { ...item, enabled: !item.enabled } : item)),
    );
    setLastSavedLabel('Unsaved changes');
  };

  const handleSave = () => {
    setSavedSignature(buildSignature(contactEmail, preferences));
    setLastSavedLabel(`Saved for ${contactEmail}`);
  };

  return (
    <div className="shadcn-spec-page">
      <div className="shadcn-stack">
        <Card data-testid="workspace-preferences">
          <CardHeader>
            <div className="shadcn-stack">
              <span className="shadcn-badge">Workspace Preferences</span>
              <div>
                <CardTitle>Incident response notifications</CardTitle>
                <CardDescription>
                  A realistic shadcn-style settings panel built with local React dependency files.
                </CardDescription>
              </div>
            </div>
            <span
              className={dirty ? 'shadcn-badge shadcn-badge-warning' : 'shadcn-badge shadcn-badge-success'}
              data-testid="save-state"
            >
              {dirty ? 'Needs review' : 'Saved'}
            </span>
          </CardHeader>
          <div className="shadcn-divider" />
          <div className="shadcn-stat-row">
            <div className="shadcn-stat-card">
              <p className="shadcn-stat-label">Enabled rules</p>
              <p className="shadcn-stat-value" data-testid="enabled-count">
                {enabledCount} / {preferences.length}
              </p>
            </div>
            <div className="shadcn-stat-card">
              <p className="shadcn-stat-label">Delivery channels</p>
              <p className="shadcn-stat-value" data-testid="channel-list">
                {deliveryChannels.join(' / ')}
              </p>
            </div>
          </div>
        </Card>

        <Card>
          <div className="shadcn-stack">
            <div>
              <label className="shadcn-field-label" htmlFor="contact-email">
                Escalation contact
              </label>
              <input
                className="shadcn-input"
                data-testid="contact-email"
                id="contact-email"
                onChange={(event) => setContactEmail((event.target as HTMLInputElement).value)}
                type="email"
                value={contactEmail}
              />
              <p className="shadcn-input-hint">Critical alerts will use this mailbox first.</p>
            </div>
            <div className="shadcn-divider" />
            <div className="shadcn-meta-list">
              {preferences.map((item) => (
                <PreferenceRow item={item} key={item.id} onToggle={togglePreference} />
              ))}
            </div>
            <div className="shadcn-divider" />
            <div className="shadcn-meta-row">
              <p className="shadcn-input-hint" data-testid="last-saved-label">
                {lastSavedLabel}
              </p>
              <Button data-testid="save-button" onClick={handleSave}>
                Save preferences
              </Button>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
}

describe('shadcn use cases: workspace preferences', () => {
  it('renders a composed settings panel from local React dependency files', async () => {
    styles.use();

    try {
      await withShadcnSpec(
        <WorkspacePreferencesCase />,
        async ({ container, flush, waitForSelector }) => {
          await waitForSelector<HTMLElement>('[data-testid="workspace-preferences"]');

          const enabledCount = container.querySelector('[data-testid="enabled-count"]') as HTMLParagraphElement | null;
          const channelList = container.querySelector('[data-testid="channel-list"]') as HTMLParagraphElement | null;
          const saveState = container.querySelector('[data-testid="save-state"]') as HTMLSpanElement | null;
          const emailInput = container.querySelector('[data-testid="contact-email"]') as HTMLInputElement | null;
          const saveButton = container.querySelector('[data-testid="save-button"]') as HTMLButtonElement | null;
          const lastSavedLabel = container.querySelector('[data-testid="last-saved-label"]') as HTMLParagraphElement | null;
          const weeklyDigestToggle = container.querySelector('[data-testid="toggle-weekly_digest"]') as HTMLButtonElement | null;
          const incidentsToggle = container.querySelector('[data-testid="toggle-incidents"]') as HTMLButtonElement | null;

          expect(enabledCount).not.toBeNull();
          expect(channelList).not.toBeNull();
          expect(saveState).not.toBeNull();
          expect(emailInput).not.toBeNull();
          expect(saveButton).not.toBeNull();
          expect(lastSavedLabel).not.toBeNull();
          expect(weeklyDigestToggle).not.toBeNull();
          expect(incidentsToggle).not.toBeNull();

          expect(enabledCount!.textContent).toContain('2 / 3');
          expect(channelList!.textContent).toContain('Email / Slack');
          expect(saveState!.textContent).toContain('Saved');
          expect(emailInput!.value).toBe(defaultContactEmail);

          weeklyDigestToggle!.click();
          await flush(2);
          expect(enabledCount!.textContent).toContain('3 / 3');
          expect(saveState!.textContent).toContain('Needs review');
          expect(weeklyDigestToggle!.getAttribute('aria-pressed')).toBe('true');

          incidentsToggle!.click();
          await flush(2);
          expect(enabledCount!.textContent).toContain('2 / 3');
          expect(incidentsToggle!.getAttribute('aria-pressed')).toBe('false');

          saveButton!.click();
          await flush(2);

          expect(lastSavedLabel!.textContent).toContain(defaultContactEmail);
          expect(saveState!.textContent).toContain('Saved');

          await snapshot();
        },
        { framesToWait: 2, width: 320, minHeight: 420 },
      );
    } finally {
      styles.unuse();
    }
  });
});
