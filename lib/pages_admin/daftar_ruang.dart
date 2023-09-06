import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_krt_ruang/pages_admin/detailRuangTambah.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DaftarRuang extends StatefulWidget {
  @override
  State<DaftarRuang> createState() => _DaftarRuangState();
}

class _DaftarRuangState extends State<DaftarRuang> {
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference ruang = FirebaseFirestore.instance.collection('ruang');

  List<String> daftarRuang = [];

  Future getDaftarRuang() async {
    daftarRuang.clear();
    await FirebaseFirestore.instance
        .collection('ruang')
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              print(document.reference);
              daftarRuang.add(document.reference.id);
              // setState(() {});
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Daftar Ruangan"),
          backgroundColor: Colors.orange.shade400,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          child: RefreshIndicator(
            onRefresh: getDaftarRuang,
            child: Container(
              alignment: Alignment.center,
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
              child: FutureBuilder(
                future: getDaftarRuang(),
                builder: (context, snapshot) {
                  return ListView.builder(
                      itemCount: daftarRuang.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            margin: new EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            shadowColor: Colors.orange.shade400,
                            elevation: 2.0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              child: ListTile(
                                title: FutureBuilder<DocumentSnapshot>(
                                  future: ruang.doc(daftarRuang[index]).get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      Map<String, dynamic> data = snapshot.data!
                                          .data() as Map<String, dynamic>;
                                      return Text(
                                        'Ruang ${data['nama_ruang']}',
                                        style: TextStyle(
                                          color: Colors.purple.shade400,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                    return Text('Loading...');
                                  },
                                ),
                                subtitle: FutureBuilder<DocumentSnapshot>(
                                  future: ruang.doc(daftarRuang[index]).get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      Map<String, dynamic> data = snapshot.data!
                                          .data() as Map<String, dynamic>;
                                      return Text(
                                        'Kapasitas ${data['kapasitas_ruang']}',
                                      );
                                    }
                                    return Text('Loading...');
                                  },
                                ),
                                trailing: SizedBox(
                                  height: 40, //height of button
                                  width: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailRuangTambah(
                                                    namaRuang:
                                                        daftarRuang[index],
                                                  )));
                                    },
                                    child: const Icon(
                                      Icons.search,
                                      size: 15,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                },
              ),
            ),
          ),
        ));
  }
}
