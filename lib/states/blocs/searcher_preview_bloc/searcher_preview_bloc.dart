import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:searcher_app/widgets/searcher_bar_preview/local_widgets/searcher_bar_autocomplete.dart';
import 'package:searcher_app/widgets/searcher_bar_preview/local_widgets/searcher_notes_preview.dart';

part 'searcher_preview_event.dart';

part 'searcher_preview_state.dart';

class SearcherPreviewBloc
    extends Bloc<SearcherPreviewEvent, SearcherPreviewState> {
  SearcherPreviewBloc()
      : _previews = [SearcherPreviewInitial()],
        super(SearcherPreviewInitial());

  final List<SearcherPreviewState> _previews;

  List<SearcherPreviewState> get previews => _previews;

  /// Returns the index of [preview] in [_previews] if it's in the list.
  /// If not, returns -1.
  int getPreviewIndex(SearcherPreviewState preview) {
    final Type previewType = preview.runtimeType;
    for (var i = 0; i < _previews.length; i++) {
      if (_previews[i].runtimeType == previewType) return i;
    }
    return -1;
  }

  @override
  Stream<SearcherPreviewState> mapEventToState(
    SearcherPreviewEvent event,
  ) async* {
    if (event is OpenPreview) {
      final SearcherPreviewState preview = event.preview;
      final int index = getPreviewIndex(preview);
      if (index != -1) {
        if (index != 0) {
          _previews.removeAt(index);
          _previews.insert(0, preview);
          yield UpdatingPreview(
              title: preview.title,
              preview: preview.preview,
              from: index,
              to: 0);
          yield preview;
        }
      } else {
        _previews.insert(0, preview);
        yield AddedPreview(
            title: preview.title, preview: preview.preview, to: 0);
        yield preview;
      }
    } else if (event is ClosePreview) {
      final SearcherPreviewState preview = event.preview;
      final int index = getPreviewIndex(preview);
      if (index != -1) {
        _previews.removeAt(index);
        yield RemovedPreview(
            title: preview.title, preview: preview.preview, from: index);
      }
      yield _previews[0];
    } else if (_previews.length >= 2) {
      if (event is NextPreview) {
        final SearcherPreviewState preview = _previews[0];
        _previews.removeAt(0);
        _previews.add(preview);
        yield UpdatingPreview(
            title: preview.title,
            preview: preview.preview,
            from: 0,
            to: _previews.length - 1);
        yield _previews[0];
      } else if (event is PreviousPreview) {
        final SearcherPreviewState preview = _previews.last;
        final int from = _previews.length - 1;
        _previews.removeAt(from);
        _previews.insert(0, preview);
        yield UpdatingPreview(
            title: preview.title, preview: preview.preview, from: from, to: 0);
        yield preview;
      } else if (event is MovePreview) {
        if (event.from >= 0 &&
            event.to >= 0 &&
            event.from <= _previews.length &&
            event.to <= _previews.length &&
            event.from != event.to) {
          final SearcherPreviewState preview = _previews[event.from];
          final SearcherPreviewState previous = _previews[event.to];
          _previews[event.from] = previous;
          _previews[event.to] = preview;
          final SearcherPreviewState current = _previews[0];
          yield UpdatingPreview(
              title: current.title,
              preview: current.preview,
              from: event.from,
              to: event.to);
        }
        yield _previews[0];
      }
    }
  }
}
