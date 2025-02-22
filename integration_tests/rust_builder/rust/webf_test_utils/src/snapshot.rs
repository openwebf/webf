use webf_sys::{ElementMethods, ExecutingContext, WebFNativeFuture};

pub fn snapshot_with_filename(context: ExecutingContext, filename: &'static str) -> WebFNativeFuture<()> {
  context.__webf_sync_buffer__();

  let window = context.window();
  let exception_state = context.create_exception_state();

  let snapshot_future = WebFNativeFuture::<()>::new();
  let snapshot_future_in_callback = snapshot_future.clone();

  let context_for_callback = context.clone();
  let animation_frame_callback = Box::new(move |_time_stamp| {
    let context_for_future = context_for_callback.clone();
    let snapshot_future_in_callback = snapshot_future_in_callback.clone();
    webf_sys::webf_future::spawn(context_for_callback.clone(), async move {
      let document = context_for_future.document();
      let html = document.document_element();
      let exception_state = context_for_future.create_exception_state();

      let html_blob = html.to_blob_with_device_pixel_ratio(1.0, &exception_state).await.unwrap().unwrap();

      let match_result = context_for_future.__webf_match_image_snapshot__(html_blob, filename, &exception_state).await.unwrap().unwrap();
      assert_eq!(match_result, true);

      snapshot_future_in_callback.set_result(Ok(Some(())));
    });
  });

  window.request_animation_frame(animation_frame_callback, &exception_state).unwrap();

  snapshot_future
}
