import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:searcher_app/States/Blocs/Searcher%20Bloc/searcher_bloc.dart';

class SearcherAppState extends ChangeNotifier {
  bool incognito = true;
  SearcherMode _mode = SearcherMode.search;
  late SearcherBloc searcherBloc;

  SearcherAppState() {
    searcherBloc = SearcherBloc(this);
  }

  SearcherMode get currentSearcherMode => this._mode;

  set currentSearcherMode(SearcherMode newMode) {
    if (newMode != _mode) {
      _mode = newMode;
      notifyListeners();
    }
  }

  Future<void> getSuggestions(String text) async {
    if (text.isEmpty) {
      searcherBloc.add(ClearSuggestions());
    }
    else {
      SearcherMode newMode = SearcherModeParser.fromString(text);
      this.currentSearcherMode = newMode;
      searcherBloc.add(GetSuggestions(text));
    }
  }

  Future<void> run(String text) async {
    text = text.trim();
    String command;
    SearcherMode newMode = SearcherModeParser.fromString(text);
    switch (newMode) {
      case SearcherMode.searcherCommand:
        command = text.substring(2).trim();
        break;
      case SearcherMode.terminal:
        command = text.substring(2).trim();
        break;
      case SearcherMode.search:
        command = text;
        break;
    }
    await runInMode(newMode, command);
    /* TODO: This is done so we won't confuse the user since we go back to
        search mode after a run. If this behaviour is ever changed make sure to
        change this here as well. */
    currentSearcherMode = SearcherMode.search;
    searcherBloc.add(ClearSuggestions());
  }

  Future<void> runInMode(SearcherMode mode, String text) async {
    this.currentSearcherMode = mode;
    await runInCurrentMode(text);
  }

  Future<void> runSuggestion(String suggestion) async {
    await runInCurrentMode(suggestion);
    searcherBloc.add(ClearSuggestions());
  }

  Future<void> runInCurrentMode(String text) async {
    switch (currentSearcherMode) {
      case SearcherMode.search:
        await search(text);
        return;
      case SearcherMode.searcherCommand:
        runCommand(text);
        return;
      case SearcherMode.terminal:
        await runShellScript(text);
        return;
    }
  }

  Future<void> runShellScript(String command) async {
    var shell = Shell();
    await shell.run(command);
    shell.kill();
  }

  Future<void> search(String query, {List<String> websites = const []}) async {
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
    shell.kill();
  }

  runCommand(String command) {
    switch (command) {
      case 'incognito':
        incognito = !incognito;
        notifyListeners();
        break;
    }
  }
}

enum SearcherMode {
  search,
  searcherCommand,
  terminal,
}

extension SearcherModeParser on SearcherMode {
  static SearcherMode fromString(String text) {
    text = text.trim();
    if (text.startsWith('!>')) return SearcherMode.searcherCommand;
    if (text.startsWith('>>')) return SearcherMode.terminal;
    return SearcherMode.search;
  }
}
