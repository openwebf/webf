use crate::OpaquePtr;
use libc;
#[cfg(target_os = "windows")]
use windows::Win32::System::Com::CoTaskMemFree;

pub fn safe_free_cpp_ptr<T>(ptr: *const T) {
  unsafe {
    if cfg!(target_os = "windows") {
      #[cfg(target_os = "windows")]
      {
        CoTaskMemFree(Option::from(ptr as *const libc::c_void));
      }
    } else {
      libc::free(ptr.cast_mut() as *mut libc::c_void);
    }
  }
}
