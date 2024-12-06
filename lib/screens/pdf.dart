import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

class PDFScreen extends StatelessWidget {
  const PDFScreen({super.key, required this.scannedImages});

  final List<String> scannedImages;

  @override
  Widget build(BuildContext context) {
    final fileNameController = TextEditingController();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Name your file'),
            TextField(
              controller: fileNameController,
              decoration: const InputDecoration(
                hintText: 'Enter a name for your file',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String? fileName = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Name your file'),
                      content: TextField(
                        controller: fileNameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter file name',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Get.back(result: fileNameController.text),
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                );

                if (fileName == null || fileName.isEmpty) {
                  print('No filename provided');
                  return;
                }

                print('Creating PDF with filename: $fileName');

                // Create PDF document
                final pdf = pw.Document();

                // Convert each image to PDF page
                for (String imagePath in scannedImages) {
                  print('Processing image: $imagePath');
                  final File imageFile = File(imagePath);

                  if (!await imageFile.exists()) {
                    print('Image file does not exist: $imagePath');
                    continue;
                  }

                  final Uint8List imageBytes = await imageFile.readAsBytes();
                  print('Image size: ${imageBytes.length} bytes');

                  final pdfImage = pw.MemoryImage(imageBytes);

                  pdf.addPage(
                    pw.Page(
                      pageFormat: PdfPageFormat.a4,
                      build: (pw.Context context) {
                        return pw.Center(
                          child: pw.Image(pdfImage),
                        );
                      },
                    ),
                  );
                }

                print('PDF pages created');

                // Get PDF bytes
                final Uint8List pdfBytes = await pdf.save();
                print('PDF size: ${pdfBytes.length} bytes');

                // Convert to base64
                final String base64PDF = base64Encode(pdfBytes);
                print('Base64 conversion complete');

                // Upload to Firestore
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId == null) throw 'User not logged in';

                print('Uploading to Firestore...');
                await FirebaseFirestore.instance
                    .collection('uploads')
                    .doc(userId)
                    .collection('files')
                    .doc(fileName)
                    .set({
                  'fileName': fileName,
                  'uploadDate': FieldValue.serverTimestamp(),
                  'fileData': base64PDF,
                });

                print('Upload complete');
                Get.snackbar(
                  'Success',
                  'Document scanned and uploaded successfully',
                  backgroundColor: Colors.green.shade100,
                );
              },
              child: const Text('Create PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
