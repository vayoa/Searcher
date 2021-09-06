import 'dart:async';
import 'dart:math';
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
  int _shown = 0;

  List<SearcherPreviewState> get previews => _previews;

  int get shown => _shown;

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
      if (preview.single && index != -1) {
        if (index != _shown) {
          _shown = index;
          yield SwitchedCurrentPreview(
              title: preview.title, preview: preview.preview, newShown: index);
          yield preview;
        }
      } else {
        _previews.insert(0, preview);
        yield AddedPreview(
            title: preview.title, preview: preview.preview, to: 0);
        _shown = 0;
        yield SwitchedCurrentPreview(
            title: preview.title, preview: preview.preview, newShown: 0);
        yield preview;
      }
    } else if (_previews.length >= 2) {
      if (event is ClosePreview) {
        final SearcherPreviewState preview = event.preview;
        final int index = getPreviewIndex(preview);
        if (index != -1) {
          _previews.removeAt(index);
          yield RemovedPreview(
              title: preview.title, preview: preview.preview, from: index);
          if (_shown != 0 && index <= _shown) {
            _shown--;
            final SearcherPreviewState switchedPreview = _previews[_shown];
            yield SwitchedCurrentPreview(
                title: switchedPreview.title,
                preview: switchedPreview.preview,
                newShown: _shown);
          }
        }
        yield _previews[_shown];
      } else if (event is CloseCurrentPreview) {
        final SearcherPreviewState preview = _previews[_shown];
        _previews.removeAt(_shown);
        yield RemovedPreview(
            title: preview.title, preview: preview.preview, from: _shown);
        if (_shown != 0) {
          _shown--;
          final SearcherPreviewState switchedPreview = _previews[_shown];
          yield SwitchedCurrentPreview(
              title: switchedPreview.title,
              preview: switchedPreview.preview,
              newShown: _shown);
        }
        yield _previews[_shown];
      } else if (event is NextPreview) {
        yield incrementShown();
        yield _previews[_shown];
      } else if (event is PreviousPreview) {
        yield decrementShown();
        yield _previews[_shown];
      } else if (event is MovePreview) {
        if (event.from >= 0 &&
            event.to >= 0 &&
            event.from <= _previews.length &&
            event.to <= _previews.length &&
            event.from != event.to) {
          print('from: ${event.from}, to: ${event.to}.');
          print('shown: $_shown.');
          final SearcherPreviewState preview = _previews[event.from];
          _previews.removeAt(event.from);
          _previews.insert(event.to, preview);
          if (_shown == event.from) {
            _shown = event.to;
          } else if (_shown == event.to) {
            if (_shown > event.from)
              yield decrementShown();
            else
              yield incrementShown();
          } else {
            if (_shown > event.to)
              yield incrementShown();
            else
              yield decrementShown();
          }
          print('new shown: $_shown.');
          final SearcherPreviewState current = _previews[_shown];
          yield UpdatingPreview(
              title: current.title,
              preview: current.preview,
              from: event.from,
              to: event.to);
        }
        yield _previews[_shown];
      }
    }
  }

  SwitchedCurrentPreview incrementShown() {
    if (_shown == _previews.length - 1)
      _shown = 0;
    else
      _shown++;
    final SearcherPreviewState preview = _previews[_shown];
    return SwitchedCurrentPreview(
        title: preview.title, preview: preview.preview, newShown: _shown);
  }

  SwitchedCurrentPreview decrementShown() {
    if (_shown == 0)
      _shown = _previews.length - 1;
    else
      _shown--;
    final SearcherPreviewState preview = _previews[_shown];
    return SwitchedCurrentPreview(
        title: preview.title, preview: preview.preview, newShown: _shown);
  }
}
