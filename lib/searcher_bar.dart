import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:searcher_app/searcher_buttons.dart';
import 'package:http/http.dart' as http;
import 'group_chip.dart';

class SearcherBar extends StatefulWidget {
  const SearcherBar({
    Key? key,
  }) : super(key: key);

  @override
  _SearcherBarState createState() => _SearcherBarState();
}

class _SearcherBarState extends State<SearcherBar> {
  final double padding = 14.0;
  final TextEditingController _textEditingController = TextEditingController();
  ValueNotifier<List<String>> suggestions = ValueNotifier(const []);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 850, minWidth: 700),
            child: Material(
              elevation: 15.0,
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(32.0),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 8.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 65,
                    minHeight: 65,
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: padding),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textEditingController,
                                  textAlignVertical: TextAlignVertical.center,
                                  style: TextStyle(color: Colors.grey[200]),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search...',
                                    hintStyle:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                  onSubmitted: (query) async {
                                    await search(query);
                                  },
                                  onChanged: (newQuery) async {
                                    List<String> newSuggestions =
                                        await getAutocompleteSuggestions(
                                            newQuery);
                                    if (newSuggestions.isNotEmpty) {
                                      suggestions.value = newSuggestions;
                                    }
                                  },
                                ),
                              ),
                              SearcherButtons(),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: padding,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                GroupChip(selected: false),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ValueListenableBuilder<List<String>>(
            valueListenable: suggestions,
            builder: (context, suggestionsList, child) {
              final bolded = _textEditingController.text.toLowerCase();
              if (bolded.isNotEmpty && suggestionsList.isNotEmpty) {
                print(suggestionsList);
                return ListView.builder(
                  itemCount: suggestionsList.length,
                  itemExtent: 40.0,
                  itemBuilder: (context, index) {
                    final suggestion = suggestionsList[index];
                    final boldedIndex = suggestion.indexOf(bolded);
                    RichText title;
                    if (boldedIndex == -1) {
                      title = RichText(
                          text: TextSpan(
                              text: suggestion,
                              style: const TextStyle(color: Colors.black)));
                    } else if (boldedIndex == 0) {
                      final remainder = suggestion.substring(bolded.length);
                      title = RichText(
                        text: TextSpan(
                            text: bolded,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            children: [
                              TextSpan(
                                  text: remainder,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal))
                            ]),
                      );
                    } else if (boldedIndex !=
                        suggestion.length - bolded.length - 1) {
                      final left = suggestion.substring(0, boldedIndex);
                      final right =
                          suggestion.substring(boldedIndex + bolded.length);
                      title = RichText(
                        text: TextSpan(
                            text: left,
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                  text: bolded,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: right,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal))
                            ]),
                      );
                    } else {
                      final remainder =
                          suggestion.substring(0, boldedIndex + bolded.length);
                      title = RichText(
                          text: TextSpan(
                              text: remainder,
                              style: const TextStyle(color: Colors.black),
                              children: [
                            TextSpan(
                                text: bolded,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))
                          ]));
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        child: ListTile(
                          title: title,
                          visualDensity: VisualDensity.compact,
                          dense: true,
                          minVerticalPadding: 0.0,
                          contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          onTap: () => search(suggestion),
                        ),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.black26))),
                      ),
                    );
                  },
                );
              } else
                return Container();
            },
          ),
        )
      ],
    );
  }

  Future<void> search(String query,
      {List<String> websites = const [], bool incognito = true}) async {
    var shell = Shell();
    String process = 'start chrome ';
    if (incognito) {
      process += '--incognito "? ';
    } else {
      process += '"? ';
    }
    websites.asMap().forEach((key, value) {
      process += 'site:$value ';
      if (key != websites.length - 1) {
        process += 'OR ';
      }
    });
    process += '$query"';
    await shell.run(process);
  }

  Future<List<String>> getAutocompleteSuggestions(String query) async {
    final response = await http.get(Uri.parse(
        'https://www.google.com/complete/search?q=$query&hl=en&client=chrome'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return List.generate(
          json[1].length, (index) => json[1][index].toString());
    }
    return [];
  }
}
