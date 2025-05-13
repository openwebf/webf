const exec = require("child_process").execSync;
const fs = require("fs");
const PATH = require("path");
const os = require('os');

/**
 * Copy a file from source to destination
 */
function copyFile(source, destination) {
  console.log(`Copying file: ${source} -> ${destination}`);
  
  // Ensure the destination directory exists
  const destDir = PATH.dirname(destination);
  if (!fs.existsSync(destDir)) {
    fs.mkdirSync(destDir, { recursive: true });
  }
  
  // Delete the destination file if it exists
  if (fs.existsSync(destination)) {
    fs.unlinkSync(destination);
    console.log(`Deleted existing file: ${destination}`);
  }
  
  // Read and write the file
  const buffer = fs.readFileSync(source);
  fs.writeFileSync(destination, buffer);
}

/**
 * Copy macOS dynamic libraries to webf/macos folder
 */
function copyMacOSDynamicLibraries(webfDir) {
  console.log('Copying macOS dynamic libraries...');
  
  const macosDir = PATH.join(webfDir, 'macos');
  const sourceDylibDir = PATH.join(__dirname, '../bridge/build/macos/lib/x86_64/');
  
  // Copy the dynamic libraries
  const libraries = ['libwebf.dylib', 'libquickjs.dylib'];
  for (const lib of libraries) {
    const sourceLib = PATH.join(sourceDylibDir, lib);
    const destLib = PATH.join(macosDir, lib);
    
    if (fs.existsSync(sourceLib)) {
      copyFile(sourceLib, destLib);
    } else {
      console.error(`Error: Could not find ${sourceLib}`);
    }
  }
}

/**
 * Copy C/C++ source files from bridge/ to webf/src for non-macOS platforms
 */
function copyCppSourceFiles(rootDir, webfDir) {
  console.log('Copying C/C++ source files...');
  
  const bridgeDir = PATH.join(rootDir, 'bridge');
  const srcDir = PATH.join(webfDir, 'src');
  
  // Ensure the src directory exists
  if (!fs.existsSync(srcDir)) {
    fs.mkdirSync(srcDir, { recursive: true });
  } else {
    // Clean the src directory if it exists
    console.log('Cleaning existing src directory...');
    if (os.platform() === 'win32') {
      exec(`rd /s /q "${srcDir}"`);
      fs.mkdirSync(srcDir, { recursive: true });
    } else {
      exec(`rm -rf "${srcDir}"`);
      fs.mkdirSync(srcDir, { recursive: true });
    }
  }
  
  // Directories to copy (based on iOS structure)
  const directoriesToCopy = [
    'bindings',
    'core',
    'foundation',
    'include',
    'code_gen',
    'multiple_threading',
    'third_party/dart',
    'third_party/gumbo-parser',
    'third_party/modp_b64',
    'third_party/quickjs',
  ];
  
  // Copy all directories recursively
  for (const dir of directoriesToCopy) {
    const sourceDir = PATH.join(bridgeDir, dir);
    const destDir = PATH.join(srcDir, dir);
    
    if (fs.existsSync(sourceDir)) {
      // Create the destination directory if it doesn't exist
      if (!fs.existsSync(destDir)) {
        fs.mkdirSync(destDir, { recursive: true });
      }
      
      // Use rsync or recursive copy depending on the platform
      if (os.platform() === 'win32') {
        // For Windows, use xcopy or robocopy
        exec(`xcopy "${sourceDir}" "${destDir}" /E /I /Y`);
      } else {
        // For Unix-like systems, use rsync or cp
        exec(`rsync -a "${sourceDir}/" "${destDir}/"`);
      }
    } else {
      console.warn(`Warning: Source directory ${sourceDir} does not exist.`);
    }
  }
  
  // Also copy specific files at the root level
  const rootFilesToCopy = [
    'CMakeLists.txt',
    'webf_bridge.cc',
    'webf_bridge.h'
  ];
  
  for (const file of rootFilesToCopy) {
    const sourceFile = PATH.join(bridgeDir, file);
    const destFile = PATH.join(srcDir, file);
    
    if (fs.existsSync(sourceFile)) {
      copyFile(sourceFile, destFile);
    } else {
      console.warn(`Warning: Source file ${sourceFile} does not exist.`);
    }
  }
}

/**
 * Patch the Windows CMakeLists.txt to use src instead of win_src
 */
function patchWindowsCMake(webfDir) {
  console.log('Patching Windows CMakeLists.txt...');
  
  const windowsCMake = PATH.join(webfDir, 'windows/CMakeLists.txt');
  if (fs.existsSync(windowsCMake)) {
    let txt = fs.readFileSync(windowsCMake, { encoding: 'utf-8' });
    txt = txt.replace('win_src', 'src');
    fs.writeFileSync(windowsCMake, txt);
    console.log('Windows CMakeLists.txt patched successfully.');
  } else {
    console.error(`Error: Windows CMakeLists.txt not found at ${windowsCMake}`);
  }
}

/**
 * Patch the App Revision in CMakeLists.txt
 */
function patchAppRev(webfDir) {
  console.log('Patching App Revision in CMakeLists.txt...');
  
  const gitHead = exec('git rev-parse --short HEAD').toString().trim();
  const cmakePath = PATH.join(webfDir, 'src/CMakeLists.txt');
  
  if (fs.existsSync(cmakePath)) {
    let txt = fs.readFileSync(cmakePath, { encoding: 'utf-8' });
    
    // Split the content into lines
    const lines = txt.split('\n');
    
    const start = lines.findIndex(line => line.indexOf('git rev-parse') >= 0);
    if (start >= 0) {
      // Remove the git command lines
      let updatedContent = [
        ...lines.slice(0, start - 1),
        ...lines.slice(start + 5)
      ].join('\n');
      
      // Replace the placeholder with the actual git head
      updatedContent = updatedContent.replace('${GIT_HEAD}', gitHead);
      
      fs.writeFileSync(cmakePath, updatedContent);
      console.log(`App Revision patched to: ${gitHead}`);
    } else {
      console.warn('Warning: Could not find git rev-parse line in CMakeLists.txt');
    }
  } else {
    console.error(`Error: CMakeLists.txt not found at ${cmakePath}`);
  }
}

/**
 * Patch the App Version in CMakeLists.txt
 */
function patchAppVersion(webfDir) {
  console.log('Patching App Version in CMakeLists.txt...');
  
  const appVer = exec('node bridge/scripts/get_app_ver.js', {
    cwd: PATH.join(__dirname, '../')
  }).toString().trim();
  
  const cmakePath = PATH.join(webfDir, 'src/CMakeLists.txt');
  
  if (fs.existsSync(cmakePath)) {
    let txt = fs.readFileSync(cmakePath, { encoding: 'utf-8' });
    
    // Split the content into lines
    const lines = txt.split('\n');
    
    const start = lines.findIndex(line => line.indexOf('node get_app_ver.js') >= 0);
    if (start >= 0) {
      // Remove the app version command lines
      let updatedContent = [
        ...lines.slice(0, start - 1),
        ...lines.slice(start + 5)
      ].join('\n');
      
      // Replace the placeholder with the actual app version
      updatedContent = updatedContent.replace('${APP_VER}', appVer);
      
      fs.writeFileSync(cmakePath, updatedContent);
      console.log(`App Version patched to: ${appVer}`);
    } else {
      console.warn('Warning: Could not find node get_app_ver.js line in CMakeLists.txt');
    }
  } else {
    console.error(`Error: CMakeLists.txt not found at ${cmakePath}`);
  }
}

/**
 * Patch the iOS podspec file with app version and revision
 */
function patchIOSPodspec(webfDir) {
  console.log('Patching iOS podspec file...');
  
  const gitHead = exec('git rev-parse --short HEAD').toString().trim();
  const appVer = exec('node bridge/scripts/get_app_ver.js', {
    cwd: PATH.join(__dirname, '../')
  }).toString().trim();
  
  const podspecPath = PATH.join(webfDir, 'ios/webf.podspec');
  
  if (fs.existsSync(podspecPath)) {
    let txt = fs.readFileSync(podspecPath, { encoding: 'utf-8' });
    
    // Replace APP_REV and APP_VERSION in podspec
    txt = txt.replace(/APP_REV=\\\\"[^\\]*\\\\"/, `APP_REV=\\\\"${gitHead}\\\\"`);
    txt = txt.replace(/APP_VERSION=\\\\"[^\\]*\\\\"/, `APP_VERSION=\\\\"${appVer}\\\\"`);
   
    fs.writeFileSync(podspecPath, txt);
    console.log(`iOS podspec patched with Revision: ${gitHead} and Version: ${appVer}`);
  } else {
    console.error(`Error: iOS podspec not found at ${podspecPath}`);
  }
}

/**
 * Add files to git and create commit
 */
function addFilesToGit(webfDir) {
  console.log('Adding files to git...');
  
  // Add src directory
  exec('git add src', {
    cwd: webfDir
  });
  
  // Remove win_src if it exists
  if (fs.existsSync(PATH.join(webfDir, 'win_src'))) {
    exec('rm -rf win_src', {
      cwd: webfDir
    });
    console.log('Removed win_src directory');
  }
  
  // Add Windows CMakeLists.txt
  exec('git add windows/CMakeLists.txt', {
    cwd: webfDir
  });
  
  // Add macOS libraries
  exec('git add macos/libwebf.dylib macos/libquickjs.dylib', {
    cwd: webfDir
  });
  
  // Set git user for the commit
  exec('git config user.email bot@openwebf.com');
  exec('git config user.name openwebf-bot');
  
  // Create commit
  exec('git commit -m "Prepare WebF package for publishing"');
  
  console.log('Files added to git and committed.');
}

/**
 * Main function to run all tasks
 */
function main() {
  console.log('Starting WebF package preparation...');
  
  const rootDir = PATH.join(__dirname, '..');
  const webfDir = PATH.join(rootDir, 'webf');
  
  try {
    // 1. Copy macOS dynamic libraries
    copyMacOSDynamicLibraries(webfDir);
    
    // // 2. Copy C/C++ source files for other platforms
    copyCppSourceFiles(rootDir, webfDir);
    
    // // 3. Patch Windows CMakeLists.txt
    patchWindowsCMake(webfDir);
    
    // 4. Patch App Revision and Version in CMakeLists.txt
    patchAppRev(webfDir);
    patchAppVersion(webfDir);
    
    // 5. Patch iOS podspec
    patchIOSPodspec(webfDir);
    
    // 6. Add generated files to git
    addFilesToGit(webfDir);
    
    console.log('WebF package preparation completed successfully!');
  } catch (error) {
    console.error('Error preparing WebF package:', error);
    process.exit(1);
  }
}

// Run the main function
main();