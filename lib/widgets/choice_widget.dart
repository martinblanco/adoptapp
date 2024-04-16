import 'package:flutter/material.dart';

class Choice<T> extends StatefulWidget {
  final List<ButtonSegment<T>> segments;
  final Set<T> initialSelection;
  final void Function(Set<T>) onSelectionChanged;
  final bool multiSelectionEnabled;

  Choice({
    required this.segments,
    required this.initialSelection,
    required this.onSelectionChanged,
    this.multiSelectionEnabled = false,
  });

  @override
  State<Choice<T>> createState() => _ChoiceState<T>();
}

class _ChoiceState<T> extends State<Choice<T>> {
  late Set<T> selectedValues;

  @override
  void initState() {
    super.initState();
    selectedValues = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: widget.segments,
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.orange,
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: Colors.orange,
      ),
      selected: selectedValues,
      onSelectionChanged: (Set<T> newSelection) {
        setState(() {
          selectedValues = newSelection;
        });
        widget.onSelectionChanged(selectedValues);
      },
      multiSelectionEnabled: widget.multiSelectionEnabled,
    );
  }
}
