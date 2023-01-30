import 'package:flutter/material.dart';

int indexSelected = -1;

class SelectorCard extends StatefulWidget {
  SelectorCard(
      {required this.title, required this.texts, required this.icons}) {
    _isSelected = List.generate(texts.length, (index) => false);
    for (int i = 0; i < texts.length; i++) {
      children.add(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icons[i],
            size: 30,
          ),
          Text(texts[i]),
        ],
      ));
    }
  }

  String title;
  List<String> texts;
  List<IconData> icons;
  List<Widget> children = [];
  late final List<bool> _isSelected;

  int selected() {
    return indexSelected;
  }

  @override
  _SelectorCardState createState() => _SelectorCardState();
}

class _SelectorCardState extends State<SelectorCard> {
  @override
  Widget build(BuildContext context) {
    var _isSelected = widget._isSelected;
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            const SizedBox(height: 20),
            Center(
              child: ToggleButtons(
                children: widget.children,
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                onPressed: (int index) {
                  setState(() {
                    for (int buttonIndex = 0;
                        buttonIndex < _isSelected.length;
                        buttonIndex++) {
                      if (buttonIndex == index) {
                        if (!_isSelected[index]) {
                          _isSelected[buttonIndex] = true;
                          indexSelected = buttonIndex;
                        }
                      } else {
                        _isSelected[buttonIndex] = false;
                      }
                    }
                  });
                },
                isSelected: _isSelected,
                borderRadius: BorderRadius.circular(30),
                selectedColor: Colors.white,
                fillColor: Colors.orange,
                color: Colors.orange,
                borderColor: Colors.orange,
                selectedBorderColor: Colors.orange,
                borderWidth: 2,
                splashColor: Colors.teal[100],
                constraints: BoxConstraints.expand(
                    width: MediaQuery.of(context).size.width /
                        (1.2 * _isSelected.length),
                    height: 60),
              ),
            )
          ],
        ),
      ),
    );
  }
}
