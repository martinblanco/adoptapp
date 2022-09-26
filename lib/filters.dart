import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FiltrosPage extends StatefulWidget {
  @override
  _FiltrosPageState createState() => _FiltrosPageState();
}

class _FiltrosPageState extends State<FiltrosPage> {
  @override
  Widget build(BuildContext context) {
    // List of widgets in the drawer

    return Scaffold(
      appBar: AppBar(
        title: Text('Filtros'),
        leading: Icon(Icons.cancel),
        backgroundColor: Colors.teal,
        actions: [
          TextButton(
            child: Text('LIMPIAR'),
            onPressed: () {},
          ),
          TextButton(
            child: Text('APLICAR'),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            CustomCard(
              children: [
                Text(
                  'Ordenar por',
                ),
                DropDown(),
              ],
            ),
            CustomCard(
              children: [
                Text(
                  'Animal',
                ),
                SizedBox(
                  height: 20,
                ),
                TransactionToggle(children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.dog),
                      Text('Perros'),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.cat),
                      Text('Gatos'),
                    ],
                  ),
                ])
              ],
            ),
            CustomCard(
              children: [
                Text(
                  'Tamaño',
                ),
                SizedBox(
                  height: 20,
                ),
                TransactionToggle(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.recommend,
                          color: Colors.green,
                          size: 30,
                        ),
                        Text('Pequeño'),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thumb_down,
                          color: Colors.yellow[800],
                          size: 30,
                        ),
                        Text('Mediano'),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          Icons.media_bluetooth_off,
                          color: Colors.red[600],
                          size: 30,
                        ),
                        Text('Grande'),
                      ],
                    ),
                  ],
                )
              ],
            ),
            CustomCard(children: [
              CheckBoxList(
                children: [
                  'Sale',
                  'Credit',
                  'Refund',
                  'Loan',
                  'Direct Material'
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  CustomCard({this.children});

  final children;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class CheckBoxList extends StatefulWidget {
  CheckBoxList({required this.children}) {
    this.values = List.generate(children.length, (index) => false);
  }
  final List<String> children;
  // final int count;
  late final List<bool> values;
  @override
  _CheckBoxListState createState() => _CheckBoxListState();
}

class _CheckBoxListState extends State<CheckBoxList> {
  @override
  Widget build(BuildContext context) {
    var children = widget.children;
    var values = widget.values;
    return Column(
        children: children.map((element) {
      int index = children.indexOf(element);
      return CheckboxListTile(
        activeColor: Colors.teal,
        title: Text(
          element,
        ),
        value: values[index],
        onChanged: (bool? value) {
          setState(() {
            values[index] = value!;
          });
        },
      );
    }).toList());
  }
}

class DropDown extends StatefulWidget {
  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  String dropdownValue = 'Newest First';
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
      items: ['Mas cercano', 'Mas reciente']
          .map((e) => DropdownMenuItem(
                child: Text(e),
                value: e,
              ))
          .toList(),
      underline: Container(
        height: 3,
        color: Colors.teal,
      ),
    );
  }
}

class TransactionToggle extends StatefulWidget {
  TransactionToggle({required this.children}) {
    _isSelected = List.generate(children.length, (index) => false);
  }
  final List<Widget> children;
  late final List<bool> _isSelected;
  @override
  _TransactionToggleState createState() => _TransactionToggleState();
}

class _TransactionToggleState extends State<TransactionToggle> {
  @override
  Widget build(BuildContext context) {
    var children = widget.children;
    var _isSelected = widget._isSelected;
    return Center(
      child: ToggleButtons(
        children: children,
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
                if (!_isSelected[index]) _isSelected[buttonIndex] = true;
              } else {
                _isSelected[buttonIndex] = false;
              }
            }
          });
        },
        isSelected: _isSelected,
        borderRadius: BorderRadius.circular(30),
        selectedColor: Colors.white,
        fillColor: Colors.teal,
        borderColor: Colors.teal,
        selectedBorderColor: Colors.teal,
        borderWidth: 2,
        splashColor: Colors.teal[100],
        constraints: BoxConstraints.expand(
            width:
                MediaQuery.of(context).size.width / (1.2 * _isSelected.length),
            height: 60),
      ),
    );
  }
}
