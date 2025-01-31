import 'package:flutter/material.dart';

class SafeAreaPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  final double expandedHeight;

  SafeAreaPersistentHeaderDelegate({required this.child, required this.expandedHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SafeArea(bottom: false, child: SizedBox.expand(child: child));
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(SafeAreaPersistentHeaderDelegate old) {
    if (old.child != child) {
      return true;
    }
    return false;
  }
}
