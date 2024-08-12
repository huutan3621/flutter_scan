import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final Function() onTap;
  final String title;
  final Color? btnColor;
  final TextStyle? txtStyle;
  final double? btnBorderRadius;
  final Color? txtColor;
  final double? txtSize;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.title,
    this.btnColor = Colors.blue,
    this.txtStyle,
    this.btnBorderRadius = 16.0,
    this.txtColor = Colors.white,
    this.txtSize = 16.0,
    this.padding = const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
    this.margin = const EdgeInsets.all(0),
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isOnTapRun = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin, // Apply margin here
      child: GestureDetector(
        onTap: isOnTapRun ? null : _startOnTap,
        child: Container(
          padding: widget.padding, // Apply padding here
          decoration: BoxDecoration(
            color: isOnTapRun ? Colors.grey : widget.btnColor,
            borderRadius: BorderRadius.circular(widget.btnBorderRadius ?? 16.0),
          ),
          child: Center(
            child: Text(
              widget.title,
              style: widget.txtStyle ??
                  TextStyle(
                    color: widget.txtColor ?? Colors.white,
                    fontSize: widget.txtSize ?? 16.0,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startOnTap() async {
    setState(() {
      isOnTapRun = true;
    });

    widget.onTap();

    setState(() {
      isOnTapRun = false;
    });
  }
}
