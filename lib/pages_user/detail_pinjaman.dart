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

class DetailPinjaman extends StatefulWidget {
  final String tanggalDipilih;
  final String emailUser;
  final String namaRuang;
  final String status;
  final String tglPengajuan;
  final String alasanPenolakan;

  DetailPinjaman({
    required this.tanggalDipilih,
    required this.emailUser,
    required this.namaRuang,
    required this.status,
    required this.tglPengajuan,
    required this.alasanPenolakan,
  });

  @override
  State<DetailPinjaman> createState() => _DetailPinjamanState(tanggalDipilih,
      emailUser, namaRuang, status, tglPengajuan, alasanPenolakan);
}

class _DetailPinjamanState extends State<DetailPinjaman> {
  final String tanggalDipilih;
  final String emailUser;
  final String namaRuang;
  final String status;
  final String tglPengajuan;
  final String alasanPenolakan;
  final tujuanPinjam = TextEditingController();
  final detailPinjam = TextEditingController();
  String layoutRuangan = "";
  String namaDepanUser = "";
  String namaBelakangUser = "";
  String noTelp = "";
  String jamPinjamStr = "";
  Map<dynamic, dynamic> jamFirestore = {};
  bool edit = false;
  Map<String, dynamic> jamMap = {};
  XFile? image;

  _DetailPinjamanState(this.tanggalDipilih, this.emailUser, this.namaRuang,
      this.status, this.tglPengajuan, this.alasanPenolakan);

  void inputPinjam() async {
    var downloadUrl = layoutRuangan;
    if (image != null) {
      var fileName = tanggalDipilih + "_" + namaRuang + "_" + emailUser;
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
    jamMap.forEach((key, value) {
      if (jamCb.contains(key)) {
        jamMap[key] = true;
      } else {
        jamMap[key] = false;
      }
    });
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("ruang_pinjam")
        .doc(tanggalDipilih + "_" + namaRuang + "_" + emailUser);
    Map<String, dynamic> pinjamRuang = {
      'nama_peminjam': (namaDepanUser + " " + namaBelakangUser).trim(),
      'telp_peminjam': noTelp.trim(),
      'nama_ruang': namaRuang.trim(),
      'tgl_pengajuan': DateFormat('dd-MM-yyyy').format(DateTime.now()).trim(),
      'tgl_pinjam': tanggalDipilih.trim(),
      'tgl_pengajuan': tglPengajuan,
      'tujuan_pinjam': tujuanPinjam.text.trim(),
      'det_pinjam': detailPinjam.text.trim(),
      'jam_pinjam': jam,
      'layout_ruang': downloadUrl,
      'verifikasi': status
    };

    jamMap.forEach((key, value) {
      jamFirestore[key] = value;
    });
    jam.forEach((key, value) {
      jamFirestore[key] = value;
    });

    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection(namaRuang.trim())
        .doc(tanggalDipilih.trim());
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
    DocumentReference documentReference2 = await FirebaseFirestore.instance
        .collection('ruang_pinjam')
        .doc(tanggalDipilih + "_" + namaRuang + "_" + emailUser);
    await documentReference2.get().then((datasnapshot) {
      setState(() {
        this.tujuanPinjam.text = datasnapshot.get("tujuan_pinjam");
        this.detailPinjam.text = datasnapshot.get("det_pinjam");
        layoutRuangan = datasnapshot.get("layout_ruang");
        this.jamMap = datasnapshot.get("jam_pinjam") as Map<String, dynamic>;
        jamMap = Map.fromEntries(jamMap.entries.toList()
          ..sort((e1, e2) => int.parse(e1.key.replaceAll(RegExp(r'[^0-9]'), ""))
              .compareTo(int.parse(e2.key.replaceAll(RegExp(r'[^0-9]'), "")))));
        this.jamPinjamStr = jamMap.entries.first.key +
            ".00 Sampai " +
            jamMap.entries.last.key +
            ".00";
        jamCb.addAll(jamMap.keys);
      });
    });
    await getDataJam();
  }

  Future<void> getDataJam() async {
    Map<String, dynamic>? mapJam;
    DocumentReference documentReference = await FirebaseFirestore.instance
        .collection(namaRuang.trim())
        .doc(tanggalDipilih.trim());
    documentReference
        .get()
        .then((datasnapshot) {
          mapJam = datasnapshot.get("jam");
          mapJam = Map.fromEntries(mapJam!.entries.toList()
            ..sort((e1, e2) =>
                int.parse(e1.key.replaceAll(RegExp(r'[^0-9]'), "")).compareTo(
                    int.parse(e2.key.replaceAll(RegExp(r'[^0-9]'), "")))));
        })
        .catchError((err) {})
        .whenComplete(() {
          setState(() {
            if (mapJam != null) {
              this.jamFirestore.addAll(rangeWaktu);
            } else {
              this.jamFirestore = mapJam!;
            }
          });
        });
  }

  void batalPinjam() async {
    DocumentReference documentReference = await FirebaseFirestore.instance
        .collection('ruang_pinjam')
        .doc(tanggalDipilih + "_" + namaRuang + "_" + emailUser);
    await documentReference.delete();
    jamMap.updateAll((key, value) => value = false);
    jamMap.forEach((key, value) {
      jamFirestore[key] = value;
    });
    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection(namaRuang.trim())
        .doc(tanggalDipilih.trim());
    Map<String, dynamic> dataRuang2 = {'jam': jamFirestore};
    await documentReference2.set(dataRuang2);
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

  void addFoto() async {
    String? hasil = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Pilih Gambar"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Peminjaman"),
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
                        // Expanded(
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
                        Text("No Telp :",
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
                              hintText: tanggalDipilih,
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
                          child: edit
                              ? ElevatedButton.icon(
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
                                )
                              : Container(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      hintText: jamPinjamStr,
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabled: false,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(20, 10, 20, 10),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(100.0)),
                                    ),
                                  ),
                                  decoration:
                                      ThemeHelper().inputBoxDecorationShaddow(),
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
                            enabled: edit,
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
                            enabled: edit,
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
                        Text("Alasan Penolakan :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          child: TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: alasanPenolakan,
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
                        if (layoutRuangan.isNotEmpty && image == null)
                          Center(child: Image.network(layoutRuangan)),
                        SizedBox(height: 5),
                        if (edit)
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
                            onPressed: () {
                              if (edit) {
                                inputPinjam();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AuthPage()));
                              } else {
                                setState(() {
                                  edit = true;
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.edit_document,
                              size: 20,
                              color: Colors.orange,
                            ),
                            label: Text(
                                edit
                                    ? "Simpan Data Pinjam"
                                    : 'Perbaharui Data Pinjaman',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.orange)),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.purple,
                              elevation: 5,
                            ),
                          ),
                        ),

                        Padding(padding: EdgeInsets.all(5)),
                        if (edit == false)
                          SizedBox(
                            height: 50, //height of button
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Apakah Ingin Membatalkan Peminjaman?",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("Tidak")),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              onPressed: () {
                                                batalPinjam();
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: Text("Ya"))
                                        ],
                                      );
                                    });
                                // batalPinjam();
                              },
                              icon: const Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.white,
                              ),
                              label: const Text('Batalkan Pinjaman',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
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
