use webf_sys::{Element, ExceptionState, ExecutingContext, NativeValue, Node, NodeMethods};
use serde_json::Value;

pub fn set_element_style(element: &Element, style: &Value, exception_state: &ExceptionState) {
  if let Some(obj) = style.as_object() {
    let element_style = element.style();
    for (key, value) in obj {
      let value_str: String = match value {
        Value::String(s) => s.clone(),
        Value::Number(n) => n.to_string(),
        _ => continue, // Skip values that aren't strings or numbers
      };
      element_style.set_property(key, NativeValue::new_string(&value_str), exception_state).unwrap();
    }
  }
}

pub fn create_element_with_style(
  context: &ExecutingContext,
  tag_name: &str,
  style: &Value,
) -> Element{
  let document = context.document();
  let exception_state = context.create_exception_state();

  let element = document.create_element(tag_name, NativeValue::new_null(), &exception_state).unwrap();
  set_element_style(&element, style, &exception_state);

  element
}

pub fn create_element_with_style_and_child(
  context: &ExecutingContext,
  tag_name: &str,
  style: &Value,
  child: &Node,
) -> Element {
  let exception_state = context.create_exception_state();
  let element = create_element_with_style(context, tag_name, style);
  element.append_child(child, &exception_state).unwrap();

  element
}

pub fn create_element_with_style_and_children(
  context: &ExecutingContext,
  tag_name: &str,
  style: &Value,
  children: &Vec<&Node>,
) -> Element {
  let exception_state = context.create_exception_state();

  let element = create_element_with_style(context, tag_name, style);
  for child in children {
    element.append_child(child, &exception_state).unwrap();
  }

  element
}
