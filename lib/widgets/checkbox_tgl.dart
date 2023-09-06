import 'package:flutter/material.dart';

class JamCheckBoxAlert extends StatefulWidget {
  final Map<dynamic, dynamic> jamFirestore;
  final Set<String> jamCurrent;
  const JamCheckBoxAlert(
      {super.key, required this.jamFirestore, required this.jamCurrent});

  @override
  State<JamCheckBoxAlert> createState() => _JamCheckBoxAlertState();
}

class _JamCheckBoxAlertState extends State<JamCheckBoxAlert> {
  Map<dynamic, dynamic> jamC = {};
  Set<String> cVal = {};

  @override
  void initState() {
    super.initState();
    cVal.addAll(widget.jamCurrent);
    widget.jamFirestore.removeWhere((key, value) => cVal.contains(key));
    jamC.addAll(widget.jamFirestore);

    widget.jamCurrent.forEach((element) {
      jamC[element] = true;
    });
    jamC = Map.fromEntries(jamC.entries.toList()
      ..sort((e1, e2) => int.parse(e1.key.replaceAll(RegExp(r'[^0-9]'), ""))
          .compareTo(int.parse(e2.key.replaceAll(RegExp(r'[^0-9]'), "")))));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade400),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Batal")),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade400),
            onPressed: () {
              Navigator.pop(context, cVal);
            },
            child: Text("OK")),
      ],
      content: SingleChildScrollView(
        child: Column(
          children: [
            ...jamC.entries.map((e) {
              return CheckboxListTile(
                activeColor: Colors.purple,
                title: Text(e.key),
                controlAffinity: ListTileControlAffinity.leading,
                value: e.value,
                onChanged: widget.jamFirestore[e.key] == true
                    ? null
                    : (bool? value) {
                        setState(() {
                          jamC[e.key] = value;
                          if (value == false) {
                            cVal.removeWhere((element) => element == e.key);
                          } else {
                            cVal.add(e.key);
                          }
                          print(cVal.toString());
                        });
                      },
              );
            }).toList()
          ],
        ),
      ),
    );
  }
}
