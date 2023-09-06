import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_krt_ruang/login/auth_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../common/constant_jam.dart';
import '../common/theme_helper.dart';
import '../widgets/checkbox_tgl.dart';

class FormBooking extends StatefulWidget {
  final DateTime tanggalDipilih;
  final String emailUser;
  final String namaRuang;

  FormBooking(
      {required this.tanggalDipilih,
      required this.emailUser,
      required this.namaRuang});

  @override
  State<FormBooking> createState() =>
      _FormBookingState(tanggalDipilih, emailUser, namaRuang);
}

class _FormBookingState extends State<FormBooking> {
  final DateTime tanggalDipilih;
  final String emailUser;
  final String namaRuang;
  final tujuanPinjam = TextEditingController();
  final detailPinjam = TextEditingController();
  String namaDepanUser = "";
  String namaBelakangUser = "";
  String noTelp = "";
  Map<dynamic, dynamic> jamFirestore = {};
  XFile? image;

  _FormBookingState(this.tanggalDipilih, this.emailUser, this.namaRuang);

  Future<void> inputPinjam() async {
    var downloadUrl = "";
    if (image != null) {
      var fileName = DateFormat('dd-MM-yyyy').format(tanggalDipilih) +
          "_" +
          namaRuang +
          "_" +
          emailUser;
      Reference ref =
          FirebaseStorage.instance.ref().child('layout_ruang/$fileName');
      UploadTask uploadFoto = ref.putFile(File(image!.path));
      TaskSnapshot snapshot = await uploadFoto.whenComplete(() {});
      downloadUrl = await snapshot.ref.getDownloadURL();
    }
    Map<dynamic, dynamic> jam = {};
    jamCb.forEach((element) {
      jam[element] = true;
    });
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("ruang_pinjam")
        .doc(DateFormat('dd-MM-yyyy').format(tanggalDipilih) +
            "_" +
            namaRuang +
            "_" +
            emailUser);
    Map<String, dynamic> pinjamRuang = {
      'nama_peminjam': (namaDepanUser + " " + namaBelakangUser).trim(),
      'telp_peminjam': noTelp.trim(),
      'nama_ruang': namaRuang.trim(),
      'tgl_pinjam': DateFormat('dd-MM-yyyy').format(tanggalDipilih).trim(),
      'tgl_pengajuan': DateFormat('dd-MM-yyyy').format(DateTime.now()).trim(),
      'tujuan_pinjam': tujuanPinjam.text.trim(),
      'det_pinjam': detailPinjam.text.trim(),
      'jam_pinjam': jam,
      'layout_ruang': downloadUrl,
      'alasan': "",
      "verifikasi": "wait"
    };
    jam.forEach((key, value) {
      jamFirestore[key] = value;
    });

    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection(namaRuang.trim())
        .doc(DateFormat('dd-MM-yyyy').format(tanggalDipilih).trim());
    Map<String, dynamic> dataRuang2 = {'jam': jamFirestore};
    documentReference2.set(dataRuang2);
    documentReference.set(pinjamRuang);
  }

  void getDataUser() async {
    DocumentReference documentReference =
        await FirebaseFirestore.instance.collection('users').doc(emailUser);
    documentReference.get().then((datasnapshot) {
      setState(() {
        this.namaDepanUser = datasnapshot.get("first_name");
        this.namaBelakangUser = datasnapshot.get("last_name");
        this.noTelp = datasnapshot.get("nomor_telp");
      });
    });
    await getDataJam();
  }

  void addFoto() async {
    String? hasil = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Pilih Gambar"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade400),
                    onPressed: () {
                      Navigator.pop(context, "camera");
                    },
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt_rounded),
                        SizedBox(width: 10),
                        Text("Buka Kamera")
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade400),
                    onPressed: () {
                      Navigator.pop(context, "gallery");
                    },
                    child: Row(
                      children: [
                        Icon(Icons.image_search),
                        SizedBox(width: 10),
                        Text("Buka Galeri")
                      ],
                    ),
                  ),
                ],
              ),
            ));
    if (hasil != null) {
      final ImagePicker _pick = ImagePicker();
      if (hasil == "gallery") {
        image = await _pick.pickImage(source: ImageSource.gallery);
      } else if (hasil == "camera") {
        image = await _pick.pickImage(source: ImageSource.camera);
      }
      setState(() {});
    }
  }

  Future<void> getDataJam() async {
    Map<String, dynamic>? mapJam;
    DocumentReference documentReference = await FirebaseFirestore.instance
        .collection(namaRuang.trim())
        .doc(DateFormat('dd-MM-yyyy').format(tanggalDipilih).trim());
    await documentReference.get().then((snapshot) {
      if (snapshot.exists) {
        mapJam = snapshot.get("jam");
        mapJam = Map.fromEntries(mapJam!.entries.toList()
          ..sort((e1, e2) => int.parse(e1.key.replaceAll(RegExp(r'[^0-9]'), ""))
              .compareTo(int.parse(e2.key.replaceAll(RegExp(r'[^0-9]'), "")))));
      }
      setState(() {
        this.jamFirestore.clear();
        this.jamFirestore.addAll(mapJam!);
      });
    }).catchError((e) {
      print(e);
      setState(() {
        this.jamFirestore.clear();
        this.jamFirestore.addAll(rangeWaktu);
      });
    }).whenComplete(() {});
  }

  @override
  void initState() {
    getDataUser();
    super.initState();
  }

  @override
  void dispose() {
    tujuanPinjam.dispose();
    detailPinjam.dispose();
    super.dispose();
  }

  Set<String> jamCb = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Form Peminjaman Ruang"),
        backgroundColor: Colors.orange.shade400,
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.grey.shade100,
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SingleChildScrollView(
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
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nama Peminjam :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          child: TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: namaDepanUser + " " + namaBelakangUser,
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0)),
                            ),
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Text("No Telepon :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          child: TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: noTelp,
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0)),
                            ),
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Text("Nama Ruangan :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          child: TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: namaRuang,
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0)),
                            ),
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Text("Tanggal Peminjaman :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: DateFormat('dd-MM-yyyy')
                                  .format(tanggalDipilih),
                              fillColor: Colors.white,
                              filled: true,
                              enabled: false,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0)),
                            ),
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        Text("Jam Peminjaman :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        SizedBox(
                          height: 50, //height of button
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              var value = await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => JamCheckBoxAlert(
                                    jamFirestore: jamFirestore,
                                    jamCurrent: jamCb),
                              );
                              print("value:" + value.toString());
                              if (value != null) {
                                jamCb = value;
                              }
                            },
                            icon: const Icon(
                              Icons.lock_clock,
                              size: 20,
                              color: Colors.purple,
                            ),
                            label: const Text('Pilih Jam Peminjaman',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.purple)),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.orange.shade400,
                              elevation: 5,
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Text("Tujuan Peminjaman :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          child: TextFormField(
                            controller: tujuanPinjam,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Masukkan Tujuan Peminjaman",
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0)),
                            ),
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Text("Catatan :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          child: TextFormField(
                            controller: detailPinjam,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Masukkan Catatan",
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0)),
                            ),
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        SizedBox(
                          height: 50, //height of button
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              addFoto();
                            },
                            icon: const Icon(
                              Icons.upload_file,
                              size: 20,
                              color: Colors.purple,
                            ),
                            label: const Text('Unggah Layout Ruangan',
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
                        if (image != null)
                          Center(child: Image.file(File(image!.path))),
                        Padding(padding: EdgeInsets.all(5)),
                        SizedBox(
                          height: 50, //height of button
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (jamCb.isEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title:
                                          Text("Jam Peminjaman Masih Kosong!"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("Ok"))
                                      ],
                                    );
                                  },
                                );
                              } else {
                                await inputPinjam();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AuthPage()));
                              }
                            },
                            icon: const Icon(
                              Icons.bookmark_added,
                              size: 20,
                              color: Colors.orange,
                            ),
                            label: const Text('Pinjam Ruangan',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.orange)),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.purple,
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
          ),
        ),
      ),
    );
  }
}
