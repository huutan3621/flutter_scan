import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/controller/create_item_provider.dart';
import 'package:flutter_scanner_app/model/item_model.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/widgets/custom_textform_field.dart';
import 'package:provider/provider.dart';

class CreateItemScreen extends StatelessWidget {
  final ProductModel? productModel;
  const CreateItemScreen({super.key, this.productModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreateItemProvider(),
      child: CreateItemChild(
        productModel: productModel,
      ),
    );
  }
}

class CreateItemChild extends StatefulWidget {
  final ProductModel? productModel;
  const CreateItemChild({super.key, this.productModel});

  @override
  _CreateItemChildState createState() => _CreateItemChildState();
}

class _CreateItemChildState extends State<CreateItemChild> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var homeProvider =
          Provider.of<CreateItemProvider>(context, listen: false);
      homeProvider.init(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateItemProvider>(
      builder: (context, value, child) {
        return Scaffold(
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
                    GestureDetector(
                      onTap: () async {
                        value.scanItemCode(context);
                      },
                      child: TextFormField(
                          controller: value.itemCodeController,
                          enabled: false,
                          decoration:
                              const InputDecoration(labelText: 'Item Code')),
                    ),
                    GestureDetector(
                      onTap: () async {
                        value.scanBarCode(context);
                      },
                      child: TextFormField(
                          controller: value.barCodeController,
                          enabled: false,
                          decoration:
                              const InputDecoration(labelText: 'Barcode')),
                    ),
                    // TextFormField(
                    //     controller: value.unitController,
                    //     enabled: false,
                    //     decoration: const InputDecoration(labelText: 'Unit')),
                    DropdownMenu<String>(
                      initialSelection: value.unitList.first,
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
                    //length
                    SelectUnitTextFormField(
                      controller: value.lengthController,
                      label: "Length",
                      unit: value.selectedLengthUnit,
                      callback: (previousValue, currentValue) {
                        value.updateSelectedLengthUnit(
                            previousValue, currentValue);
                      },
                      unitList: value.lengthUnit,
                    ),
                    //width
                    SelectUnitTextFormField(
                      controller: value.widthController,
                      label: "Width",
                      unit: value.selectedWidthUnit,
                      callback: (previousValue, currentValue) {
                        value.updateSelectedWidthUnit(
                            previousValue, currentValue);
                        // setState(() {});
                      },
                      unitList: value.lengthUnit,
                    ),
                    //height
                    SelectUnitTextFormField(
                      controller: value.weightController,
                      label: "Weight",
                      unit: value.selectedWeightUnit,
                      callback: (previousValue, currentValue) {
                        // setState(() {});
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
                        if (value.formKey.currentState!.validate()) {
                          // Handle form submission
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
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
              minimumSize: const Size(
                  double.infinity, 36), // Expands button width to full width
            ),
            child: const Text('Camera'),
          ),
        ],
      ),
    );
  }
}
