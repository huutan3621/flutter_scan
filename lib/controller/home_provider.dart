import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/model/data_model.dart';
import 'package:flutter_scanner_app/model/item_model.dart';
import 'package:flutter_scanner_app/utils/assets.dart';
import 'package:flutter_scanner_app/utils/utils.dart';

class HomeProvider extends ChangeNotifier {
  late String scanResult = '';
  final TextEditingController textController = TextEditingController();
  final List<ItemModel> listData = [];

  Future<void> init(BuildContext context) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('${AppAsset.assets}mock.json');

    final Map<String, dynamic> jsonResult = json.decode(data);

    DataModel dataModel = DataModel.fromJson(jsonResult);

    for (ItemModel e in dataModel.listData) {
      listData.add(e);
    }
    notifyListeners();
  }

  void handleScanResult(String result, BuildContext context) {
    scanResult = Utils.handleTSScanResult(result, context);
    textController.text = scanResult;
    notifyListeners();
  }

  List<List<String>> data = [
    List.generate(8, (index) => 'Header $index'),
    List.generate(8, (index) => 'Data $index'),
  ];

  void addRow() {
    data.add(List.generate(8, (index) => 'New Data $index'));
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }
}
