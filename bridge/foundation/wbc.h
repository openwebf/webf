#ifndef BRIDGE_WBC_H
#define BRIDGE_WBC_H

#include <string>
#include <cstdint>

namespace webf {
    class Wbc {
    public:
        // The WBC1 file signature is a fixed sequence of 9 bytes:
        // 0x89 0x57 0x42 0x43 0x31 0x0D 0x0A 0x1A 0x0A
        constexpr static const uint8_t WBC_SIGNATURE[] = {0x89, 0x57, 0x42, 0x43, 0x31, 0x0D, 0x0A, 0x1A, 0x0A};

        //node-lz4 default maximum block size
        static const int32_t NODE_LZ4_BLOCK_MAX_SIZE = 4 * 1024 * 1024;

        //The length of the CHECKSUM field of HEADER in the wbc file format
        static const int32_t WBC_HEADER_CHECKSUM_LENGTH = 4;

        //The length of the body field in the wbc file format.
        //This value varies depending on the size of the QuickJS bytecode size contained on the chunk.
        static const int32_t WBC_BODY_LENGTH = 4;

        //The length of the body chunk field in the wbc file format.
        //ASCII value for the letter WBDY (0x57 0x42 0x44 0x59 in hexadecimal)
        static const int32_t WBC_BODY_CHUNK_TYPE_LENGTH = 4;

        //The length of the CHECKSUM field of BODY in the wbc file format,
        //calculated from the body, to verify the integrity of the this chunk
        static const int32_t WBC_BODY_CHECKSUM_LENGTH = 4;

        //The length of node-lz4 file signature
        static const int32_t NODE_LZ4_MAGIC = 4;
        
        //The file descriptor length of node-lz4
        static const int32_t NODE_LZ4_DESCRIPTOR = 2;

        //File CHECKSUM length of node-lz4
        static const int32_t NODE_LZ4_DESCRIPTOR_CHECKSUM = 1;

        //The length of node-lz4’s real compressed content size
        static const int32_t NODE_LZ4_DATABLOCK_SIZE = 4;

        // Check whether the wbc file is correct and return dataBlockBytes
        // https://github.com/openwebf/rfc/blob/main/working/wbc1.en-US.md
        uint8_t *prepareWbc(const uint8_t *bytes, size_t length, size_t *targetSize);

        // Function to check if the beginning of `bytes` matches the `WBC_SIGNATURE`
        bool verifySignature(const uint8_t *bytes);

        //Convert uint8_t to uint32_t according to big endian
        uint32_t convertBigEndianToUint32(const uint8_t *bytes, size_t startIndex);

        //Calculate Adler32 value of array
        uint32_t calculateAdler32(const uint8_t *array, size_t len, uint32_t adler = 1);
    };
}  // namespace webf

#endif  // BRIDGE_WBC_H
