import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_krt_ruang/pages_admin/daftar_ruang.dart';
import 'package:flutter_krt_ruang/pages_admin/update_ruang.dart';

class DetailRuangTambah extends StatefulWidget {
  final String namaRuang;

  DetailRuangTambah({
    required this.namaRuang,
  });

  @override
  State<DetailRuangTambah> createState() => _DetailRuangTambahState(namaRuang);
}

class _DetailRuangTambahState extends State<DetailRuangTambah> {
  final String namaRuang;
  String kapasitasRuang = "";
  String lokasiRuang = "";
  String lantaiRuang = "";
  String fotoRuang = "";

  _DetailRuangTambahState(this.namaRuang);

  @override
  void initState() {
    getDataRuang();
    // TODO: implement initState
    super.initState();
  }

  void getDataRuang() async {
    DocumentReference documentReference =
        await FirebaseFirestore.instance.collection('ruang').doc(namaRuang);
    documentReference.get().then((datasnapshot) {
      setState(() {
        this.kapasitasRuang = datasnapshot.get("kapasitas_ruang");
        this.lokasiRuang = datasnapshot.get("nama_gedung");
        this.lantaiRuang = datasnapshot.get("lantai_ruang");
        this.fotoRuang = datasnapshot.get("foto_ruang");
      });
    });
  }

  Future<void> deleteRuang() async {
    final documentReference = await FirebaseFirestore.instance
        .collection('ruang_pinjam')
        .where('nama_ruang', isEqualTo: namaRuang);
    await documentReference.get().then((datasnapshot) {
      print(datasnapshot.docs.length);
      datasnapshot.docs.forEach(
        (element) async {
          await FirebaseFirestore.instance
              .collection('ruang_pinjam')
              .doc(element.id)
              .delete();
        },
      );
    }).whenComplete(() => setState(() {}));
    await FirebaseFirestore.instance.collection(namaRuang).get().then((value) {
      value.docs.forEach((element) async {
        await FirebaseFirestore.instance
            .collection(namaRuang)
            .doc(element.id)
            .delete();
      });
    });
    await FirebaseFirestore.instance
        .collection("ruang")
        .doc(namaRuang)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Ruangan"),
        backgroundColor: Colors.orange.shade400,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(padding: EdgeInsets.all(8)),
            Text(
              // "Nama Ruangan",
              "Ruang " + namaRuang,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.orange.shade400, thickness: 10),
            if (fotoRuang.isNotEmpty)
              Image.network(Uri.parse(fotoRuang).toString()),
            Divider(color: Colors.orange.shade400, thickness: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Kapasitas Ruangan : " + kapasitasRuang + " Orang",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Lokasi Ruangan : " + lokasiRuang,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Lantai : " + lantaiRuang,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
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
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpdateRuang(
                                            namaRuang: namaRuang,
                                          ))).then((value) {
                                getDataRuang();
                              });
                            },
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.purple,
                            ),
                            label: const Text('Perbaharui Data Ruangan',
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
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                          "Apakah Ingin Menghapus Ruangan?"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("Tidak")),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            onPressed: () async {
                                              await deleteRuang();
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DaftarRuang()));
                                            },
                                            child: Text("Ya"))
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(
                              Icons.delete_forever,
                              size: 20,
                              color: Colors.white,
                            ),
                            label: const Text('Hapus Ruangan',
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
          ]),
        ),
      ),
    );
  }
}
