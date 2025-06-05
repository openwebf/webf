# WebF UI Command Ring Buffer Design

## Important Note

This is a new implementation of the UI command system using ring buffers. To use this implementation:

1. Replace `shared_ui_command.h/cc` with `shared_ui_command_ring_buffer.h/cc` in your build
2. Update code to use `SharedUICommandRingBuffer` instead of `SharedUICommand`
3. Or use the existing `SharedUICommand` class as-is (the old implementation remains unchanged)

## Overview

The new UI command ring buffer system is designed to efficiently handle high-volume UI commands from the JavaScript worker thread to the Dart UI thread. It replaces the previous triple-buffer system with a lock-free ring buffer that provides better performance and scalability.

## Key Features

### 1. Lock-Free Ring Buffer
- Uses atomic operations for thread-safe concurrent access
- Separate cache lines for producer and consumer states to avoid false sharing
- Power-of-2 capacity for fast modulo operations

### 2. Overflow Handling
- When the ring buffer is full, commands are stored in an overflow buffer
- Overflow buffer is drained first during consumption
- No commands are dropped, even under extreme load

### 3. Command Packaging
- Commands are grouped into packages based on their type
- Reduces cross-thread communication overhead
- Maintains command ordering within and across packages

### 4. Batching Strategy
Commands are automatically split into separate packages when:
- Encountering special commands (StartRecording, FinishRecording, AsyncCaller)
- Mixing incompatible command types (e.g., node creation followed by node mutation)
- Package size exceeds threshold (1000 commands)

## Architecture

```
JS Worker Thread                    Dart UI Thread
     |                                   |
     v                                   v
AddCommand() -----> Ring Buffer -----> PopPackage()
     |              /         \              |
     |         Package 1   Package 2         |
     |             |           |             |
     v             v           v             v
  Commands    [Cmd1,Cmd2]  [Cmd3,Cmd4]   Read & Execute
```

## Usage

### JavaScript Side (Producer)
```cpp
// Commands are added to the ring buffer
context->uiCommandBuffer()->AddCommand(
    UICommand::kSetStyle, 
    styleString, 
    element->bindingObject(), 
    nullptr
);
```

### Dart Side (Consumer)
```dart
// Commands are read in batches
void* commandPack = getUICommandItems(page);
// Process commands...
freeActiveCommandBuffer(commandPack);
```

## Performance Characteristics

1. **Throughput**: Can handle millions of commands per second
2. **Latency**: Near-zero latency for command insertion
3. **Memory**: Dynamic overflow handling prevents memory limits
4. **Scalability**: Lock-free design scales with CPU cores

## Thread Safety

- Producer operations use release memory ordering
- Consumer operations use acquire memory ordering
- Overflow buffers protected by mutexes (rarely used)
- No blocking on the hot path

## Configuration

The system can be configured with:
- Ring buffer capacity (default: 64K commands)
- Package buffer capacity (default: 1K packages)
- Custom batching strategies

## Testing

Comprehensive test suite includes:
- Basic push/pop operations
- Batch operations
- Overflow handling
- Concurrent producer/consumer
- Multiple producers
- Stress tests with millions of commands