import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

typedef UploadProgressCallback = void Function(double progress);
typedef ImageUrlCallback = void Function(String imageUrl);
typedef PickedImageCallback = void Function(File? pickedImage);

double ratioX = 9;
double ratioY = 19;

Future<void> uploadPicture(
    Reference storageReference,
    UploadProgressCallback progressCallback,
    ImageUrlCallback imageUrlCallback,
    double ratiox,double ratioy,
    PickedImageCallback pickedImageCallback,
    ) async {
  final ImagePicker _picker = ImagePicker();
  ratioX = ratiox;
  ratioY = ratioy;

  // Allow the user to select an image from their phone
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  if (image == null) {
    // User canceled image selection
    return;
  }

  CroppedFile? croppedImage = await cropImage(File(image.path));
  if (croppedImage == null) {
    // Image cropping canceled
    return;
  }
  pickedImageCallback(File(croppedImage.path));

  // Create a reference to the Firebase Storage bucket
  // final Reference storageReference =
  // FirebaseStorage.instance.ref().child('user_images').child('$userId.jpg');

  // Upload the file to Firebase Storage and track the progress
  final UploadTask uploadTask = storageReference.putFile(File(croppedImage.path));
  uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
    final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
    progressCallback(progress);
  });

  // Wait for the upload to complete
  await uploadTask;

  // Get the download URL of the uploaded image
  final String downloadUrl = await storageReference.getDownloadURL();
  imageUrlCallback(downloadUrl);

  // Update the Firestore user collection with the download URL
  // await FirebaseFirestore.instance
  //     .collection('users')
  //     .doc(userId)
  //     .update({'profilePicture': downloadUrl});
}

Future<CroppedFile?> cropImage(File _pickedFile) async {
  if (_pickedFile != null) {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _pickedFile!.path,
      aspectRatio: CropAspectRatio(ratioX: ratioX,ratioY: ratioY),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        IOSUiSettings(
          aspectRatioLockEnabled: true,
          title: 'Cropper',
        ),
      ],
    );
    return croppedFile;
  }
}

// void main() {
//   // Initialize Firebase and other configurations
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Image Upload',
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Image Upload'),
//         ),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () {
//               // Define the Firebase Storage reference
//               final Reference storageReference =
//               FirebaseStorage.instance.ref().child('user_images').child('example.jpg');
//
//               uploadPicture(
//                 storageReference,
//                     (double progress) {
//                   print('Upload progress: $progress');
//                 },
//                     (String imageUrl) {
//                   print('Download URL: $imageUrl');
//                 },
//                 9,19,
//                     (File? pickedImage) {
//                   // Do something with the picked image file
//                 },
//               );
//             },
//             child: const Text('Upload Image'),
//           ),
//         ),
//       ),
//     );
//   }
// }
