import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'component/constants.dart';
import 'component/custom_outline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class MlModel extends StatefulWidget {
  @override
  State<MlModel> createState() => _MlModel();
}

class _MlModel extends State<MlModel> {
  String? result;
  final picker = ImagePicker();
  File? img;
  var url =
      "http://192.168.8.189:5000/predict"; // Ensure this URL is correct and accessible
  // get image from device function
  Future pickImage() async {
    try {
      final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          img = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // get image using camera function
  Future captureImage() async {
    try {
      final capturedFile = await picker.getImage(
        source: ImageSource.camera,
      );
      if (capturedFile != null) {
        setState(() {
          img = File(capturedFile.path);
        });
      } else {
        print('No image captured.');
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  // upload image function
  Future upload() async {
    if (img == null) {
      // Show the dialog if no image is picked
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Image Selected'),
            content: Text('Please pick an image before uploading.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
    // if (img == null) {
    //   print('No image selected for upload.');
    //   return;
    // }
    try {
      final request = http.MultipartRequest("POST", Uri.parse(url));
      final headers = {"Content-Type": "multipart/form-data"};
      request.files.add(
        http.MultipartFile(
            'image', img!.readAsBytes().asStream(), img!.lengthSync(),
            filename: img!.path.split('/').last),
      );
      request.headers.addAll(headers);

      final myRequest = await request.send();
      final res = await http.Response.fromStream(myRequest);

      if (myRequest.statusCode == 200) {
        final resJson = jsonDecode(res.body);
        print("response here: $resJson");
        setState(() {
          result = resJson['prediction'];
        });
        // Check if the prediction is "Healthy" and navigate to Threat page if true
        if (result == 'Healthy') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreatPage(diseaseName: result!),
            ),
          );
        }
        else if (['Alternaria', 'Anthracnose', 'Bacterial_Blight', 'Cercospora']
            .contains(result)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreatPage(diseaseName: result!),
            ),
          );
        }


      }
        else {
            print("Error ${myRequest.statusCode}: ${res.body}");
        }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  // UI start Here
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Constants.kBlackColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Constants.kPinkColor,
        title: Text('Pomergrenete Disease Prediction'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          width: screenWidth,
          child: Stack(
            children: [
              Positioned(
                top: screenHeight * 0.1,
                left: -88,
                child: Container(
                  height: 166,
                  width: 166,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Constants.kPinkColor,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 200,
                      sigmaY: 200,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.3,
                right: -100,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Constants.kGreenColor,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 200,
                      sigmaY: 200,
                    ),
                    child: Container(
                      height: 200,
                      width: 200,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                    CustomOutline(
                      strokeWidth: 4,
                      radius: screenWidth * 0.8,
                      padding: const EdgeInsets.all(4),
                      width: screenWidth * 0.8,
                      height: screenWidth * 0.8,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Constants.kPinkColor,
                          Constants.kPinkColor.withOpacity(0),
                          Constants.kGreenColor.withOpacity(0.1),
                          Constants.kGreenColor
                        ],
                        stops: const [
                          0.2,
                          0.4,
                          0.6,
                          1,
                        ],
                      ),
                      child: Center(
                        child: img == null
                            ? Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomLeft,
                              image: AssetImage(''),
                            ),
                          ),
                        )
                            : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomLeft,
                              image: FileImage(img!),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                    Center(
                      child: img == null
                          ? Text(
                        'THE MODEL HAS NOT BEEN PREDICTED',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Constants.kWhiteColor.withOpacity(0.85),
                          fontSize: screenHeight <= 667 ? 18 : 34,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                          : Text(
                        'Result from Model Trained: $result',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Constants.kWhiteColor.withOpacity(0.85),
                          fontSize: screenHeight <= 667 ? 18 : 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    CustomOutline(
                      strokeWidth: 3,
                      radius: 20,
                      padding: const EdgeInsets.all(3),
                      width: 180,
                      height: 38,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Constants.kPinkColor, Constants.kGreenColor],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Constants.kPinkColor.withOpacity(0.5),
                              Constants.kGreenColor.withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.white12,
                            ),
                          ),
                          onPressed: pickImage,
                          child: Text(
                            'Pick Image Here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Constants.kWhiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    CustomOutline(
                      strokeWidth: 3,
                      radius: 20,
                      padding: const EdgeInsets.all(3),
                      width: 180,
                      height: 38,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Constants.kPinkColor, Constants.kGreenColor],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Constants.kPinkColor.withOpacity(0.5),
                              Constants.kGreenColor.withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.white12,
                            ),
                          ),
                          onPressed: captureImage,
                          child: Text(
                            'Capture Image',
                            style: TextStyle(
                              fontSize: 14,
                              color: Constants.kWhiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    CustomOutline(
                      strokeWidth: 3,
                      radius: 20,
                      padding: const EdgeInsets.all(3),
                      width: 160,
                      height: 38,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Constants.kPinkColor, Constants.kGreenColor],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Constants.kPinkColor.withOpacity(0.5),
                              Constants.kGreenColor.withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.white12,
                            ),
                          ),
                          onPressed: upload,
                          child: Text(
                            'Upload Image',
                            style: TextStyle(
                              fontSize: 14,
                              color: Constants.kWhiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThreatPage extends StatelessWidget {
  final String diseaseName;

  const ThreatPage({Key? key, required this.diseaseName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String treatment = getTreatment(diseaseName);

    return Scaffold(
      appBar: AppBar(
        title: Text('Treatment for $diseaseName'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Threat detected: $diseaseName',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Recommended Treatment:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              treatment,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  String getTreatment(String disease) {
    switch (disease) {
      case 'Alternaria':
        return 'Treatment for Alternaria:\n'
            '- Spray fungicides such as chlorothalonil or mancozeb.\n'
            '- Remove and destroy infected leaves and fruit.\n'
            '- Ensure proper irrigation management to avoid water stress.\n'
            '- Apply neem oil or sulfur-based sprays as a preventive measure.\n'
            '- Ensure adequate air circulation by pruning overcrowded branches.';

      case 'Anthracnose':
        return 'Treatment for Anthracnose:\n'
            '- Use copper-based fungicides like copper oxychloride or Bordeaux mixture.\n'
            '- Regularly prune and dispose of affected twigs and leaves.\n'
            '- Avoid overhead irrigation to reduce moisture on foliage and fruit.\n'
            '- Apply bio-control agents like Trichoderma harzianum as a preventive measure.\n'
            '- Ensure timely harvesting to reduce the risk of post-harvest infection.';

      case 'Bacterial_Blight':
        return 'Treatment for Bacterial Blight:\n'
            '- Apply bactericides like streptomycin sulfate or copper-based products.\n'
            '- Prune and burn affected parts of the plant immediately.\n'
            '- Avoid mechanical injuries to the plant, which can act as entry points for bacteria.\n'
            '- Maintain proper spacing between plants to reduce humidity.\n'
            '- Practice crop rotation and avoid growing pomegranates in the same spot continuously.';

      case 'Cercospora':
        return 'Treatment for Cercospora:\n'
            '- Spray systemic fungicides like carbendazim or thiophanate-methyl.\n'
            '- Remove and destroy infected leaves and plant debris.\n'
            '- Regularly inspect plants and act quickly at the first sign of infection.\n'
            '- Avoid wetting the foliage during irrigation to minimize spore spread.\n'
            '- Apply organic sprays like neem oil or garlic extract as a preventive measure.';

      default:
        return 'No specific treatment available for the detected disease.';
    }

  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.brightness_1, size: 8, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
