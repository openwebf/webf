use webf_sys::ExecutingContext;

pub async fn test_should_work_with_set_item(context: ExecutingContext) {
  let storage = context.async_storage();
  let exception_state = context.create_exception_state();

  storage.clear(&exception_state).await.unwrap();
  storage.set_item("keyValue", "12345", &exception_state).await.unwrap();
  let value = storage.get_item("keyValue", &exception_state).await.unwrap().unwrap();

  assert_eq!(value, "12345");
}
