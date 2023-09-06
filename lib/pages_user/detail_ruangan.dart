import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_krt_ruang/pages_user/form_booking.dart';

class DetailRuang extends StatefulWidget {
  final String namaRuang;
  final DateTime tanggalDipilih;
  final String emailUser;

  DetailRuang(
      {required this.namaRuang,
      required this.tanggalDipilih,
      required this.emailUser});

  @override
  State<DetailRuang> createState() =>
      _DetailRuangState(namaRuang, tanggalDipilih, emailUser);
}

class _DetailRuangState extends State<DetailRuang> {
  final String namaRuang;
  final DateTime tanggalDipilih;
  final String emailUser;
  String kapasitasRuang = "";
  String lokasiRuang = "";
  String fotoRuang = "";
  String lantaiRuang = "";

  _DetailRuangState(this.namaRuang, this.tanggalDipilih, this.emailUser);

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
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                    builder: (context) => FormBooking(
                                          emailUser: emailUser,
                                          namaRuang: namaRuang,
                                          tanggalDipilih: tanggalDipilih,
                                        )));
                          },
                          icon: const Icon(
                            Icons.add_home_work_outlined,
                            size: 20,
                            color: Colors.purple,
                          ),
                          label: const Text('Pinjam Ruang',
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
          ]),
        ),
      ),
    );
  }
}
