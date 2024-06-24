// import 'dart:io';
//
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:open_file/open_file.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   FilePickerResult? result;
//   List<PlatformFile> files = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('File Picker Demo'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 pickFiles();
//               },
//               child: const Text('Pick Files'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ShowImgStorage()),
//                 );
//               },
//               child: const Text('Pick image from storage'),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: files.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(files[index].name),
//                     onTap: () {
//                       viewFile(files[index]);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void pickFiles() async {
//     result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'png', 'mp4', 'PNG'],
//       allowMultiple: true,
//     );
//
//     if (result != null) {
//       setState(() {
//         files = result!.files;
//       });
//     }
//   }
//
//   void viewFile(PlatformFile file) {
//     OpenFile.open(file.path);
//   }
// }
//
// class ShowImgStorage extends StatelessWidget {
//   final String imagePath = 'C:/image/a2.jpg'; // Replace with your image path
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Display Image'),
//       ),
//       body: Center(
//         child: Image.file(
//           File(imagePath),
//           width: 300,
//           height: 300,
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
// }
///------------------------------------
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> imageFiles = [];

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;

    if (status.isGranted) {
      fetchImages();
    } else if (status.isDenied) {
      _showPermissionDialog();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _showPermissionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage Permission'),
          content: Text('This app needs storage access to display images.'),
          actions: <Widget>[
            TextButton(
              child: Text('Deny'),
              onPressed: () {
                Navigator.of(context).pop();
                print('Permission not granted');
              },
            ),
            TextButton(
              child: Text('Allow'),
              onPressed: () async {
                Navigator.of(context).pop();
                var result = await Permission.storage.request();
                if (result.isGranted) {
                  fetchImages();
                } else {
                  print('Permission not granted');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchImages() async {
    try {
      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        String imagePath =
            '/storage/emulated/0/image'; // Replace with your actual folder path

        Directory imageDirectory = Directory(imagePath);

        if (imageDirectory.existsSync()) {
          setState(() {
            imageFiles = imageDirectory
                .listSync()
                .where((item) =>
                    item is File &&
                    (item.path.endsWith('.jpg') ||
                        item.path.endsWith('.jpeg') ||
                        item.path.endsWith('.png')))
                .map((item) => File(item.path))
                .toList();
          });

          if (imageFiles.isEmpty) {
            print('No images found in the directory.');
          }
        } else {
          print('Directory does not exist: $imagePath');
        }
      } else {
        print('External storage directory is null');
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Images from External Storage'),
      ),
      body: imageFiles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: imageFiles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    imageFiles[index],
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                );
              },
            ),
    );
  }
}
