import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:searcher_app/States/Blocs/Searcher%20Bloc/searcher_bloc.dart';
import 'package:searcher_app/States/Provider/searcher_app_state.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class AnimatedWaves extends StatefulWidget {
  const AnimatedWaves({Key? key}) : super(key: key);

  @override
  _AnimatedWavesState createState() => _AnimatedWavesState();
}

class _AnimatedWavesState extends State<AnimatedWaves>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearcherBloc, SearcherState>(
      bloc: Provider.of<SearcherAppState>(context).searcherBloc,
      listener: (context, state) {
        if (state is SearcherSuggestionsLoading) {
          _animationController.forward();
        } else if (state is SearcherSuggestionsClear) {
          _animationController.reverse();
        }
      },
      child: AnimateWaves(animation: _animationController),
    );
  }
}

class AnimateWaves extends AnimatedWidget {
  AnimateWaves({Key? key, required Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    final CurvedAnimation curvedAnimation =
        CurvedAnimation(parent: animation, curve: Curves.easeInOut);
    return WaveWidget(
      config: CustomConfig(
        durations: const [35000, 19440, 10800, 6000],
        heightPercentages: const [0.20, 0.23, 0.25, 0.30],
        blur: const MaskFilter.blur(BlurStyle.solid, 3),
        colors: [
          Colors.grey[700]!,
          Colors.grey[600]!,
          Colors.grey[500]!,
          Colors.grey[400]!,
        ],
      ),
      waveAmplitude: 0,
      size: Size(double.infinity,
          Tween<double>(begin: 0.0, end: 20.0).animate(curvedAnimation).value),
    );
  }
}
