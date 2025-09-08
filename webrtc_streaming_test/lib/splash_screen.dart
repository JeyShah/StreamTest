import 'package:flutter/material.dart';
import 'constants/flavours.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _carController;
  late Animation<Offset> _carSlideAnimation;

  late AnimationController _starController;
  late Animation<double> _starScaleAnimation;
  late Animation<Offset> _starMoveAnimation;

  @override
  void initState() {
    super.initState();

    // 🚗 Car animation (slide in)
    _carController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _carSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0), // start offscreen left
      end: Offset.zero, // center
    ).animate(CurvedAnimation(
      parent: _carController,
      curve: Curves.easeOut,
    ));

    // ⭐ Star animation (scale + move down)
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _starScaleAnimation = Tween<double>(
      begin: 0.1,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.easeOutBack,
    ));

    _starMoveAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0.75), // 👈 more distance = below the car
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.easeOut,
    ));

    // ⏳ Run car first, then trigger star
    _carController.forward().whenComplete(() {
      _starController.forward();
    });
  }

  @override
  void dispose() {
    _carController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SlideTransition(
          position: _carSlideAnimation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🚗 Car
              SizedBox(
                height: 150,
                child: Image.asset(
                  "assets/car.png",
                  fit: BoxFit.contain,
                ),
              ),

              // ⭐ Star (starts invisible, then appears at car center)
              SlideTransition(
                position: _starMoveAnimation,
                child: ScaleTransition(
                  scale: _starScaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20), // 👈 adjust spacing below car
                    child: Image.asset(
                      FlavorConfig.currentAppLogo, // 👈 put your star asset here
                      width: 200,
                      height: 200,
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