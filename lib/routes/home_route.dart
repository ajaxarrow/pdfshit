import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdfshits/widgets/article_form_dialog.dart';
import 'package:pdfshits/widgets/article_list.dart';

import '../models/article.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  List<Article> _articles = [];

  Future<void> fetchArticles() async {
    _articles.clear();
    _articles = await Article().getArticles();
  }

  void _refreshList(){
    setState(() {

    });
  }

  void _removeArticle(String id) async {
    await Article(id: id).deleteArticle();
    _refreshList();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text("Article Deleted!"),
        )
    );
  }

  void _openArticleDialog(){
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        builder: (ctx) => ArticleFormDialog(
          mode: Mode.create,
          onAddArticle: _refreshList,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchArticles(),
        builder: (ctx, snapshot) {
          Widget body;
          if (snapshot.connectionState == ConnectionState.waiting) {
            body = const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            body = Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Widget mainContent = Container(
              width: double.infinity,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'OOPS!',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize:  50
                    ),
                  ),
                  SizedBox(height:  5),
                  Text(
                      'There are no available articles found. Try adding some!'
                  )
                ],
              ),
            );

            if (_articles.isNotEmpty) {
              mainContent = ArticleList(
                onUpdateArticleList: _refreshList,
                articles: _articles,
                onRemoveArticle: _removeArticle
              );
            }

            body = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height:  10),
                _articles.isNotEmpty ? const Padding(
                  padding: EdgeInsets.only(left:  15, top:  5, bottom:  5),
                  child: Text(
                    'Notes',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize:  23
                    ),
                  ),
                ) : const SizedBox.shrink(),
                Expanded(child: mainContent),
              ],
            );
          }

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                'artikulo.',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize:  24
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(
                      Icons.logout,
                      size:  25,
                    )
                )
              ],
            ),
            body: body,
            floatingActionButton: FloatingActionButton(
              onPressed: _openArticleDialog,
              child: const Icon(Icons.add),
            ),
          );
        }
    );
  }
}
