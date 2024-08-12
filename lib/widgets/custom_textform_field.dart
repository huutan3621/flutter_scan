import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/widgets/dialog_helper.dart';

class SelectUnitTextFormField extends StatefulWidget {
  final String label;
  final String unit;
  final bool obscureText;
  final IconButton? iconButton;
  final Function(String, String)? callback;
  final TextEditingController? controller;
  final List<String>? unitList;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool? isRequired;
  final String? selectedUnit; // Added selectedUnit field

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
    this.validator,
    this.isRequired = false,
    this.selectedUnit, // Added selectedUnit field
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
    // Ensure dropdownValue is a valid item in list or set to null
    dropdownValue = list.contains(widget.selectedUnit)
        ? widget.selectedUnit!
        : (list.isNotEmpty ? list.first : widget.unit);
  }

  @override
  void didUpdateWidget(covariant SelectUnitTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unitList != oldWidget.unitList ||
        widget.selectedUnit != oldWidget.selectedUnit) {
      setState(() {
        list = widget.unitList ?? [];
        dropdownValue = list.contains(widget.selectedUnit)
            ? widget.selectedUnit!
            : (list.isNotEmpty ? list.first : widget.unit);
      });
    }
  }

  void _onDropdownChanged(String? newValue) {
    if (newValue != null) {
      final value = widget.controller?.text ?? '';
      if (value.isEmpty || int.tryParse(value) != null) {
        setState(() {
          dropdownValue = newValue;
          if (widget.callback != null) {
            widget.callback!(dropdownValue, newValue);
          }
        });
      } else {
        // Show error or some feedback if the value is not an integer
        DialogHelper.showErrorDialog(
            context: context,
            message: 'Please enter a valid integer before changing the unit.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType ??
          TextInputType.number, // Ensure only number input
      decoration: InputDecoration(
        suffixIcon: widget.iconButton ??
            DropdownButton<String>(
              value: list.contains(dropdownValue) ? dropdownValue : null,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              onChanged: _onDropdownChanged,
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              underline: Container(), // Remove the underline
            ),
        labelText: widget.label,
      ),
      validator: widget.isRequired == true
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              // Check if value is a valid integer
              if (int.tryParse(value) == null) {
                return 'Please enter a valid integer';
              }
              return null;
            }
          : widget.validator,
    );
  }
}
