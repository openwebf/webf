use proc_macro::TokenStream;
use syn::spanned::Spanned;
use syn::{parse_macro_input, ItemFn};
use quote::quote;

#[proc_macro_attribute]
pub fn webf_test(_attr: TokenStream, item: TokenStream) -> TokenStream {
  let input_fn = parse_macro_input!(item as ItemFn);

  let fn_name = input_fn.sig.ident.to_string();
  let fn_ident = input_fn.sig.ident.clone();
  let prefixed_fn_name = syn::Ident::new(&format!("register_test_{}", fn_name), fn_name.span());

  let expanded = quote! {
    #input_fn

    #[ctor::ctor]
    fn #prefixed_fn_name() {
      webf_test_utils::sync_runner::register_test_case(
        module_path!().to_string(),
        file!().to_string(),
        #fn_name.to_string(),
        std::sync::Arc::new(#fn_ident)
      );
    }
  };

  expanded.into()
}

#[proc_macro_attribute]
pub fn webf_test_async(_attr: TokenStream, item: TokenStream) -> TokenStream {
  let input_fn = parse_macro_input!(item as ItemFn);

  let fn_name = input_fn.sig.ident.to_string();
  let fn_ident = input_fn.sig.ident.clone();
  let prefixed_fn_name = syn::Ident::new(&format!("register_test_async_{}", fn_name), fn_name.span());

  let expanded = quote! {
    #input_fn

    #[ctor::ctor]
    fn #prefixed_fn_name() {
      webf_test_utils::async_runner::register_test_case(
        module_path!().to_string(),
        file!().to_string(),
        #fn_name.to_string(),
        std::sync::Arc::new(
          Box::new(|context| {
            Box::pin(#fn_ident(context))
          })
        )
      );
    }
  };

  expanded.into()
}

#[proc_macro_attribute]
pub fn webf_test_callback(_attr: TokenStream, item: TokenStream) -> TokenStream {
  let input_fn = parse_macro_input!(item as ItemFn);

  let fn_name = input_fn.sig.ident.to_string();
  let fn_ident = input_fn.sig.ident.clone();
  let prefixed_fn_name = syn::Ident::new(&format!("register_test_callback_{}", fn_name), fn_name.span());

  let expanded = quote! {
    #input_fn

    #[ctor::ctor]
    fn #prefixed_fn_name() {
      webf_test_utils::callback_runner::register_test_case(
        module_path!().to_string(),
        file!().to_string(),
        #fn_name.to_string(),
        std::sync::Arc::new(
          Box::new(|context, done| {
            Box::pin(#fn_ident(context, done))
          })
        )
      );
    }
  };

  expanded.into()
}
