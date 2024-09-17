#ifndef BRIDGE_WBC_H
#define BRIDGE_WBC_H

#include <cstdint>
#include <string>

namespace webf {

class Wbc {
 public:
  // The WBC1 file signature is a fixed sequence of 9 bytes:
  // 0x89 0x57 0x42 0x43 0x31 0x0D 0x0A 0x1A 0x0A
  constexpr static const uint8_t WBC_SIGNATURE[] = {0x89, 0x57, 0x42, 0x43, 0x31, 0x0D, 0x0A, 0x1A, 0x0A};

  //The length of the header field in the wbc file format.
  static const int32_t WBC_HEADER_LENGTH = 4;

  // ASCII value for the letter `WBHD` (0x57 0x42 0x48 0x44 in hexadecimal)
  static const int32_t WBC_HEADER_CHUNK_TYPE_LENGTH = 4;

  // Specifies the compression method used. Currently, only the value 0 is allowed, representing the LZ4 deflate/inflate compression method.
  static const int32_t WBC_HEADER_COMPRESSION_METHOD = 1;

  // Specifies the compile level when produce the QuickJS bytecodes, different compile level would lead to different bytecode size and optimization level.
  // Default to 0.
  static const int32_t WBC_HEADER_COMPILE_LEVEL = 1;

  // The bytecode versions contains in this file.H
  // QuickJS bytecode = 0
  // V8 bytecode = 1
  // Default to 0.
  static const int32_t WBC_HEADER_BYTECODE_VERSION = 1;

  static const int32_t WBC_QUICKJS_BYTECODE = 0;
  static const int32_t WBC_V8_BYTECODE_v1 = 1;

  // Preallocated space for other usage in the future.
  static const int32_t WBC_HEADER_ADDITIONAL_DATA = 3;

  // The length of the CHECKSUM field of HEADER in the wbc file format
  static const int32_t WBC_HEADER_CHECKSUM_LENGTH = 4;

  // The bytecode version of WBC file format.
  static const int32_t WBC_HEADER_BYTECODE_VERSION_LENGTH = 1;

  // The length of the body field in the wbc file format.
  // This value varies depending on the size of the QuickJS bytecode size contained on the chunk.
  static const int32_t WBC_BODY_LENGTH = 4;

  // The length of the body chunk field in the wbc file format.
  // ASCII value for the letter WBDY (0x57 0x42 0x44 0x59 in hexadecimal)
  static const int32_t WBC_BODY_CHUNK_TYPE_LENGTH = 4;

  // The length of the CHECKSUM field of BODY in the wbc file format,
  // calculated from the body, to verify the integrity of the this chunk
  static const int32_t WBC_BODY_CHECKSUM_LENGTH = 4;

  // Check whether the wbc file is correct and return dataBlockBytes
  // https://github.com/openwebf/rfc/blob/main/working/wbc1.en-US.md
  bool prepareWbc(const uint8_t *bytes, size_t length, size_t *targetStart, size_t *targetEnd);

  // Function to check if the beginning of `bytes` matches the `WBC_SIGNATURE`
  bool verifySignature(const uint8_t* bytes);

  // Convert uint8_t to uint32_t according to big endian
  uint32_t convertBigEndianToUint32(const uint8_t* bytes, size_t startIndex);

  // Calculate Adler32 value of array
  uint32_t calculateAdler32(const uint8_t* array, size_t len, uint32_t adler = 1);
};

}  // namespace webf

#endif  // BRIDGE_WBC_H
