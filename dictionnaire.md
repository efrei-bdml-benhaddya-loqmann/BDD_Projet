# Dictionnaire de données
## Projet BDD ALSI61 — Outil de gestion de planning d'entreprise

---

## Table : `Service`

| Attribut | Type | Contraintes | Description |
|---|---|---|---|
| `id_service` | INT | PK, AUTO_INCREMENT, NOT NULL | Identifiant unique du service |
| `code_service` | VARCHAR(3) | UNIQUE, NOT NULL, CHECK `S##` | Code court du service (ex: S01, S02) |
| `libelle` | VARCHAR(100) | NOT NULL | Nom complet du service (ex: Informatique, RH) |

---

## Table : `Employe`

| Attribut | Type | Contraintes | Description |
|---|---|---|---|
| `id_employe` | INT | PK, AUTO_INCREMENT, NOT NULL | Identifiant unique de l'employé |
| `nom` | VARCHAR(100) | NOT NULL | Nom de famille de l'employé |
| `prenom` | VARCHAR(100) | NOT NULL | Prénom de l'employé |
| `email` | VARCHAR(150) | UNIQUE, NOT NULL | Adresse e-mail professionnelle (identifiant de connexion) |
| `date_embauche` | DATE | NOT NULL | Date d'entrée dans l'entreprise |
| `id_service` | INT | FK → Service, NOT NULL | Service auquel appartient l'employé |
| `id_manager` | INT | FK → Employe (auto-ref), NULL | Manager direct. NULL = sommet de la hiérarchie (DG) |

---

## Table : `StatutJour`

| Attribut | Type | Contraintes | Description |
|---|---|---|---|
| `id_statut` | INT | PK, AUTO_INCREMENT, NOT NULL | Identifiant unique du statut |
| `libelle` | VARCHAR(50) | NOT NULL | Libellé long (ex: Congé Payé, Télétravail) |
| `code` | CHAR(3) | UNIQUE, NOT NULL, CHECK | Code court : CP, RTT, TT, BUR, MAL, FOR |
| `decompte_solde` | BOOLEAN | NOT NULL, DEFAULT FALSE | TRUE si ce statut décompte du solde (CP=TRUE, RTT=TRUE, autres=FALSE) |

**Valeurs de référence :**

| code | libelle | decompte_solde |
|---|---|---|
| CP | Congé Payé | TRUE |
| RTT | Réduction Temps de Travail | TRUE |
| TT | Télétravail | FALSE |
| BUR | Présence Bureau | FALSE |
| MAL | Maladie | FALSE |
| FOR | Formation | FALSE |

---

## Table : `EntreePlanning`

> **Association ternaire matérialisée** : Employé × Jour × StatutJour  
> L'attribut `demi_journee` porte la sémantique de la ternaire.

| Attribut | Type | Contraintes | Description |
|---|---|---|---|
| `id_entree` | INT | PK, AUTO_INCREMENT, NOT NULL | Identifiant unique de l'entrée |
| `date` | DATE | NOT NULL | Date concernée par l'entrée planning |
| `demi_journee` | ENUM | NOT NULL | Granularité temporelle : `matin`, `apres-midi`, `journee` |
| `id_employe` | INT | FK → Employe, NOT NULL | Employé concerné |
| `id_statut` | INT | FK → StatutJour, NOT NULL | Statut du jour (CP, TT, BUR…) |

**Contraintes supplémentaires :**
- `UNIQUE(id_employe, date, demi_journee)` — une seule entrée par triplet employé/date/demi-journée
- `TRIGGER trg_entree_no_overlap_insert` — interdit la coexistence de `journee` et `matin`/`apres-midi` le même jour pour le même employé
- `TRIGGER trg_entree_no_overlap_update` — même vérification lors d'une modification

---

## Table : `DemandeConge`

> Archive de la demande de congé. Séparée d'`EntreePlanning` (qui est la vérité terrain).  
> Quand `statut_demande` passe à `validee`, l'application génère les `EntreePlanning` correspondantes.

| Attribut | Type | Contraintes | Description |
|---|---|---|---|
| `id_demande` | INT | PK, AUTO_INCREMENT, NOT NULL | Identifiant unique de la demande |
| `date_debut` | DATE | NOT NULL | Premier jour de la période demandée |
| `date_fin` | DATE | NOT NULL, CHECK ≥ date_debut | Dernier jour de la période demandée |
| `demi_journee_debut` | ENUM | NOT NULL, DEFAULT `journee` | Précision sur le premier jour : `matin`, `apres-midi`, `journee` |
| `demi_journee_fin` | ENUM | NOT NULL, DEFAULT `journee` | Précision sur le dernier jour : `matin`, `apres-midi`, `journee` |
| `statut_demande` | ENUM | NOT NULL, DEFAULT `en_attente` | État de la demande : `en_attente`, `validee`, `refusee` |
| `date_soumission` | DATETIME | NOT NULL, DEFAULT NOW() | Horodatage de la soumission par l'employé |
| `motif` | TEXT | NULL | Motif optionnel saisi par l'employé |
| `id_employe` | INT | FK → Employe, NOT NULL | Employé ayant soumis la demande |
| `id_statut` | INT | FK → StatutJour, NOT NULL | Type de congé demandé (CP, RTT, MAL…) |
| `id_manager_valideur` | INT | FK → Employe, NULL | Manager ayant traité la demande. NULL = pas encore traité |

---

## Table : `SoldeConge`

> Table de stock des droits à congé. Mise à jour par l'application lors de la validation d'une demande.

| Attribut | Type | Contraintes | Description |
|---|---|---|---|
| `id_solde` | INT | PK, AUTO_INCREMENT, NOT NULL | Identifiant unique du solde |
| `annee` | YEAR | NOT NULL | Année concernée (ex: 2026) |
| `jours_acquis` | DECIMAL(5,1) | NOT NULL, CHECK ≥ 0, DEFAULT 0 | Total de jours acquis sur l'année |
| `jours_pris` | DECIMAL(5,1) | NOT NULL, CHECK ≥ 0, DEFAULT 0 | Total de jours consommés sur l'année |
| `id_employe` | INT | FK → Employe, NOT NULL | Employé concerné |
| `id_statut` | INT | FK → StatutJour, NOT NULL | Type de congé concerné (CP ou RTT en pratique) |

**Contraintes supplémentaires :**
- `UNIQUE(id_employe, id_statut, annee)` — un seul solde par employé/type/année
- `CHECK(jours_acquis - jours_pris >= 0)` — le solde disponible ne peut pas être négatif

---

## Récapitulatif des triggers

| Nom | Table | Événement | Rôle |
|---|---|---|---|
| `trg_entree_no_overlap_insert` | EntreePlanning | BEFORE INSERT | Bloque si `journee` ↔ `matin`/`apres-midi` coexistent le même jour/employé |
| `trg_entree_no_overlap_update` | EntreePlanning | BEFORE UPDATE | Même vérification lors d'une modification |

---

## Glossaire métier

| Terme | Définition |
|---|---|
| **Entrée Planning** | Fait atomique : un employé, un jour (ou demi-journée), un statut. Représente la réalité terrain. |
| **Demande de Congé** | Requête soumise par un employé sur une plage de dates. Archive RH, indépendante des entrées planning. |
| **Solde** | Nombre de jours restants = `jours_acquis - jours_pris`. Calculé sur l'année civile. |
| **Validation** | Action du manager : passe `statut_demande` à `validee` et déclenche la création des EntreePlanning + mise à jour du solde. |
| **Modification d'un jour** | Modification directe d'une `EntreePlanning` (ex: changer `journee` → `matin` pour insérer une présence l'après-midi). La `DemandeConge` source n'est pas modifiée. |
