# 🌾 AgroConnect BF — Référence Projet Complète
**CS27 Groupe 14 — Information Systems Design — Dr. Moïse**
**Version finale — Mars 2026**

---

## 1. Description du Projet

AgroConnect BF est une plateforme digitale B2B/B2C connectant **agriculteurs**, **acheteurs** et **transporteurs** au Burkina Faso. Elle résout trois problèmes majeurs :

- Les agriculteurs n'ont pas de visibilité pour vendre leurs produits à distance
- Les acheteurs peinent à trouver des fournisseurs fiables avec des prix transparents
- Il n'existe pas de système structuré pour organiser les livraisons agricoles

---

## 2. Stack Technique Finale

| Composant | Technologie | Hébergement |
|---|---|---|
| **Backend API** | Node.js + Express + Mongoose | Railway |
| **Frontend Web** | ReactJS + Vite + Tailwind CSS | Vercel |
| **Mobile** | Flutter | APK / Play Store |
| **Base de données** | MongoDB Atlas | Cloud Atlas M0 (gratuit) |
| **Authentification** | JWT + OTP Email (Resend.com) | Intégré |
| **Paiement** | CinetPay simulé V1 (escrow) | CinetPay |
| **Cartographie** | OpenStreetMap + OSRM + react-leaflet / flutter_map | Gratuit |
| **Docs API** | Swagger UI (express) | Railway |
| **Agent de code** | Antigravity | — |

---

## 3. Modèle de Rôles

### Rôles principaux

| Rôle | canSell | canBuy | Description |
|---|---|---|---|
| `FARMER` 🌾 | `true` | `true` | Publie et vend ses produits agricoles |
| `BUYER` 🛒 | `false` (activable) | `true` | Passe des commandes en volume |
| `TRANSPORTER` 🚛 | `false` | `true` | Prend des missions de livraison |
| `ADMIN` 🔑 | `false` | `false` | Supervise la plateforme |

### JWT Payload
```json
{
  "sub": "userId",
  "email": "user@email.com",
  "role": "FARMER",
  "canSell": true,
  "canBuy": true,
  "isVerified": true,
  "iat": 1710000000,
  "exp": 1710604800
}
```

---

## 4. Architecture Backend (Node.js + Express)

### Structure des dossiers
```
backend/
├── src/
│   ├── config/
│   │   ├── database.js          # Connexion MongoDB Atlas
│   │   └── swagger.js           # Config Swagger
│   ├── middleware/
│   │   ├── auth.middleware.js    # verifyToken (JWT)
│   │   ├── roles.middleware.js   # requireRole(...roles)
│   │   ├── canSell.middleware.js # requireCanSell
│   │   └── isVerified.middleware.js # requireVerified
│   ├── models/
│   │   ├── User.model.js
│   │   ├── Product.model.js
│   │   ├── Order.model.js
│   │   ├── DeliveryOffer.model.js
│   │   ├── Payment.model.js
│   │   ├── Conversation.model.js
│   │   ├── Message.model.js
│   │   └── Dispute.model.js
│   ├── routes/
│   │   ├── auth.routes.js
│   │   ├── products.routes.js
│   │   ├── orders.routes.js
│   │   ├── deliveries.routes.js
│   │   ├── payments.routes.js
│   │   ├── messaging.routes.js
│   │   ├── disputes.routes.js
│   │   └── admin.routes.js
│   ├── controllers/
│   │   └── [un par route]
│   ├── services/
│   │   └── email.service.js     # Resend OTP
│   ├── seed/
│   │   └── admin.seed.js
│   └── app.js                   # Express app + routes
├── server.js                    # Entry point
├── .env
└── package.json
```

### Middlewares RBAC
```javascript
// middleware/auth.middleware.js
const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'Token manquant' });
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ message: 'Token invalide' });
  }
};

// middleware/roles.middleware.js
const requireRole = (...roles) => (req, res, next) => {
  if (!roles.includes(req.user?.role))
    return res.status(403).json({ message: 'Accès refusé' });
  next();
};

// middleware/canSell.middleware.js
const requireCanSell = (req, res, next) => {
  if (!req.user?.canSell)
    return res.status(403).json({ message: 'Vous ne pouvez pas vendre' });
  next();
};

// middleware/isVerified.middleware.js
const requireVerified = (req, res, next) => {
  if (!req.user?.isVerified)
    return res.status(403).json({ message: 'Email non vérifié' });
  next();
};
```

---

## 5. Collections MongoDB

### User
```javascript
{
  email: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true },
  firstName: { type: String, required: true },
  lastName:  { type: String, required: true },
  phone:     { type: String },
  role:      { type: String, enum: ['FARMER','BUYER','TRANSPORTER','ADMIN'], required: true },
  canSell:   { type: Boolean, default: false },
  canBuy:    { type: Boolean, default: true  },
  isVerified:   { type: Boolean, default: false },
  otpCode:      { type: String },   // haché bcrypt
  otpExpires:   { type: Date },
  otpAttempts:  { type: Number, default: 0 },   // max 3
  resetPasswordToken:   { type: String },
  resetPasswordExpires: { type: Date },
  walletBalance: { type: Number, default: 0 },
  walletPending: { type: Number, default: 0 },
  totalEarned:   { type: Number, default: 0 },
  isActive:      { type: Boolean, default: true },
  profilePicture: { type: String },
  city:           { type: String },
  address:        { type: String },
  vehicleType:    { type: String },   // TRANSPORTER uniquement
  specialty:      { type: String },   // FARMER uniquement
  ratings: [{ from: ObjectId, score: Number, comment: String, createdAt: Date }],
  averageRating:  { type: Number, default: 0 },
  totalRatings:   { type: Number, default: 0 },
  timestamps: true
}
```

### Product
```javascript
{
  seller:      { type: ObjectId, ref: 'User', required: true },
  name:        { type: String, required: true },
  description: { type: String, required: true },
  price:       { type: Number, required: true },
  unit:        { type: String, required: true },  // kg, sac, tonne, litre, unité
  quantity:    { type: Number, required: true },
  category:    { type: String, enum: ['Céréales','Légumes','Fruits','Élevage','Semences','Autres'] },
  images:      [{ type: String }],
  city:        { type: String, required: true },
  address:     { type: String },
  lat:         { type: Number },
  lng:         { type: Number },
  available:   { type: Boolean, default: true },
  timestamps: true
}
```

### Order
```javascript
{
  buyer:   { type: ObjectId, ref: 'User', required: true },
  seller:  { type: ObjectId, ref: 'User', required: true },
  product: { type: ObjectId, ref: 'Product', required: true },
  quantity:  { type: Number, required: true },
  unitPrice: { type: Number, required: true },   // prix négocié ou catalogue
  totalPrice:{ type: Number, required: true },
  status: {
    type: String,
    enum: ['PENDING','CONFIRMED','IN_TRANSIT','DELIVERED','CANCELLED','DISPUTED'],
    default: 'PENDING'
  },
  // Renseigné par le Farmer à la confirmation
  pickupAddress: { type: String },
  pickupCity:    { type: String },
  pickupLat:     { type: Number },
  pickupLng:     { type: Number },
  availableFrom: { type: Date },
  transporterInstructions: { type: String },
  // Renseigné par le Buyer à la commande
  deliveryAddress: { type: String, required: true },
  deliveryCity:    { type: String, required: true },
  deliveryLat:     { type: Number },
  deliveryLng:     { type: Number },
  deliveryBudget:  { type: Number },  // budget indicatif livraison
  // Assigné après sélection du transporteur
  transporter:        { type: ObjectId, ref: 'User' },
  transporterAssigned:{ type: Boolean, default: false },
  deliveryFee:        { type: Number },
  transporterLat:     { type: Number },
  transporterLng:     { type: Number },
  transporterPositionUpdatedAt: { type: Date },
  // Note et motif de refus
  buyerNote:    { type: String },
  refusalReason:{ type: String },
  timestamps: true
}
```

### DeliveryOffer
```javascript
{
  order:       { type: ObjectId, ref: 'Order', required: true },
  transporter: { type: ObjectId, ref: 'User',  required: true },
  proposedFee: { type: Number, required: true },
  message:     { type: String },
  status:      { type: String, enum: ['PENDING','ACCEPTED','REJECTED'], default: 'PENDING' },
  timestamps: true
}
```

### Payment
```javascript
{
  order:          { type: ObjectId, ref: 'Order', required: true },
  buyer:          { type: ObjectId, ref: 'User',  required: true },
  productAmount:  { type: Number, required: true },
  commissionRate: { type: Number, default: 0.03 },
  commissionAmount:{ type: Number, required: true },
  deliveryAmount: { type: Number, required: true },
  totalAmount:    { type: Number, required: true },
  splits: [{
    recipient: String,   // 'farmer', 'transporter', 'platform'
    recipientId: ObjectId,
    amount: Number,
    type: String,        // 'product', 'delivery', 'commission'
    released: Boolean
  }],
  status: {
    type: String,
    enum: ['PENDING','HELD','FULLY_RELEASED','REFUNDED','FAILED'],
    default: 'PENDING'
  },
  paymentMethod:          { type: String },
  cinetpayTransactionId:  { type: String },
  timestamps: true
}
```

### Conversation
```javascript
{
  participants: [{ type: ObjectId, ref: 'User' }],
  product:     { type: ObjectId, ref: 'Product' },
  order:       { type: ObjectId, ref: 'Order' },
  lastMessage: { type: ObjectId, ref: 'Message' },
  timestamps: true
}
```

### Message
```javascript
{
  conversation: { type: ObjectId, ref: 'Conversation', required: true },
  sender:       { type: ObjectId, ref: 'User', required: true },
  content:      { type: String, required: true },
  type: {
    type: String,
    enum: ['text','price_offer','price_accepted','price_rejected'],
    default: 'text'
  },
  offerAmount: { type: Number },
  read:        { type: Boolean, default: false },
  timestamps: true
}
```

### Dispute
```javascript
{
  order:        { type: ObjectId, ref: 'Order', required: true },
  claimant:     { type: ObjectId, ref: 'User',  required: true },
  defendant:    { type: ObjectId, ref: 'User',  required: true },
  reason: {
    type: String,
    enum: ['NON_DELIVERED','DAMAGED','WRONG_QUANTITY','WRONG_PRODUCT','PAYMENT_ISSUE','OTHER']
  },
  description:  { type: String, required: true },
  photos:       [{ type: String }],
  status:       { type: String, enum: ['OPEN','IN_REVIEW','RESOLVED'], default: 'OPEN' },
  resolution:   { type: String },
  resolvedBy:   { type: ObjectId, ref: 'User' },
  resolvedAt:   { type: Date },
  decision: {
    type: String,
    enum: ['REFUND_BUYER','VALIDATE_DELIVERY','PARTIAL','NO_ACTION']
  },
  timestamps: true
}
```

---

## 6. Routes API Complètes

### Auth — `/api/auth`
| Méthode | Route | Auth | Description |
|---|---|---|---|
| POST | `/register` | Public | Inscription + envoi OTP |
| POST | `/verify-otp` | JWT | Vérifier le code OTP |
| POST | `/resend-otp` | JWT | Renvoyer un OTP |
| POST | `/login` | Public | Connexion → JWT |
| POST | `/forgot-password` | Public | Demander réinitialisation |
| POST | `/reset-password` | Public | Réinitialiser avec OTP |
| PATCH | `/capabilities` | JWT | Modifier canSell / canBuy |
| GET | `/me` | JWT | Profil de l'utilisateur connecté |

### Products — `/api/products`
| Méthode | Route | Auth | Description |
|---|---|---|---|
| GET | `/` | Public | Catalogue (filtres: ville, catégorie, prix, dispo) |
| GET | `/:id` | Public | Détail d'un produit |
| POST | `/` | JWT + canSell + isVerified | Publier un produit |
| PUT | `/:id` | JWT + Owner | Modifier un produit |
| DELETE | `/:id` | JWT + Owner | Supprimer un produit |
| GET | `/my/products` | JWT + canSell | Mes produits |
| PATCH | `/:id/toggle` | JWT + Owner | Activer / désactiver |

### Orders — `/api/orders`
| Méthode | Route | Auth | Description |
|---|---|---|---|
| POST | `/` | JWT + canBuy + isVerified | Passer une commande |
| GET | `/my/buyer` | JWT + canBuy | Mes commandes (acheteur) |
| GET | `/my/seller` | JWT + canSell | Mes commandes (vendeur) |
| GET | `/:id` | JWT + Owner | Détail commande |
| PATCH | `/:id/confirm` | JWT + FARMER + Owner | Confirmer + adresse collecte |
| PATCH | `/:id/cancel` | JWT + Owner | Annuler |
| PATCH | `/:id/transporter-position` | JWT + TRANSPORTER | Mettre à jour GPS |

### Deliveries — `/api/deliveries`
| Méthode | Route | Auth | Description |
|---|---|---|---|
| GET | `/available` | JWT + TRANSPORTER | Missions disponibles |
| POST | `/:orderId/offer` | JWT + TRANSPORTER | Soumettre une offre |
| DELETE | `/offers/:offerId` | JWT + TRANSPORTER Owner | Retirer son offre |
| GET | `/offers/mine` | JWT + TRANSPORTER | Mes offres |
| GET | `/mine` | JWT + TRANSPORTER | Mes livraisons |
| PATCH | `/:orderId/status` | JWT + TRANSPORTER assigné | IN_TRANSIT ou DELIVERED |
| GET | `/orders/:orderId/offers` | JWT + BUYER Owner | Offres reçues sur ma commande |
| POST | `/offers/:offerId/accept` | JWT + BUYER Owner | Choisir un transporteur |
| POST | `/offers/:offerId/reject` | JWT + BUYER Owner | Refuser une offre |

### Payments — `/api/payments`
| Méthode | Route | Auth | Description |
|---|---|---|---|
| POST | `/initiate/:orderId` | JWT + BUYER | Initier le paiement |
| POST | `/confirm/:paymentId` | JWT + BUYER | Confirmer (simulation) |
| GET | `/order/:orderId` | JWT + Owner | Détail paiement |
| GET | `/wallet` | JWT | Mon portefeuille |
| POST | `/withdraw` | JWT | Demander un retrait |
| GET | `/history` | JWT | Historique transactions |

### Messaging — `/api/conversations`
| Méthode | Route | Auth | Description |
|---|---|---|---|
| GET | `/` | JWT | Mes conversations |
| POST | `/` | JWT + isVerified | Créer/ouvrir une conversation |
| GET | `/:id/messages` | JWT + Participant | Messages d'une conversation |
| POST | `/:id/messages` | JWT + Participant | Envoyer un message |
| POST | `/:id/price-offer` | JWT + Participant | Envoyer une offre de prix |
| PATCH | `/messages/:msgId/respond` | JWT + Participant | Accepter/refuser offre de prix |
| PATCH | `/:id/read` | JWT + Participant | Marquer comme lu |

### Disputes — `/api/disputes`
| Méthode | Route | Auth | Description |
|---|---|---|---|
| POST | `/` | JWT + isVerified | Ouvrir un litige |
| GET | `/mine` | JWT | Mes litiges |
| GET | `/:id` | JWT + Owner | Détail litige |

### Admin — `/api/admin`
| Méthode | Route | Auth | Description |
|---|---|---|---|
| GET | `/stats` | JWT + ADMIN | KPIs globaux |
| GET | `/users` | JWT + ADMIN | Liste utilisateurs (paginé) |
| GET | `/users/:id` | JWT + ADMIN | Détail utilisateur |
| PATCH | `/users/:id/suspend` | JWT + ADMIN | Suspendre un compte |
| PATCH | `/users/:id/activate` | JWT + ADMIN | Réactiver un compte |
| GET | `/products` | JWT + ADMIN | Tous les produits |
| PATCH | `/products/:id/hide` | JWT + ADMIN | Masquer un produit |
| GET | `/orders` | JWT + ADMIN | Toutes les commandes |
| GET | `/disputes` | JWT + ADMIN | Tous les litiges |
| POST | `/disputes/:id/resolve` | JWT + ADMIN | Résoudre un litige |
| GET | `/payments` | JWT + ADMIN | Tous les paiements |
| POST | `/payments/:id/release` | JWT + ADMIN | Libération manuelle |
| PATCH | `/payments/withdrawals/:id/validate` | JWT + ADMIN | Valider retrait |

---

## 7. Flux Métier Complets

### 7.1 Flux Commande Complet
```
[BUYER]       POST /orders                    → statut PENDING
[FARMER]      PATCH /orders/:id/confirm       → statut CONFIRMED + adresse collecte
[SYSTEM]      Mission visible dans /deliveries/available
[TRANSPORTER] POST /deliveries/:id/offer      → offre soumise
[BUYER]       POST /deliveries/offers/:id/accept → transporteur assigné
[BUYER]       POST /payments/initiate/:orderId → paiement HELD (escrow)
[TRANSPORTER] PATCH /deliveries/:id/status IN_TRANSIT → statut IN_TRANSIT
[TRANSPORTER] PATCH /deliveries/:id/status DELIVERED  → statut DELIVERED
[SYSTEM]      Libération automatique des fonds → wallets crédités
```

### 7.2 Calcul Split Paiement
```
Produits              250 000 FCFA
Commission 3%         -  7 500 FCFA  → Plateforme
Net Farmer            242 500 FCFA
Livraison              12 500 FCFA   → Transporteur (0% commission)
─────────────────────────────────────
Total payé Acheteur   262 500 FCFA
```

### 7.3 Négociation de prix (Messagerie)
```
[BUYER] envoie message type: 'price_offer', offerAmount: 4500
[FARMER] répond accept → type: 'price_accepted'
         → order.unitPrice mis à jour automatiquement
[FARMER] répond refuse → type: 'price_rejected'
         → prix inchangé
```

### 7.4 Flux Litige
```
[BUYER/FARMER] POST /disputes        → statut OPEN, fonds gelés
[ADMIN]        Examine preuves       → statut IN_REVIEW
[ADMIN]        POST /admin/disputes/:id/resolve
               decision: 'REFUND_BUYER'     → acheteur remboursé
               decision: 'VALIDATE_DELIVERY' → vendeur + transporteur payés
               decision: 'PARTIAL'           → partage
               decision: 'NO_ACTION'         → litige infondé
```

---

## 8. Variables d'Environnement

### Backend `.env`
```env
# MongoDB Atlas
MONGODB_URI=mongodb+srv://agroconnect:<password>@cluster.xxxxx.mongodb.net/agroconnect?retryWrites=true&w=majority

# JWT
JWT_SECRET=votre_secret_jwt_tres_long_et_complexe
JWT_EXPIRATION=7d

# Email OTP — Resend.com (gratuit 3 000 emails/mois)
RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxxxx
FROM_EMAIL=noreply@agroconnect.bf

# Paiement CinetPay (simulé en V1)
COMMISSION_RATE=0.03
CINETPAY_API_KEY=
CINETPAY_SITE_ID=
CINETPAY_NOTIFY_URL=https://votre-app.railway.app/api/payments/webhook

# Serveur
PORT=3000
NODE_ENV=production
```

### Frontend Web `.env`
```env
VITE_API_URL=https://votre-app.railway.app
```

### Flutter `lib/core/config.dart`
```dart
const String apiBaseUrl = 'https://votre-app.railway.app/api';
// Pas de clé cartographique — OpenStreetMap + flutter_map sont gratuits
```

---

## 9. Cartographie — Stack Gratuite

| Composant | Solution | Coût |
|---|---|---|
| Tuiles carte | OpenStreetMap | Gratuit |
| Calcul d'itinéraire | OSRM (`router.project-osrm.org`) | Gratuit |
| Géocodage adresses | Nominatim | Gratuit |
| Flutter | `flutter_map` + `latlong2` | Gratuit |
| ReactJS | `react-leaflet` + `leaflet` | Gratuit |

**Aucune clé API. Aucun compte à créer.**

---

## 10. Design — 56 Vues Stitch

| Phase | Rôle | Nb vues | Contenu clé |
|---|---|---|---|
| 1 — Visiteur | Non connecté | 6 | Accueil, Catalogue, Détail produit |
| 2 — Auth | Tous | 7 | Register, OTP, Login, Reset password |
| 3 — Transporteur | TRANSPORTER | 11 | Marché missions, Offres, Carte, Wallet |
| 4 — Farmer | FARMER | 10 | Catalogue perso, Commandes, Confirmer |
| 5 — Acheteur | BUYER | 12 | Catalogue, Commander, Choisir transport, Payer |
| 6 — Admin | ADMIN | 10 | Dashboard, Litiges, Paiements, Stats |
| **Total** | — | **56** | — |

**Charte graphique :** Vert `#16a34a`, fond `#f9fafb`, cartes blanches `border-radius: 12px`

**Note Web :** Les designs mobiles Stitch servent de référence de contenu pour le web ReactJS. Adaptations : navbar bas → sidebar gauche, bottom sheets → modals, layout 1 col → 2-3 colonnes.

---

## 11. Planning 6 Jours

| Jour | Objectif | Livrable |
|---|---|---|
| **Jour 1** | Setup + Auth complet | Repos GitHub, Auth OTP fonctionnel, JWT, RBAC, Seeder Admin |
| **Jour 2** | Products + Orders + Deliveries | API testée sur Postman |
| **Jour 3** | Messaging + Disputes + Payments + Admin | Tous les modules backend |
| **Jour 4** | Frontend Web + Mobile (pages principales) | Intégration Auth + Catalogue |
| **Jour 5** | Intégration API complète + tests | Flux end-to-end validés |
| **Jour 6** | Déploiement + Docs + Démo | Railway + Vercel en ligne, README, slides |

---

## 12. Répartition des Membres

| Membre | Rôle | Modules |
|---|---|---|
| **Membre 1** (Lead Dev) | Architecte + Lead | Setup, DeliveriesModule, PaymentsModule, AdminModule, déploiement, revue de code |
| **Membre 2** | Backend Dev | AuthModule (OTP), ProductsModule, OrdersModule, MessagingModule, DisputesModule |
| **Membre 3** | Frontend Web | ReactJS complet — toutes les vues, intégration API, déploiement Vercel |
| **Membre 4** | Mobile Dev | Flutter complet — toutes les vues, intégration API, APK release |
| **Membre 5** | DevOps / Docs | Swagger, Postman, GitHub Issues, MongoDB Atlas, README, slides démo |
