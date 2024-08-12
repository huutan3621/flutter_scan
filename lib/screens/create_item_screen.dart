import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/controller/create_item_provider.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/widgets/custom_textform_field.dart';
import 'package:provider/provider.dart';

class CreateItemScreen extends StatelessWidget {
  final ProductModel? product;
  final String? itemCode;
  final List<String>? unitList;

  const CreateItemScreen({
    super.key,
    this.itemCode,
    this.product,
    this.unitList,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreateItemProvider(),
      child: CreateItemChild(
        itemCode: itemCode,
        product: product,
        unitList: unitList,
      ),
    );
  }
}

class CreateItemChild extends StatefulWidget {
  final String? itemCode;
  final ProductModel? product;
  final List<String>? unitList;

  const CreateItemChild({
    super.key,
    this.itemCode,
    this.product,
    this.unitList,
  });

  @override
  _CreateItemChildState createState() => _CreateItemChildState();
}

class _CreateItemChildState extends State<CreateItemChild> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var homeProvider =
          Provider.of<CreateItemProvider>(context, listen: false);
      homeProvider.init(widget.itemCode, widget.product, widget.unitList);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateItemProvider>(
      builder: (context, value, child) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, 'refresh');
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Create Item'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: value.formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: value.itemCodeController,
                        enabled: value.isItemCodeScanEnabled,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'SKU'),
                        onTap: () {
                          value.scanItemCode(context);
                        },
                        onChanged: (value) {},
                      ),
                      TextFormField(
                        controller: value.barCodeController,
                        enabled: value.isBarcodeEnable,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Barcode'),
                        onTap: () {
                          value.scanBarCode(context);
                        },
                        onChanged: (value) {},
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: DropdownMenu<String>(
                          initialSelection: value.unitController.text.isEmpty
                              ? null
                              : value.unitController.text,
                          controller: value.unitController,
                          requestFocusOnTap: false,
                          label: const Text('Unit'),
                          expandedInsets: EdgeInsets.zero,
                          onSelected: (String? string) {
                            value.chooseUnit(string);
                          },
                          dropdownMenuEntries: value.unitList
                              .map<DropdownMenuEntry<String>>((String string) {
                            return DropdownMenuEntry<String>(
                              value: string,
                              label: string,
                            );
                          }).toList(),
                        ),
                      ),
                      SelectUnitTextFormField(
                        controller: value.lengthController,
                        label: "Length",
                        unit: value.selectedLengthUnit,
                        callback: (previousValue, currentValue) {
                          value.updateSelectedLengthUnit(
                              previousValue, currentValue);
                        },
                        unitList: value.lengthUnit,
                        isRequired: true,
                      ),
                      SelectUnitTextFormField(
                        controller: value.widthController,
                        label: "Width",
                        unit: value.selectedWidthUnit,
                        callback: (previousValue, currentValue) {
                          value.updateSelectedWidthUnit(
                              previousValue, currentValue);
                        },
                        unitList: value.lengthUnit,
                        isRequired: true,
                      ),
                      SelectUnitTextFormField(
                        controller: value.heightController,
                        label: "Height",
                        unit: value.selectedHeightUnit,
                        callback: (previousValue, currentValue) {
                          value.updateSelectedHeightUnit(
                              previousValue, currentValue);
                        },
                        unitList: value.lengthUnit,
                        isRequired: true,
                      ),
                      SelectUnitTextFormField(
                        controller: value.weightController,
                        label: "Weight",
                        unit: value.selectedWeightUnit,
                        callback: (previousValue, currentValue) {
                          value.updateSelectedWeightUnit(
                              previousValue, currentValue);
                        },
                        unitList: value.weightUnit,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        children: value.images
                            .map((image) => Image.file(File(image.path),
                                width: 100, height: 100))
                            .toList(),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return modalBottomSheet(value, context);
                            },
                          );
                        },
                        child: const Text('Import Image'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          value.onSubmit(context);
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget modalBottomSheet(CreateItemProvider value, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.teal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              value.chooseImageFromGallery(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
            ),
            child: const Text('Pick Image'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              value.chooseImageFromCamera(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
            ),
            child: const Text('Camera'),
          ),
        ],
      ),
    );
  }
}
