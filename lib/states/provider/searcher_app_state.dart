import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:searcher_app/modals/searcher_commands.dart';
import 'package:searcher_app/modals/searcher_group.dart';
import 'package:searcher_app/states/blocs/searcher_bloc/searcher_bloc.dart';
import 'package:searcher_app/states/blocs/searcher_preview_bloc/searcher_preview_bloc.dart';

class SearcherAppState extends ChangeNotifier {
  bool _incognito = true;
  SearcherMode _mode = SearcherMode.search;
  late SearcherBloc _searcherBloc;
  SearcherPreviewBloc _previewBloc = SearcherPreviewBloc();
  final List<SearcherGroup> _searcherGroups = [
    SearcherGroup(
      title: 'Programming',
      websites: const [
        'www.stackoverflow.com/',
        'https://www.codegrepper.com',
      ],
    )
  ];
  int _currentSearcherGroup = 0;

  SearcherAppState() {
    _searcherBloc = SearcherBloc(this);
  }

  SearcherBloc get searcherBloc => _searcherBloc;

  SearcherPreviewBloc get previewBloc => _previewBloc;

  SearcherMode get currentSearcherMode => this._mode;

  List<SearcherGroup> get searcherGroups => _searcherGroups;

  int get currentSearcherGroup => _currentSearcherGroup;

  set currentSearcherMode(SearcherMode newMode) {
    if (newMode != _mode) {
      _mode = newMode;
      notifyListeners();
    }
  }

  bool get incognito => _incognito;

  switchIncognito() {
    _incognito = !_incognito;
    notifyListeners();
  }

  Future<void> getSuggestions(String text) async {
    if (text.isEmpty) {
      _searcherBloc.add(ClearSuggestions());
    } else {
      SearcherMode newMode = SearcherModeParser.fromString(text);
      this.currentSearcherMode = newMode;
      _searcherBloc.add(GetSuggestions(text));
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
    _searcherBloc.add(ClearSuggestions());
  }

  Future<void> runInMode(SearcherMode mode, String text) async {
    this.currentSearcherMode = mode;
    await runInCurrentMode(text);
  }

  Future<void> runSuggestion(String suggestion) async {
    await runInCurrentMode(suggestion);
    _searcherBloc.add(ClearSuggestions());
  }

  Future<void> runInCurrentMode(String text) async {
    switch (currentSearcherMode) {
      case SearcherMode.search:
        await currentSearcherGroupSearch(text);
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

  Future<void> search(String query, {SearcherGroup? searcherGroup}) async {
    var shell = Shell();
    String process = 'start chrome ';
    if (_incognito) {
      process += '--incognito "? ';
    } else {
      process += '"? ';
    }
    if (searcherGroup != null) {
      searcherGroup.websites.asMap().forEach((key, value) {
        process += 'site:$value ';
        if (key != searcherGroup.websites.length - 1) {
          process += 'OR ';
        }
      });
    }
    process += '$query"';
    await shell.run(process);
    shell.kill();
  }

  runCommand(String command) {
    SearcherCommands.all[command]!.command.call(this);
  }

  Future<void> currentSearcherGroupSearch(String query) async {
    SearcherGroup? _searcherGroup;
    if (_searcherGroups.isNotEmpty &&
        _currentSearcherGroup < _searcherGroups.length)
      _searcherGroup = _searcherGroups[_currentSearcherGroup];
    await search(query, searcherGroup: _searcherGroup);
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
