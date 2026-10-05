enum UserRole { apprenant, moniteur, autoEcole, administrateur }

UserRole userRoleFromJson(dynamic value) {
  return UserRole.values.firstWhere(
    (role) => role.name == value,
    orElse: () => UserRole.apprenant,
  );
}

class User {
  final int? id;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String? ville;
  final String? sexe;
  final DateTime? dateNaissance;
  final String? categoriePermis;
  final String? autoEcole;
  final String? horaireFormation;
  final bool? hasCNI;
  final String? photoProfil;
  final String? token;
  final UserRole role;

  User({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    this.ville,
    this.sexe,
    this.dateNaissance,
    this.categoriePermis,
    this.autoEcole,
    this.horaireFormation,
    this.hasCNI,
    this.photoProfil,
    this.token,
    this.role = UserRole.apprenant,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: (json['nom'] ?? json['name'] ?? '').toString(),
      prenom: (json['prenom'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      telephone: json['telephone'],
      ville: json['ville'],
      sexe: json['sexe'],
      dateNaissance: json['date_naissance'] != null ? DateTime.parse(
          json['date_naissance']) : null,
      categoriePermis: json['categorie_permis'],
      autoEcole: json['auto_ecole'],
      horaireFormation: json['horaire_formation'],
      hasCNI: json['has_cni'] == 1 || json['has_cni'] == true,
      photoProfil: json['photo_profil'],
      token: json['token'],
      role: userRoleFromJson(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'ville': ville,
      'sexe': sexe,
      'date_naissance': dateNaissance?.toIso8601String(),
      'categorie_permis': categoriePermis,
      'auto_ecole': autoEcole,
      'horaire_formation': horaireFormation,
      'has_cni': hasCNI == true ? 1 : 0,
      'photo_profil': photoProfil,
      'role': role.name,
    };
  }
}
