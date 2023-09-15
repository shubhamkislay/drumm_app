import 'package:flutter/cupertino.dart';

class AppleWatchMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Function onTap;

  const AppleWatchMenuItem({
    required Key key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: Draggable<int>(
        data: 0,
        feedback: Container(
          width: 100,
          height: 100,
          child: CupertinoButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: CupertinoColors.systemBlue,
                ),
                SizedBox(height: 8),
                Text(
                  label,
                  style: CupertinoTheme.of(context).textTheme.textStyle,
                ),
              ],
            ),
          ),
        ),
        childWhenDragging: Container(),
        child: DragTarget<int>(
          onWillAccept: (data) => data != 0,
          onAccept: (data) {
            // Handle item drop
          },
          builder: (context, candidateData, rejectedData) {
            return Opacity(
              opacity: candidateData.isEmpty ? 1.0 : 0.5,
              child: CupertinoButton(
                onPressed: onTap(),
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: CupertinoColors.systemBlue,
                    ),
                    SizedBox(height: 8),
                    Text(
                      label,
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
