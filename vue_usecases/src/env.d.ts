/// <reference types="vite/client" />

import '@openwebf/vue-cupertino-ui';

declare global {
  // WebF runtime hook used by @openwebf/vue-router
  // eslint-disable-next-line no-var
  var webf: any;
}
