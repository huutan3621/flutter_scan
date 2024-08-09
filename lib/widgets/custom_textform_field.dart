import 'package:flutter/material.dart';

class SelectUnitTextFormField extends StatefulWidget {
  final String label;
  final String unit;
  final bool obscureText;
  final IconButton? iconButton;
  final Function(String, String)? callback;
  final TextEditingController? controller;
  final List<String>? unitList;
  final TextInputType? keyboardType;

  const SelectUnitTextFormField({
    super.key,
    required this.label,
    required this.unit,
    this.obscureText = false,
    this.iconButton,
    this.callback,
    this.controller,
    required this.unitList,
    this.keyboardType,
  });

  @override
  State<SelectUnitTextFormField> createState() =>
      _SelectUnitTextFormFieldState();
}

class _SelectUnitTextFormFieldState extends State<SelectUnitTextFormField> {
  late List<String> list;
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    list = widget.unitList ?? [];
    dropdownValue = list.isNotEmpty ? list.first : '';
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType ?? TextInputType.number,
      decoration: InputDecoration(
        suffixIcon: widget.iconButton ??
            DropdownButton<String>(
              value: dropdownValue.isNotEmpty ? dropdownValue : null,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              onChanged: (String? value) {
                if (value != null) {
                  if (widget.callback != null) {
                    widget.callback!(dropdownValue, value);
                  }
                  setState(() {
                    dropdownValue = value;
                  });
                }
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
        labelText: widget.label,
      ),
    );
  }
}
