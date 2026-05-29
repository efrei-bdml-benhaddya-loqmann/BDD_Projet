-- ====================================================
-- 07_data.sql — Jeu de données (DML)
-- ====================================================
-- À exécuter APRÈS les scripts de création 00→06.
-- Volumes : 4 services, 6 statuts, 10 employés, 51 entrées planning,
--           12 demandes de congé, 20 soldes.
-- ====================================================
USE planning_entreprise;

-- ----------------------------------------
-- SERVICE
-- ----------------------------------------
INSERT INTO Service (code_service, libelle) VALUES
    ('S01', 'Direction'),
    ('S02', 'Informatique'),
    ('S03', 'Ressources Humaines'),
    ('S04', 'Commercial');

-- ----------------------------------------
-- STATUTJOUR  (ids : CP=1, RTT=2, TT=3, BUR=4, MAL=5, FOR=6)
-- ----------------------------------------
INSERT INTO StatutJour (libelle, code, decompte_solde) VALUES
    ('Congé payé',  'CP',  TRUE),
    ('RTT',         'RTT', TRUE),
    ('Télétravail', 'TT',  FALSE),
    ('Bureau',      'BUR', FALSE),
    ('Maladie',     'MAL', FALSE),
    ('Formation',   'FOR', FALSE);

-- ----------------------------------------
-- EMPLOYE  (managers insérés avant leurs subordonnés)
-- ----------------------------------------
-- 1 = Direction générale (pas de manager)
INSERT INTO Employe (nom, prenom, email, date_embauche, id_service, id_manager) VALUES
    ('Martin',  'Sophie', 'sophie.martin@entreprise.fr',  '2015-03-01', 1, NULL);
-- 2,3,4 = responsables de service, rattachés à la DG (id 1)
INSERT INTO Employe (nom, prenom, email, date_embauche, id_service, id_manager) VALUES
    ('Dubois',  'Pierre', 'pierre.dubois@entreprise.fr',  '2017-09-15', 2, 1),
    ('Bernard', 'Claire', 'claire.bernard@entreprise.fr', '2018-01-10', 3, 1),
    ('Moreau',  'Luc',    'luc.moreau@entreprise.fr',     '2016-06-20', 4, 1);
-- 5..10 = collaborateurs
INSERT INTO Employe (nom, prenom, email, date_embauche, id_service, id_manager) VALUES
    ('Petit',   'Julie',  'julie.petit@entreprise.fr',    '2020-02-03', 2, 2),
    ('Robert',  'Thomas', 'thomas.robert@entreprise.fr',  '2021-11-08', 2, 2),
    ('Richard', 'Emma',   'emma.richard@entreprise.fr',   '2019-05-22', 3, 3),
    ('Durand',  'Hugo',   'hugo.durand@entreprise.fr',    '2022-03-14', 4, 4),
    ('Simon',   'Lea',    'lea.simon@entreprise.fr',      '2023-09-01', 4, 4),
    ('Laurent', 'Nathan', 'nathan.laurent@entreprise.fr', '2021-01-18', 2, 2);

-- ----------------------------------------
-- ENTREEPLANNING — semaine du 25/05/2026 (lun) au 29/05/2026 (ven)
-- ----------------------------------------
INSERT INTO EntreePlanning (date, demi_journee, id_employe, id_statut) VALUES
    -- Emp 1 (Sophie, Direction)
    ('2026-05-25', 'journee', 1, 4), ('2026-05-26', 'journee', 1, 4),
    ('2026-05-27', 'journee', 1, 3), ('2026-05-28', 'journee', 1, 4),
    ('2026-05-29', 'journee', 1, 3),
    -- Emp 2 (Pierre, Info)
    ('2026-05-25', 'journee', 2, 4), ('2026-05-26', 'journee', 2, 3),
    ('2026-05-27', 'journee', 2, 4), ('2026-05-28', 'journee', 2, 4),
    ('2026-05-29', 'journee', 2, 3),
    -- Emp 3 (Claire, RH)
    ('2026-05-25', 'journee', 3, 4), ('2026-05-26', 'journee', 3, 4),
    ('2026-05-27', 'journee', 3, 4), ('2026-05-28', 'journee', 3, 3),
    ('2026-05-29', 'journee', 3, 1),
    -- Emp 4 (Luc, Commercial) — formation jeu/ven
    ('2026-05-25', 'journee', 4, 3), ('2026-05-26', 'journee', 4, 4),
    ('2026-05-27', 'journee', 4, 4), ('2026-05-28', 'journee', 4, 6),
    ('2026-05-29', 'journee', 4, 6),
    -- Emp 5 (Julie, Info) — vendredi en demi-journées (matin bureau / aprem télétravail)
    ('2026-05-25', 'journee', 5, 4), ('2026-05-26', 'journee', 5, 4),
    ('2026-05-27', 'journee', 5, 3), ('2026-05-28', 'journee', 5, 3),
    ('2026-05-29', 'matin', 5, 4), ('2026-05-29', 'apres-midi', 5, 3),
    -- Emp 6 (Thomas, Info) — maladie début de semaine
    ('2026-05-25', 'journee', 6, 5), ('2026-05-26', 'journee', 6, 5),
    ('2026-05-27', 'journee', 6, 4), ('2026-05-28', 'journee', 6, 4),
    ('2026-05-29', 'journee', 6, 4),
    -- Emp 7 (Emma, RH)
    ('2026-05-25', 'journee', 7, 4), ('2026-05-26', 'journee', 7, 2),
    ('2026-05-27', 'journee', 7, 4), ('2026-05-28', 'journee', 7, 4),
    ('2026-05-29', 'journee', 7, 3),
    -- Emp 8 (Hugo, Commercial)
    ('2026-05-25', 'journee', 8, 4), ('2026-05-26', 'journee', 8, 4),
    ('2026-05-27', 'journee', 8, 4), ('2026-05-28', 'journee', 8, 4),
    ('2026-05-29', 'journee', 8, 1),
    -- Emp 9 (Lea, Commercial) — congé début de semaine
    ('2026-05-25', 'journee', 9, 1), ('2026-05-26', 'journee', 9, 1),
    ('2026-05-27', 'journee', 9, 4), ('2026-05-28', 'journee', 9, 4),
    ('2026-05-29', 'journee', 9, 4),
    -- Emp 10 (Nathan, Info)
    ('2026-05-25', 'journee', 10, 4), ('2026-05-26', 'journee', 10, 3),
    ('2026-05-27', 'journee', 10, 4), ('2026-05-28', 'journee', 10, 4),
    ('2026-05-29', 'journee', 10, 6);

-- ----------------------------------------
-- DEMANDECONGE  (mix de statuts ; valideur = manager)
-- ----------------------------------------
INSERT INTO DemandeConge
    (date_debut, date_fin, statut_demande, motif, id_employe, id_statut, id_manager_valideur) VALUES
    ('2026-05-25', '2026-05-26', 'validee',    'Week-end prolongé',          9,  1, 4),
    ('2026-05-29', '2026-05-29', 'validee',    'Rendez-vous personnel',      8,  1, 4),
    ('2026-05-29', '2026-05-29', 'validee',    'Pont',                       3,  1, 1),
    ('2026-05-26', '2026-05-26', 'validee',    'Récupération RTT',           7,  2, 3),
    ('2026-06-10', '2026-06-14', 'en_attente', 'Vacances été',               5,  1, NULL),
    ('2026-05-25', '2026-05-26', 'validee',    'Arrêt maladie',              6,  5, 2),
    ('2026-06-02', '2026-06-02', 'en_attente', 'RTT',                        10, 2, NULL),
    ('2026-07-01', '2026-07-15', 'en_attente', 'Congés annuels',             2,  1, NULL),
    ('2026-06-20', '2026-06-20', 'refusee',    'Sous-effectif ce jour',      8,  2, 4),
    ('2026-08-01', '2026-08-10', 'en_attente', 'Vacances août',              9,  1, NULL),
    ('2026-06-05', '2026-06-05', 'refusee',    'Période de clôture',         4,  1, 1),
    ('2026-05-30', '2026-05-30', 'en_attente', 'RTT samedi récupéré',        5,  2, NULL);

-- ----------------------------------------
-- SOLDECONGE  (année 2026 ; CP et RTT par employé)
-- ----------------------------------------
INSERT INTO SoldeConge (annee, jours_acquis, jours_pris, id_employe, id_statut) VALUES
    (2026, 25, 5,  1, 1), (2026, 12, 2,  1, 2),
    (2026, 25, 10, 2, 1), (2026, 12, 3,  2, 2),
    (2026, 25, 12, 3, 1), (2026, 12, 4,  3, 2),
    (2026, 25, 8,  4, 1), (2026, 12, 1,  4, 2),
    (2026, 25, 15, 5, 1), (2026, 12, 6,  5, 2),
    (2026, 25, 3,  6, 1), (2026, 12, 0,  6, 2),
    (2026, 25, 20, 7, 1), (2026, 12, 8,  7, 2),
    (2026, 25, 22, 8, 1), (2026, 12, 10, 8, 2),
    (2026, 25, 25, 9, 1), (2026, 12, 12, 9, 2),
    (2026, 25, 6, 10, 1), (2026, 12, 2, 10, 2);
