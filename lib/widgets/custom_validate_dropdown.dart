import 'package:flutter/material.dart';

class CustomValidateDropDown extends StatefulWidget {
  final String label;
  final String? unit;
  final List<String>? unitList;
  final Function(String)? onSelected;
  final bool isRequired;
  final FormFieldValidator<String>? validator;

  const CustomValidateDropDown({
    super.key,
    required this.label,
    this.unit,
    required this.unitList,
    this.onSelected,
    this.isRequired = false,
    this.validator,
  });

  @override
  State<CustomValidateDropDown> createState() => _CustomValidateDropDownState();
}

class _CustomValidateDropDownState extends State<CustomValidateDropDown> {
  late List<String> list;
  String? dropdownValue;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    list = widget.unitList ?? [];
    dropdownValue = (widget.unit != null && list.contains(widget.unit))
        ? widget.unit
        : (list.isNotEmpty ? list.first : null);
  }

  @override
  void didUpdateWidget(covariant CustomValidateDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unitList != oldWidget.unitList ||
        widget.unit != oldWidget.unit) {
      setState(() {
        list = widget.unitList ?? [];
        dropdownValue = (widget.unit != null && list.contains(widget.unit))
            ? widget.unit
            : (list.isNotEmpty ? list.first : null);
      });
    }
  }

  void _onDropdownChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        dropdownValue = newValue;
        errorMessage = null;
        widget.onSelected?.call(newValue);
      });
    }
  }

  String? _validate() {
    if (widget.isRequired) {
      if (list.isEmpty) {
        return 'No options available';
      }
      if (dropdownValue == null || dropdownValue!.isEmpty) {
        return 'This field is required';
      }
    }
    if (widget.validator != null) {
      return widget.validator!(dropdownValue);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isError = _validate() != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: isError ? Colors.red : Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButton<String>(
              value: list.isNotEmpty ? dropdownValue : null,
              hint: Text(widget.label),
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              isExpanded: true,
              onChanged: list.isNotEmpty ? _onDropdownChanged : null,
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              underline: Container(),
            ),
          ),
          if (isError)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _validate() ?? "",
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
