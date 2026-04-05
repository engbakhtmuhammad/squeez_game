import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:squeez_game/constants.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
        ),
      )
      ..loadRequest(Uri.parse(kPrivacyPolicyUrl));
  }

  void _refresh() {
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: size.height * .05,
              bottom: size.height * .15,
            ),
            child: WebViewWidget(controller: _controller),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: size.height * .05,
            left: 20,
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Image.asset('assets/back.png'),
                ),
                TextButton(
                  onPressed: _refresh,
                  child: Image.asset('assets/update.png'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
