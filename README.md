# 🌾 AgroConnect BF — Mobile App (Flutter)

Application mobile destinée spécifiquement aux **Transporteurs** (pour le GPS temps réel) et aux **Agriculteurs** (pour la facilité d'usage sur le terrain).

## Membre de l'équipe Mobile
- **Membre 4** : Mobile Dev (Flutter Lead)
- **Membre 1** : Coordination API Payments

## Stack
- Flutter 3.x
- Provider (State management)
- Dio (API Client)
- Google Maps SDK
- Flutter Secure Storage

## Installation
```bash
flutter pub get
# Configurer les clés API Google Maps dans android/ios
flutter run
```

## Structure `lib/`
- `api/` : Client Dio avec intercepteur JWT
- `providers/` : Gestion de l'état (Auth, Orders, etc.)
- `screens/` : Écrans par rôle (auth, farmer, buyer, transporter)
- `widgets/` : Composants UI réutilisables
- `models/` : Classes Data de désérialisation JSON
- `utils/` : Helpers GPS, formateurs de prix
