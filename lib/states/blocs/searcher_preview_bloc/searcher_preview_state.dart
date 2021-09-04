part of 'searcher_preview_bloc.dart';

@immutable
abstract class SearcherPreviewState {
  final String title;
  final Widget preview;

  SearcherPreviewState({required this.title, required this.preview});
}

class SearcherPreviewInitial extends AutocompletePreview {}

class AutocompletePreview extends SearcherPreviewState {
  AutocompletePreview()
      : super(title: 'Autocomplete', preview: const SearcherBarAutocomplete());
}

class NotesPreview extends SearcherPreviewState {
  NotesPreview() : super(title: 'Autocomplete', preview: const SearcherNotesPreview());
}

class DummyPreview extends SearcherPreviewState {
  DummyPreview()
      : super(title: 'Dummy Preview', preview: Container(color: Colors.white));
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
