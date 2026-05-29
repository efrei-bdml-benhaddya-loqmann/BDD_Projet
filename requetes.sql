-- ====================================================
-- requetes.sql
-- Projet BDD ALSI61 — Outil de gestion de planning
-- ====================================================
-- 15 requêtes (R1 → R15).
-- R1-R10  : jointures, agrégats, regroupements, tri.
-- R11-R15 : sous-requêtes (scalaire, dérivée, corrélée) + EXISTS / NOT EXISTS.
-- Chaque requête retourne au moins une ligne sur le jeu de données fourni.
-- ====================================================
USE planning_entreprise;


-- ----------------------------------------------------
-- R1. Liste de tous les employés avec leur service et leur manager.
--     Approche : jointure Employe-Service + auto-jointure pour le manager.
-- ----------------------------------------------------
SELECT  e.id_employe,
        e.nom,
        e.prenom,
        s.libelle                                AS service,
        CONCAT_WS(' ', m.prenom, m.nom)          AS manager
FROM    Employe e
JOIN    Service s ON s.id_service = e.id_service
LEFT JOIN Employe m ON m.id_employe = e.id_manager
ORDER BY e.nom, e.prenom;


-- ----------------------------------------------------
-- R2. Nombre d'employés par service.
--     Approche : regroupement + COUNT.
-- ----------------------------------------------------
SELECT  s.code_service,
        s.libelle,
        COUNT(e.id_employe) AS nb_employes
FROM    Service s
LEFT JOIN Employe e ON e.id_service = s.id_service
GROUP BY s.id_service, s.code_service, s.libelle
ORDER BY nb_employes DESC;


-- ----------------------------------------------------
-- R3. Employés embauchés depuis le 01/01/2020.
--     Approche : filtre sur une date.
-- ----------------------------------------------------
SELECT  nom, prenom, date_embauche
FROM    Employe
WHERE   date_embauche >= '2020-01-01'
ORDER BY date_embauche;


-- ----------------------------------------------------
-- R4. Planning détaillé de l'employé id = 1 (la DG), trié par date.
--     Approche : jointure planning-statut + filtre + tri.
-- ----------------------------------------------------
SELECT  ep.date,
        ep.demi_journee,
        sj.libelle AS statut
FROM    EntreePlanning ep
JOIN    StatutJour sj ON sj.id_statut = ep.id_statut
WHERE   ep.id_employe = 1
ORDER BY ep.date, ep.demi_journee;


-- ----------------------------------------------------
-- R5. Nombre de jours de télétravail par employé.
--     Approche : filtre code='TT' + regroupement + COUNT.
-- ----------------------------------------------------
SELECT  e.nom,
        e.prenom,
        COUNT(ep.id_entree) AS nb_jours_tt
FROM    Employe e
JOIN    EntreePlanning ep ON ep.id_employe = e.id_employe
JOIN    StatutJour sj     ON sj.id_statut  = ep.id_statut
WHERE   sj.code = 'TT'
GROUP BY e.id_employe, e.nom, e.prenom
ORDER BY nb_jours_tt DESC;


-- ----------------------------------------------------
-- R6. Demandes de congé en attente, avec demandeur et type.
--     Approche : jointures + filtre sur le statut de la demande.
-- ----------------------------------------------------
SELECT  dc.id_demande,
        CONCAT_WS(' ', e.prenom, e.nom) AS demandeur,
        sj.libelle                      AS type_conge,
        dc.date_debut,
        dc.date_fin
FROM    DemandeConge dc
JOIN    Employe e     ON e.id_employe = dc.id_employe
JOIN    StatutJour sj ON sj.id_statut = dc.id_statut
WHERE   dc.statut_demande = 'en_attente'
ORDER BY dc.date_debut;


-- ----------------------------------------------------
-- R7. Managers et nombre de collaborateurs directs.
--     Approche : auto-jointure Employe (manager) + regroupement.
-- ----------------------------------------------------
SELECT  m.nom,
        m.prenom,
        COUNT(e.id_employe) AS nb_subordonnes
FROM    Employe m
JOIN    Employe e ON e.id_manager = m.id_employe
GROUP BY m.id_employe, m.nom, m.prenom
ORDER BY nb_subordonnes DESC;


-- ----------------------------------------------------
-- R8. Soldes de congés restants par employé et par type (année 2026).
--     Approche : calcul (acquis - pris) + jointures.
-- ----------------------------------------------------
SELECT  CONCAT_WS(' ', e.prenom, e.nom)      AS employe,
        sj.libelle                           AS type_conge,
        sc.jours_acquis,
        sc.jours_pris,
        (sc.jours_acquis - sc.jours_pris)     AS jours_restants
FROM    SoldeConge sc
JOIN    Employe e     ON e.id_employe = sc.id_employe
JOIN    StatutJour sj ON sj.id_statut = sc.id_statut
WHERE   sc.annee = 2026
ORDER BY employe, type_conge;


-- ----------------------------------------------------
-- R9. Répartition des statuts sur la semaine du 25 au 29/05/2026.
--     Approche : filtre par intervalle de dates + regroupement.
-- ----------------------------------------------------
SELECT  sj.libelle,
        sj.code,
        COUNT(ep.id_entree) AS nb_entrees
FROM    EntreePlanning ep
JOIN    StatutJour sj ON sj.id_statut = ep.id_statut
WHERE   ep.date BETWEEN '2026-05-25' AND '2026-05-29'
GROUP BY sj.id_statut, sj.libelle, sj.code
ORDER BY nb_entrees DESC;


-- ----------------------------------------------------
-- R10. Chaque employé avec le nom de son manager (NULL = sommet hiérarchie).
--      Approche : LEFT JOIN auto-référente.
-- ----------------------------------------------------
SELECT  CONCAT_WS(' ', e.prenom, e.nom)              AS employe,
        COALESCE(CONCAT_WS(' ', m.prenom, m.nom), '— (Direction)') AS manager
FROM    Employe e
LEFT JOIN Employe m ON m.id_employe = e.id_manager
ORDER BY manager, employe;


-- ====================================================
-- R11 → R15 : SOUS-REQUÊTES / EXISTS / NOT EXISTS
-- ====================================================

-- ----------------------------------------------------
-- R11. Employés dont le solde CP restant est supérieur à la MOYENNE
--      des soldes CP restants de l'entreprise.
--      Approche : sous-requête scalaire (AVG) dans le WHERE.
-- ----------------------------------------------------
SELECT  CONCAT_WS(' ', e.prenom, e.nom)          AS employe,
        (sc.jours_acquis - sc.jours_pris)        AS cp_restant
FROM    Employe e
JOIN    SoldeConge sc ON sc.id_employe = e.id_employe
JOIN    StatutJour sj ON sj.id_statut  = sc.id_statut
WHERE   sj.code = 'CP'
  AND   (sc.jours_acquis - sc.jours_pris) > (
            SELECT AVG(sc2.jours_acquis - sc2.jours_pris)
            FROM   SoldeConge sc2
            JOIN   StatutJour sj2 ON sj2.id_statut = sc2.id_statut
            WHERE  sj2.code = 'CP'
        )
ORDER BY cp_restant DESC;


-- ----------------------------------------------------
-- R12. Employés ayant plus d'entrées de planning que la MOYENNE
--      d'entrées par employé.
--      Approche : sous-requête dérivée (table dérivée) + HAVING.
-- ----------------------------------------------------
SELECT  e.nom,
        e.prenom,
        COUNT(ep.id_entree) AS nb_entrees
FROM    Employe e
JOIN    EntreePlanning ep ON ep.id_employe = e.id_employe
GROUP BY e.id_employe, e.nom, e.prenom
HAVING  COUNT(ep.id_entree) > (
            SELECT AVG(nb) FROM (
                SELECT COUNT(*) AS nb
                FROM   EntreePlanning
                GROUP BY id_employe
            ) AS sous_total
        )
ORDER BY nb_entrees DESC;


-- ----------------------------------------------------
-- R13. Employés ayant AU MOINS UNE demande de congé validée.
--      Approche : EXISTS (sous-requête corrélée).
-- ----------------------------------------------------
SELECT  e.nom, e.prenom
FROM    Employe e
WHERE   EXISTS (
            SELECT 1
            FROM   DemandeConge dc
            WHERE  dc.id_employe = e.id_employe
              AND  dc.statut_demande = 'validee'
        )
ORDER BY e.nom;


-- ----------------------------------------------------
-- R14. Employés n'ayant JAMAIS télétravaillé (aucune entrée TT).
--      Approche : NOT EXISTS (sous-requête corrélée).
-- ----------------------------------------------------
SELECT  e.nom, e.prenom
FROM    Employe e
WHERE   NOT EXISTS (
            SELECT 1
            FROM   EntreePlanning ep
            JOIN   StatutJour sj ON sj.id_statut = ep.id_statut
            WHERE  ep.id_employe = e.id_employe
              AND  sj.code = 'TT'
        )
ORDER BY e.nom;


-- ----------------------------------------------------
-- R15. Employés ayant pris plus de jours de CP que la MOYENNE
--      de CP pris DANS LEUR PROPRE SERVICE.
--      Approche : sous-requête corrélée (corrélation sur le service).
-- ----------------------------------------------------
SELECT  CONCAT_WS(' ', e.prenom, e.nom) AS employe,
        s.libelle                       AS service,
        sc.jours_pris                   AS cp_pris
FROM    Employe e
JOIN    Service s     ON s.id_service = e.id_service
JOIN    SoldeConge sc ON sc.id_employe = e.id_employe
JOIN    StatutJour sj ON sj.id_statut  = sc.id_statut
WHERE   sj.code = 'CP'
  AND   sc.jours_pris > (
            SELECT AVG(sc2.jours_pris)
            FROM   Employe e2
            JOIN   SoldeConge sc2 ON sc2.id_employe = e2.id_employe
            JOIN   StatutJour sj2 ON sj2.id_statut  = sc2.id_statut
            WHERE  sj2.code = 'CP'
              AND  e2.id_service = e.id_service
        )
ORDER BY service, cp_pris DESC;
