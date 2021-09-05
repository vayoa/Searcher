part of 'searcher_preview_bloc.dart';

@immutable
abstract class SearcherPreviewState {
  final String title;
  final Widget preview;
  final bool single;
  static int globalPreviewCount = 0;
  final int globalID = globalPreviewCount;

  SearcherPreviewState({
    required this.title,
    required this.preview,
    this.single = true,
  }) {
    globalPreviewCount++;
  }

  int get instanceID => 0;
}

class SearcherPreviewInitial extends AutocompletePreview {}

class AutocompletePreview extends SearcherPreviewState {
  AutocompletePreview()
      : super(title: 'Autocomplete', preview: const SearcherBarAutocomplete());
}

class NotesPreview extends SearcherPreviewState {
  NotesPreview() : super(title: 'Notes', preview: const SearcherNotesPreview());
}

class DummyPreview extends SearcherPreviewState {
  static int _instanceCount = 0;
  static final Random rnd = new Random();
  late final int _instanceID;

  DummyPreview()
      : super(
          title: 'Dummy Preview',
          preview: Container(
              color: Color.fromARGB(
            rnd.nextInt(256),
            rnd.nextInt(256),
            rnd.nextInt(256),
            rnd.nextInt(256),
          )),
          single: false,
        ) {
    _instanceID = _instanceCount;
    _instanceCount++;
  }

  @override
  int get instanceID => _instanceID;
}

class UpdatingPreview extends SearcherPreviewState {
  final String title;
  final Widget preview;
  final int from;
  final int to;

  UpdatingPreview({
    required this.title,
    required this.preview,
    required this.from,
    required this.to,
  }) : super(title: title, preview: preview);
}

class AddedPreview extends SearcherPreviewState {
  final String title;
  final Widget preview;
  final int to;

  AddedPreview({
    required this.title,
    required this.preview,
    required this.to,
  }) : super(title: title, preview: preview);
}

class RemovedPreview extends SearcherPreviewState {
  final String title;
  final Widget preview;
  final int from;

  RemovedPreview({
    required this.title,
    required this.preview,
    required this.from,
  }) : super(title: title, preview: preview);
}

class SwitchedCurrentPreview extends SearcherPreviewState {
  final String title;
  final Widget preview;
  final int newShown;

  SwitchedCurrentPreview({
    required this.title,
    required this.preview,
    required this.newShown,
  }) : super(title: title, preview: preview);
}
