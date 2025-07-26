import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

Future<String?> uploadCVToCloudinary(File file) async {
  const cloudName = 'dmwdf8q6o';
  const apiKey = '261788596984861';
  const apiSecret = 'GLZudU2e2fghjJRd1Kp8O29KJuA';

  final timestamp =
      (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();
  final signatureData = 'timestamp=$timestamp$apiSecret';
  final signature = sha1.convert(utf8.encode(signatureData)).toString();

  final url =
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/upload');

  final request = http.MultipartRequest('POST', url)
    ..fields['api_key'] = apiKey
    ..fields['timestamp'] = timestamp
    ..fields['signature'] = signature
    ..files.add(await http.MultipartFile.fromPath('file', file.path));

  try {
    final response = await request.send();
    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final data = jsonDecode(res.body);
      return data['secure_url'];
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<String?> uploadImageToCloudinary(File file) async {
  const cloudName = 'dmwdf8q6o';
  const apiKey = '261788596984861';
  const apiSecret = 'GLZudU2e2fghjJRd1Kp8O29KJuA';

  final timestamp =
      (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();
  final signatureData = 'timestamp=$timestamp$apiSecret';
  final signature = sha1.convert(utf8.encode(signatureData)).toString();

  final url =
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  final request = http.MultipartRequest('POST', url)
    ..fields['api_key'] = apiKey
    ..fields['timestamp'] = timestamp
    ..fields['signature'] = signature
    ..files.add(await http.MultipartFile.fromPath('file', file.path));

  try {
    final response = await request.send();
    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final data = jsonDecode(res.body);
      return data['secure_url'];
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
