{
  "name": "<%= packageName %>",
  "version": "<%= version %>",
  "description": "<%= description %>",
  "main": "dist/index.js",
  "module": "dist/index.mjs",
  "types": "dist/index.d.ts",
  "files": ["dist"],
  "scripts": {
    "build": "tsup",
    "dev": "tsup --watch",
    "clean": "rimraf dist",
    "prepublishOnly": "npm run build"
  },
  "keywords": [
    "webf",
    "flutter",
    "native",
    "module"
  ],
  "author": "",
  "license": "Apache-2.0",
  "type": "commonjs",
  "dependencies": {
    "@openwebf/webf-enterprise-typings": "^0.23.7"
  },
  "devDependencies": {
    "rimraf": "^5.0.0",
    "tsup": "^8.5.0",
    "typescript": "^5.8.3"
  },
  "publishConfig": {
    "access": "public"
  }
}

