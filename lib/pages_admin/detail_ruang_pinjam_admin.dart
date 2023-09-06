import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_krt_ruang/common/constant_jam.dart';
import 'package:image_picker/image_picker.dart';

import '../common/theme_helper.dart';

class DetailPinjamanAdmin extends StatefulWidget {
  final String id;

  DetailPinjamanAdmin({
    required this.id,
  });

  @override
  State<DetailPinjamanAdmin> createState() => _DetailPinjamanAdminState(id);
}

class _DetailPinjamanAdminState extends State<DetailPinjamanAdmin> {
  final String id;
  final tujuanPinjam = TextEditingController();
  final detailPinjam = TextEditingController();
  String layoutRuangan = "";
  String namaDepanUser = "";
  String namaBelakangUser = "";
  String noTelp = "";
  String jamPinjamStr = "";
  String verif = "";
  String tglPengajuan = "";
  final _AlasanTolakController = TextEditingController();
  Map<dynamic, dynamic> jamFirestore = {};

  Map<String, dynamic> jamMap = {};
  XFile? image;

  _DetailPinjamanAdminState(this.id);

  void getDataUser() async {
    DocumentReference documentReference = await FirebaseFirestore.instance
        .collection('users')
        .doc(id.toString().split("_")[2]);
    documentReference.get().then((datasnapshot) {
      setState(() {
        this.namaDepanUser = datasnapshot.get("first_name");
        this.namaBelakangUser = datasnapshot.get("last_name");
        this.noTelp = datasnapshot.get("nomor_telp");
      });
    });
    DocumentReference documentReference2 =
        await FirebaseFirestore.instance.collection('ruang_pinjam').doc(id);
    await documentReference2.get().then((datasnapshot) {
      setState(() {
        this.tujuanPinjam.text = datasnapshot.get("tujuan_pinjam");
        this.detailPinjam.text = datasnapshot.get("det_pinjam");
        layoutRuangan = datasnapshot.get("layout_ruang");
        this.jamMap = datasnapshot.get("jam_pinjam") as Map<String, dynamic>;
        this.tglPengajuan = datasnapshot.get("tgl_pengajuan");
        jamMap = Map.fromEntries(jamMap.entries.toList()
          ..sort((e1, e2) => int.parse(e1.key.replaceAll(RegExp(r'[^0-9]'), ""))
              .compareTo(int.parse(e2.key.replaceAll(RegExp(r'[^0-9]'), "")))));
        this.jamPinjamStr = jamMap.entries.first.key +
            ".00 Sampai " +
            jamMap.entries.last.key +
            ".00";
        this.verif = datasnapshot.get("verifikasi");
        jamCb.addAll(jamMap.keys);
      });
    });
  }

  void verifikasiPinjam() async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("ruang_pinjam").doc(id);
    Map<String, dynamic> verifRuang = {
      'verifikasi': verif,
      'alasan': _AlasanTolakController.text.trim(),
    };
    await documentReference.update(verifRuang);
    jamMap.updateAll((key, value) => value = false);
    jamMap.forEach((key, value) {
      jamFirestore[key] = value;
    });
    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection(id.toString().split("_")[1].trim())
        .doc(id.split("_").first.trim());
    Map<String, dynamic> dataRuang2 = {'jam': rangeWaktu};
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
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                  borderSide: BorderSide(color: Colors.grey)),
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                            ),
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Text("Nomor Telepon :",
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
                                  borderRadius: BorderRadius.circular(100.0),
                                  borderSide: BorderSide(color: Colors.grey)),
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
                              hintText: id.toString().split("_")[1],
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                  borderSide: BorderSide(color: Colors.grey)),
                            ),
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Text("Tanggal Pengajuan :",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: tglPengajuan,
                              fillColor: Colors.white,
                              filled: true,
                              enabled: false,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                  borderSide: BorderSide(color: Colors.grey)),
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
                              hintText: id.split("_").first,
                              fillColor: Colors.white,
                              filled: true,
                              enabled: false,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                  borderSide: BorderSide(color: Colors.grey)),
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
                          child: Container(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: jamPinjamStr,
                                fillColor: Colors.white,
                                filled: true,
                                enabled: false,
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 10, 20, 10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                    borderSide: BorderSide(color: Colors.grey)),
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
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: tujuanPinjam.text,
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                  borderSide: BorderSide(color: Colors.grey)),
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
                            keyboardType: TextInputType.multiline,
                            enabled: false,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: detailPinjam.text,
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                  borderSide: BorderSide(color: Colors.grey)),
                            ),
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        if (layoutRuangan.isNotEmpty)
                          Center(child: Image.network(layoutRuangan)),
                        SizedBox(
                          height: 5,
                        ),
                        if (verif == "wait")
                          SizedBox(
                            height: 50, //height of button
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Verifikasi Ruangan"),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("Kembali")),
                                          ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            "Alasan Penolakan"),
                                                        content: TextFormField(
                                                          controller:
                                                              _AlasanTolakController,
                                                          decoration:
                                                              InputDecoration(
                                                                  hintText:
                                                                      "Masukkan Alasan Penolakan"),
                                                        ),
                                                        actions: [
                                                          ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                  "Batal")),
                                                          ElevatedButton(
                                                              onPressed: () {
                                                                verif =
                                                                    "Ditolak";
                                                                verifikasiPinjam();
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                  "Kirim")),
                                                        ],
                                                      );
                                                    });
                                                // verif = "Ditolak";
                                                // verifikasiPinjam();
                                                // Navigator.pop(context);
                                                // Navigator.pop(context);
                                              },
                                              child: Text("Ditolak")),
                                          ElevatedButton(
                                              onPressed: () {
                                                verif = "Disetujui";
                                                verifikasiPinjam();
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: Text("Disetujui"))
                                        ],
                                      );
                                    });
                              },
                              icon: const Icon(
                                Icons.verified,
                                size: 20,
                                color: Colors.white,
                              ),
                              label: const Text('Verifikasi Pinjaman',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orange,
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
