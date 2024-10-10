#include "core/<%= blob.implement %>.h"

namespace webf {

class ExecutingContext;

class V8<%= className %> final {
 public:
  static void Install(ExecutingContext* context);
 private:
  static void InstallGlobalFunctions(ExecutingContext* context);
};

}
