import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_krt_ruang/pages_admin/detailRuangTambah.dart';
import 'package:image_picker/image_picker.dart';
import '../common/constant_jam.dart';
import '../common/theme_helper.dart';

class TambahRuang extends StatefulWidget {
  const TambahRuang({super.key});

  @override
  State<TambahRuang> createState() => _TambahRuangState();
}

class _TambahRuangState extends State<TambahRuang> {
  final _formKey = GlobalKey<FormState>();
  final namaRuangController = TextEditingController();
  final kapasitasController = TextEditingController();
  final namaGedungController = TextEditingController();
  final lantaiController = TextEditingController();
  XFile? image;

  Future<void> inputGedung() async {
    var downloadUrl = "";
    if (image != null) {
      var fileName = namaRuangController.text.trim();
      Reference ref =
          FirebaseStorage.instance.ref().child('gambar_ruang/$fileName');
      UploadTask uploadFoto = ref.putFile(File(image!.path));
      TaskSnapshot snapshot = await uploadFoto.whenComplete(() {});
      downloadUrl = await snapshot.ref.getDownloadURL();
    }
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("ruang")
        .doc(namaRuangController.text);
    Map<String, dynamic> dataRuang = {
      'nama_ruang': namaRuangController.text.trim(),
      'kapasitas_ruang': kapasitasController.text.trim(),
      'nama_gedung': namaGedungController.text.trim(),
      'lantai_ruang': lantaiController.text.trim(),
      'foto_ruang': downloadUrl
    };
    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection(namaRuangController.text.trim())
        .doc("tanggal");
    Map<String, dynamic> dataRuang2 = {'jam': rangeWaktu};
    await documentReference.set(dataRuang);
    await documentReference2.set(dataRuang2);
  }

  @override
  void dispose() {
    namaRuangController.dispose();
    kapasitasController.dispose();
    namaGedungController.dispose();
    lantaiController.dispose();
    super.dispose();
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
        title: Text("Form Tambah Ruang"),
        backgroundColor: Colors.orange.shade400,
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.grey.shade100,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Container(
            alignment: Alignment.center,
            color: Colors.grey.shade100,
            child: Padding(
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nama Ruangan :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          child: TextFormField(
                            controller: namaRuangController,
                            decoration: ThemeHelper().textInputDecoration(
                                'Nama Ruang', 'Masukkan Nama Ruang'),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Mohon Masukkan Nama Ruang";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Text("Kapasitas Ruangan :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          child: TextFormField(
                            controller: kapasitasController,
                            keyboardType: TextInputType.number,
                            decoration: ThemeHelper().textInputDecoration(
                                'Kapasitas Ruang', 'Masukkan Kapasitas Ruang'),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Mohon Masukkan Kapasitas Ruang";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Text("Lokasi Ruangan :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          child: TextFormField(
                            controller: namaGedungController,
                            decoration: ThemeHelper().textInputDecoration(
                                'Nama Gedung', 'Masukkan Nama Gedung'),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Mohon Masukkan Nama Gedung Tempat Ruangan";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Text("Lantai :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          child: TextFormField(
                            controller: lantaiController,
                            keyboardType: TextInputType.number,
                            decoration: ThemeHelper().textInputDecoration(
                                'Nomor Lantai', 'Masukkan Nomor Lantai Ruang'),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Mohon Masukkan Nomor Lantai Ruang";
                              }
                              return null;
                            },
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
                            label: const Text('Unggah Foto Ruangan',
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
                              if (_formKey.currentState!.validate()) {
                                await inputGedung();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailRuangTambah(
                                            namaRuang: namaRuangController.text
                                                .toString())));
                              }
                            },
                            icon: const Icon(
                              Icons.bookmark_added,
                              size: 20,
                              color: Colors.orange,
                            ),
                            label: const Text('Simpan Ruangan',
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
