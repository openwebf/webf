// Generated from template:
//   code_generator/src/json/templates/media_features.h.tmpl
// and input files:
//   <%= template_path %>


#ifndef WEBF_CORE_CSS_MEDIA_FEATURES_H_
#define WEBF_CORE_CSS_MEDIA_FEATURES_H_

namespace webf {

#define CSS_MEDIAQUERY_NAMES_FOR_EACH_MEDIAFEATURE(macro) \
<% _.forEach(data, function(name, index) { %>
   macro(media_feature_names_stdstring::k<%= upperCamelCase(name) %>, <%= upperCamelCase(name) %>) <%= index + 1 != data.length ? "\\" : '' %>
<% }) %>


} // webf

#endif  // #define WEBF_CORE_CSS_MEDIA_FEATURES_H_
