import 'package:flutter/material.dart';
import 'package:searcher_app/modals/searcher_command.dart';
import 'package:searcher_app/states/blocs/searcher_preview_bloc/searcher_preview_bloc.dart';

class SearcherCommands {
  static final Map<String, SearcherCommand> all = {
    'incognito': SearcherCommand(
      name: 'incognito',
      description:
          'Switches whether Chrome will open in incognito mode or not.',
      type: SearcherCommandType.setting,
      command: (appState) {
        appState.switchIncognito();
      },
    ),
    'note': SearcherCommand(
      name: 'note',
      description: 'Save a new note.',
      type: SearcherCommandType.action,
      iconData: Icons.note_rounded,
      command: (_) {},
    ),
    'notes': SearcherCommand(
      name: 'notes',
      description: 'Display all of your saved notes.',
      type: SearcherCommandType.action,
      iconData: Icons.folder_rounded,
      command: (appState) {
        appState.previewBloc.add(OpenPreview(preview: NotesPreview()));
      },
    ),
    'expand': SearcherCommand(
      name: 'expand',
      description: 'Display all of your saved notes.',
      type: SearcherCommandType.action,
      iconData: Icons.aspect_ratio_rounded,
      command: (_) {},
    ),
    'dummy': SearcherCommand(
      name: 'dummy',
      description: 'Display a dummy searcher preview.',
      type: SearcherCommandType.action,
      command: (appState) {
        appState.previewBloc.add(OpenPreview(preview: DummyPreview()));
      },
    ),
    'next': SearcherCommand(
      name: 'next',
      description: 'Focus on the next preview.',
      type: SearcherCommandType.action,
      command: (appState) {
        appState.previewBloc.add(NextPreview());
      },
    ),
    'previous': SearcherCommand(
      name: 'previous',
      description: 'Focus on the previous preview.',
      type: SearcherCommandType.action,
      command: (appState) {
        appState.previewBloc.add(PreviousPreview());
      },
    ),
    'close': SearcherCommand(
      name: 'close',
      description: 'Close the current focused preview.',
      type: SearcherCommandType.action,
      command: (appState) {
        appState.previewBloc.add(CloseCurrentPreview());
      },
    ),
  };
}
