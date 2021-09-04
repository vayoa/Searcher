import 'package:flutter/material.dart';
import 'package:searcher_app/states/provider/searcher_app_state.dart';

class SearcherCommand {
  final String name;
  final String description;
  final SearcherCommandType type;
  final void Function(SearcherAppState) command;
  final IconData? iconData;

  IconData get icon => iconData ?? type.toIcon();

  const SearcherCommand({
    required this.name,
    required this.description,
    required this.type,
    required this.command,
    this.iconData,
  });
}

enum SearcherCommandType {
  setting,
  action,
}

extension SearcherCommandTypeExtensions on SearcherCommandType {
  IconData toIcon() {
    switch (this) {
      case SearcherCommandType.setting:
        return Icons.settings_rounded;
      case SearcherCommandType.action:
        return Icons.adjust;
    }
  }
}
