import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

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
  FilePickerResult? result;
  List<PlatformFile> files = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Picker Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                pickFiles();
              },
              child: const Text('Pick Files'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => GalleryScreen()),
                // );
              },
              child: const Text('open gallery'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(files[index].name),
                    onTap: () {
                      viewFile(files[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pickFiles() async {
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4', 'PNG'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        files = result!.files;
      });
    }
  }

  void viewFile(PlatformFile file) {
    OpenFile.open(file.path);
  }
}
