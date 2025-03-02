import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../controllers.onboarding/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      body: Stack(
        children: [
          //horizontal scrollable pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(
                  image: ShiftslImages.onboarding1,
                  title: "welcome to shiftsl",
                  subtile: "balh balah balah"),
              OnBoardingPage(
                  image: ShiftslImages.onboarding2,
                  title: "welcome to shiftsl",
                  subtile: "balh balah balah"),
              OnBoardingPage(
                  image: ShiftslImages.onboarding3,
                  title: "welcome to shiftsl",
                  subtile: "balh balah balah"),
            ],
          ),
          //skip button
          const OnBoardingSkip(),
          //dot navigation indicator
          const OnBoardingDotNav(),
          //Cicular button
          const OnBoardingButton(),
        ],
      ),
    );
  }
}

class OnBoardingButton extends StatelessWidget {
  const OnBoardingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      right: 20,
      child: ElevatedButton(
        onPressed: () => OnboardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: ShiftslColors.primaryColor,
          iconColor: ShiftslColors.secondaryColor,
        ),
        child: const Icon(Iconsax.arrow_right_3),
      ),
    );
  }
}

class OnBoardingDotNav extends StatelessWidget {
  const OnBoardingDotNav({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;
    return Positioned(
      bottom: 50,
      left: 20,
      child: SmoothPageIndicator(
        controller: controller.pageController,
        count: 3,
        onDotClicked: controller.dotNavigationClick,
        effect: ExpandingDotsEffect(
          dotColor: ShiftslColors.accentColor,
          activeDotColor: ShiftslColors.primaryColor,
          dotHeight: 8,
        ),
      ),
    );
  }
}

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 20,
      child: TextButton(
        onPressed: () => OnboardingController.instance.skipPage(),
        child: Text(
          "Skip",
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: ShiftslColors.primaryColor,
          ),
        ),
      ),
    );
  }
}

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subtile,
  });

  final String image, title, subtile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ShiftslSizes.defaultSpace),
      child: Column(
        children: [
          Image(
            width: ShiftslHelperFunctions.screenWidth() * 0.8,
            height: ShiftslHelperFunctions.screenHeight() * 0.6,
            image: AssetImage(image),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            subtile,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
