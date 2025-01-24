use std::cell::RefCell;
use std::collections::VecDeque;
use std::future::Future;
use std::pin::Pin;
use std::rc::Rc;
use std::task::{Context, Poll, Waker};

use futures::task;

type Task = Pin<Box<dyn Future<Output = ()>>>;

pub struct FutureRuntime {
  tasks: VecDeque<Task>,
}

impl FutureRuntime {
  pub fn new() -> FutureRuntime {
    FutureRuntime {
      tasks: VecDeque::new(),
    }
  }

  /// Spawn a future onto the mini-tokio instance.
  pub fn spawn<F>(&mut self, future: F)
  where
    F: Future<Output = ()> + 'static,
  {
    self.tasks.push_back(Box::pin(future));
  }

  pub fn run(&mut self) {
    let waker = task::noop_waker();
    let mut cx = Context::from_waker(&waker);
    let mut unfinished_tasks = VecDeque::new();

    while let Some(mut task) = self.tasks.pop_front() {
      if task.as_mut().poll(&mut cx).is_pending() {
        unfinished_tasks.push_back(task);
      }
    }

    self.tasks.append(&mut unfinished_tasks);
  }
}

pub struct WebFNativeFuture<T> {
  inner: Rc<RefCell<Inner<T>>>,
}

struct Inner<T> {
  result: Option<Result<Option<T>, String>>,
}

impl<T> WebFNativeFuture<T> {
  pub fn new() -> WebFNativeFuture<T> {
    WebFNativeFuture {
      inner: Rc::new(RefCell::new(Inner {
        result: None,
      })),
    }
  }

  pub fn set_result(&self, result: Result<Option<T>, String>) {
    let mut inner = self.inner.borrow_mut();
    inner.result = Some(result);
  }
}

impl<T> Future for WebFNativeFuture<T>
where
  T: 'static,
{
  type Output = Result<Option<T>, String>;

  fn poll(self: Pin<&mut Self>, cx: &mut Context) -> Poll<Self::Output> {
    let mut inner = self.inner.borrow_mut();

    if let Some(result) = inner.result.take() {
      Poll::Ready(result)
    } else {
      Poll::Pending
    }
  }
}

impl<T> Clone for WebFNativeFuture<T>
{
  fn clone(&self) -> Self {
    WebFNativeFuture {
      inner: self.inner.clone(),
    }
  }
}
