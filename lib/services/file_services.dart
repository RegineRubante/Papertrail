import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:base_codecs/base_codecs.dart';

class FileService {
  static Future<void> downloadAndOpenFile(
    BuildContext context,
    String fileName,
    String base85Data,
  ) async {
    try {
      debugPrint('Starting download process...');
      debugPrint('Showing download progress dialog...');
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      }

      debugPrint('Getting application documents directory...');
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.pdf';
      debugPrint('File path: ${directory.path}/$fileName.pdf');

      debugPrint('Decoding base85 data...');
      final bytes = base85AsciiDecode(base85Data);
      final file = File(filePath);
      debugPrint('Writing bytes to file...');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        debugPrint('Closing progress dialog...');
        Navigator.pop(context);
      }

      debugPrint('Opening file...');
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        debugPrint('Failed to open file');
        throw 'Could not open file';
      }
      debugPrint('File opened successfully');
    } catch (e) {
      if (context.mounted) {
        debugPrint('Closing progress dialog due to error...');
        Navigator.pop(context);
      }

      debugPrint('Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<String?> getFileData(String documentId) async {
    try {
      debugPrint('Fetching file data for document ID: $documentId');
      final doc = await FirebaseFirestore.instance
          .collection('uploads')
          .doc(documentId)
          .get();

      debugPrint('File data fetched successfully');
      return doc.data()?['fileData'] as String?;
    } catch (e) {
      debugPrint('Error fetching file data: $e');
      return null;
    }
  }
}
