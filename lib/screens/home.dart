import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import 'package:image_picker/image_picker.dart';

import 'package:tflite_v2/tflite_v2.dart';

import '../drawer/drawer.dart';

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _image; // Variable to store the picked image

  ZoomDrawerController zoomDrawerController = ZoomDrawerController();

  // Function to open the image picker
  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(
          source: source); // Pick the image from the specified source
      if (pickedImage != null) {
        // If image was picked successfully, update the state to display the image
        setState(() {
          _image = File(pickedImage.path);
        });
      }
    } catch (e) {
      print(
          'Error picking image: $e'); // Log any error that occurs during image picking
    }
  }

  



  String modelPath = 'assets/best_model.tflite';
  String labelsPath = 'assets/labels.txt';


  List? restults;
  String confidence = "";
  String name = "";
  String number = "";


   loadModel() async {
    try {
      var result = await Tflite.loadModel(
        model: modelPath,
        labels: labelsPath,
        );
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  applymodelonimage(File, file) async {
    var res = await Tflite.runModelOnImage(
      path: file.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
      );

      setState(() {
        restults = res!;

        String str = restults![0]["labels"];
        name = str.substring(2);
        confidence = restults != null ? (restults![0]["confidence"]*100.0.toString().substring(0,2)) + "%" : "nothing";
      });
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    print("loadModel()  $loadModel()");
    print("loadModel()  $loadModel");
    print("applymodelonimage()  $applymodelonimage()");
    print("applymodelonimage()  $applymodelonimage");
    print('Name: $name \nconfidence $confidence ');
    print('restults: $restults ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eye Consult'),
        leading: IconButton(
          icon: const Icon(Icons.menu), // Add the drawer icon here
          onPressed: () {
            zoomDrawerController
                .toggle!(); // Open/close the zoomable drawer on icon tap
          },
        ),
      ),
      body: ZoomDrawer(
        controller: zoomDrawerController,
        style: DrawerStyle.defaultStyle,
        borderRadius: 24.0,
        showShadow: false,
        angle: -12.0,
        openCurve: Curves.fastOutSlowIn,
        closeCurve: Curves.bounceIn,
        drawerShadowsBackgroundColor: Colors.grey.shade300,
        slideWidth: MediaQuery.of(context).size.width * 0.65,
        menuScreen: const MyYoungDrawer(),
        mainScreen: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
             SelectableText(
                    'Name: $name \nconfidence $confidence '),
            const SizedBox(
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_image != null) ...[
                    // If an image is selected, display it
                    Image.file(_image!),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
             Center(
                child: SelectableText(
                    'Name: $name \nconfidence $confidence '))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(
            context), // Show the bottom sheet when the FAB is pressed
        child: const Icon(Icons.add_a_photo_rounded),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                15.0)), // Set the shape of the bottom sheet with rounded top corners
      ),
      builder: (BuildContext context) {
        return Container(
          child: _buildBottomSheetContent(),
        );
      },
    );
  }

  /// this is a model button sheet
  Widget _buildBottomSheetContent() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Options'),
          _buildRoundedButton(
            'Gallery',
            () {
              _getImage(ImageSource.gallery); // Pick an image from the gallery
              Navigator.pop(
                  context); // Close the bottom sheet after an option is selected
            },
          ),
          const SizedBox(height: 8.0),
          _buildRoundedButton(
            'Camera',
            () {
              _getImage(ImageSource.camera); // Pick an image from the camera
              Navigator.pop(
                  context); // Close the bottom sheet after an option is selected
            },
          ),
        ],
      ),
    );
  }

  /// these are the two widget for the two buttons form Elevated button
  Widget _buildRoundedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              15.0), // Set the shape of the button with rounded corners
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Text(text),
      ),
    );
  }
}
