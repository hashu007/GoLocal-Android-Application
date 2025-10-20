import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class _ImagePlaceholder extends StatefulWidget {
  final String? existingUrl;
  final ValueChanged<String?> onImageUploaded;

  const _ImagePlaceholder({this.existingUrl, required this.onImageUploaded});

  @override
  State<_ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<_ImagePlaceholder> {
  File? _pickedFile;
  bool _uploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() => _pickedFile = File(picked.path));
      await _uploadImage(File(picked.path));
    }
  }

  Future<void> _uploadImage(File file) async {
    setState(() => _uploading = true);
    try {
      final fileName = "uploads/${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      widget.onImageUploaded(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed: $e")),
      );
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.existingUrl;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _uploading
                ? const Center(child: CircularProgressIndicator())
                : (_pickedFile != null
                ? Image.file(_pickedFile!, fit: BoxFit.cover)
                : (imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 48))),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.upload),
          label: const Text("Upload Image"),
        ),
      ],
    );
  }
}
