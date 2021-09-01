import 'package:flutter/material.dart';

class GroupChip extends StatelessWidget {
  const GroupChip({
    Key? key,
    required this.selected,
  }) : super(key: key);

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      visualDensity: VisualDensity.compact,
      label: Container(width: 10),
      selected: this.selected,
    );
  }
}