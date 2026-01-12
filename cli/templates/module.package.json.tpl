{
  "name": "<%= packageName %>",
  "version": "<%= version %>",
  "description": "<%= description %>",
  "main": "dist/index.cjs",
  "module": "dist/index.mjs",
  "types": "dist/index.d.mts",
  "exports": {
    ".": {
      "import": {
        "types": "./dist/index.d.mts",
        "default": "./dist/index.mjs"
      },
      "require": {
        "types": "./dist/index.d.cts",
        "default": "./dist/index.cjs"
      }
    }
  },
  "files": ["dist"],
  "scripts": {
    "build": "tsdown",
    "dev": "tsdown --watch",
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
    "tsdown": "^0.19.0",
    "typescript": "^5.8.3"
  },
  "publishConfig": {
    "access": "public"
  }
}
