import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  @override
  _CreateItemPageState createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                  decoration: const InputDecoration(labelText: 'Item Code')),
              TextFormField(
                  decoration: const InputDecoration(labelText: 'Barcode')),
              TextFormField(
                  decoration: const InputDecoration(labelText: 'Unit')),
              TextFormField(
                  decoration: const InputDecoration(labelText: 'Length')),
              TextFormField(
                  decoration: const InputDecoration(labelText: 'Width')),
              TextFormField(
                  decoration: const InputDecoration(labelText: 'Height')),
              TextFormField(
                  decoration: const InputDecoration(labelText: 'Weight')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_images.length >= 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Maximum 5 images allowed')),
                    );
                    return;
                  }

                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                  );

                  if (pickedFile != null) {
                    final fileSize = await pickedFile.length(); // Get file size

                    if (fileSize <= 2 * 1024 * 1024) {
                      // Check if file size is <= 2MB
                      setState(() {
                        _images.add(pickedFile);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Image size must be less than 2MB')),
                      );
                    }
                  }
                },
                child: const Text('Pick Image'),
              ),
              Wrap(
                spacing: 10,
                children: _images
                    .map((image) =>
                        Image.file(File(image.path), width: 100, height: 100))
                    .toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle form submission
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
