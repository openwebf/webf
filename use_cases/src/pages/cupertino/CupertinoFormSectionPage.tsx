import React, {useState} from 'react';
import {WebFListView} from '@openwebf/react-core-ui';
import {
  FlutterCupertinoFormSection,
  FlutterCupertinoFormRow,
  FlutterCupertinoSwitch,
} from '@openwebf/react-cupertino-ui';
import {WebFSlot} from '../../components/WebFSlot';

export const CupertinoFormSectionPage: React.FC = () => {
  const [username, setUsername] = useState('john.appleseed');
  const [email, setEmail] = useState('');
  const [emailError, setEmailError] = useState<string | null>(null);
  const [primaryNotifications, setPrimaryNotifications] = useState(true);
  const [marketingEmails, setMarketingEmails] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);

  const handleEmailBlur = () => {
    if (email && !email.includes('@')) {
      setEmailError('Please enter a valid email address.');
    } else {
      setEmailError(null);
    }
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
        <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">
          Cupertino Form Section
        </h1>
        <p className="text-fg-secondary mb-6">
          iOS-style grouped form sections and rows built with WebF and Flutter.
        </p>

        {/* Quick Start */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Quick Start</h2>
          <p className="text-fg-secondary mb-4">
            Use <code>FlutterCupertinoFormSection</code> with nested <code>FlutterCupertinoFormRow</code>{' '}
            to build settings-style forms. Each row uses slots for the prefix label, helper text, and error text.
          </p>

          <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
            <div className="bg-white rounded-2xl overflow-hidden">
              <FlutterCupertinoFormSection insetGrouped>
                <WebFSlot name="header">
                  <div className="px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">
                    Account Settings
                  </div>
                </WebFSlot>

                <FlutterCupertinoFormRow>
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Username</span>
                  </WebFSlot>
                  <input
                    className="flex-1 px-3 py-2 text-sm rounded-lg border border-line bg-surface focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Enter username"
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                  />
                </FlutterCupertinoFormRow>

                <FlutterCupertinoFormRow>
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Email</span>
                  </WebFSlot>
                  <input
                    className="flex-1 px-3 py-2 text-sm rounded-lg border border-line bg-surface focus:outline-none focus:ring-2 focus:ring-blue-500"
                    type="email"
                    placeholder="Enter email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    onBlur={handleEmailBlur}
                  />
                  <WebFSlot name="helper">
                      <span className="block mt-1 text-xs text-gray-500">
                        We&apos;ll send a verification link.
                      </span>
                  </WebFSlot>
                  {emailError && (
                    <WebFSlot name="error">
                      <span className="block mt-1 text-xs text-red-600">{emailError}</span>
                    </WebFSlot>
                  )}
                </FlutterCupertinoFormRow>

                <FlutterCupertinoFormRow>
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Notifications</span>
                  </WebFSlot>
                  <FlutterCupertinoSwitch
                    checked={primaryNotifications}
                    onChange={(e) => setPrimaryNotifications(e.detail)}
                  />
                  <WebFSlot name="helper">
                      <span className="block mt-1 text-xs text-gray-500">
                        {primaryNotifications ? 'Enabled for this account.' : 'Notifications are off.'}
                      </span>
                  </WebFSlot>
                </FlutterCupertinoFormRow>

                <WebFSlot name="footer">
                  <div className="px-4 py-2 text-xs text-gray-500">
                    These settings apply to your main WebF account.
                  </div>
                </WebFSlot>
              </FlutterCupertinoFormSection>
            </div>
          </div>

          <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`import {
  FlutterCupertinoFormSection,
  FlutterCupertinoFormRow,
} from '@openwebf/react-cupertino-ui';

export function AccountSettingsSection() {
  return (
    <FlutterCupertinoFormSection insetGrouped>
      <span slotName="header">Account Settings</span>

      <FlutterCupertinoFormRow>
        <span slotName="prefix">Username</span>
        <input placeholder="Enter username" />
      </FlutterCupertinoFormRow>

      <FlutterCupertinoFormRow>
        <span slotName="prefix">Email</span>
        <input type="email" placeholder="Enter email" />
        <span slotName="helper">We will send a verification link.</span>
      </FlutterCupertinoFormRow>

      <FlutterCupertinoFormRow>
        <span slotName="prefix">Notifications</span>
        {/* Use any WebF-compatible control, e.g. FlutterCupertinoSwitch */}
        <flutter-cupertino-switch />
      </FlutterCupertinoFormRow>

      <span slotName="footer">These settings apply to your main account.</span>
    </FlutterCupertinoFormSection>
  );
}`}</code>
              </pre>
          </div>
        </section>

        {/* Slots Demo */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Row Slots</h2>
          <p className="text-fg-secondary mb-4">
            <code>FlutterCupertinoFormRow</code> supports slots for prefix, helper, and error text. Use them to build
            rich, accessible form rows.
          </p>

          <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
            <div className="bg-white rounded-2xl overflow-hidden">
              <FlutterCupertinoFormSection insetGrouped>
                <WebFSlot name="header">
                  <div className="px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">
                    Profile Details
                  </div>
                </WebFSlot>

                <FlutterCupertinoFormRow>
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Language</span>
                  </WebFSlot>
                  <span className="text-sm text-gray-800">English</span>
                </FlutterCupertinoFormRow>

                <FlutterCupertinoFormRow>
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Two-Factor Auth</span>
                  </WebFSlot>
                  <FlutterCupertinoSwitch
                    checked={marketingEmails}
                    onChange={(e) => setMarketingEmails(e.detail)}
                  />
                  <WebFSlot name="helper">
                      <span className="block mt-1 text-xs text-gray-500">
                        Adds an extra layer of security to your account.
                      </span>
                  </WebFSlot>
                </FlutterCupertinoFormRow>

                <FlutterCupertinoFormRow>
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Password</span>
                  </WebFSlot>
                  <span className="text-sm text-blue-600 cursor-pointer select-none">Change...</span>
                  <WebFSlot name="helper">
                      <span className="block mt-1 text-xs text-gray-500">
                        Use at least 8 characters with a number and a symbol.
                      </span>
                  </WebFSlot>
                  {!rememberMe && (
                    <WebFSlot name="error">
                        <span className="block mt-1 text-xs text-red-600">
                          Remember me is disabled; you may be signed out more often.
                        </span>
                    </WebFSlot>
                  )}
                </FlutterCupertinoFormRow>

                <FlutterCupertinoFormRow>
                  <WebFSlot name="prefix">
                    <span className="text-sm text-gray-700">Remember Me</span>
                  </WebFSlot>
                  <FlutterCupertinoSwitch
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.detail)}
                  />
                </FlutterCupertinoFormRow>
              </FlutterCupertinoFormSection>
            </div>
          </div>

          <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`<FlutterCupertinoFormRow>
  <span slotName="prefix">Language</span>
  <span>English</span>
</FlutterCupertinoFormRow>

<FlutterCupertinoFormRow>
  <span slotName="prefix">Password</span>
  <button>Change...</button>
  <span slotName="helper">Use at least 8 characters.</span>
  <span slotName="error">Password is too weak.</span>
</FlutterCupertinoFormRow>`}</code>
              </pre>
          </div>
        </section>

        {/* Layout & Props */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Layout & Props</h2>
          <p className="text-fg-secondary mb-4">
            <code>FlutterCupertinoFormSection</code> mirrors Flutter&apos;s <code>CupertinoFormSection</code>. Use{' '}
            <code>insetGrouped</code> for the modern inset style and <code>clipBehavior</code> to control how content
            is clipped to the rounded corners.
          </p>

          <div className="grid md:grid-cols-2 gap-4 mb-4">
            <div className="bg-surface-secondary rounded-xl p-6 border border-line">
              <h3 className="font-semibold text-fg-primary mb-3 text-sm">Plain Grouped</h3>
              <div className="bg-white rounded-xl overflow-hidden">
                <FlutterCupertinoFormSection>
                  <WebFSlot name="header">
                    <div className="px-4 py-2 text-xs font-semibold text-gray-500 uppercase">
                      Plain Grouped
                    </div>
                  </WebFSlot>
                  <FlutterCupertinoFormRow>
                    <WebFSlot name="prefix">
                      <span className="text-sm text-gray-700">Option A</span>
                    </WebFSlot>
                    <span className="text-sm text-gray-800">Enabled</span>
                  </FlutterCupertinoFormRow>
                  <FlutterCupertinoFormRow>
                    <WebFSlot name="prefix">
                      <span className="text-sm text-gray-700">Option B</span>
                    </WebFSlot>
                    <span className="text-sm text-gray-800">Disabled</span>
                  </FlutterCupertinoFormRow>
                </FlutterCupertinoFormSection>
              </div>
            </div>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line">
              <h3 className="font-semibold text-fg-primary mb-3 text-sm">Inset Grouped</h3>
              <div className="bg-transparent">
                <FlutterCupertinoFormSection insetGrouped>
                  <WebFSlot name="header">
                    <div className="px-4 py-2 text-xs font-semibold text-gray-500 uppercase">
                      Inset Grouped
                    </div>
                  </WebFSlot>
                  <FlutterCupertinoFormRow>
                    <WebFSlot name="prefix">
                      <span className="text-sm text-gray-700">Notifications</span>
                    </WebFSlot>
                    <span className="text-sm text-gray-800">On</span>
                  </FlutterCupertinoFormRow>
                  <FlutterCupertinoFormRow>
                    <WebFSlot name="prefix">
                      <span className="text-sm text-gray-700">Sounds</span>
                    </WebFSlot>
                    <span className="text-sm text-gray-800">Default</span>
                  </FlutterCupertinoFormRow>
                </FlutterCupertinoFormSection>
              </div>
            </div>
          </div>

          <div className="bg-gray-50 rounded-lg p-4 border border-gray-200 mb-4">
              <pre className="text-sm overflow-x-auto">
                <code>{`<FlutterCupertinoFormSection
  insetGrouped
  clipBehavior="hardEdge"  // 'none' | 'hardEdge' | 'antiAlias' | 'antiAliasWithSaveLayer'
>
  {/* header, rows, footer */}
</FlutterCupertinoFormSection>`}</code>
              </pre>
          </div>

          <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-2 text-sm text-fg-secondary">
            <div>
              <code className="bg-gray-100 px-2 py-0.5 rounded">insetGrouped?: boolean</code> – use inset grouped
              appearance (like modern iOS Settings).
            </div>
            <div>
              <code className="bg-gray-100 px-2 py-0.5 rounded">clipBehavior?: string</code> – how content is clipped
              to rounded corners. One of <code>'none'</code>, <code>'hardEdge'</code>,{' '}
              <code>'antiAlias'</code>, <code>'antiAliasWithSaveLayer'</code>.
            </div>
            <div>
              <code className="bg-gray-100 px-2 py-0.5 rounded">style / className</code> – use standard React props to
              tweak margins, background color, and radius.
            </div>
          </div>
        </section>

        {/* Styling */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Styling</h2>
          <p className="text-fg-secondary mb-4">
            While Flutter manages most layout and background styling, you can still adjust margins, radius, and
            colors via <code>style</code> / <code>className</code> on the React components and inner elements.
          </p>

          <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4">
            <FlutterCupertinoFormSection
              insetGrouped
              clipBehavior="hardEdge"
              style={{
                marginTop: 20,
                marginLeft: 10,
                marginRight: 10,
                backgroundColor: '#e0f7fa',
                borderRadius: 15,
              }}
            >
              <WebFSlot name="header">
                  <span
                    style={{color: '#00796b', fontWeight: 'bold', paddingLeft: 16, fontSize: 12}}
                  >
                    Custom Style Section
                  </span>
              </WebFSlot>

              <FlutterCupertinoFormRow style={{paddingLeft: 16, paddingRight: 16}}>
                <WebFSlot name="prefix">
                  <span>Item 1</span>
                </WebFSlot>
                <span>Value 1</span>
              </FlutterCupertinoFormRow>

              <FlutterCupertinoFormRow style={{paddingLeft: 16, paddingRight: 16}}>
                <WebFSlot name="prefix">
                  <span>Item 2</span>
                </WebFSlot>
                <span>Value 2</span>
              </FlutterCupertinoFormRow>
            </FlutterCupertinoFormSection>
          </div>

          <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`<FlutterCupertinoFormSection
  insetGrouped
  style={{
    marginTop: 20,
    marginLeft: 10,
    marginRight: 10,
    backgroundColor: '#e0f7fa',
    borderRadius: 15,
  }}
>
  <span
    slotName="header"
    style={{ color: '#00796b', fontWeight: 'bold', paddingLeft: 16 }}
  >
    Custom Style Section
  </span>

  <FlutterCupertinoFormRow style={{ paddingLeft: 16, paddingRight: 16 }}>
    <span slotName="prefix">Item 1</span>
    <span>Value 1</span>
  </FlutterCupertinoFormRow>
</FlutterCupertinoFormSection>`}</code>
              </pre>
          </div>
        </section>

        {/* Notes & Best Practices */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Notes & Best Practices</h2>
          <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded space-y-2 text-sm text-gray-700">
            <p>
              <code>FlutterCupertinoFormSection</code> and <code>FlutterCupertinoFormRow</code> are the WebF
              counterparts to Flutter&apos;s <code>CupertinoFormSection</code> / <code>CupertinoFormRow</code>.
            </p>
            <p>
              Layout is primarily controlled by Flutter (margins, separators, background). Use <code>style</code> for
              fine-tuning rather than rebuilding the layout in CSS.
            </p>
            <p>
              Rows are simple containers – they don&apos;t emit their own events. Place interactive controls (inputs,
              switches, pickers) inside rows and handle events on those controls.
            </p>
            <p>
              Prefer concise prefix labels (1–2 words) and keep helper / error text short and specific for better
              readability on small screens.
            </p>
          </div>
        </section>
      </WebFListView>
    </div>
  );
};

