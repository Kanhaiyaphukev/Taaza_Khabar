import 'package:flutter/material.dart';

class NewsWebView extends StatefulWidget {
  final String url;
  const NewsWebView({super.key, required this.url});

  @override
  State<NewsWebView> createState() => _NewsWebViewState();
}

class _NewsWebViewState extends State<NewsWebView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 136, 136, 45),
        title: const Text("NEWS PULSE"),
      ),
    );
  }
}
