#![feature(noop_waker)]

use std::ffi::*;
use std::future::Future;
use std::task::{Context, Poll, Waker};
use std::pin::Pin;
use std::sync::{Arc, Mutex};
use std::cell::RefCell;

#[repr(C)]
pub struct WebFNativeFutureData {
  pub ptr: *mut Pin<Box<dyn Future<Output=()>>>,
  pub poll_fn: extern "C" fn(ptr: *mut c_void) -> c_int,
}

pub extern "C" fn poll_webf_native_future(ptr: *mut c_void) -> c_int {
  let mut future = unsafe {
    Box::from_raw(ptr as *mut Pin<Box<dyn Future<Output = ()>>>)
  };
  let future_ptr = future.as_mut();
  let waker = Waker::noop();
  let mut context = Context::from_waker(&waker);
  match future_ptr.as_mut().poll(&mut context) {
    Poll::Ready(()) => 1,
    Poll::Pending => 0,
  }
}

pub struct WebFNativeFuture<T> {
  inner: Arc<Mutex<Inner<T>>>,
}

struct Inner<T> {
  waker: Option<Waker>,
  result: Option<Result<Option<T>, String>>,
}

impl<T> WebFNativeFuture<T> {
  pub fn new() -> WebFNativeFuture<T> {
    WebFNativeFuture {
      inner: Arc::new(Mutex::new(Inner {
        waker: None,
        result: None,
      })),
    }
  }

  pub fn set_result(&self, result: Result<Option<T>, String>) {
    let mut inner = self.inner.lock().unwrap();
    inner.result = Some(result);
    if let Some(waker) = inner.waker.take() {
      waker.wake();
    }
  }
}

impl<T> Future for WebFNativeFuture<T>
where
  T: 'static,
{
  type Output = Result<Option<T>, String>;

  fn poll(self: Pin<&mut Self>, cx: &mut Context) -> Poll<Self::Output> {
    let mut inner = self.inner.lock().unwrap();

    if let Some(result) = inner.result.take() {
      Poll::Ready(result)
    } else {
      inner.waker = Some(cx.waker().clone());
      Poll::Pending
    }
  }
}

impl Clone for WebFNativeFuture<String> {
  fn clone(&self) -> Self {
    WebFNativeFuture {
      inner: self.inner.clone(),
    }
  }
}
