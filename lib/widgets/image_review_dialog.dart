import 'package:flutter/material.dart';
import 'package:flutter_scanner_app/model/product_model.dart';
import 'package:flutter_scanner_app/widgets/custom_button.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePreviewDialog extends StatelessWidget {
  final List<dynamic> images; // List of either XFile or ImageViewModel

  const ImagePreviewDialog({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: pageController,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: image is ImageViewModel
                        ? Image.network(
                            image.url ?? "",
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File((image as XFile).path),
                            fit: BoxFit.cover,
                          ),
                  );
                },
                onPageChanged: (index) {
                  pageController.jumpToPage(index);
                },
              ),
            ),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return GestureDetector(
                    onTap: () {
                      pageController.jumpToPage(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                        child: image is ImageViewModel
                            ? Image.network(
                                image.url ?? "",
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File((image as XFile).path),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            CustomButton(
              onTap: () {
                Navigator.of(context).pop();
              },
              title: "Đóng",
              margin: const EdgeInsets.all(16),
            ),
          ],
        ),
      ),
    );
  }
}
