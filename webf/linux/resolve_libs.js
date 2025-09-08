const fs = require('fs');
const path = require('path');

/**
 * Copies shared library files from bridge build directory, always overwriting if source exists
 */
function copyLibFiles() {
  const libFiles = [
    'libquickjs.so',
    'libwebf.so'
  ];

  const currentDir = __dirname;
  const bridgeLibDir = path.join(currentDir, '..', '..', 'bridge', 'build', 'linux', 'lib');
  let copiedCount = 0;

  console.log('Processing shared library files...');
  
  for (const libFile of libFiles) {
    const libPath = path.join(currentDir, libFile);
    const bridgeLibPath = path.join(bridgeLibDir, libFile);
    
    try {
      // Always copy from bridge if the original file exists
      if (fs.existsSync(bridgeLibPath)) {
        // Remove existing file/symlink if present
        if (fs.existsSync(libPath)) {
          const stats = fs.lstatSync(libPath);
          if (stats.isSymbolicLink()) {
            console.log(`Removing symbolic link: ${libFile}`);
          } else {
            console.log(`Overwriting existing file: ${libFile}`);
          }
          fs.unlinkSync(libPath);
        }
        
        // Copy from bridge directory
        fs.copyFileSync(bridgeLibPath, libPath);
        console.log(`✓ Copied from bridge: ${libFile}`);
        copiedCount++;
      } else {
        console.warn(`Warning: ${libFile} not found in bridge build directory: ${bridgeLibPath}`);
      }
    } catch (error) {
      console.error(`Error processing ${libFile}: ${error.message}`);
    }
  }

  return copiedCount;
}

// Main execution
if (require.main === module) {
  const copiedCount = copyLibFiles();
  
  if (copiedCount > 0) {
    console.log(`\nSuccessfully copied ${copiedCount} shared library files from bridge build directory.`);
  } else {
    console.log('\nNo shared library files were copied.');
  }
}

module.exports = { copyLibFiles };