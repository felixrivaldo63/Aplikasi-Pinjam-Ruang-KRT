import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/theme_helper.dart';

class KritikSaran extends StatefulWidget {
  const KritikSaran({super.key});

  @override
  State<KritikSaran> createState() => _KritikSaranState();
}

class _KritikSaranState extends State<KritikSaran> {
  final krtikSaranUserController = TextEditingController();
  List<String> namaRuanganDipilih = [];
  String? selectedValue;

  Future<void> inputKritikSaran() async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("kritik_saran").doc();
    Map<String, dynamic> user = {
      'kritik_saran': krtikSaranUserController.text.trim(),
      'nama_ruang': selectedValue,
    };
    documentReference.set(user);
  }

  void getDataRuang() async {
    final documentReference = await FirebaseFirestore.instance
        .collection('ruang')
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
              setState(() {
                namaRuanganDipilih.add(document.reference.id);
              });
            }));
  }

  @override
  void initState() {
    getDataRuang();
    super.initState();
  }

  @override
  void dispose() {
    krtikSaranUserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Form Kritik Dan Saran"),
        backgroundColor: Colors.orange.shade400,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () async {
          try {
            final url = Uri.parse("https://wa.me/+6281271732371");
            await launchUrl(url, mode: LaunchMode.externalApplication);
            // }
          } catch (e) {
            throw e;
          }
        },
        child: Icon(Icons.chat, size: 20),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text("Nama Ruangan :",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: DropdownButtonFormField2(
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          isExpanded: true,
                          hint: const Text(
                            'Pilih Ruangan Yang Ingin Di Lihat',
                            style: TextStyle(fontSize: 14),
                          ),
                          items: namaRuanganDipilih
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Mohon Pilih Ruangan';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            selectedValue = value.toString();
                          },
                          buttonStyleData: const ButtonStyleData(
                            height: 60,
                            padding: EdgeInsets.only(left: 20, right: 10),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black45,
                            ),
                            iconSize: 30,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text("Kritik Dan Saran :",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Container(
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: 10,
                          controller: krtikSaranUserController,
                          decoration: InputDecoration(
                            hintText: "Masukkan Kritik Dan Saran",
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2.0)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
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
                          onPressed: () async {
                            if (krtikSaranUserController.text == "" ||
                                selectedValue == null) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Mohon Isi Kritik & Saran!"),
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
                              await inputKritikSaran();
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(
                            Icons.bookmark_added,
                            size: 20,
                            color: Colors.purple,
                          ),
                          label: const Text('Kirim Kritik & Saran',
                              style: TextStyle(
                                  fontSize: 20, color: Colors.purple)),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orange.shade400,
                            elevation: 5,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Divider(color: Colors.orange.shade400, thickness: 10),
                      SizedBox(height: 5),
                      Text(
                        "Kontak :",
                        style: TextStyle(fontSize: 20),
                      ),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 20),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Nomor Telp : 0812XXXXXXX",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.email, size: 20),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Email : admin@gmail.com",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
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
