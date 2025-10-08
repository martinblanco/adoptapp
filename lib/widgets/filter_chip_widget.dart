import 'package:flutter/material.dart';

class CustomFilterChip extends StatefulWidget {
  final String text;
  final bool selected;
  final Function(bool) onChanged;

  const CustomFilterChip({Key? key, 
    required this.text,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomFilterChipState createState() => _CustomFilterChipState();
}

class _CustomFilterChipState extends State<CustomFilterChip> {
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.text),
      selected: widget.selected,
      selectedColor: Colors.orange,
      checkmarkColor: widget.selected ? Colors.white : Colors.orange,
      labelStyle: TextStyle(
        color: widget.selected ? Colors.white : Colors.orange,
      ),
      onSelected: (bool value) {
        setState(() {
          widget.onChanged(value);
        });
      },
    );
  }
}
