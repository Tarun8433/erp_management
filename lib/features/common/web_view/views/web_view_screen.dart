import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A reusable screen that renders a remote page inside an in-app WebView.
///
/// Navigate to it with a title + url, e.g.:
/// ```dart
/// Get.to(() => const WebViewScreen(),
///     arguments: {'title': 'Privacy Policy', 'url': 'https://...'});
/// ```
class WebViewScreen extends StatefulWidget {
  final String? title;
  final String? url;

  const WebViewScreen({super.key, this.title, this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  final RxBool _isLoading = true.obs;
  final RxBool _hasError = false.obs;

  String get _title {
    if (widget.title != null && widget.title!.isNotEmpty) return widget.title!;
    final args = Get.arguments;
    if (args is Map && args['title'] is String) return args['title'] as String;
    return '';
  }

  String get _url {
    if (widget.url != null && widget.url!.isNotEmpty) return widget.url!;
    final args = Get.arguments;
    if (args is Map && args['url'] is String) return args['url'] as String;
    return '';
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            _hasError.value = false;
            _isLoading.value = true;
          },
          onPageFinished: (_) => _isLoading.value = false,
          onWebResourceError: (_) {
            _hasError.value = true;
            _isLoading.value = false;
          },
        ),
      );
    _load();
  }

  void _load() {
    final url = _url;
    if (url.isEmpty) {
      _hasError.value = true;
      _isLoading.value = false;
      return;
    }
    _controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title.isEmpty ? 'Web' : _title),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_hasError.value) {
          return _ErrorView(onRetry: () {
            _isLoading.value = true;
            _load();
          });
        }
        return Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading.value)
              const Center(child: CircularProgressIndicator()),
          ],
        );
      }),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: scheme.error),
            const SizedBox(height: 16),
            Text(
              'Unable to load the page.\nPlease check your connection.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
