import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AnalyzeVideoPage extends StatefulWidget {
  @override
  _AnalyzeVideoPageState createState() => _AnalyzeVideoPageState();
}

class _AnalyzeVideoPageState extends State<AnalyzeVideoPage> {
  List<dynamic> analysisResults = [];
  bool loading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> pickAndUploadVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      setState(() {
        loading = true;
        analysisResults.clear();
      });

      try {
        final uri = Uri.parse('http://192.168.1.8:5000/analyze'); // IP السيرفر
        final request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath('video', file.path));

        final response = await request.send();
        if (response.statusCode == 200) {
          final body = await response.stream.bytesToString();
          final jsonResult = jsonDecode(body);

          setState(() {
            analysisResults = jsonResult;
            loading = false;
          });

          // 🔍 كشف "fall"
          bool fallDetected = false;
          for (var frame in jsonResult) {
            for (var detection in frame['detections']) {
              final label = detection['label'].toString().toLowerCase().trim();
              print("🔍 Label detected: $label"); // لطباعة التصنيفات

              if (label.contains('fall')) {
                fallDetected = true;
                break;
              }
            }
            if (fallDetected) break;
          }

          if (fallDetected) {
            await _audioPlayer.play(AssetSource('Alerts/siren-alert-96052.mp3'));
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text("⚠️ تنبيه سقوط"),
                content: Text("تم اكتشاف شخص ساقط في الفيديو."),
                actions: [
                  TextButton(
                    onPressed: () {
                      _audioPlayer.stop();
                      Navigator.pop(context);
                    },
                    child: Text("تم"),
                  )
                ],
              ),
            );
          }
        } else {
          print('❌ خطأ في الاستجابة: ${response.statusCode}');
          setState(() => loading = false);
        }
      } catch (e) {
        print('❌ استثناء: $e');
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : analysisResults.isEmpty
          ? Center(child: Text("لم يتم رفع أو تحليل فيديو بعد"))
          : ListView.builder(
        itemCount: analysisResults.length,
        itemBuilder: (context, index) {
          final frame = analysisResults[index];
          final detections = frame['detections'] as List;

          bool fallInFrame = detections.any((detection) =>
              detection['label']
                  .toString()
                  .toLowerCase()
                  .contains('fall'));

          String statusText = fallInFrame ? '🚨 سقوط' : '✅ طبيعي';
          Color statusColor = fallInFrame ? Colors.red : Colors.green;

          return Card(
            child: ListTile(
              title: Text("Frame ${frame['frame']}"),
              subtitle: Text("حالة الشخص: $statusText"),
              tileColor: statusColor.withOpacity(0.1),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickAndUploadVideo,
        child: Icon(Icons.video_call),
        tooltip: "رفع فيديو",
      ),
    );
  }
}
