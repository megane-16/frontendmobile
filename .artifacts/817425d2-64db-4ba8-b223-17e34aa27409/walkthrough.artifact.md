# Walkthrough - Implémentation du Quiz DriveFlow

La fonctionnalité de Quiz est maintenant opérationnelle et intégrée à l'application.

## Changements effectués

### 1. Modèles et Services
- Création de `quiz_model.dart` pour définir les questions et les résultats.
- Création de `quiz_repository.dart` avec un jeu de 4 questions de test sur le code de la route.

### 2. Interfaces Utilisateur
- **TheoryView** : Nouvel onglet "Théorie" (3ème icône de la barre de navigation) qui sert de centre d'entraînement.
- **QuizView** : Écran de quiz interactif avec :
    - Gestion du score en temps réel.
    - Feedback visuel immédiat (Vert pour juste, Rouge pour faux).
    - Affichage d'explications après chaque réponse.
    - Résumé final avec option de recommencer ou de quitter.

### 3. Navigation
- Mise à jour de `bottom_navigation_bar.dart` pour inclure `TheoryView` et éviter les crashs sur les onglets vides.

## Comment tester

1.  Lancez l'application (ou effectuez un **Hot Restart**).
2.  Cliquez sur l'icône **"Théorie"** (le livre ouvert) dans la barre en bas.
3.  Appuyez sur **"Quiz Rapide"**.
4.  Répondez aux questions et observez les explications !
