import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:flutter_krt_ruang/pages_user/page_kritik_saran.dart';
import 'package:intl/intl.dart';

class InfoRuang extends StatefulWidget {
  @override
  State<InfoRuang> createState() => _InfoRuangState();
}

class _InfoRuangState extends State<InfoRuang> {
  List<String> namaRuanganDipilih = [];
  List<int> jumPinjam = [];
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    getDataRuang();
    super.initState();
  }

  void getDataRuang() async {
    await FirebaseFirestore.instance
        .collection('ruang')
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              setState(() {
                namaRuanganDipilih.add(document.reference.id);
                jumPinjam.add(0);
              });
            }));
    getDataPinjam();
  }

  void getDataPinjam() async {
    jumPinjam = List.generate(namaRuanganDipilih.length, (index) => 0);
    await FirebaseFirestore.instance
        .collection('ruang_pinjam')
        .where("verifikasi", isEqualTo: "Disetujui")
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              setState(() {
                List<String> id = document.reference.id.toString().split("_");
                String ruang = id[1];
                int indexRuang = namaRuanganDipilih.indexOf(ruang);
                if (startDate != null && endDate != null) {
                  List<String> tgl = id[0].split("-");
                  DateTime tanggal =
                      DateTime.parse("${tgl[2]}${tgl[1]}${tgl[0]}");
                  if (tanggal.compareTo(startDate!) >= 0 &&
                      tanggal.compareTo(endDate!) <= 0) {
                    jumPinjam[indexRuang] = jumPinjam[indexRuang] + 1;
                  }
                } else {
                  jumPinjam[indexRuang] = jumPinjam[indexRuang] + 1;
                }

                print(jumPinjam.toString());
              });
            }));
  }

  Widget barChart2() {
    return Echarts(
      option: jsonEncode({
        "title": {
          "text": "Jumlah Peminjaman Ruangan",
          "subtext": startDate != null && endDate != null
              ? "${DateFormat('dd-MM-yyyy').format(startDate!)} - ${DateFormat('dd-MM-yyyy').format(endDate!)}"
              : "",
          "left": "center",
          "textStyle": {"fontSize": 20},
        },
        "color": ["orange"],
        "tooltip": {
          "trigger": "axis",
          "axisPointer": {"type": "shadow"}
        },
        "grid": {"width": "80%", "height": "75%"},
        "yAxis": [
          {
            "type": "category",
            "data": namaRuanganDipilih,
            "position": "bottom",
            "show": true,
            "z": 10,
            "axisLabel": {
              "inside": true,
              "textStyle": {"color": "purple"}
            }
          }
        ],
        "xAxis": [
          {"type": "value", "interval": 1}
        ],
        "series": [
          {
            "name": "Jumlah Peminjaman",
            "type": "bar",
            "barWidth": "60%",
            "data": jumPinjam
          }
        ]
      }),
    );
  }

  void dateRangePickerDial() {
    showCustomDateRangePicker(
      context,
      dismissible: true,
      minimumDate: DateTime.now().subtract(const Duration(days: 365)),
      maximumDate: DateTime.now().add(const Duration(days: 365)),
      endDate: endDate,
      startDate: startDate,
      backgroundColor: Colors.white,
      primaryColor: Colors.orange,
      onApplyClick: (start, end) {
        setState(() {
          endDate = end;
          startDate = start;
          getDataPinjam();
        });
      },
      onCancelClick: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade500,
                            offset: Offset(4, 4),
                            blurRadius: 15,
                            spreadRadius: 1),
                        BoxShadow(
                            color: Colors.white,
                            offset: Offset(4, 4),
                            blurRadius: 15,
                            spreadRadius: 1),
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50, //height of button
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text("Pilih Jenis Data Grafik"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                setState(() {
                                                  startDate = null;
                                                  endDate = null;
                                                  getDataPinjam();
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(Icons.list),
                                                  SizedBox(width: 10),
                                                  Text("Data Total")
                                                ],
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                dateRangePickerDial();
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                      Icons.date_range_rounded),
                                                  SizedBox(width: 10),
                                                  Text("Pilih Rentang Waktu")
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ));
                            },
                            icon: const Icon(
                              Icons.date_range,
                              size: 20,
                              color: Colors.purple,
                            ),
                            label: const Text('Pilih Rentang Waktu Grafik',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.purple)),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.orange.shade400,
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: barChart2(),
                  height: 400,
                  width: 350,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade500,
                            offset: Offset(4, 4),
                            blurRadius: 15,
                            spreadRadius: 1),
                        BoxShadow(
                            color: Colors.white,
                            offset: Offset(4, 4),
                            blurRadius: 15,
                            spreadRadius: 1),
                      ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade500,
                            offset: Offset(4, 4),
                            blurRadius: 15,
                            spreadRadius: 1),
                        BoxShadow(
                            color: Colors.white,
                            offset: Offset(4, 4),
                            blurRadius: 15,
                            spreadRadius: 1),
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50, //height of button
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => KritikSaran()));
                            },
                            icon: const Icon(
                              Icons.phone,
                              size: 20,
                              color: Colors.purple,
                            ),
                            label: const Text('Kritik Dan Saran',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.purple)),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.orange.shade400,
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
