import 'dart:io';
import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

class GoogleDriveService {
  static const _scopes = [drive.DriveApi.driveFileScope];

  Future<drive.DriveApi> _getDriveApi() async {
    // Lokasi file service_account.json
    final serviceAccountFile = File('assets/service_account.json');

    if (!serviceAccountFile.existsSync()) {
      throw Exception('Service account file not found at assets/service_account.json');
    }

    final credentials = json.decode(serviceAccountFile.readAsStringSync());
    final authClient = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(credentials),
      _scopes,
    );

    return drive.DriveApi(authClient);
  }

  Future<String?> uploadFileToGoogleDrive(File file) async {
    final driveApi = await _getDriveApi();

    final media = drive.Media(file.openRead(), file.lengthSync());
    final driveFile = drive.File()
      ..name = file.path.split('/').last
      ..parents = ["1v7THAXQ-mcw7NVrqVAkYRJw9QRRMnMJX"]; // ID folder Google Drive

    try {
      final uploadedFile = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );

      // Berikan izin publik untuk file
      await driveApi.permissions.create(
        drive.Permission()
          ..type = "anyone"
          ..role = "reader",
        uploadedFile.id!,
      );

      final fileUrl = "https://drive.google.com/uc?id=${uploadedFile.id}";
      print("File uploaded successfully: $fileUrl");
      return fileUrl;
    } catch (e) {
      print("Error uploading to Google Drive: $e");
      return null;
    }
  }


}
