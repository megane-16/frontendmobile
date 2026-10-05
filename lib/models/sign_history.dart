class SignHistory {
  final int? id;
  final String signName;
  final DateTime scannedAt;
  final String imagePath;

  const SignHistory({
    this.id,
    required this.signName,
    required this.scannedAt,
    required this.imagePath,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'sign_name': signName,
        'scanned_at': scannedAt.toIso8601String(),
        'image_path': imagePath,
      };

  factory SignHistory.fromMap(Map<String, Object?> map) => SignHistory(
        id: map['id'] as int?,
        signName: map['sign_name'] as String,
        scannedAt: DateTime.parse(map['scanned_at'] as String),
        imagePath: map['image_path'] as String,
      );
}
