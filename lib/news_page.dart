import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Article {
  final String title;
  final String url;
  final String? urlToImage;
  final String source;

  Article({
    required this.title,
    required this.url,
    this.urlToImage,
    required this.source,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      source: json['source']['name'] ?? 'Unknown Source',
    );
  }
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<Article>> future;
  String? searchTerm;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  List<String> categoryItems = [
    "general",
    "business",
    "entertainment",
    "health",
    "science",
    "sports",
    "technology",
  ];
  late String selectedCategory;

  @override
  void initState() {
    selectedCategory = categoryItems[0];
    future = getNewsData();

    super.initState();
  }

  Future<List<Article>> getNewsData() async {
    String apiKey =
        "775425bfa9cf4b24a7cfe7284ec37454"; // Replace with your API key

    // Constructing query parameters
    final queryParameters = {
      'country': 'us',
      'category': selectedCategory,
      if (searchTerm != null && searchTerm!.isNotEmpty) 'q': searchTerm!,
      'apiKey': apiKey,
    };

    final url = Uri.https('newsapi.org', '/v2/top-headlines', queryParameters);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['articles'] as List)
          .map((article) => Article.fromJson(article))
          .toList();
    } else {
      throw Exception('Failed to load news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isSearching ? searchAppBar() : appBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildCategories(),
            Expanded(
              child: FutureBuilder<List<Article>>(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error loading the news"),
                    );
                  } else {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return _buildNewsListView(snapshot.data!);
                    } else {
                      return const Center(
                        child: Text("No news available"),
                      );
                    }
                  }
                },
                future: future,
              ),
            ),
          ],
        ),
      ),
    );
  }

  searchAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        color: Colors.white,
        icon: const Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          setState(() {
            isSearching = false;
            searchTerm = null;
            searchController.text = "";
            future = getNewsData();
          });
        },
      ),
      title: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.white),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
      actions: [
        IconButton(
            color: Colors.white,
            onPressed: () {
              setState(() {
                searchTerm = searchController.text;
                future = getNewsData();
              });
            },
            icon: const Icon(Icons.search)),
      ],
    );
  }

  appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: const Text("Taaza Khabar", style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
            onPressed: () {
              setState(() {
                isSearching = true;
              });
            },
            icon: const Icon(Icons.search)),
      ],
    );
  }

  Widget _buildNewsListView(List<Article> articleList) {
    return ListView.builder(
      itemBuilder: (context, index) {
        Article article = articleList[index];
        return _buildNewsItem(article);
      },
      itemCount: articleList.length,
    );
  }

  Widget _buildNewsItem(Article article) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsWebView(url: article.url),
            ));
      },
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: Image.network(
                  article.urlToImage ?? "",
                  fit: BoxFit.fitHeight,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      article.source,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedCategory = categoryItems[index];
                  future = getNewsData();
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  categoryItems[index] == selectedCategory
                      ? Colors.black
                      : Colors.black,
                ),
              ),
              child: Text(
                categoryItems[index],
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        itemCount: categoryItems.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}

class NewsWebView extends StatelessWidget {
  final String url;

  const NewsWebView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News Article')),
      body: Center(
        child: Text('Open WebView here for $url'),
      ),
    );
  }
}
