import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory
          .listSync()
          .where((file) => file.path.endsWith('.pdf'))
          .toList();
      
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading files: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _renameFile(FileSystemEntity file) async {
    final TextEditingController renameController = TextEditingController(
      text: file.path.split('/').last.replaceAll('.pdf', ''),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: renameController,
          decoration: const InputDecoration(
            labelText: 'New file name',
            hintText: 'Enter new file name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (renameController.text.trim().isNotEmpty) {
                try {
                  final newPath = '${file.parent.path}/${renameController.text.trim()}.pdf';
                  await file.rename(newPath);
                  _loadFiles(); // Refresh the list
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('File renamed successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Error renaming file: $e');
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error renaming file'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(FileSystemEntity file) async {
    try {
      await file.delete();
      _loadFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting file'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openFile(FileSystemEntity file) async {
    try {
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        throw result.message;
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Downloads'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFiles,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
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

                const SizedBox(height: 24),

                // Files container
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.6,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Downloaded Files',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _files.isEmpty
                                  ? const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.folder_open,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'No Documents Downloaded',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _files.length,
                                      itemBuilder: (context, index) {
                                        final file = _files[index];
                                        final fileName = file.path.split('/').last;
                                        final fileStats = file.statSync();
                                        final modifiedDate =
                                            DateFormat('MMM d, yyyy')
                                                .format(fileStats.modified);

                                        // Filter based on search query
                                        if (_searchQuery.isNotEmpty &&
                                            !fileName
                                                .toLowerCase()
                                                .contains(_searchQuery)) {
                                          return const SizedBox.shrink();
                                        }

                                        return Card(
                                          elevation: 2,
                                          margin:
                                              const EdgeInsets.only(bottom: 8),
                                          child: ListTile(
                                            leading:
                                                const Icon(Icons.file_present),
                                            title: Text(
                                              fileName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Text(modifiedDate),
                                            trailing: PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_vert),
                                              onSelected: (value) async {
                                                switch (value) {
                                                  case 'rename':
                                                    await _renameFile(file);
                                                    break;
                                                  case 'open':
                                                    await _openFile(file);
                                                    break;
                                                  case 'delete':
                                                    await showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            'Delete File'),
                                                        content: const Text(
                                                            'Are you sure you want to delete this file?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                                'Cancel'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              _deleteFile(file);
                                                            },
                                                            child: const Text(
                                                                'Delete',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red)),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    break;
                                                }
                                              },
                                              itemBuilder: (BuildContext context) => [
                                                const PopupMenuItem<String>(
                                                  value: 'open',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.open_in_new),
                                                      SizedBox(width: 8),
                                                      Text('Open'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem<String>(
                                                  value: 'rename',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.edit),
                                                      SizedBox(width: 8),
                                                      Text('Rename'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem<String>(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete, color: Colors.red),
                                                      SizedBox(width: 8),
                                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
