import 'package:flutter/material.dart';

class DropDown extends StatefulWidget {
  const DropDown({Key? key, required this.textos}) : super(key: key);
  final List<String> textos;

  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  String dropdownValue = '';

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.textos.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: dropdownValue,
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
      },
      isExpanded: true,
      items: widget.textos
          .map((e) => DropdownMenuItem(
                child: Text(e, style: TextStyle(color: Colors.orange)),
                value: e,
              ))
          .toList(),
      underline: Container(
        height: 3,
        color: Colors.orange,
      ),
    );
  }
}
