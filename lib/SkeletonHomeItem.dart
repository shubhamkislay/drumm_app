import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';

class SkeletonHomeItem extends StatelessWidget {
  const SkeletonHomeItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          color: COLOR_PRIMARY_DARK,
          borderRadius: BorderRadius.circular(8),
          //border: Border.all(color: Colors.grey.shade900,width: 2.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 125,
              width: 125,
              //color: Colors.black,
              child: Image.asset("images/drumm_logo.png",color: Colors.white.withOpacity(0.1),fit: BoxFit.contain,),
            ),
            const SizedBox(
              height: 200,
              width: 200,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 0.5,
              ),
            )
          ],
        ),
      ),
    );
  }
}
