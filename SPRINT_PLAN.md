# Sprint Plan — Projet BDD ALSI61 : Outil de gestion de planning d'entreprise

**Dates :** 28/05/2026 (J1, jeudi soir) → 31/05/2026 (dépôt avant minuit)
**Équipe :** 3 personnes (trinôme)
**Capacité brute :** ~22-27 h équipe (2-3 h/soir × 3 soirs × 3 personnes) + élargissement possible sur le week-end + Claude Code en accélérateur
**Sprint Goal :** *Livrer le 31/05 un projet BDD complet (modélisation, SQL, app Python CLI, rapport, vidéo) conforme au cahier des charges ALSI61, testable sur une installation MySQL fraîche, sans bug bloquant.*

---

## 1. Périmètre fonctionnel choisi (cadré pour éviter l'overkill)

**Domaine :** Outil interne de gestion de planning et de présences pour une entreprise.

**Cas d'usage couverts :**
- Un employé consulte son planning et celui de ses collègues.
- Un employé déclare son statut sur un jour ou demi-journée (Présent bureau, Télétravail, RTT, Congé payé, Maladie, Formation).
- Un manager valide/refuse les demandes de congé/RTT.
- Suivi du solde de congés/RTT par employé.

**Couverture des contraintes du sujet :**
- ≥ 5 entités distinctes ✅
- Association ternaire OU porteuse d'attributs ✅ (voir §3)
- 3FN ✅
- Une entité "principale" pour les fonctionnalités CRUD de l'app : **DemandeConge** (l'app est centrée sur la réservation de congés : un employé réserve/modifie/annule ses demandes, le manager valide/refuse).

---

## 2. Capacité

| Personne | Disponibilité | Allocation cible | Notes |
|----------|---------------|------------------|-------|
| Dev 1 (toi) | 3 soirs × 2.5 h = 7.5 h | Pilote technique : MCD/MLD, DDL, app Python | Utilise Claude Code |
| Dev 2 | 3 soirs × 2.5 h = 7.5 h | Données + requêtes SQL + tests | |
| Dev 3 | 3 soirs × 2.5 h = 7.5 h | Rapport, dictionnaire, vidéo, README | |
| **Total** | **~22.5 h** | **~18 h utiles** (80 % capacité) | Buffer 20 % pour debug/imprévu |

> Avec Claude Code, prévoir un gain de 30-40 % sur le code (DDL, DML, app Python).

---

## 3. Modèle conceptuel — proposition de cadrage (à valider J1)

### Entités (6 — au-dessus du minimum 5)
1. **Employe** (id_employe, nom, prenom, email, date_embauche, #id_service, #id_manager)
2. **Service** (id_service, code_service, libelle) — règle : code de la forme `S` + 2 chiffres
3. **StatutJour** (id_statut, libelle, code, decompte_solde BOOLEAN) — référentiel (CP, RTT, TT, BUR, MAL, FOR)
4. **EntreePlanning** (id_entree, date, demi_journee ENUM('matin','apres-midi','journee'), #id_employe, #id_statut) — **association ternaire matérialisée** Employe × Jour × Statut
5. **DemandeConge** (id_demande, date_debut, date_fin, demi_journee_debut, demi_journee_fin, statut_demande, date_soumission, motif, #id_employe, #id_statut, #id_manager_valideur)
6. **SoldeConge** (id_solde, annee, jours_acquis, jours_pris, #id_employe, #id_statut) — porteur d'attributs

### Association porteuse d'attributs (exigence)
`EntreePlanning` porte l'attribut `demi_journee` et joue le rôle d'association ternaire **Employe – Jour – StatutJour** (le "Jour" étant capturé par l'attribut date pour éviter une table Calendrier inutile — option simple, conforme 3FN).

### Règles métier (extrait — à compléter J1)
- Un employé appartient à un et un seul service.
- Un employé a au plus un manager direct, qui est lui-même un employé.
- Une entrée de planning identifie (employé, date, demi-journée) de manière unique → **UNIQUE(id_employe, date, demi_journee)**.
- Une demande de congé doit avoir `date_debut ≤ date_fin` (CHECK).
- Le code service est de la forme `S` + 2 chiffres (CHECK regex ou trigger).
- Le solde de congés ne peut pas être négatif (CHECK `jours_acquis - jours_pris >= 0`).
- Une demande validée génère automatiquement des `EntreePlanning` (logique applicative, pas BD).

---

## 4. Backlog du sprint

| Prio | Item | Estim. | Owner | Dépendances |
|------|------|--------|-------|-------------|
| **P0** | Cadrage domaine + règles métier finalisées | 1 h | Dev 3 | — |
| **P0** | MCD draw.io + validation 3FN | 1.5 h | Dev 1 | Cadrage |
| **P0** | MLD textuel | 0.5 h | Dev 1 | MCD |
| **P0** | Dictionnaire de données | 1 h | Dev 3 | MLD |
| **P0** | `script_creation.sql` — DDL complet | 1.5 h | Dev 1 | MLD |
| **P0** | `script_creation.sql` — DML jeu de données cohérent (≥ 5 employés, 2 services, 6 statuts, 30+ entrées planning, 10+ demandes, soldes) | 1.5 h | Dev 2 | DDL |
| **P0** | `requetes.sql` — Les 15 requêtes R1→R15 avec commentaires | 3 h | Dev 2 | DML |
| **P0** | App Python **Flask** : connexion MySQL + 8 fonctionnalités sur DemandeConge (réserver, lister+filtrer, détail, modifier, annuler, valider, refuser) + grille calendrier équipe | 4 h | Dev 1 | DDL |
| **P0** | Rapport PDF (domaine, règles, dictionnaire, MCD, MLD) | 2 h | Dev 3 | Tout précédent |
| **P0** | README.txt (lancement, domaine, règles, dictionnaire) | 0.5 h | Dev 3 | App OK |
| **P0** | Vidéo Panopto 12 min (les 3 visibles) | 2.5 h | Trio | Tout OK |
| **P0** | Repo GitHub + dépôt vidéo Teams | 0.5 h | Dev 1 | Tout OK |
| P1 | Tests sur install MySQL fraîche (Docker) | 1 h | Dev 2 | App + SQL OK |
| P2 | Vue SQL `v_planning_semaine` (bonus lisibilité requêtes) | 0.5 h | Dev 2 | DDL |

**Charge planifiée :** ~18.5 h utiles | **Capacité :** ~22.5 h → **82 % de charge** (sain, marge de 4 h).

---

## 5. Planning jour par jour

### Jeudi 28/05 — Soir (J1) — *Modélisation + DDL*
- 20:00-20:30 — Kickoff : valider domaine, règles métier, périmètre (les 3).
- 20:30-22:00 — En parallèle :
  - Dev 1 : MCD draw.io → MLD
  - Dev 3 : Rédaction règles métier + début dictionnaire
- 22:00-22:30 — Revue croisée + Dev 1 attaque DDL avec Claude Code.

**Sortie J1 :** MCD.pdf, MLD.txt, script_creation.sql (DDL OK), dictionnaire.md draft.

### Vendredi 29/05 — Soir (J2) — *DML + Requêtes + Squelette app*
- 19:30-20:00 — Standup (15 min) : revue J1 + ajustements.
- 20:00-22:30 — En parallèle :
  - Dev 2 : DML (30 min) puis attaque les 15 requêtes (2 h) en testant au fur et à mesure
  - Dev 1 : Squelette Python (connexion + menu + 2-3 fonctions) avec Claude Code
  - Dev 3 : Finalise dictionnaire + commence rapport

**Sortie J2 :** script_creation.sql complet, requetes.sql avec ≥ 12/15 requêtes, app Python lit/liste.

### Samedi 30/05 — Journée + soir (J3) — *Finalisation + Vidéo*
- Matin (10:00-12:00) — Bouclage : finir 3 dernières requêtes, finir app (CRUD complet + classement + recherche + détail).
- Après-midi (14:00-17:00) — Tests sur Docker MySQL fraîche, debug, rapport PDF final, README.
- Soir (19:00-21:30) — **Vidéo en une seule session** : script (30 min) + tournage (1 h) + montage léger + upload Panopto.

**Sortie J3 :** Tout livrable prêt.

### Dimanche 31/05 — *Buffer + dépôt*
- Buffer pour imprévus.
- Push GitHub final.
- Vérification dépôt vidéo Teams.
- Inscription groupe Excel Teams.

---

## 6. Plan de la vidéo (12 min max)

| Temps | Section | Qui parle |
|-------|---------|-----------|
| 0:00-0:30 | Intro + visages des 3 membres | Tous |
| 0:30-4:00 | **Conception (3-4 min)** — choix entités, asso ternaire, cardinalités, 3FN | Dev 1 |
| 4:00-6:30 | **Modèle physique (2-3 min)** — contenu tables, violation contrainte, FK ON DELETE | Dev 3 |
| 6:30-11:00 | **Démo (4-5 min)** — 3-4 requêtes sur MySQL Workbench (exécution live, expliquer logique) + démo app Flask (réserver un congé, validation manager qui décompte le solde, grille calendrier) | Dev 2 |
| 11:00-12:00 | Bilan critique + améliorations possibles | Tous |

**Améliorations à citer dans le bilan :** authentification, soft delete + audit log, vues SQL pour reporting, gestion timezone, contraintes temporelles (chevauchement de congés), index sur `(id_employe, date)`.

---

## 7. Risques & mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Dérive sur la modélisation (trop d'entités, "overkill") | Retard cascade sur SQL + app | Lock du périmètre à 6 entités max J1 — pas de "et si on rajoutait…" |
| Une requête R11-R15 bloque | Note Partie II amputée | Si bloqué > 30 min, basculer sur Claude Code direct, ne pas s'acharner seul |
| App Python instable le J3 | Pénalité forte ("application qui ne se lance pas") | Test obligatoire sur install fraîche dès J3 matin, requirements.txt figé |
| Vidéo dépassée à 12 min | Couper en montage | Répéter une fois, viser 10:30 au tournage |
| Un membre absent de la vidéo | **0/20 pour cette personne** (règle stricte) | Caler le créneau vidéo dès J1, confirmer dispo des 3 |
| `script_creation.sql` qui plante sur MySQL fraîche | Forte pénalité | Tester impérativement dans un conteneur Docker MySQL vierge avant push final |

---

## 8. Definition of Done (par item)

- [ ] **MCD** : ≥ 5 entités, 1 ternaire/porteuse, 3FN justifiée par écrit.
- [ ] **MLD** : notation `Table(pk, attr, #fk)` complète et cohérente avec le MCD.
- [ ] **DDL** : `mysql -u root -p < script_creation.sql` passe sans erreur sur MySQL 8 vierge.
- [ ] **DML** : volumes suffisants pour que chaque requête R1-R15 retourne ≥ 1 ligne.
- [ ] **Requêtes** : 15/15, chacune avec commentaire d'approche, R11-R15 utilisent bien sous-requêtes/EXISTS/NOT EXISTS.
- [ ] **App** : les 8 fonctionnalités CRUD sur DemandeConge fonctionnent (réserver, lister+filtrer, détail, modifier, annuler, valider, refuser) depuis le menu web.
- [ ] **Rapport PDF** : domaine + règles + dictionnaire + MCD + MLD.
- [ ] **README.txt** : commande de lancement testée, domaine, règles, dictionnaire.
- [ ] **Repo** : `ALSI-BDD_NOM1_NOM2_NOM3` avec arborescence exacte du sujet.
- [ ] **Vidéo** : ≤ 12 min, 3 visages au début, déposée sur Teams via Panopto.

---

## 9. Stack technique cible

- **SGBD** : MySQL 8.x via **MySQL Workbench** (modélisation visuelle, exécution des 15 requêtes, démo vidéo).
- **Modélisation MCD** : draw.io (export PDF) — Workbench pour le MLD/diagramme physique.
- **App** : Python 3.11+ avec **Flask** (micro-framework web léger) + **Jinja2** templates + **Bootstrap 5 via CDN** (aucun build, design propre out-of-the-box) + `mysql-connector-python` + `python-dotenv`.
- **Pourquoi Flask et pas console ?** L'énoncé impose "menu d'accès aux fonctionnalités" — une interface web remplit cette exigence et fait beaucoup mieux à la vidéo. À assumer dans la démo : *"nous avons choisi une interface web légère plutôt que console, pour mieux visualiser le planning sous forme de calendrier"*.
- **Entité principale CRUD = DemandeConge** : l'app est une appli de **réservation de congés**. Page d'accueil = mes demandes + mes soldes ; l'employé réserve/modifie/annule, le manager valide/refuse (le manager courant est choisi via le sélecteur navbar, sans auth).
- **Visuel signature** : page `/calendrier` = **grille hebdo** (lignes = employés, colonnes = jours, cellules colorées par statut : vert=Bureau, bleu=TT, jaune=RTT, orange=CP, rouge=Maladie). Très impactant en 5 secondes de vidéo.
- **Pas de JavaScript custom** : tout en HTML + Bootstrap pour rester léger.
- **Repo** : GitHub public, accès à `ChiboutBD`.
- **Vidéo** : OBS ou Loom → upload Panopto.

### Structure cible du dossier `src/`
```
src/
├── app.py                  # routes Flask + queries
├── db.py                   # connexion MySQL + helpers query/execute
├── requirements.txt        # flask, mysql-connector-python, python-dotenv
├── .env.example            # template credentials
└── templates/
    ├── base.html           # layout Bootstrap + sélecteur utilisateur (navbar)
    ├── mes_conges.html     # accueil : mes demandes (entité principale) + soldes + filtre + à valider
    ├── conge_form.html     # réserver / modifier une demande
    ├── conge_detail.html   # détail + modifier/annuler + valider/refuser (manager)
    ├── calendrier.html     # grille planning hebdo de l'équipe
    └── stats.html          # statistiques des congés
```

---

## 10. Anti-overkill — ce qu'on ne fait PAS

- Pas d'ORM (SQLAlchemy), `mysql-connector-python` brut suffit.
- Pas de framework JS (React/Vue), juste HTML + Bootstrap CDN.
- Pas de build front-end (pas de npm, pas de webpack).
- Pas de tests unitaires formels, juste tests manuels exhaustifs.
- Pas de CI/CD.
- Pas de gestion d'utilisateurs/auth dans l'app (sélecteur d'employé courant dans la navbar suffit).
- Pas de Calendrier comme table séparée (la date suffit dans EntreePlanning).
- Pas de plus de 6 entités — la richesse vient des associations, pas du nombre.
- Pas de Docker en livrable — juste pour notre test local sur install fraîche.

---

**Prochaine étape :** je peux enchaîner directement sur la **Task #1 (Cadrage + MCD + MLD)** dès que tu valides ce plan — produire le MCD textuel, le MLD, et générer le squelette du repo. Dis-moi si tu veux ajuster le périmètre ou démarrer.
