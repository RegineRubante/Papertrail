import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../services/file_services.dart';
import 'package:file_picker/file_picker.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final fileNameController = TextEditingController();

    Get.put(fileNameController);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Document',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Profile section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.lightBlue,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String? profileImage;
                        if (snapshot.hasData && snapshot.data!.exists) {
                          try {
                            profileImage = snapshot.data?.get('profilePicture') as String?;
                          } catch (e) {
                            profileImage = null;
                          }
                        }
                        
                        return CircleAvatar(
                          radius: 40,
                          backgroundImage: profileImage != null
                              ? MemoryImage(base64Decode(profileImage))
                              : const AssetImage('lib/assets/profile1.png') as ImageProvider,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Error loading username');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            final username =
                                snapshot.data?.get('username') ?? 'username';
                            final role = snapshot.data?.get('role') ?? 'User';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  role,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          print('Starting document scan...');
                          // Get images from scanner
                          final List<String> scannedImages =
                              await CunningDocumentScanner.getPictures() ?? [];
                          print('Scanned images result: $scannedImages');
                          print('Navigating to PDF screen');

                          print('Creating PDF with filename');

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

                            final Uint8List imageBytes =
                                await imageFile.readAsBytes();
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

                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
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
                                  onPressed: () async {
                                    await uploadFile(context, userId,
                                        fileNameController.text, base64PDF);
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          );
                        } catch (e, stackTrace) {
                          print('Error occurred: $e');
                          print('Stack trace: $stackTrace');
                          Get.snackbar(
                            'Error',
                            'Failed to process document: ${e.toString()}',
                            backgroundColor: Colors.red.shade100,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Scan Document',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // Pick a PDF file
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                          );

                          debugPrint('File picker result: $result');

                          if (result != null) {
                            debugPrint('File picker result is not null');
                            PlatformFile file = result.files.first;
                            debugPrint('File path: ${file.path}');

                            // Read file bytes using dart:io
                            File pickedFile = File(file.path!);
                            Uint8List fileBytes = await pickedFile.readAsBytes();
                            debugPrint('File bytes read successfully: ${fileBytes.length} bytes');

                            // Convert to base64
                            String base64PDF = base64Encode(fileBytes);
                            debugPrint('Base64 conversion complete');

                            // Get the user ID
                            final userId = FirebaseAuth.instance.currentUser?.uid;
                            if (userId == null) {
                              Get.snackbar(
                                'Error',
                                'User not logged in',
                                backgroundColor: Colors.red.shade100,
                              );
                              return;
                            }

                            if (context.mounted) {
                              // Show dialog to enter file name
                              final fileNameController = TextEditingController(text: file.name);
                              showDialog<void>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Name your file'),
                                  content: TextField(
                                    controller: fileNameController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter file name',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await uploadFile(
                                          context,
                                          userId,
                                          fileNameController.text,
                                          base64PDF,
                                        );
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } else {
                            // User canceled the picker
                            Get.snackbar(
                              'Cancelled',
                              'No file selected',
                              backgroundColor: Colors.yellow.shade100,
                            );
                          }
                        } catch (e) {
                          debugPrint('Error picking/reading file: $e');
                          Get.snackbar(
                            'Error',
                            'Failed to read file: ${e.toString()}',
                            backgroundColor: Colors.red.shade100,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Upload File',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Files Uploaded Container
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.35,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.lightBlue,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Files Uploaded',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('uploads')
                              .where('userId', isEqualTo: userId)
                              .orderBy('uploadDate', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              print(snapshot.error);
                              return const Center(
                                child: Text('Error loading documents'),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.data?.docs.isEmpty ?? true) {
                              return const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No Documents uploaded',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              );
                            }

                            // Filter documents based on search query
                            final filteredDocs =
                                snapshot.data!.docs.where((doc) {
                              final fileName =
                                  doc['fileName'].toString().toLowerCase();
                              return fileName.contains(_searchQuery);
                            }).toList();

                            if (filteredDocs.isEmpty) {
                              return const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No matching documents found',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) {
                                final doc = filteredDocs[index];

                                return ListTile(
                                  leading: const Icon(Icons.file_present),
                                  title: Text(doc['fileName']),
                                  subtitle: Text(
                                    doc['uploadDate'] != null
                                        ? DateFormat('MMM d, yyyy')
                                            .format(doc['uploadDate'].toDate())
                                        : 'Date unknown',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () async {
                                      debugPrint('Downloading file...');
                                      final fileData =
                                          await FileService.getFileData(doc.id);
                                      if (fileData != null && context.mounted) {
                                        await FileService.downloadAndOpenFile(
                                          context,
                                          doc['fileName'],
                                          fileData,
                                        );
                                      } else if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Could not download file'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> uploadFile(BuildContext context, String userId, String fileName,
      String base64PDF) async {
    print('Uploading to Firestore...');
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    await FirebaseFirestore.instance.collection('uploads').add({
      'fileName': fileName,
      'uploadDate': FieldValue.serverTimestamp(),
      'fileData': base64PDF,
      'userId': userId,
    });

    print('Upload complete');
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
