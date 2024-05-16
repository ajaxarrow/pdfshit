import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdfshits/routes/pdf_viewer_route.dart';
import 'package:pdfshits/widgets/article_details_dialog.dart';
import 'package:pdfshits/widgets/article_form_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/article.dart';

class ArticleItem extends StatelessWidget {
  const ArticleItem({
    super.key,
    required this.article,
    required this.onUpdateArticleList
  });

  final Article article;
  final Function() onUpdateArticleList;

  @override
  Widget build(BuildContext context) {

    Future<void> printPDF() async {
      try {
        final doc = pw.Document();

        doc.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Text('Hello Jimmy'),
              );
            }
        ));

        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => doc.save(),
        );
      } catch (e) {
        print(e);
      }
    }

    void openArticleFormDialog(){
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          builder: (ctx) => ArticleFormDialog(
            mode: Mode.update,
            article: article,
            onUpdateArticle: onUpdateArticleList,
          )
      );
    }

    void openArticleDetailsDialog(){
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          builder: (ctx) => ArticleDetailsDialog(article: article)
      );
    }

    return GestureDetector(
      onTap: openArticleDetailsDialog,
      child: Card(
        margin: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 15
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                      article.title!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16
                      )
                  ),
                  const Spacer(),
                  FirebaseAuth.instance.currentUser?.uid == article.uid ? TextButton.icon(
                      onPressed: openArticleFormDialog,
                      label: const Text('Edit'),
                      icon: const Icon(Icons.edit_rounded,
                          size: 16)
                  ) : Container()
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PDFViewerRoute(
                        path: article.path!,
                      )));
                    },
                    label: const Text('Preview PDF'),
                    icon: const Icon(
                      Icons.edit_rounded,
                      size: 16),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: printPDF,
                    label: const Text('Print PDF'),
                    icon: const Icon(
                        Icons.edit_rounded,
                        size: 16),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
