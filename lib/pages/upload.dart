import 'dart:io';

import 'package:WaveCheck/models/user.dart';
import 'package:WaveCheck/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

final goalsRef = Firestore.instance.collection('goals');
final StorageReference storageRef = FirebaseStorage.instance.ref();
final DateTime timestamp = DateTime.now();

class Upload extends StatefulWidget {
  final User currentUser;
  final String goalID;

  Upload(this.goalID, this.currentUser);

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> with AutomaticKeepAliveClientMixin<Upload> {
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Photo with Camera"), onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(1.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/images/camera.png', height: 260.0),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              color: const Color(0xFF3cba54),
              textColor: Colors.white,
              padding: EdgeInsets.all(12.0),
              splashColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                "Upload Image",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              onPressed: () => selectImage(context)),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 50));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
      storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({String mediaUrl}) {
    goalsRef
    .document(widget.goalID)
    .updateData(
      {
        'urls': [mediaUrl],
        'completed': true,
        'timestamp': timestamp
      }
    );
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
    );
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: clearImage
        ),
        title: Text(
          "",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              "Post",
              style: TextStyle(
                color: Color(0xFF46A4E4),
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.cloud_upload,
              color: Colors.grey[600],
              size: 35.0,
            ),
            title: Container(
              child: Text("You're almost there! Click Post to upload and complete your goal.")
            ),
          ),
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
