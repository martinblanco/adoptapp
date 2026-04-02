import 'package:flutter/material.dart';

class DropDown extends StatefulWidget {
  final List<String> textos;
  final String? initialValue;
  final Function(String)? onChanged;

  const DropDown({
    Key? key,
    required this.textos,
    this.initialValue,
    this.onChanged,
  }) : super(key: key);

  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.initialValue ?? widget.textos.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
        if (widget.onChanged != null) {
          widget.onChanged!(value!);
        }
      },
      items: widget.textos.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
