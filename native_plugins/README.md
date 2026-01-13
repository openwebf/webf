# WebF Native Plugins

This directory contains WebF-specific Flutter packages that extend WebF functionality with additional modules.

## Available Modules

### [webf_share](./share/)
**Content and image sharing functionality**
- Share images with text and subject
- Share text content and URLs
- Save screenshots to device storage
- Create preview images for display

### [webf_bluetooth](./bluetooth/)
**Bluetooth Low Energy (BLE) operations**
- Get adapter state and turn on Bluetooth
- Scan for nearby BLE devices
- Connect and disconnect from devices
- Discover services and characteristics
- Read and write characteristic values
- Read and write descriptor values
- Subscribe to characteristic notifications

### [webf_sqflite](./sqflite/)
**SQLite database operations**
- Open, close, and delete databases
- Execute raw SQL queries (SELECT, INSERT, UPDATE, DELETE)
- Use helper methods for common operations (query, insert, update, delete)
- Execute batch operations for performance
- Execute transactions for atomicity

## Requirements

- **Flutter**: >=3.0.0
- **Dart SDK**: >=3.6.0 <4.0.0
- **WebF**: ^0.24.0

## License

Apache-2.0
