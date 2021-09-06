import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:searcher_app/modals/searcher_command.dart';
import 'package:searcher_app/modals/searcher_commands.dart';
import 'package:searcher_app/states/blocs/searcher_bloc/searcher_bloc.dart';
import 'package:searcher_app/states/provider/searcher_app_state.dart';

class SearcherBarAutocomplete extends StatelessWidget {
  const SearcherBarAutocomplete({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearcherBloc, SearcherState>(
      bloc: Provider.of<SearcherAppState>(context, listen: false).searcherBloc,
      builder: (context, state) {
        if (state is SearcherSuggestionsDone) {
          final suggestionsMap = state.suggestions;
          final formattedQuery = state.formattedText;
          final List<String> suggestionsList = suggestionsMap.keys.toList();
          final List<String> descriptionsList = suggestionsMap.values.toList();
          final bolded = formattedQuery.toLowerCase();
          if (bolded.isNotEmpty && suggestionsList.isNotEmpty) {
            return ListView.builder(
              itemCount: suggestionsList.length,
              itemExtent: 50.0,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final hasDescription = descriptionsList[index].isNotEmpty;
                final suggestion = suggestionsList[index];
                SearcherCommand? entry;
                if (hasDescription) {
                  entry = SearcherCommands.all[suggestion];
                }
                final boldedIndex = suggestion.indexOf(bolded);
                RichText title;
                if (boldedIndex == -1) {
                  title = RichText(
                      text: TextSpan(
                          text: suggestion,
                          style: TextStyle(color: Colors.grey[300])));
                } else if (boldedIndex == 0) {
                  final remainder = suggestion.substring(bolded.length);
                  title = RichText(
                    text: TextSpan(
                        text: bolded,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[300]),
                        children: [
                          TextSpan(
                              text: remainder,
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal))
                        ]),
                  );
                } else if (boldedIndex != suggestion.length - bolded.length) {
                  final left = suggestion.substring(0, boldedIndex);
                  final right =
                      suggestion.substring(boldedIndex + bolded.length);
                  title = RichText(
                    text: TextSpan(
                        text: left,
                        style: TextStyle(color: Colors.grey[300]),
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
                  final remainder = suggestion.substring(0, boldedIndex);
                  title = RichText(
                      text: TextSpan(
                          text: remainder,
                          style: TextStyle(color: Colors.grey[300]),
                          children: [
                        TextSpan(
                            text: bolded,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))
                      ]));
                }
                return Container(
                  child: ListTile(
                    title: title,
                    subtitle: hasDescription
                        ? Text(descriptionsList[index],
                            style: TextStyle(color: Colors.grey[500]))
                        : null,
                    leading: entry == null
                        ? null
                        : Icon(entry.icon, color: Colors.grey[300]),
                    minLeadingWidth: 0.0,
                    visualDensity: VisualDensity.compact,
                    dense: hasDescription,
                    minVerticalPadding: 0.0,
                    hoverColor: Colors.black12,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    onTap: () =>
                        Provider.of<SearcherAppState>(context, listen: false)
                            .runInCurrentMode(suggestion),
                  ),
                  decoration: BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.black26))),
                );
              },
            );
          }
        }
        return SizedBox(width: 0, height: 0);
      },
    );
  }
}
