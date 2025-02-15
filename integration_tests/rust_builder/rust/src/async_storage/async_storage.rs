use webf_sys::ExecutingContext;
use webf_test_macros::webf_test_async;

#[webf_test_async]
pub async fn test_should_work_with_get_item(context: ExecutingContext) {
  let storage = context.async_storage();
  let exception_state = context.create_exception_state();

  storage.clear(&exception_state).await.unwrap();
  storage.set_item("keyValue", "12345", &exception_state).await.unwrap();
  let value = storage.get_item("keyValue", &exception_state).await.unwrap().unwrap();

  assert_eq!(value, "12345");
}

#[webf_test_async]
pub async fn test_should_work_with_set_item_and_remove_item(context: ExecutingContext) {
  let storage = context.async_storage();
  let exception_state = context.create_exception_state();

  storage.clear(&exception_state).await.unwrap();
  storage.set_item("keyValue", "12345", &exception_state).await.unwrap();
  storage.remove_item("keyValue", &exception_state).await.unwrap();
  let value = storage.get_item("keyValue", &exception_state).await.unwrap().unwrap();

  assert_eq!(value, "");
}

#[webf_test_async]
pub async fn test_should_work_with_set_item_and_clear_and_get_all_keys(context: ExecutingContext) {
  let storage = context.async_storage();
  let exception_state = context.create_exception_state();

  storage.clear(&exception_state).await.unwrap();
  storage.set_item("keyA", "1", &exception_state).await.unwrap();
  storage.set_item("keyB", "1", &exception_state).await.unwrap();
  let before_keys = storage.get_all_keys(&exception_state).await.unwrap().unwrap();
  assert_eq!(before_keys.len(), 2);
  storage.clear(&exception_state).await.unwrap();
  let keys = storage.get_all_keys(&exception_state).await.unwrap().unwrap();
  assert_eq!(keys.len(), 0);
}

#[webf_test_async]
pub async fn test_should_work_with_length(context: ExecutingContext) {
  let storage = context.async_storage();
  let exception_state = context.create_exception_state();

  storage.clear(&exception_state).await.unwrap();
  let zero = storage.length(&exception_state).await.unwrap().unwrap();
  assert_eq!(zero, 0);

  storage.set_item("333", "666", &exception_state).await.unwrap();
  let one = storage.length(&exception_state).await.unwrap().unwrap();
  assert_eq!(one, 1);
}
