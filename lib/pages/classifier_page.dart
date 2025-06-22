import 'package:flutter/material.dart';
import 'package:skin_disease_classifier/const/ngrok.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class SkinClassifierScreen extends StatefulWidget {
  const SkinClassifierScreen({super.key});

  @override
  _SkinClassifierScreenState createState() => _SkinClassifierScreenState();
}

// Add SingleTickerProviderStateMixin to handle animation controllers
class _SkinClassifierScreenState extends State<SkinClassifierScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  final String baseUrl = ngrok_url; // Assuming ngrok_url is defined elsewhere

  // Animation controller for entrance animations
  late AnimationController _controller;
  late List<Animation<double>> _entranceAnimations;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create staggered animations for widgets
    _entranceAnimations = List.generate(
      4, // Number of widgets to animate
      (index) => CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.2 * index, // Staggered start time
          0.5 + 0.2 * index, // Staggered end time
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // Start the animations
    _controller.forward();
  }

  @override
  void dispose() {
    // Dispose the controller to free up resources
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _result = null; // Reset result when a new image is picked
      }
    });
  }

  Future<void> _classifyImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var jsonResponse = json.decode(responseString);

      setState(() {
        _result = jsonResponse;
        _isLoading = false;
      });

      if (jsonResponse['success'] == false) {
        _showErrorDialog(jsonResponse['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error connecting to server: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper widget for building animated items
  Widget _buildAnimatedItem({required Widget child, required Animation<double> animation}) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Disease Classifier'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAnimatedItem(
              animation: _entranceAnimations[0],
              child: Card(
                elevation: 4,
                clipBehavior: Clip.antiAlias, // Ensures the image respects the card's border radius
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SizedBox(
                  height: screenHeight * 0.35,
                  // *** ANIMATION: Use AnimatedSwitcher for a smooth cross-fade between placeholder and image ***
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _image == null
                        ? Center(
                            key: const ValueKey('placeholder'), // Add a key for the switcher to identify the widget
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: screenWidth * 0.15, color: Colors.grey),
                                SizedBox(height: screenHeight * 0.02),
                                const Text('No image selected'),
                              ],
                            ),
                          )
                        : Image.file(
                           _image!,
                            key: ValueKey(_image!.path), // Use a unique key for the image
                            fit: BoxFit.cover
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.025),

            _buildAnimatedItem(
              animation: _entranceAnimations[1],
              child: ElevatedButton.icon(
                onPressed: _showPickerDialog,
                label: const Text('Select Image'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),

            _buildAnimatedItem(
              animation: _entranceAnimations[2],
              child: ElevatedButton.icon(
                onPressed: _image == null || _isLoading ? null : _classifyImage,
                icon: _isLoading
                    ? SizedBox(
                        width: screenHeight * 0.025,
                        height: screenHeight * 0.025,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : null,
                label: Text(_isLoading ? 'Classifying...' : 'Classify Image'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.025),

            // *** ANIMATION: AnimatedSwitcher to gracefully show/hide the results card ***
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.vertical,
                    child: child,
                  ),
                );
              },
              child: (_result != null && _result!['success'] == true)
                  ? _buildResultsCard(screenWidth, screenHeight) // Display the card if results are available
                  : const SizedBox.shrink(key: ValueKey('empty')), // Otherwise, display an empty box
            ),
            SizedBox(height: screenHeight/20,),
          ],
        ),
      ),
    );
  }

  // Extracted results card into a builder method for clarity
  Widget _buildResultsCard(double screenWidth, double screenHeight) {
    return Card(
      key: const ValueKey('resultsCard'),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Classification Result',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                   SizedBox(
                    height:screenHeight/18 ,
                    child: Image.asset("assets/img/icon.png",)),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Predicted Class:',
                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                        Text(
                          _result!['predicted_class'],
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Confidence: ${_result!['confidence']}%',
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'All Predictions:',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            ...(_result!['all_predictions'] as Map<String, dynamic>)
                .entries
                .map((entry) => Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text(
                            '${entry.value}%',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )),
          ],
        ),
      ),
    );
  }
}