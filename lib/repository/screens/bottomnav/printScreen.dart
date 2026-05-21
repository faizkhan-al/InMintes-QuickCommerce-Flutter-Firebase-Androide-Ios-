import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_minutes/repository/widgets/uihelper.dart';

class PrintScreen extends StatefulWidget {
  TextEditingController searchController = TextEditingController();

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  TextEditingController searchController = TextEditingController();

  String userAddress = "";
  bool showFullAddress = false;

  @override
  void initState() {
    super.initState();
    _fetchUserAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0XFFFFFBF2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 190,
                    width: double.infinity,
                    color: const Color(0XFFF2D59B),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UiHelper.CustomText(
                          text: "InMinutes",
                          color: Colors.black,
                          fontweight: FontWeight.bold,
                          fontsize: 16,
                          fontfamily: "bold",
                        ),
                        UiHelper.CustomText(
                          text: "16 minutes",
                          color: Colors.black,
                          fontweight: FontWeight.bold,
                          fontsize: 18,
                          fontfamily: "bold",
                        ),
                        Row(
                          children: [
                            UiHelper.CustomText(
                              text: "HOME - ",
                              color: Colors.black,
                              fontweight: FontWeight.bold,
                              fontsize: 14,
                            ),
                            Expanded(child: buildAddressWidget()),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Center(
                          child: UiHelper.CustomTextField(
                            controller: searchController,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 15,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: ClipOval(
                        child: Image.asset(
                          "assets/images/person.png",
                          height: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              UiHelper.CustomText(
                text: "Print Store",
                color: Color(0XFF000000),
                fontweight: FontWeight.bold,
                fontsize: 32,
                fontfamily: "bold",
              ),
              UiHelper.CustomText(
                text: "InMinutesensures secure prints at every stage",
                color: Color(0XFF9C9C9C),
                fontweight: FontWeight.bold,
                fontsize: 14,
              ),
              SizedBox(height: 70),
              Stack(
                children: [
                  Container(
                    height: 210,
                    width: 430,
                    decoration: BoxDecoration(
                      color: Color(0XFFF2D59B),
                      borderRadius: BorderRadius.circular(5),
                    ),

                    child: Column(
                      children: [
                        SizedBox(height: 15),
                        Row(
                          children: [
                            SizedBox(width: 20),
                            UiHelper.CustomText(
                              text: "Documents",
                              color: Colors.black,
                              fontweight: FontWeight.bold,
                              fontsize: 20,
                              fontfamily: "bold",
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(width: 20),
                            UiHelper.CustomImage(img: "star.png"),
                            UiHelper.CustomText(
                              text: "  Price starting at rs 3/page",
                              color: Color(0XFF9C9C9C),
                              fontweight: FontWeight.normal,
                              fontsize: 17,
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            SizedBox(width: 20),
                            UiHelper.CustomImage(img: "star.png"),
                            UiHelper.CustomText(
                              text: "  Paper quality: 70 GSM",
                              color: Color(0XFF9C9C9C),
                              fontweight: FontWeight.normal,
                              fontsize: 17,
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            SizedBox(width: 20),
                            UiHelper.CustomImage(img: "star.png"),
                            UiHelper.CustomText(
                              text: "  Single side prints",
                              color: Color(0XFF9C9C9C),
                              fontweight: FontWeight.normal,
                              fontsize: 17,
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            SizedBox(width: 20),
                            SizedBox(
                              width: 150,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (BuildContext context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: Icon(Icons.camera_alt),
                                              title: Text('Camera'),
                                              onTap: () async {
                                                final pickedFile =
                                                    await ImagePicker()
                                                        .pickImage(
                                                          source:
                                                              ImageSource
                                                                  .camera,
                                                        );
                                                if (pickedFile != null) {
                                                  //use pickedFile.path
                                                  Navigator.pop(
                                                    context,
                                                  ); //close the bottom sheet
                                                }
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.folder),
                                              title: Text('Gallery / Files'),
                                              onTap: () async {
                                                final pickedFile =
                                                    await ImagePicker()
                                                        .pickImage(
                                                          source:
                                                              ImageSource
                                                                  .gallery,
                                                        );
                                                if (pickedFile != null) {
                                                  //use pickedFile.path
                                                  Navigator.pop(
                                                    context,
                                                  ); //close the bottom sheet
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0XFF27AF34),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: UiHelper.CustomText(
                                  text: "Upload Files",
                                  color: Color(0XFFFFFFFF),
                                  fontweight: FontWeight.bold,
                                  fontsize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    right: 40,
                    child: UiHelper.CustomImage(img: "files.png"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAddressWidget() {
    const int maxChars = 30;
    if (userAddress == "User not logged in" ||
        userAddress == "No address found") {
      return Text(
        userAddress,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      );
    }
    if (userAddress.length <= maxChars) {
      return Text(userAddress, style: const TextStyle(fontSize: 13));
    }
    return GestureDetector(
      onTap: () => setState(() => showFullAddress = !showFullAddress),
      child: Text(
        showFullAddress
            ? userAddress
            : "${userAddress.substring(0, maxChars)}...",
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Future<void> _fetchUserAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => userAddress = "User not logged in");
      return;
    }
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('addresses')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(
        () =>
            userAddress =
                "${data['house']}, ${data['area']}, ${data['address']}",
      );
    } else {
      setState(() => userAddress = "No address found");
    }
  }
}
