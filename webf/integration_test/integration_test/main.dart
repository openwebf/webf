import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:webf/webf.dart';

import 'fp_integration_test.dart' as fp_test;
import 'fcp_integration_test.dart' as fcp_test;
import 'lcp_integration_test.dart' as lcp_test;
import 'widget_fcp_lcp_test.dart' as widget_fcp_lcp_test;
import 'widget_fcp_lcp_simple_test.dart' as widget_fcp_lcp_simple_test;
import 'route_performance_metrics_test.dart' as route_performance_test;
import 'lcp_content_verification_test.dart' as lcp_content_verification_test;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Register custom elements once
  WebF.defineCustomElement('test-text-widget', (context) => widget_fcp_lcp_simple_test.TestTextWidgetElement(context));
  WebF.defineCustomElement('test-layout-widget', (context) => widget_fcp_lcp_test.TestLayoutWidgetElement(context));

  group('WebF Integration Tests', () {
    group('First Paint (FP)', fp_test.main);
    group('First Contentful Paint (FCP)', fcp_test.main);
    group('Largest Contentful Paint (LCP)', lcp_test.main);
    group('Widget FCP/LCP', widget_fcp_lcp_test.main);
    group('Widget FCP/LCP Simple', widget_fcp_lcp_simple_test.main);
    group('Route Performance Metrics', route_performance_test.main);
    group('LCP Content Verification', lcp_content_verification_test.main);
  });
}
