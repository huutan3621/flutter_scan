import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/controller/create_item_provider.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/widgets/custom_button.dart';
import 'package:flutter_scanner_app/widgets/custom_textform_field.dart';
import 'package:flutter_scanner_app/widgets/custom_validate_dropdown.dart';
import 'package:flutter_scanner_app/widgets/loading_overlay.dart';
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
      homeProvider.init(
        widget.itemCode,
        widget.product,
        widget.unitList,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateItemProvider>(
      builder: (context, value, child) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, value.itemCodeController.text);
            return false;
          },
          child: CustomLoadingOverlay(
            isLoading: value.isLoading,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Cập nhật sản phẩm'),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: value.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: value.itemCodeController,
                            enabled: value.isItemCodeScanEnabled,
                            readOnly: true,
                            decoration: const InputDecoration(labelText: 'SKU'),
                            onTap: () {
                              value.scanItemCode(context);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Trường này bắt buộc nhập';
                              }
                              return null;
                            },
                          ),
                          // TextFormField(
                          //   controller: value.barCodeController,
                          //   enabled: value.isBarcodeEnable,
                          //   readOnly: true,
                          //   decoration:
                          //       const InputDecoration(labelText: 'Barcode'),
                          //   onTap: () {
                          //     value.scanBarCode(context);
                          //   },
                          //   validator: (value) {
                          //     if (value == null || value.isEmpty) {
                          //       return 'Trường này bắt buộc nhập';
                          //     }
                          //     return null;
                          //   },
                          // ),

                          TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                                text: widget.product?.itemName ?? ""),
                            decoration: const InputDecoration(
                                labelText: 'Tên sản phẩm'),
                          ),
                          CustomValidateDropDown(
                            label: "Đơn vị",
                            selectedItem: value.selectedProductUnit,
                            itemList: value.unitList,
                            disabledItemList: value.disableUnitList ?? [],
                            isRequired: true,
                            onSelected: (p0) {
                              value.chooseUnit(p0);
                            },
                            validator: (selectedUnit) {
                              if (value.unitList.isEmpty) {
                                return 'Không có đơn vị khả dụng';
                              }
                              if (selectedUnit == null ||
                                  selectedUnit.isEmpty) {
                                return 'Trường này bắt buộc nhập';
                              }
                              return null;
                            },
                            // isLoading: value.isLoading,
                          ),
                          SelectUnitTextFormField(
                            controller: value.lengthController,
                            label: "Độ dài",
                            unit: value.selectedLengthUnit,
                            selectedUnit: value.selectedLengthUnit,
                            callback: (previousValue, currentValue) {
                              value.updateSelectedUnit(
                                  previousValue, currentValue);
                            },
                            unitList: value.lengthUnit,
                            isRequired: true,
                          ),
                          SelectUnitTextFormField(
                            controller: value.widthController,
                            label: "Chiều rộng",
                            unit: value.selectedLengthUnit,
                            selectedUnit: value.selectedLengthUnit,
                            callback: (previousValue, currentValue) {
                              value.updateSelectedUnit(
                                  previousValue, currentValue);
                            },
                            unitList: value.lengthUnit,
                            isRequired: true,
                          ),
                          SelectUnitTextFormField(
                            controller: value.heightController,
                            label: "Chiều cao",
                            unit: value.selectedLengthUnit,
                            selectedUnit: value.selectedLengthUnit,
                            callback: (previousValue, currentValue) {
                              value.updateSelectedUnit(
                                  previousValue, currentValue);
                            },
                            unitList: value.lengthUnit,
                            isRequired: true,
                          ),
                          SelectUnitTextFormField(
                            controller: value.weightController,
                            label: "Cân nặng",
                            unit: value.selectedWeightUnit,
                            selectedUnit: value.selectedWeightUnit,
                            callback: (previousValue, currentValue) {
                              value.updateSelectedWeightUnit(
                                  previousValue, currentValue);
                            },
                            unitList: value.weightUnit,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(
                              value.images.length,
                              (index) {
                                final image = value.images[index];
                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        value.showImagePreview(context);
                                      },
                                      child: SizedBox(
                                        width:
                                            (MediaQuery.of(context).size.width /
                                                    3) -
                                                20,
                                        height: 100,
                                        child: Image.file(
                                          File(image.path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.cancel,
                                            color: Colors.white),
                                        onPressed: () {
                                          value.removeImage(index);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        onTap: () async {
                          showModalBottomSheet<void>(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return modalBottomSheet(value, context);
                            },
                          );
                        },
                        title: 'Thêm ảnh',
                        btnColor: Colors.green[300],
                      ),
                      CustomButton(
                        onTap: () async {
                          if (value.formKey.currentState?.validate() ?? false) {
                            value.onSubmit(context);
                          }
                        },
                        title: 'Cập nhật',
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
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            onTap: () async {
              value.chooseImageFromGallery(context);
            },
            title: 'Thư viện',
            btnColor: Colors.green[300],
          ),
          const SizedBox(height: 16),
          CustomButton(
            onTap: () async {
              value.chooseImageFromCamera(context);
            },
            title: 'Máy ảnh',
            btnColor: Colors.blue[400],
          ),
        ],
      ),
    );
  }
}
