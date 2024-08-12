import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final Function() onTap;
  final String title;
  final MaterialColor? btnColor;
  const CustomButton({
    super.key,
    required this.onTap,
    required this.title,
    this.btnColor = Colors.blue,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isOnTapRun = false;

  @override
  void initState() {
    isOnTapRun = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isOnTapRun ? _startOnTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        decoration: BoxDecoration(
          color: isOnTapRun ? Colors.grey : Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Future<void> _startOnTap() async {
    setState(() {
      isOnTapRun = true;
    });

    widget.onTap;

    setState(() {
      isOnTapRun = false;
    });
  }
}
