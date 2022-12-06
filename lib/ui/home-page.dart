import 'dart:convert';

import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:linkwell/linkwell.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:tabnews/data/news_data.dart';
import 'package:tabnews/data/store_secure_user.dart';
import 'package:tabnews/main.dart';
import 'package:tabnews/ui/content-page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  String order = "Relevantes";
  String orderApi = "relevant";
  bool darkMode = false;
  bool isLoading = false;
  bool error = false;
  int page = 1;
  List news = [];
  List storedNews = [];

  @override
  void initState() {
    StoreSecureUser.readData("darkMode").then((value) {
      setState(() {
        if (value == "1") {
          darkMode = true;
        } else {
          darkMode = false;
        }
      });
    });

    loadNews();

    loadStoredNews();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  loadNews() async {
    setState(() {
      isLoading = true;
    });
    await NewsData.getNews(page, orderApi).then((value) {
      setState(() {
        if (value != null) {
          news = value;
        } else {
          error = true;
        }
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  loadStoredNews() async {
    try {
      await StoredNewsData.readData().then((value) {
        print(value);
        setState(() {
          storedNews = json.decode(value);
        });
      });
    } catch (e) {
      await StoredNewsData.saveData(storedNews);
      print("Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: darkMode ? Colors.white : App.primary, //change your color here
        ),
        title: Text(
          "TabNews",
          style: TextStyle(color: darkMode ? Colors.white : App.primary),
        ),
        backgroundColor: darkMode ? App.primary : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                launchUrl(Uri.parse("mailto:guilherme.campos137@gmail.com"));
              },
              icon: Icon(
                FontAwesomeIcons.bug,
                color: darkMode ? Colors.white : App.primary,
              )),
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Olá Mundo!"),
                        content: LinkWell(
                            "Esta aplicação foi desenvolvida por Guilherme Crisi utilizando Flutter e a API do TabNews, nenhuma publicação é criada por nós, tudo é feito e fornecido por https://www.tabnews.com.br, o código desta aplicação esta disponível no meu github https://www.github.com/Guidcrisi"),
                      );
                    });
              },
              icon: Icon(
                FontAwesomeIcons.circleExclamation,
                color: darkMode ? Colors.white : App.primary,
              )),
          IconButton(
              onPressed: () async {
                setState(() {
                  darkMode = !darkMode;
                });
                if (darkMode) {
                  await StoreSecureUser.writeData("darkMode", "1");
                } else {
                  await StoreSecureUser.writeData("darkMode", "0");
                }
              },
              icon: Icon(
                darkMode ? Icons.sunny : FontAwesomeIcons.solidMoon,
                color: darkMode ? Colors.white : App.primary,
              ))
        ],
      ),
      floatingActionButton: FloatingActionBubble(
        items: <Bubble>[
          Bubble(
            title: "Relevantes",
            iconColor: darkMode ? App.primary : Colors.white,
            bubbleColor: darkMode ? Colors.white : App.primary,
            icon: FontAwesomeIcons.filter,
            titleStyle: TextStyle(
                fontSize: 16, color: darkMode ? App.primary : Colors.white),
            onPress: () {
              _animationController.reverse();
              setState(() {
                order = "Relevantes";
                orderApi = "relevant";
                page = 1;
                loadNews();
              });
            },
          ),
          Bubble(
            title: "Antigos",
            iconColor: darkMode ? App.primary : Colors.white,
            bubbleColor: darkMode ? Colors.white : App.primary,
            icon: FontAwesomeIcons.filter,
            titleStyle: TextStyle(
                fontSize: 16, color: darkMode ? App.primary : Colors.white),
            onPress: () {
              _animationController.reverse();
              setState(() {
                order = "Antigos";
                orderApi = "old";
                page = 1;
                loadNews();
              });
            },
          ),
          Bubble(
            title: "Novos",
            iconColor: darkMode ? App.primary : Colors.white,
            bubbleColor: darkMode ? Colors.white : App.primary,
            icon: FontAwesomeIcons.filter,
            titleStyle: TextStyle(
                fontSize: 16, color: darkMode ? App.primary : Colors.white),
            onPress: () {
              _animationController.reverse();
              setState(() {
                order = "Novos";
                orderApi = "new";
                page = 1;
                loadNews();
              });
            },
          ),
          Bubble(
            title: "Salvos",
            iconColor: darkMode ? App.primary : Colors.white,
            bubbleColor: darkMode ? Colors.white : App.primary,
            icon: FontAwesomeIcons.filter,
            titleStyle: TextStyle(
                fontSize: 16, color: darkMode ? App.primary : Colors.white),
            onPress: () {
              _animationController.reverse();
              setState(() {
                order = "Salvos";
                orderApi = "relevant";
                page = 1;
                loadStoredNews();
              });
            },
          ),
        ],
        animation: _animation,
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
        iconColor: darkMode ? App.primary : Colors.white,
        iconData: FontAwesomeIcons.listUl,
        backGroundColor: darkMode ? Colors.white : App.primary,
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
                          loadNews();
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
                  margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ordenando por: $order",
                        style: TextStyle(
                            color: darkMode ? Colors.white : App.primary,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(
                        height: 15,
                        color: Colors.transparent,
                      ),
                      order == "Salvos"
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: storedNews.length,
                              itemBuilder: (context, index) {
                                return newsTile(index, true);
                              },
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: news.length,
                              itemBuilder: (context, index) {
                                return newsTile(index, false);
                              },
                            ),
                      order == "Salvos"
                          ? const SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      if (page != 1) {
                                        setState(() {
                                          page--;
                                        });
                                        loadNews();
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.angleLeft,
                                          color: page == 1
                                              ? Colors.blue.withOpacity(0.4)
                                              : Colors.blue,
                                        ),
                                        Text(
                                          "Anterior",
                                          style: TextStyle(
                                              color: page == 1
                                                  ? Colors.blue.withOpacity(0.4)
                                                  : Colors.blue),
                                        )
                                      ],
                                    )),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        page++;
                                      });
                                      loadNews();
                                    },
                                    child: Row(
                                      children: const [
                                        Text("Próximo"),
                                        Icon(FontAwesomeIcons.angleRight)
                                      ],
                                    ))
                              ],
                            )
                    ],
                  ),
                )),
    );
  }

  newsTile(index, stored) {
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
                    stored
                        ? storedNews[index]["user"]
                        : news[index]["owner_username"],
                    stored ? storedNews[index]["slug"] : news[index]["slug"],
                    false),
              ));
        },
        title: Text(
          stored ? storedNews[index]["title"] : news[index]["title"],
          style: TextStyle(color: App.primary, fontWeight: FontWeight.bold),
        ),
        subtitle: stored
            ? const Text(
                "As páginas salvas ainda não tem descrição, porém funciona! Agradeço a compreensão")
            : Text(
                "${news[index]["tabcoins"]} tabcoins · ${news[index]["children_deep_count"]} comentários · ${news[index]["owner_username"]} · ${dateFormater(DateTime.parse(news[index]["created_at"]))}",
                style:
                    const TextStyle(color: Color.fromARGB(255, 100, 100, 100)),
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
