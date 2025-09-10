const fs = require('fs');
const path = require('path');

/**
 * Copies DLL files from bridge build directory, always overwriting if source exists
 */
function copyDllFiles() {
  const dllFiles = [
    'libgcc_s_seh-1.dll',
    'libc++.dll', 
    'libwinpthread-1.dll',
    'libquickjs.dll',
    'libwebf.dll'
  ];

  const currentDir = __dirname;
  const bridgeBinDir = path.join(currentDir, '..', '..', 'bridge', 'build', 'windows', 'lib');
  let copiedCount = 0;

  console.log('Processing DLL files...');
  
  for (const dllFile of dllFiles) {
    const dllPath = path.join(currentDir, dllFile);
    const bridgeDllPath = path.join(bridgeBinDir, dllFile);
    
    try {
      // Always copy from bridge if the original file exists
      if (fs.existsSync(bridgeDllPath)) {
        // Remove existing file/symlink if present
        if (fs.existsSync(dllPath)) {
          const stats = fs.lstatSync(dllPath);
          if (stats.isSymbolicLink()) {
            console.log(`Removing symbolic link: ${dllFile}`);
          } else {
            console.log(`Overwriting existing file: ${dllFile}`);
          }
          fs.unlinkSync(dllPath);
        }
        
        // Copy from bridge directory
        fs.copyFileSync(bridgeDllPath, dllPath);
        console.log(`✓ Copied from bridge: ${dllFile}`);
        copiedCount++;
      } else {
        console.warn(`Warning: ${dllFile} not found in bridge build directory: ${bridgeDllPath}`);
      }
    } catch (error) {
      console.error(`Error processing ${dllFile}: ${error.message}`);
    }
  }

  return copiedCount;
}

// Main execution
if (require.main === module) {
  const copiedCount = copyDllFiles();
  
  if (copiedCount > 0) {
    console.log(`\nSuccessfully copied ${copiedCount} DLL files from bridge build directory.`);
  } else {
    console.log('\nNo DLL files were copied.');
  }
}

module.exports = { copyDllFiles };
