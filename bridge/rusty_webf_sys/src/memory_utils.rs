use windows::Win32;
use libc;
use crate::OpaquePtr;

pub fn safe_free_cpp_ptr<T>(ptr: *const T) {
  unsafe {
    if cfg!(target_os = "windows") {
      #[cfg(target_os = "windows")]
      {
        Win32::System::Memory::HeapFree(
          Win32::System::Memory::GetProcessHeap().unwrap(),
          Win32::System::Memory::HEAP_FLAGS(0),
          Option::from(ptr as *const libc::c_void)
        ).expect("Failed to call HeapFree");
      }
    } else if cfg!(target_os = "macos") || cfg!(target_os = "linux") {
      libc::free(ptr.cast_mut() as *mut libc::c_void);
    }
  }
}