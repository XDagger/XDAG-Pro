import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xdag/common/color.dart';
import 'package:xdag/widget/nav_header.dart';

class WebViewPageRouteParams {
  final String url;
  final String title;
  WebViewPageRouteParams({required this.url, this.title = ''});
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final WebViewPageRouteParams params = ModalRoute.of(context)!.settings.arguments as WebViewPageRouteParams;
      controller.loadRequest(Uri.parse(params.url));
      // print(params.url);
    });
  }

  @override
  Widget build(BuildContext context) {
    final WebViewPageRouteParams params = ModalRoute.of(context)!.settings.arguments as WebViewPageRouteParams;
    return Scaffold(
      backgroundColor: DarkColors.bgColor,
      body: Column(
        children: [
          NavHeader(title: params.title),
          const SizedBox(height: 10),
          Expanded(
            child: WebViewWidget(controller: controller),
          ),
        ],
      ),
    );
  }
}
