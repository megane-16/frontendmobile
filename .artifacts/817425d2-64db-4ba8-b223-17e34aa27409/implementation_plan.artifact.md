# Refonte visuelle et interactive de la page des Cours

Ce plan vise à transformer la page `Cour` en une interface moderne, interactive et cohérente avec le design system "DriveFlow" (basé sur le style de l'inscription).

## User Review Required

> [!TIP]
> Nous allons utiliser des composants Material 3 et des animations intégrées pour rendre l'interface plus vivante sans ajouter de dépendances lourdes.

## Proposed Changes

### [Views]

#### [MODIFY] [cour.dart](file:///home/ngo-ndjeng-cresse/AndroidStudioProjects/driveflow1/lib/views/cour.dart)
- **Nouvel En-tête** : Utilisation d'un `SliverAppBar` flexible qui se réduit au scroll avec un dégradé `Indigo` vers `Pink`.
- **Indicateur de Progression** : Passage d'une barre horizontale à un design plus moderne intégré dans le header.
- **Filtrage par Onglets** : Ajout d'un `TabBar` pour basculer entre "Mes prochains cours" et "Historique".
- **Cartes Modernes** : Refonte des `LessonCard` avec des ombres douces, des icônes contextuelles et des micro-interactions.
- **Animations** : Ajout de `AnimatedOpacity` et `TweenAnimationBuilder` pour l'entrée des données.

## Verification Plan

### Manual Verification
- Vérifier que le dégradé s'affiche correctement dans le header.
- Tester le basculement entre les onglets "À venir" et "Effectuées".
- Vérifier la fluidité du défilement avec le `SliverAppBar`.
- Confirmer que le bouton flottant (FAB) est bien visible et stylisé.
