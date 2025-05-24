{
  "name": "<%= packageName %>",
  "version": "0.0.1",
  "description": "",
  "main": "dist/index.js",
  "module": "dist/index.mjs",
  "types": "dist/index.d.ts",
  "files": ["dist"],
  "scripts": {
    "build": "tsup"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "type": "commonjs",
  "peerDependencies": {
    "react": ">=16.8.0",
    "react-dom": ">=16.8.0"
  },
  "devDependencies": {
    "@types/react": "^19.1.0",
    "@types/react-dom": "^19.1.2",
    "tsup": "^8.5.0",
    "typescript": "^5.8.3"
  }
}
