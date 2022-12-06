import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:tabnews/data/news_data.dart';
import 'package:tabnews/data/store_secure_user.dart';
import 'package:tabnews/main.dart';
import 'package:tabnews/ui/home-page.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentPage extends StatefulWidget {
  String user;
  String slug;
  bool resposta;
  ContentPage(this.user, this.slug, this.resposta);

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  bool darkMode = false;
  bool isLoading = false;
  bool error = false;
  bool storePage = false;
  String markdownSource = "";
  Map content = {};
  List comments = [];
  List storedNews = [];
  int? indexStoredNews;

  @override
  void initState() {
    super.initState();
    StoreSecureUser.readData("darkMode").then((value) {
      setState(() {
        if (value == "1") {
          darkMode = true;
        } else {
          darkMode = false;
        }
      });
    });
    loadContent();
    loadComments();
  }

  loadContent() async {
    setState(() {
      isLoading = true;
    });
    await NewsData.getContent(widget.user, widget.slug).then((value) {
      if (value != null) {
        setState(() {
          content = value as Map;
          markdownSource = content["body"];
        });
      } else {
        setState(() {
          error = false;
        });
      }
    });
    loadStoredNews();
  }

  loadComments() async {
    await NewsData.getComments(widget.user, widget.slug).then((value) {
      if (value != null) {
        setState(() {
          comments = value;
        });
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  loadStoredNews() async {
    try {
      await StoredNewsData.readData().then((value) {
        setState(() {
          storedNews = json.decode(value);
        });
      });
    } catch (e) {
      print("Erro: $e");
    }
    if (storedNews.isNotEmpty) {
      for (var i = 0; i < storedNews.length; i++) {
        print(storedNews[i]["user"]);
        print(content["owner_username"]);
        if (storedNews[i]["user"] == content["owner_username"] &&
            storedNews[i]["slug"] == content["slug"]) {
          setState(() {
            storePage = true;
            indexStoredNews = i;
          });
        }
      }
    }
    print(storedNews);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color:
                darkMode ? Colors.white : App.primary, //change your color here
          ),
          centerTitle: true,
          title: Text(
            "TabNews",
            style: TextStyle(color: darkMode ? Colors.white : App.primary),
          ),
          backgroundColor: darkMode ? App.primary : Colors.white,
          elevation: 0,
          actions: [
            isLoading
                ? SizedBox()
                : IconButton(
                    onPressed: () async {
                      if (!storePage) {
                        try {
                          Map<String, dynamic> storedNew = Map();
                          storedNew["user"] = content["owner_username"];
                          storedNew["slug"] = content["slug"];
                          storedNew["title"] = content["title"];
                          setState(() {
                            storedNews.add(storedNew);
                          });
                          await StoredNewsData.saveData(storedNews);
                        } catch (e) {
                          print("Erro: $e");
                        }
                        setState(() {
                          storePage = true;
                        });
                      } else {
                        try {
                          setState(() {
                            storedNews.removeAt(indexStoredNews!);
                          });
                          await StoredNewsData.saveData(storedNews);
                        } catch (e) {
                          print("Erro: $e");
                        }
                        setState(() {
                          storePage = false;
                        });
                      }
                    },
                    icon: Icon(
                      storePage
                          ? FontAwesomeIcons.solidFloppyDisk
                          : FontAwesomeIcons.floppyDisk,
                      color: darkMode ? Colors.white : App.primary,
                    )),
            widget.resposta
                ? IconButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()),
                          (route) => false);
                    },
                    icon: Icon(
                      FontAwesomeIcons.house,
                      color: darkMode ? Colors.white : App.primary,
                    ))
                : const SizedBox()
          ],
        ),
        backgroundColor: darkMode ? App.primary : Colors.white,
        body: error
            ? Container(
                margin: const EdgeInsets.all(25),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Houve um erro ao carregar as notícias, tente novamente mais tarde",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: darkMode ? Colors.white : App.primary,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                          onPressed: () {
                            loadContent();
                          },
                          child: const Text("Tentar novamente"))
                    ],
                  ),
                ),
              )
            : isLoading
                ? Center(
                    child: LoadingBouncingGrid.circle(
                      backgroundColor: darkMode ? Colors.white : App.primary,
                    ),
                  )
                : SingleChildScrollView(
                    child: Container(
                    margin: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              content["owner_username"],
                              style: TextStyle(
                                  color: darkMode ? Colors.white : App.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              dateFormater(
                                  DateTime.parse(content["created_at"])),
                              style: TextStyle(
                                  color: darkMode ? Colors.white : App.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${content["tabcoins"].toString()} tabcoins",
                              style: TextStyle(
                                  color: darkMode ? Colors.white : App.primary,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        const Divider(
                          height: 15,
                          color: Colors.transparent,
                        ),
                        widget.resposta
                            ? const SizedBox()
                            : Text(content["title"],
                                style: TextStyle(
                                    color:
                                        darkMode ? Colors.white : App.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                        const Divider(
                          height: 15,
                          color: Colors.transparent,
                        ),
                        MarkdownWidget(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          data: markdownSource,
                          styleConfig: StyleConfig(
                              markdownTheme: darkMode
                                  ? MarkdownTheme.darkTheme
                                  : MarkdownTheme.lightTheme,
                              pConfig: PConfig(onLinkTap: (url) {
                                launchUrl(Uri.parse(url!));
                              })),
                        ),
                        Divider(
                          height: 15,
                          color: darkMode ? Colors.white : App.primary,
                        ),
                        Text(
                          "Comentários",
                          style: TextStyle(
                              color: darkMode ? Colors.white : App.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const Divider(
                          height: 15,
                          color: Colors.transparent,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return commentTile(index);
                          },
                        )
                      ],
                    ),
                  )));
  }

  commentTile(index) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 0.5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            )
          ],
          borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContentPage(
                    comments[index]["owner_username"],
                    comments[index]["slug"],
                    true),
              ));
        },
        title: MarkdownWidget(
          shrinkWrap: true,
          selectable: false,
          physics: const NeverScrollableScrollPhysics(),
          data: comments[index]["body"],
          styleConfig: StyleConfig(
            markdownTheme: MarkdownTheme.lightTheme,
          ),
        ),
        subtitle: Text(
          "${comments[index]["tabcoins"]} tabcoins · ${comments[index]["children_deep_count"]} comentários · ${comments[index]["owner_username"]} · ${dateFormater(DateTime.parse(comments[index]["created_at"]))}",
          style: const TextStyle(color: Color.fromARGB(255, 100, 100, 100)),
        ),
      ),
    );
  }

  dateFormater(DateTime? data) {
    DateTime now = DateTime.now();
    var outFormat = DateFormat('dd');
    var formatedNow = outFormat.format(now);
    var formated = outFormat.format(data!);
    int days = int.parse(formatedNow) - int.parse(formated);
    if (days > 0) {
      return "$days dias atrás";
    } else {
      return "Publicado hoje";
    }
  }
}
