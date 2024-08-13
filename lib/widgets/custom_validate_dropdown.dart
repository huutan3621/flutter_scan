import 'package:flutter/material.dart';

class CustomValidateDropDown extends StatefulWidget {
  final String label;
  final String? selectedItem;
  final List<String>? itemList;
  final Function(String)? onSelected;
  final bool isRequired;
  final FormFieldValidator<String>? validator;
  final List<String>? disabledItemList;
  final bool isLoading;

  const CustomValidateDropDown({
    super.key,
    required this.label,
    this.selectedItem,
    required this.itemList,
    this.onSelected,
    this.isRequired = false,
    this.validator,
    this.disabledItemList,
    this.isLoading = false,
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
    _updateDropdownValue();
  }

  @override
  void didUpdateWidget(covariant CustomValidateDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemList != oldWidget.itemList ||
        widget.selectedItem != oldWidget.selectedItem ||
        widget.disabledItemList != oldWidget.disabledItemList) {
      _updateDropdownValue();
    }
  }

  void _updateDropdownValue() {
    list = widget.itemList ?? [];
    dropdownValue = (widget.selectedItem != null &&
            widget.selectedItem!.isNotEmpty &&
            list.contains(widget.selectedItem))
        ? widget.selectedItem
        : (list.isNotEmpty ? list.first : null);
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
          Text(widget.label),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isError ? Colors.red : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButton<String>(
              value: dropdownValue, // Ensure dropdownValue is used
              hint: Text(widget.label),
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              isExpanded: true,
              onChanged: list.isNotEmpty
                  ? (value) {
                      if (value != null &&
                          !(widget.disabledItemList?.contains(value) ??
                              false)) {
                        _onDropdownChanged(value);
                      }
                    }
                  : null,
              items: list.map<DropdownMenuItem<String>>((String value) {
                final isDisabled =
                    widget.disabledItemList?.contains(value) ?? false;
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: isDisabled ? Colors.grey : Colors.black,
                    ),
                  ),
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
