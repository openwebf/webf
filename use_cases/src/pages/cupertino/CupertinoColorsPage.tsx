import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { CupertinoColors, CupertinoIcons } from '@openwebf/react-cupertino-ui';

const CupertinoColorsPage: React.FC = () => {
  const ColorSwatch = ({ name, color, description }: { name: string; color: string; description?: string }) => (
    <div className="flex items-center gap-4 p-3 bg-surface rounded-lg border border-line">
      <div
        className="w-16 h-16 rounded-lg shadow-md flex-shrink-0 border border-line"
        style={{ backgroundColor: color }}
      />
      <div className="flex-1 min-w-0">
        <div className="text-base font-medium text-fg-primary">{name}</div>
        <div className="text-sm text-fg-secondary font-mono">{color}</div>
        {description && <div className="text-xs text-fg-secondary mt-1">{description}</div>}
      </div>
    </div>
  );

  const ColorGroup = ({ title, children }: { title: string; children: React.ReactNode }) => (
    <div className="mb-6">
      <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">{title}</h2>
      <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-3">
        {children}
      </div>
    </div>
  );

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">Cupertino Colors</h1>
          <p className="text-fg-secondary mb-6">
            Static and dynamic iOS color palette from Flutter's Cupertino design system
          </p>

          {/* Primary System Colors */}
          <ColorGroup title="Primary System Colors">
            <ColorSwatch
              name="systemBlue"
              color={CupertinoColors.systemBlue}
              description="Default iOS blue, used for links and primary actions"
            />
            <ColorSwatch
              name="systemGreen"
              color={CupertinoColors.systemGreen}
              description="Success and positive actions"
            />
            <ColorSwatch
              name="systemIndigo"
              color={CupertinoColors.systemIndigo}
              description="Deep blue-purple"
            />
            <ColorSwatch
              name="systemOrange"
              color={CupertinoColors.systemOrange}
              description="Warnings and highlights"
            />
            <ColorSwatch
              name="systemPink"
              color={CupertinoColors.systemPink}
              description="Accent color"
            />
            <ColorSwatch
              name="systemPurple"
              color={CupertinoColors.systemPurple}
              description="Creative and media"
            />
            <ColorSwatch
              name="systemRed"
              color={CupertinoColors.systemRed}
              description="Errors and destructive actions"
            />
            <ColorSwatch
              name="systemTeal"
              color={CupertinoColors.systemTeal}
              description="Calm and neutral"
            />
            <ColorSwatch
              name="systemYellow"
              color={CupertinoColors.systemYellow}
              description="Attention and energy"
            />
          </ColorGroup>

          {/* Grayscale Colors */}
          <ColorGroup title="Grayscale System Colors">
            <ColorSwatch
              name="systemGrey"
              color={CupertinoColors.systemGrey}
              description="Base gray"
            />
            <ColorSwatch
              name="systemGrey2"
              color={CupertinoColors.systemGrey2}
              description="Lighter gray"
            />
            <ColorSwatch
              name="systemGrey3"
              color={CupertinoColors.systemGrey3}
              description="Light gray"
            />
            <ColorSwatch
              name="systemGrey4"
              color={CupertinoColors.systemGrey4}
              description="Very light gray"
            />
            <ColorSwatch
              name="systemGrey5"
              color={CupertinoColors.systemGrey5}
              description="Extra light gray"
            />
            <ColorSwatch
              name="systemGrey6"
              color={CupertinoColors.systemGrey6}
              description="Nearly white gray"
            />
          </ColorGroup>

          {/* Label Colors */}
          <ColorGroup title="Label Colors">
            <ColorSwatch
              name="label"
              color={CupertinoColors.label}
              description="Primary text and content"
            />
            <ColorSwatch
              name="secondaryLabel"
              color={CupertinoColors.secondaryLabel}
              description="Secondary text"
            />
            <ColorSwatch
              name="tertiaryLabel"
              color={CupertinoColors.tertiaryLabel}
              description="Tertiary text"
            />
            <ColorSwatch
              name="quaternaryLabel"
              color={CupertinoColors.quaternaryLabel}
              description="Quaternary text"
            />
          </ColorGroup>

          {/* Fill Colors */}
          <ColorGroup title="Fill Colors">
            <ColorSwatch
              name="systemFill"
              color={CupertinoColors.systemFill}
              description="Primary fill for UI elements"
            />
            <ColorSwatch
              name="secondarySystemFill"
              color={CupertinoColors.secondarySystemFill}
              description="Secondary fill"
            />
            <ColorSwatch
              name="tertiarySystemFill"
              color={CupertinoColors.tertiarySystemFill}
              description="Tertiary fill"
            />
            <ColorSwatch
              name="quaternarySystemFill"
              color={CupertinoColors.quaternarySystemFill}
              description="Quaternary fill"
            />
          </ColorGroup>

          {/* Background Colors */}
          <ColorGroup title="Background Colors">
            <ColorSwatch
              name="systemBackground"
              color={CupertinoColors.systemBackground}
              description="Primary background"
            />
            <ColorSwatch
              name="secondarySystemBackground"
              color={CupertinoColors.secondarySystemBackground}
              description="Secondary background"
            />
            <ColorSwatch
              name="tertiarySystemBackground"
              color={CupertinoColors.tertiarySystemBackground}
              description="Tertiary background"
            />
          </ColorGroup>

          {/* Grouped Background Colors */}
          <ColorGroup title="Grouped Background Colors">
            <ColorSwatch
              name="systemGroupedBackground"
              color={CupertinoColors.systemGroupedBackground}
              description="Background for grouped content"
            />
            <ColorSwatch
              name="secondarySystemGroupedBackground"
              color={CupertinoColors.secondarySystemGroupedBackground}
              description="Secondary grouped background"
            />
            <ColorSwatch
              name="tertiarySystemGroupedBackground"
              color={CupertinoColors.tertiarySystemGroupedBackground}
              description="Tertiary grouped background"
            />
          </ColorGroup>

          {/* Separator Colors */}
          <ColorGroup title="Separator Colors">
            <ColorSwatch
              name="separator"
              color={CupertinoColors.separator}
              description="Thin lines and dividers"
            />
            <ColorSwatch
              name="opaqueSeparator"
              color={CupertinoColors.opaqueSeparator}
              description="Opaque separator"
            />
          </ColorGroup>

          {/* Link and Placeholder */}
          <ColorGroup title="Link & Placeholder">
            <ColorSwatch
              name="link"
              color={CupertinoColors.link}
              description="Hyperlinks and tappable text"
            />
            <ColorSwatch
              name="placeholderText"
              color={CupertinoColors.placeholderText}
              description="Placeholder text in inputs"
            />
          </ColorGroup>

          {/* Standard Colors */}
          <ColorGroup title="Standard Colors">
            <ColorSwatch
              name="black"
              color={CupertinoColors.black}
              description="Pure black"
            />
            <ColorSwatch
              name="white"
              color={CupertinoColors.white}
              description="Pure white"
            />
            <ColorSwatch
              name="darkBackgroundGray"
              color={CupertinoColors.darkBackgroundGray}
              description="Dark mode background"
            />
            <ColorSwatch
              name="lightBackgroundGray"
              color={CupertinoColors.lightBackgroundGray}
              description="Light mode background"
            />
          </ColorGroup>

          {/* Active Colors */}
          <ColorGroup title="Active & Interaction Colors">
            <ColorSwatch
              name="activeBlue"
              color={CupertinoColors.activeBlue}
              description="Active blue state"
            />
            <ColorSwatch
              name="activeGreen"
              color={CupertinoColors.activeGreen}
              description="Active green state"
            />
            <ColorSwatch
              name="activeOrange"
              color={CupertinoColors.activeOrange}
              description="Active orange state"
            />
          </ColorGroup>

          {/* Inactive Colors */}
          <ColorGroup title="Inactive Colors">
            <ColorSwatch
              name="inactiveGray"
              color={CupertinoColors.inactiveGray}
              description="Disabled and inactive elements"
            />
          </ColorGroup>

          {/* Destructive Colors */}
          <ColorGroup title="Destructive Colors">
            <ColorSwatch
              name="destructiveRed"
              color={CupertinoColors.destructiveRed}
              description="Destructive actions and warnings"
            />
          </ColorGroup>

          {/* Example Usage */}
          <div className="mb-6">
            <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-blue-500">Usage Example</h2>
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-4">
              <div>
                <p className="text-sm text-fg-secondary mb-3">Using CupertinoColors in your components:</p>
                <pre className="bg-surface p-4 rounded-lg text-xs overflow-x-auto border border-line">
{`import { CupertinoColors } from '@openwebf/react-cupertino-ui';

// In your component
<div style={{
  color: CupertinoColors.label,
  backgroundColor: CupertinoColors.systemBackground
}}>
  Primary content
</div>

<button style={{
  backgroundColor: CupertinoColors.systemBlue,
  color: CupertinoColors.white
}}>
  Action Button
</button>`}
                </pre>
              </div>

              <div>
                <p className="text-sm text-fg-secondary mb-3">Live Example:</p>
                <div className="flex flex-wrap gap-3">
                  <button
                    className="px-4 py-2 rounded-lg font-medium"
                    style={{
                      backgroundColor: CupertinoColors.systemBlue,
                      color: CupertinoColors.white
                    }}
                  >
                    Primary
                  </button>
                  <button
                    className="px-4 py-2 rounded-lg font-medium"
                    style={{
                      backgroundColor: CupertinoColors.systemGreen,
                      color: CupertinoColors.white
                    }}
                  >
                    Success
                  </button>
                  <button
                    className="px-4 py-2 rounded-lg font-medium"
                    style={{
                      backgroundColor: CupertinoColors.destructiveRed,
                      color: CupertinoColors.white
                    }}
                  >
                    Danger
                  </button>
                  <button
                    className="px-4 py-2 rounded-lg font-medium"
                    style={{
                      backgroundColor: CupertinoColors.systemGrey,
                      color: CupertinoColors.white
                    }}
                  >
                    Secondary
                  </button>
                </div>
              </div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};

export default CupertinoColorsPage;

