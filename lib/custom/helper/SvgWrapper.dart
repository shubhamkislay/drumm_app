import 'package:flutter_svg/flutter_svg.dart';

class SvgWrapper {
  final String rawSvg;

  SvgWrapper(this.rawSvg);

  Future<SvgPicture?> generateLogo() async {
    assert(rawSvg != null);
    try {
      return await SvgPicture.string(rawSvg);
    } catch (e) {
      print(e);
      return null;
    }
  }
}