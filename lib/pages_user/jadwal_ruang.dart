import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_krt_ruang/common/constant_jam.dart';
import 'package:flutter_krt_ruang/pages_user/detail_ruangan.dart';
import 'package:flutter_krt_ruang/pages_user/tabelRuang.dart';
import 'package:intl/intl.dart';

class JadwalRuang extends StatefulWidget {
  final emailUser;

  const JadwalRuang({super.key, required this.emailUser});
  @override
  State<JadwalRuang> createState() => _JadwalRuangState();
}

class _JadwalRuangState extends State<JadwalRuang> {
  List<Ruang> ruangData = [];

  final getDataFromFireStore =
      FirebaseFirestore.instance.collection('ruang').snapshots();

  Map<dynamic, dynamic> jamRuang = {};

  List<String> namaRuanganDipilih = [];
  String? selectedValue;

  Widget _buildTable() {
    return Center(
      child: Table(
        border: TableBorder.all(width: 2, color: Colors.black),
        children: [
          TableRow(
              decoration: BoxDecoration(color: Colors.orange.shade400),
              children: [
                Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          "Nama Ruang",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ))),
                Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text("Jam",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)))),
                Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text("Status",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)))),
              ]),
          ...jamRuang.entries.map((e) => TableRow(children: [
                Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(selectedValue!, style: TextStyle(fontSize: 15)),
                )),
                Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(e.key, style: TextStyle(fontSize: 15)),
                )),
                Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                      (e.value.toString() == "true")
                          ? "Sudah dipinjam"
                          : "Belum dipinjam",
                      style: TextStyle(
                          fontSize: 15,
                          color: (e.value.toString() == "true")
                              ? Colors.red
                              : Colors.green)),
                )),
              ])),
        ],
      ),
    );
  }

  DateTime _dateTime = DateTime.now();

  void getDataRuang() async {
    final documentReference = await FirebaseFirestore.instance
        .collection('ruang')
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              setState(() {
                namaRuanganDipilih.add(document.reference.id);
              });
            }));
  }

  void cekRuang() async {
    if (_dateTime != null && selectedValue != null) {
      Map<dynamic, dynamic>? mapJam = null;
      DocumentReference? documentReference = await FirebaseFirestore.instance
          .collection(selectedValue!)
          .doc(DateFormat('dd-MM-yyyy').format(_dateTime).trim());
      await documentReference.get().then((snapshot) {
        if (snapshot.exists) {
          mapJam = snapshot.get("jam");
          mapJam = Map.fromEntries(mapJam!.entries.toList()
            ..sort((e1, e2) =>
                int.parse(e1.key.replaceAll(RegExp(r'[^0-9]'), "")).compareTo(
                    int.parse(e2.key.replaceAll(RegExp(r'[^0-9]'), "")))));
        }
        setState(() {
          this.jamRuang.clear();
          this.jamRuang.addAll(mapJam!);
        });
      }).catchError((e) {
        print(e);
        setState(() {
          this.jamRuang.clear();
          this.jamRuang.addAll(rangeWaktu);
        });
      }).whenComplete(() {});
    }
  }

  void _showDatePicker() {
    showDatePicker(
            builder: (context, child) {
              return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.orange.shade400, // <-- SEE HERE
                      onPrimary: Colors.purple, // <-- SEE HERE
                      onSurface: Colors.black, // <-- SEE HERE
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        primary: Colors.purple, // button text color
                      ),
                    ),
                  ),
                  child: child!);
            },
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2022),
            lastDate: DateTime(2030))
        .then((value) {
      if (value == null) {
        _dateTime = DateTime.now();
      } else {
        setState(() {
          _dateTime = value;
        });
      }
      cekRuang();
    });
  }

  @override
  void initState() {
    getDataRuang();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          Container(
              child: Center(
            child: Column(
              children: [
                Text("Tanggal Yang Dipilih : ", style: TextStyle(fontSize: 20)),
                SizedBox(height: 5),
                Text(
                  DateFormat('dd-MM-yyyy').format(_dateTime),
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          )),
          SizedBox(height: 5),
          SizedBox(
            height: 50, //height of button
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showDatePicker,
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: Colors.purple,
              ),
              label: const Text('Pilih Tanggal',
                  style: TextStyle(fontSize: 20, color: Colors.purple)),
              style: ElevatedButton.styleFrom(
                  primary: Colors.orange.shade400,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
            ),
          ),
          SizedBox(height: 5),
          Divider(color: Colors.orange.shade400, thickness: 10),
          SizedBox(height: 5),
          Text("Pilih Ruangan : ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          DropdownButtonFormField2(
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            isExpanded: true,
            hint: const Text(
              'Pilih Ruangan Yang Ingin Di Lihat',
              style: TextStyle(fontSize: 14),
            ),
            items: namaRuanganDipilih
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ))
                .toList(),
            validator: (value) {
              if (value == null) {
                return 'Mohon Pilih Ruangan';
              }
              return null;
            },
            onChanged: (value) {
              selectedValue = value.toString();
              cekRuang();
            },
            buttonStyleData: const ButtonStyleData(
              height: 60,
              padding: EdgeInsets.only(left: 20, right: 10),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black45,
              ),
              iconSize: 30,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          SizedBox(height: 5),
          Divider(color: Colors.orange.shade400, thickness: 10),
          SizedBox(height: 5),
          _buildTable(),
          SizedBox(height: 5),
          SizedBox(
            height: 50, //height of button
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: selectedValue == null
                  ? null
                  : () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailRuang(
                                    namaRuang: selectedValue!,
                                    emailUser: widget.emailUser,
                                    tanggalDipilih: _dateTime,
                                  )));
                    },
              icon: const Icon(
                Icons.search,
                size: 20,
                color: Colors.purple,
              ),
              label: const Text('Lihat Ruangan',
                  style: TextStyle(fontSize: 20, color: Colors.purple)),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange.shade400,
                elevation: 5,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
