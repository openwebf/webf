use std::future::Future;
use std::task::{Context, Poll, Waker};
use std::pin::Pin;
use std::sync::{Arc, Mutex};
use std::cell::RefCell;

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
