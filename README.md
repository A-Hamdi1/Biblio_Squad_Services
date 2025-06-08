# Biblio Squad Services

## 📚 Aperçu

Biblio Squad Services est une application mobile Flutter complète conçue pour la gestion de bibliothèque moderne. Elle intègre plusieurs services avancés basés sur l'intelligence artificielle et le machine learning pour faciliter la gestion des livres, des documents et des utilisateurs.

## 🌟 Fonctionnalités

L'application offre plusieurs modules de services intégrés :

### 📷 Reconnaissance de Texte (OCR)
- Numérisation et extraction de texte à partir d'images
- Traitement et sauvegarde des documents numérisés
- Exportation des textes extraits

### 🌐 Service de Traduction
- Traduction de textes entre différentes langues
- Intégration avec la reconnaissance de texte pour traduire des documents numérisés

### 📊 Scanner de Code-barres
- Scan des codes-barres de livres
- Récupération automatique des informations de livres depuis la base de données
- Affichage des détails des livres (titre, auteur, année de publication, catégorie, prix)

### 📑 Scanner de Documents
- Numérisation et organisation de documents
- Catégorisation des documents numérisés
- Gestion des documents par catégories

### 💬 FAQ Chat (Smart Reply)
- Assistant conversationnel intelligent
- Réponses automatiques aux questions fréquentes
- Reconnaissance vocale intégrée

### 👥 Gestion des Utilisateurs
- Système d'authentification complet (inscription, connexion)
- Gestion des rôles et permissions (utilisateur, auteur, administrateur)
- Interface d'administration pour la gestion des utilisateurs

## 🔐 Système de Rôles et Permissions

L'application implémente un système de contrôle d'accès basé sur les rôles :

- **Utilisateur** : Accès aux services de base (OCR, traduction, code-barres, chat)
- **Auteur** : Accès aux services de base + scanner de documents
- **Administrateur** : Accès complet à toutes les fonctionnalités, y compris la gestion des utilisateurs

## 🛠️ Technologies Utilisées

- **Framework** : Flutter (SDK ^3.6.0)
- **Base de données** : Firebase Firestore
- **Authentification** : Firebase Auth
- **ML Kit** : Google ML Kit pour OCR, traduction, et analyse de code-barres
- **Architecture** : Architecture modulaire avec Provider pour la gestion d'état

## 🏗️ Architecture

L'application est construite avec une architecture modulaire où chaque fonctionnalité principale est encapsulée dans son propre module. Cette approche offre plusieurs avantages :

- ✅**Maintenance simplifiée** : Chaque module peut être développé et testé indépendamment
- ♻️**Réutilisabilité** : Les modules peuvent être réutilisés dans d'autres projets
- 📈**Évolutivité** : De nouveaux modules peuvent être ajoutés facilement
- 🧩**Séparation des préoccupations** : Chaque module a une responsabilité claire

### 📂Structure des modules

Chaque module suit une structure similaire :

```
module_name/
  ├── lib/
  │   ├── module_name.dart (point d'entrée principal)
  │   ├── core/ (logique métier)
  │   │   ├── constants/
  │   │   ├── providers/
  │   │   └── services/
  │   ├── models/ (modèles de données)
  │   ├── ui/ (interface utilisateur)
  │   │   ├── screens/
  │   │   ├── widgets/
  │   │   └── components/
  │   └── utils/ (utilitaires)
  └── pubspec.yaml (dépendances du module)
```

## 🔄Gestion des états

L'application utilise le package `provider` pour la gestion des états. Chaque module expose ses propres providers qui sont ensuite regroupés dans l'application principale via `global_providers.dart`.

## 🛡️Contrôle d'accès

Le système de contrôle d'accès est basé sur les rôles des utilisateurs. Chaque fonctionnalité vérifie si l'utilisateur a les droits nécessaires avant de permettre l'accès. Cette vérification est effectuée via des méthodes comme `canAccessOcrService()`, `canAccessTranslationService()`, etc.


## 📂 Structure du Projet

Le projet est organisé en modules indépendants pour faciliter la maintenance et l'évolutivité :

```
Biblio_Squad_Services/
├── lib/
│   ├── features/        # Fonctionnalités principales de l'application
│   ├── pages/           # Pages de l'interface utilisateur
│   ├── visions/         # Définition des fonctionnalités visuelles
│   └── main.dart        # Point d'entrée de l'application
├── modules/             # Modules de services
│   ├── auth_service/    # Service d'authentification
│   ├── barcode_service/ # Service de scan de code-barres
│   ├── document_scan_service/ # Service de numérisation de documents
│   ├── gestion_users_service/ # Service de gestion des utilisateurs
│   ├── ocr_service/     # Service de reconnaissance de texte
│   ├── smart_reply_service/ # Service de chat intelligent
│   └── translation_service/ # Service de traduction
└── assets/              # Ressources (images, polices)
```

## ⚙️ Prérequis

- Flutter SDK ^3.6.0
- Dart SDK
- JDK 17 (pour Android)
- Firebase project configuré
- Compte Google Cloud Platform avec APIs activées pour ML Kit

## 🚀 Installation

1. Clonez le dépôt :
```bash
git clone https://github.com/A-Hamdi1/Biblio_Squad_Services.git
```

2. Naviguez vers le répertoire du projet :
```bash
cd Biblio_Squad_Services
```

3. Installez les dépendances :
```bash
flutter pub get
```

4. Configurez Firebase :
   - Créez un projet Firebase
   - Ajoutez une application Android/iOS
   - Téléchargez le fichier de configuration (google-services.json / GoogleService-Info.plist)
   - Placez-le dans le dossier approprié

5. Lancez l'application :
```bash
flutter run
```

## 📱 Captures d'écran

*Des captures d'écran de l'application*


## 👥 Contribution

Les contributions sont les bienvenues ! Voici comment contribuer :

1. 🍴 Forkez le projet
2. 🌿 Créez votre branche de fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. 💾 Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. 📤 Poussez vers la branche (`git push origin feature/AmazingFeature`)
5. 🔃 Ouvrez une Pull Request

## 📜 Licence

Distribué sous la licence MIT. Voir `LICENSE` pour plus d'informations.

## 📞 Contact

- Akram Hamdi
- Email : hamdi.akram.dev@gmail.com


---

⭐️ N'hésitez pas à donner une étoile à ce projet si vous l'avez trouvé utile ! ⭐️