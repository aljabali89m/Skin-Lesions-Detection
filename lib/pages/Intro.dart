import 'package:flutter/material.dart';
import 'package:skin_disease_classifier/pages/classifier_page.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

// Add SingleTickerProviderStateMixin to handle the animation controller
class _IntroState extends State<Intro> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create a fade animation with a curve
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Create a slide animation for the icon and text
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5), // Start 50% down from the final position
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    // Create a scale animation for the button
    _scaleAnimation = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack));


    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is removed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Apply fade and slide transition to the icon
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SizedBox(
                    height:screenHeight/3 ,
                    child: Image.asset("assets/img/icon.png",)),
                ),
              ),
              SizedBox(height: screenHeight / 15),
              // Apply fade and slide transition to the text
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    "Skin Disease Classifier",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: screenWidth / 7, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: screenHeight / 10),
              // Apply scale and fade transition to the button
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _scaleAnimation, // You can use the same animation or a different one
                  child: Container(
                    width: screenWidth / 2,
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      borderRadius: BorderRadius.circular(25), // Corrected property
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(_createRoute());
                      },
                      child: Text(
                        "Start",
                        style: TextStyle(fontSize: screenWidth / 15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// This function now creates a route with a slide transition
Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const SkinClassifierScreen(),
    // Add transitions for the new page
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Define a slide transition from right to left
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    // Set transition duration
    transitionDuration: const Duration(milliseconds: 500),
  );
}