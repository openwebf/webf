use std::cell::RefCell;
use std::collections::VecDeque;
use std::future::Future;
use std::pin::Pin;
use std::rc::Rc;
use std::task::{Context, Poll, Waker};
use futures::task;
use crate::ExecutingContext;

type Task = Pin<Box<dyn Future<Output = ()>>>;

pub struct FutureRuntime {
  tasks: VecDeque<Task>,
  context: ExecutingContext,
  callback_id: Option<i32>,
}

impl FutureRuntime {
  pub fn new(context: ExecutingContext) -> FutureRuntime {
    FutureRuntime {
      tasks: VecDeque::new(),
      context,
      callback_id: None,
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

    if !unfinished_tasks.is_empty() {
      self.tasks.append(&mut unfinished_tasks);
      return;
    }

    if let Some(callback_id) = self.callback_id.take() {
      let exception_state = self.context.create_exception_state();
      self.context.remove_rust_future_task(callback_id, &exception_state);
    }

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

pub fn spawn<F>(context: ExecutingContext, future: F)
where
  F: Future<Output = ()> + 'static,
{
  let runtime = Rc::new(RefCell::new(FutureRuntime::new(context.clone())));
  let runtime_clone = runtime.clone();
  runtime.borrow_mut().spawn(future);
  let runtime_run_task_callback = Box::new(move || {
    runtime.borrow_mut().run();
  });
  let exception_state = context.create_exception_state();
  let callback_id = context.add_rust_future_task(runtime_run_task_callback, &exception_state).unwrap();
  runtime_clone.borrow_mut().callback_id = Some(callback_id);
}
