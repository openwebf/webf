{
  "name": "<%= packageName %>",
  "version": "<%= version %>",
  "description": "<%= description %>",
  "main": "dist/index.js",
  "module": "dist/index.mjs",
  "types": "dist/index.d.ts",
  "files": ["dist", "README.md"],
  "scripts": {
    "build": "tsup"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "type": "commonjs",
  "peerDependencies": {
    "react": ">=16.8.0",
    "react-dom": ">=16.8.0",
    "@openwebf/react-core-ui": "^0.24.1"
  },
  "devDependencies": {
    "@openwebf/react-core-ui": "^0.24.1",
    "@types/react": "^19.1.0",
    "@types/react-dom": "^19.1.2",
    "picomatch": "^4.0.2",
    "tsup": "^8.5.0",
    "typescript": "^5.8.3"
  }
}
