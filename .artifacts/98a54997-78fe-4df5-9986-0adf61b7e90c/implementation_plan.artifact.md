# Support des Documents (Images & PDF) pour les Leçons

Permettre aux moniteurs d'uploader des images ET des fichiers PDF pour les cours, et permettre aux apprenants de visualiser ces images et télécharger les fichiers PDF sur leur dashboard mobile.

## User Review Required

> [!IMPORTANT]
> Les modifications touchent à la fois la base de données (ajout de colonnes), le backend Laravel (logique d'upload et API) et le frontend Flutter (affichage et téléchargement).

## Proposed Changes

### Backend (Laravel) - `/home/ngo-ndjeng-cresse/drive_flow`

#### [NEW] [Migration]
- Créer une migration pour ajouter `media_path` (string) et `media_type` (string) à la table `driving_lessons`.

#### [MODIFY] [InstructorDashboardController.php](file:///home/ngo-ndjeng-cresse/drive_flow/app/Http/Controllers/Api/InstructorDashboardController.php)
- Mettre à jour `complete` pour gérer l'upload du fichier (image ou PDF).
- Mettre à jour `presentLesson` pour inclure l'URL complète du fichier et son type.

### Frontend (Flutter)

#### [MODIFY] [cour_model.dart](file:///home/ngo-ndjeng-cresse/AndroidStudioProjects/driveflow1/lib/models/cour_model.dart)
- Ajouter `final String? mediaPath;` et `final String? mediaType;` à la classe `Lesson`.
- Mettre à jour `fromJson` pour parser ces champs.

#### [MODIFY] [cour.dart](file:///home/ngo-ndjeng-cresse/AndroidStudioProjects/driveflow1/lib/views/cour.dart)
- Dans `_buildLessonItem`, ajouter une logique conditionnelle :
  - Si `mediaType` est une image : Afficher une prévisualisation de l'image.
  - Si `mediaType` est un PDF : Ajouter un bouton "Télécharger le PDF".

## Verification Plan

### Manual Verification
- Le moniteur enregistre un cours avec un fichier (PDF ou image).
- L'apprenant ouvre son dashboard.
- Vérifier l'affichage du fichier ou du bouton de téléchargement selon le type.
- Vérifier que le téléchargement (pour PDF) ou l'affichage (pour image) fonctionne.
