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
  "files": ["dist", "index.d.ts", "README.md"],
  "scripts": {
    "build": "tsdown"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "type": "commonjs",
  "peerDependencies": {
    "vue": "^3.0.0",
    "@openwebf/vue-core-ui": "^0.24.0"
  },
  "devDependencies": {
    "@openwebf/vue-core-ui": "^0.24.0",
    "tsdown": "^0.19.0",
    "typescript": "^5.8.3",
    "vue": "^3.0.0"
  }
}
