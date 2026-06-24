class UserModel {
  final String id;
  final String nama;
  final String namaWarung;
  final String email;
  final String telepon;
  final String role; // 'owner' | 'admin'

  UserModel({
    required this.id,
    required this.nama,
    required this.namaWarung,
    required this.email,
    required this.telepon,
    this.role = 'owner',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      nama: map['nama'] ?? '',
      namaWarung: map['namaWarung'] ?? '',
      email: map['email'] ?? '',
      telepon: map['telepon'] ?? '',
      role: map['role'] ?? 'owner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'namaWarung': namaWarung,
      'email': email,
      'telepon': telepon,
      'role': role,
    };
  }

  UserModel copyWith({
    String? nama,
    String? namaWarung,
    String? email,
    String? telepon,
    String? role,
  }) {
    return UserModel(
      id: id,
      nama: nama ?? this.nama,
      namaWarung: namaWarung ?? this.namaWarung,
      email: email ?? this.email,
      telepon: telepon ?? this.telepon,
      role: role ?? this.role,
    );
  }
}
