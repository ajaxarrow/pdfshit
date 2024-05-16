import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdfshits/models/article.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

enum Mode {update, create}

class ArticleFormDialog extends StatefulWidget {
  const ArticleFormDialog({
    super.key,
    this.article,
    this.mode,
    this.onAddArticle,
    this.onUpdateArticle
  });

  final void Function()? onAddArticle;
  final void Function()? onUpdateArticle;
  final Mode? mode;
  final Article? article;

  @override
  State<ArticleFormDialog> createState() => _ArticleFormDialogState();
}

class _ArticleFormDialogState extends State<ArticleFormDialog> {
  final _form = GlobalKey<FormState>();
  final articleTitleController = TextEditingController();
  String path = '';
  bool isSaved = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.article != null){
      articleTitleController.text = widget.article!.title!;
    }
  }

  void addArticle(Article article) async{
    await article.addArticle();
    widget.onAddArticle!();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(seconds: 2),
      content: Text("Article Added!"),
    ));
  }

  void updateArticle(Article article) async{
    await article.updateArticle();
    widget.onUpdateArticle!();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(seconds: 2),
      content: Text("Article Updated!"),
    ));
  }

  void submitArticle() {
    final isValid = _form.currentState!.validate();
    if(!isValid){
      return;
    }
    _form.currentState!.save();
    if (widget.mode == Mode.create) {
      addArticle(Article(
        path: path,
        title: articleTitleController.text,
      ));
    } else {
      updateArticle(Article(
        path: path,
        title: articleTitleController.text,
        id: widget.article!.id!
      ));
    }
  }

  void pickfile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(

    );
    var uuid = const Uuid();
    String fileName = uuid.v4();
    final pathName = 'public/${fileName}.pdf';
    setState(() {
      path = pathName;
    });

    if (result != null) {
      if(kIsWeb){
        Uint8List bytes = Uint8List.fromList(result.files.single.bytes!);
        try {
          await Supabase.instance.client.storage
              .from('pdf')
              .uploadBinary(pathName, bytes);

          setState(() {
            isSaved = true;
          });
        } on StorageException catch (e) {
          print("Upload failed: $e");
        }
      } else {
        File file = File(result.files.single.path!);
        try {
          await Supabase.instance.client.storage
              .from('pdf')
              .upload(pathName, file);
          setState(() {
            isSaved = true;
          });
        } on StorageException catch (e) {
          print("Upload failed: $e");
        }
      }

    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 30
              ),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.mode == Mode.create
                              ? 'Add Article'
                              : 'Update Article',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20
                          ),
                        ),
                        IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close_rounded))
                      ],
                    ),
                    const SizedBox(height: 25),
                    const Text('Title:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      validator: (value){
                        if (value!.trim().isEmpty || value == null ){
                          return 'Title must not be empty';
                        }
                        return null;
                      },
                      controller: articleTitleController,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.note),
                          hintText: 'Enter Article Title'
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 19)
                          ),
                          onPressed: pickfile,
                          child: Text(
                              isSaved ? 'Pick PDF (PDF Selected)' : 'Pick PDF (No PDF Selected)',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              )
                          )
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xfff3ecd8),
                                  padding: const EdgeInsets.symmetric(vertical: 19)
                              ),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xffaa763c)
                                  )
                              )
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 19)
                              ),
                              onPressed: submitArticle,
                              child: const Text(
                                  'Save',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  )
                              )
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }
}
