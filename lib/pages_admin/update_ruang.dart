import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../common/constant_jam.dart';
import '../common/theme_helper.dart';

class UpdateRuang extends StatefulWidget {
  const UpdateRuang({super.key, required this.namaRuang});
  final String namaRuang;

  @override
  State<UpdateRuang> createState() => _UpdateRuangState();
}

class _UpdateRuangState extends State<UpdateRuang> {
  final namaRuangController = TextEditingController();
  final kapasitasController = TextEditingController();
  final namaGedungController = TextEditingController();
  final lantaiController = TextEditingController();
  XFile? image;
  String fotoRuang = "";
  @override
  void initState() {
    getDataRuang();
    super.initState();
  }

  void getDataRuang() async {
    DocumentReference documentReference = await FirebaseFirestore.instance
        .collection('ruang')
        .doc(widget.namaRuang);
    await documentReference.get().then((datasnapshot) {
      setState(() {
        this.namaRuangController.text = datasnapshot.get("nama_ruang");
        this.kapasitasController.text = datasnapshot.get("kapasitas_ruang");
        this.namaGedungController.text = datasnapshot.get("nama_gedung");
        this.lantaiController.text = datasnapshot.get("lantai_ruang");
        this.fotoRuang = datasnapshot.get("foto_ruang");
      });
    });
  }

  Future<void> inputGedung() async {
    var downloadUrl = fotoRuang;
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
        title: Text("Form Perbaharui Ruang"),
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
                          enabled: false,
                          controller: namaRuangController,
                          decoration: InputDecoration(
                            hintText: "Masukkan Nama Ruang",
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400)),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2.0)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2.0)),
                          ),
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
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2.0)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2.0)),
                          ),
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
                          decoration: InputDecoration(
                            hintText: "Masukkan Nama Gedung Tempat Ruangan",
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2.0)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2.0)),
                          ),
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
                          decoration: InputDecoration(
                            hintText: "Masukkan Nomor Lantai Ruang",
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2.0)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2.0)),
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
                          label: const Text('Unggah Foto Ruangan',
                              style: TextStyle(
                                  fontSize: 20, color: Colors.purple)),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orange.shade400,
                            elevation: 5,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      if (fotoRuang.isNotEmpty && image == null)
                        Center(
                            child:
                                Image.network(Uri.parse(fotoRuang).toString())),
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
                            await inputGedung();
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.bookmark_added,
                            size: 20,
                            color: Colors.orange,
                          ),
                          label: const Text('Perbaharui Data Ruangan',
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
    );
  }
}
