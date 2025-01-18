use webf_sys::ExecutingContext;

pub fn test_local_storage_method_access(context: ExecutingContext) {
  let storage = context.local_storage();
  let exception_state = context.create_exception_state();
  storage.clear(&exception_state);

  let keys = storage.get_all_keys(&exception_state);
  assert_eq!(keys.len(), 0);

  storage.set_item("name", "user1", &exception_state).unwrap();

  let keys = storage.get_all_keys(&exception_state);
  assert_eq!(keys.len(), 1);

  storage.remove_item("name", &exception_state).unwrap();

  let keys = storage.get_all_keys(&exception_state);
  assert_eq!(keys.len(), 0);
}

pub fn test_session_storage_method_access(context: ExecutingContext) {
  let storage = context.session_storage();
  let exception_state = context.create_exception_state();
  storage.clear(&exception_state);

  let keys = storage.get_all_keys(&exception_state);
  assert_eq!(keys.len(), 0);

  storage.set_item("name", "user1", &exception_state).unwrap();

  let keys = storage.get_all_keys(&exception_state);
  assert_eq!(keys.len(), 1);

  storage.remove_item("name", &exception_state).unwrap();

  let keys = storage.get_all_keys(&exception_state);
  assert_eq!(keys.len(), 0);
}
