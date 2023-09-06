import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DaftarKritikSaran extends StatefulWidget {
  const DaftarKritikSaran({super.key});

  @override
  State<DaftarKritikSaran> createState() => _DaftarKritikSaranState();
}

class _DaftarKritikSaranState extends State<DaftarKritikSaran> {
  List<Map<String, dynamic>> daftarKS = [];

  @override
  void initState() {
    // getDaftarKritikSaran();
    super.initState();
  }

  Future getDaftarKritikSaran() async {
    daftarKS.clear();
    await FirebaseFirestore.instance
        .collection('kritik_saran')
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              print(document.reference);
              Map<String, dynamic> data = {};
              data.addAll(document.data());
              data["id"] = document.id;
              daftarKS.add(data);
            }));
  }

  Future<void> deleteKritikSaran(String id) async {
    final documentReference = await FirebaseFirestore.instance
        .collection('kritik_saran')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Kritik Saran"),
        backgroundColor: Colors.orange.shade400,
      ),
      body: RefreshIndicator(
        onRefresh: getDaftarKritikSaran,
        child: Container(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.shade100,
                  // border: Border.all(color: Colors.purple.shade400, width: 3),
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
                future: getDaftarKritikSaran(),
                builder: (context, snapshot) {
                  return ListView.builder(
                      itemCount: daftarKS.length,
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
                                title: Text(
                                  "Ruang " + daftarKS[index]["nama_ruang"],
                                  style: TextStyle(
                                    color: Colors.purple.shade400,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(daftarKS[index]["kritik_saran"]),
                                trailing: SizedBox(
                                  // height: 50,
                                  width: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  "Apakah Ingin Menghapus Data?"),
                                              actions: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Tidak")),
                                                ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                Colors.red),
                                                    onPressed: () async {
                                                      await deleteKritikSaran(
                                                          daftarKS[index]
                                                              ["id"]);
                                                      await getDaftarKritikSaran();
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Ya"))
                                              ],
                                            );
                                          });
                                    },
                                    child: const Icon(
                                      Icons.delete_forever,
                                      size: 20,
                                      color: Colors.white,
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
        ),
      ),
    );
  }
}
