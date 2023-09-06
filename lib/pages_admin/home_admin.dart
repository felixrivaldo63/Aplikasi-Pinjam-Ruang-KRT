import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_krt_ruang/pages_admin/daftar_kritik_saran.dart';
import 'package:flutter_krt_ruang/pages_admin/detail_ruang_pinjam_admin.dart';
import 'package:flutter_krt_ruang/pages_admin/tambah_ruang.dart';
import 'package:flutter_krt_ruang/pages_admin/daftar_ruang.dart';
import 'package:intl/intl.dart';

class HomeAdmin extends StatefulWidget {
  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  List<Map<String, dynamic>> daftarPinjam = [];

  DateTime _dateTime = DateTime.now();
  bool tabPilih = false;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  void _showDatePicker() {
    showDatePicker(
            builder: (context, child) {
              return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.orange.shade400,
                      onPrimary: Colors.purple,
                      onSurface: Colors.black,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        primary: Colors.purple,
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
          getDataRuangPinjam();
        });
      }
    });
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
          getDataRuangPinjam();
        });
      },
      onCancelClick: () {},
    );
  }

  DateFormat formatter = DateFormat('yyyy-MM-dd');

  String emailUser = "";
  void getDataUser() async {
    DocumentReference documentReference = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email);
    await documentReference.get().then((datasnapshot) {
      setState(() {
        this.emailUser = datasnapshot.get("email");
      });
    });
  }

  @override
  void initState() {
    startDate = DateTime(_dateTime.year, _dateTime.month, _dateTime.day);
    endDate = DateTime(_dateTime.year, _dateTime.month, _dateTime.day);

    Future.delayed(Duration.zero, () {
      getDataUser();
      getDataRuangPinjam();
    });

    // TODO: implement initState
    super.initState();
  }

  Future<void> getDataRuangPinjam() async {
    daftarPinjam.clear();
    final documentReference =
        await FirebaseFirestore.instance.collection('ruang_pinjam');
    if (tabPilih == false) {
      documentReference
          // .where("tgl_pinjam",
          //     isEqualTo: DateFormat('dd-MM-yyyy').format(_dateTime))
          .get()
          .then((datasnapshot) {
        print(datasnapshot.docs.length);
        setState(() {
          datasnapshot.docs.forEach(
            (element) {
              List<String> id = element.id.toString().split("_");
              Map<String, dynamic> dataRuangPinjam = {};
              List<String> tgl = id[0].split("-");
              DateTime tanggal = DateTime.parse("${tgl[2]}${tgl[1]}${tgl[0]}");
              if (tanggal.compareTo(startDate) >= 0 &&
                  tanggal.compareTo(endDate) <= 0) {
                dataRuangPinjam["id"] = element.id;
                dataRuangPinjam.addAll(element.data());
                daftarPinjam.add(dataRuangPinjam);
                print(element.data());
              }
            },
          );
        });
      });
    } else {
      documentReference
          .where("verifikasi", isEqualTo: "wait")
          .get()
          .then((datasnapshot) {
        print(datasnapshot.docs.length);
        datasnapshot.docs.forEach(
          (element) {
            final tgl = (element.data()["tgl_pinjam"]).split("-");
            DateTime tanggal = DateTime.parse("${tgl[2]}-${tgl[1]}-${tgl[0]}");
            DateTime now = DateTime.now();
            DateTime hariini = DateTime(now.year, now.month, now.day);
            if (tanggal.compareTo(hariini) >= 0) {
              Map<String, dynamic> dataRuangPinjam = {};
              dataRuangPinjam["id"] = element.id;
              dataRuangPinjam.addAll(element.data());
              daftarPinjam.add(dataRuangPinjam);
              print(element.data());
            }
          },
        );
      }).whenComplete(() => setState(() {}));
    }
  }

  String jamPinjam(Map<String, dynamic> jamMap) {
    jamMap = Map.fromEntries(jamMap.entries.toList()
      ..sort((e1, e2) => int.parse(e1.key.replaceAll(RegExp(r'[^0-9]'), ""))
          .compareTo(int.parse(e2.key.replaceAll(RegExp(r'[^0-9]'), "")))));
    return jamMap.entries.first.key +
        ".00 Sampai " +
        jamMap.entries.last.key +
        ".00";
  }

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.orange.shade400,
          title: Text(
            'Halaman Utama Admin',
            style: TextStyle(color: Colors.purple),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Apakah Ingin Keluar Dari Aplikasi?"),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Tidak")),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  signUserOut();
                                },
                                child: Text("Ya"))
                          ],
                        );
                      });
                },
                icon: Icon(
                  Icons.logout_outlined,
                  color: Colors.purple,
                ))
          ]),
      body: RefreshIndicator(
        onRefresh: getDataRuangPinjam,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 35, 20, 0),
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
                        Row(children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    tabPilih = false;
                                    getDataRuangPinjam();
                                  });
                                },
                                icon: const Icon(
                                  Icons.list,
                                  size: 15,
                                  color: Colors.purple,
                                ),
                                label: const Text('Daftar Pinjam',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.purple)),
                                style: ElevatedButton.styleFrom(
                                  primary: tabPilih == false
                                      ? Colors.orange.shade400
                                      : Colors.grey,
                                  elevation: 5,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    tabPilih = true;
                                    getDataRuangPinjam();
                                  });
                                },
                                icon: const Icon(
                                  Icons.check,
                                  size: 15,
                                  color: Colors.purple,
                                ),
                                label: const Text('Verifikasi',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.purple)),
                                style: ElevatedButton.styleFrom(
                                  primary: tabPilih == true
                                      ? Colors.orange.shade400
                                      : Colors.grey,
                                  elevation: 5,
                                ),
                              ),
                            ),
                          ),
                        ]),
                        Padding(padding: EdgeInsets.all(5)),
                        Divider(color: Colors.orange.shade400, thickness: 10),
                        if (tabPilih == false)
                          Column(
                            children: [
                              Padding(padding: EdgeInsets.all(5)),
                              Center(
                                child: Text(
                                  "Tanggal Yang Dipilih :",
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(5)),
                              Center(
                                child: Text(
                                  DateFormat('dd-MM-yyyy').format(startDate) +
                                      " - " +
                                      DateFormat('dd-MM-yyyy').format(endDate),
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(5)),
                              SizedBox(height: 5),
                              SizedBox(
                                height: 50, //height of button
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: dateRangePickerDial,
                                  icon: const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 20,
                                    color: Colors.purple,
                                  ),
                                  label: const Text('Pilih Tanggal',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.purple)),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.orange.shade400,
                                    elevation: 5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Divider(
                                  color: Colors.orange.shade400, thickness: 10),
                            ],
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ...daftarPinjam
                                .map((e) => tabPilih == false
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Card(
                                          margin: new EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 5.0),
                                          shadowColor: Colors.orange.shade400,
                                          elevation: 2.0,
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                                5, 2.5, 5, 2.5),
                                            margin: EdgeInsets.fromLTRB(
                                                2.5, 2.5, 2.5, 2.5),
                                            child: ListTile(
                                              title: Text(
                                                e["nama_ruang"],
                                                style: TextStyle(
                                                  color: Colors.purple.shade400,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Tanggal : " +
                                                        e["tgl_pinjam"],
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    jamPinjam(e["jam_pinjam"]),
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              trailing: SizedBox(
                                                height: 50, //height of button
                                                width: 50,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                DetailPinjamanAdmin(
                                                                  id: e['id'],
                                                                )));
                                                  },
                                                  child: const Icon(
                                                    Icons.search,
                                                    size: 18,
                                                    color: Colors.purple,
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary:
                                                        Colors.orange.shade400,
                                                    elevation: 5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Card(
                                          margin: new EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 5.0),
                                          shadowColor: Colors.orange.shade400,
                                          elevation: 2.0,
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                                5, 2.5, 5, 2.5),
                                            margin: EdgeInsets.fromLTRB(
                                                2.5, 2.5, 2.5, 2.5),
                                            child: ListTile(
                                              title: Text(
                                                e["tgl_pinjam"],
                                                style: TextStyle(
                                                  color: Colors.purple.shade400,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text(
                                                e["nama_ruang"],
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              trailing: SizedBox(
                                                height: 50, //height of button
                                                width: 50,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                DetailPinjamanAdmin(
                                                                  id: e['id'],
                                                                )));
                                                  },
                                                  child: const Icon(
                                                    Icons.search,
                                                    size: 20,
                                                    color: Colors.purple,
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary:
                                                        Colors.orange.shade400,
                                                    elevation: 5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ))
                                .toList()
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                  child: SingleChildScrollView(
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
                                        builder: (context) => TambahRuang()));
                              },
                              icon: const Icon(
                                Icons.add,
                                size: 20,
                                color: Colors.purple,
                              ),
                              label: const Text('Tambah Ruangan',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.purple)),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orange.shade400,
                                elevation: 5,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            height: 50, //height of button
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DaftarRuang()));
                              },
                              icon: const Icon(
                                Icons.list,
                                size: 20,
                                color: Colors.purple,
                              ),
                              label: const Text('Daftar Ruangan',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.purple)),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orange.shade400,
                                elevation: 5,
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(5)),
                          SizedBox(
                            height: 50, //height of button
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DaftarKritikSaran()));
                              },
                              icon: const Icon(
                                Icons.file_copy,
                                size: 20,
                                color: Colors.purple,
                              ),
                              label: const Text('Daftar Kritik & Saran',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
