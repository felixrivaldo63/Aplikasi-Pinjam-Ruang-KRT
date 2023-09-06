import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_krt_ruang/pages_user/detail_pinjaman.dart';

class ProfileUser extends StatefulWidget {
  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
  }

  final db = FirebaseFirestore.instance;
  final users = FirebaseAuth.instance.currentUser!;
  String namaUser = "";
  List<Map<String, dynamic>> daftarPinjam = [];

  @override
  void initState() {
    getDataUser();
    super.initState();
  }

  void getDataUser() async {
    DocumentReference documentReference =
        await FirebaseFirestore.instance.collection('users').doc(users.email);
    documentReference.get().then((datasnapshot) {
      setState(() {
        this.namaUser = datasnapshot.get("first_name") +
            " " +
            datasnapshot.get("last_name");
      });
    }).whenComplete(() async => await getDataRuangPinjam());
  }

  Future<void> getDataRuangPinjam() async {
    daftarPinjam.clear();
    final documentReference = await FirebaseFirestore.instance
        .collection('ruang_pinjam')
        .where("nama_peminjam", isEqualTo: namaUser);

    documentReference.get().then((datasnapshot) {
      print(datasnapshot.docs.length);
      datasnapshot.docs.forEach(
        (element) {
          final tgl = (element.data()["tgl_pinjam"]).split("-");
          DateTime tanggal = DateTime.parse("${tgl[2]}-${tgl[1]}-${tgl[0]}");
          DateTime now = DateTime.now();
          DateTime hariini = DateTime(now.year, now.month, now.day);
          if (tanggal.compareTo(hariini) >= 0) {
            daftarPinjam.add(element.data());
            print(element.data());
          }
        },
      );
    }).whenComplete(() => setState(() {}));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: RefreshIndicator(
          onRefresh: () async {
            await getDataRuangPinjam();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Container(
                    width: double.infinity,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_pin_rounded,
                          size: 150,
                          color: Colors.orange.shade400,
                        ),
                        Text(
                          this.namaUser.toString().toUpperCase(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(8)),
                Text(
                  "Daftar Ruangan Yang Dipinjam :",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: daftarPinjam.isNotEmpty
                            ? [
                                ...daftarPinjam
                                    .map(
                                      (e) => Padding(
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
                                            padding: EdgeInsets.symmetric(),
                                            margin: EdgeInsets.symmetric(),
                                            child: ListTile(
                                              title: Text(
                                                e["tgl_pinjam"],
                                                style: TextStyle(
                                                    color:
                                                        Colors.purple.shade400,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                              isThreeLine: true,
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    e["nama_ruang"],
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  Text(
                                                    jamPinjam(e["jam_pinjam"]),
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    e["verifikasi"] == "wait"
                                                        ? "Belum Disetujui"
                                                        : e["verifikasi"],
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 14,
                                                    ),
                                                  )
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
                                                                DetailPinjaman(
                                                                  emailUser: users
                                                                      .email!,
                                                                  namaRuang: e[
                                                                      "nama_ruang"],
                                                                  tanggalDipilih:
                                                                      e["tgl_pinjam"],
                                                                  status: e[
                                                                      "verifikasi"],
                                                                  tglPengajuan:
                                                                      e["tgl_pengajuan"],
                                                                  alasanPenolakan:
                                                                      e["alasan"],
                                                                )));
                                                  },
                                                  child: const Icon(
                                                    Icons.search,
                                                    size: 20,
                                                    color: Colors.purple,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList()
                              ]
                            : [Text("Belum Ada Ruangan Yang Dipinjam!")],
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
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                            "Apakah Ingin Keluar Dari Aplikasi?"),
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
                              icon: const Icon(
                                Icons.logout,
                                size: 20,
                                color: Colors.orange,
                              ),
                              label: const Text('Logout',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.orange)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
