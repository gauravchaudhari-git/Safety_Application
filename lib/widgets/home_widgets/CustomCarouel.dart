import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myfirstproject/utils/quotes.dart';
import 'package:myfirstproject/widgets/home_widgets/safewebview.dart';

class CustomCarouel extends StatelessWidget {
  const CustomCarouel({super.key});

  void navigateToRoute(BuildContext context, Widget route) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => route));
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 2.0,
        autoPlay: true,
      ),
      items: List.generate(
        imageSliders.length,
        (index) => Card(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () {
              if (index == 0) {
                navigateToRoute(
                    context,
                    const SafeWebView(
                        url:
                            "https://seniority.in/blog/10-women-who-changed-the-face-of-india-with-their-achievements"));
              } else if (index == 1) {
                navigateToRoute(
                    context,
                    const SafeWebView(
                        url:
                            "https://plan-international.org/ending-violence/16-ways-end-violence-girls"));
              } else if (index == 2) {
                navigateToRoute(
                    context,
                    const SafeWebView(
                        url:
                            "https://www.healthline.com/health/womens-health/self-defense-tips-escape"));
              } else {
                navigateToRoute(
                    context,
                    const SafeWebView(
                        url:
                            "https://www.healthline.com/health/womens-health/self-defense-tips-escape"));
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        imageSliders[index],
                      ))),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ]),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 8),
                    child: Text(
                      articleTitle[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                      ),
                    ),
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
