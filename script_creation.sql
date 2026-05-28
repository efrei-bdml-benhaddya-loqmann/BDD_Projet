-- ====================================================
-- script_creation.sql
-- Projet BDD ALSI61 — Outil de gestion de planning
-- ====================================================
-- Exécution : mysql -u root -p < script_creation.sql
-- Testé sur MySQL 8.x
-- ====================================================

-- ----------------------------------------
-- 0. Initialisation
-- ----------------------------------------
DROP DATABASE IF EXISTS planning_entreprise;
CREATE DATABASE planning_entreprise
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE planning_entreprise;

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------
-- 1. SERVICE
-- ----------------------------------------
CREATE TABLE Service (
    id_service   INT          NOT NULL AUTO_INCREMENT,
    code_service VARCHAR(3)   NOT NULL,
    libelle      VARCHAR(100) NOT NULL,

    CONSTRAINT pk_service       PRIMARY KEY (id_service),
    CONSTRAINT uq_code_service  UNIQUE      (code_service),
    CONSTRAINT ck_code_service  CHECK       (code_service REGEXP '^S[0-9]{2}$')
) ENGINE=InnoDB;

-- ----------------------------------------
-- 2. EMPLOYE
-- ----------------------------------------
CREATE TABLE Employe (
    id_employe    INT          NOT NULL AUTO_INCREMENT,
    nom           VARCHAR(100) NOT NULL,
    prenom        VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL,
    date_embauche DATE         NOT NULL,
    id_service    INT          NOT NULL,
    id_manager    INT              NULL COMMENT 'NULL = sommet hiérarchie (DG)',

    CONSTRAINT pk_employe       PRIMARY KEY (id_employe),
    CONSTRAINT uq_email         UNIQUE      (email),
    CONSTRAINT fk_emp_service   FOREIGN KEY (id_service) REFERENCES Service(id_service)
                                    ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_emp_manager   FOREIGN KEY (id_manager) REFERENCES Employe(id_employe)
                                    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------
-- 3. STATUTJOUR
-- ----------------------------------------
CREATE TABLE StatutJour (
    id_statut      INT         NOT NULL AUTO_INCREMENT,
    libelle        VARCHAR(50) NOT NULL,
    code           CHAR(3)     NOT NULL,
    decompte_solde BOOLEAN     NOT NULL DEFAULT FALSE
        COMMENT 'TRUE = décompte sur SoldeConge (CP, RTT)',

    CONSTRAINT pk_statut    PRIMARY KEY (id_statut),
    CONSTRAINT uq_code      UNIQUE      (code),
    CONSTRAINT ck_code      CHECK       (code IN ('CP', 'RTT', 'TT', 'BUR', 'MAL', 'FOR'))
) ENGINE=InnoDB;

-- ----------------------------------------
-- 4. ENTREEPLANNING
-- ----------------------------------------
CREATE TABLE EntreePlanning (
    id_entree  INT  NOT NULL AUTO_INCREMENT,
    date       DATE NOT NULL,
    demi_journee ENUM('matin', 'apres-midi', 'journee') NOT NULL,
    id_employe INT  NOT NULL,
    id_statut  INT  NOT NULL,

    CONSTRAINT pk_entree        PRIMARY KEY (id_entree),
    CONSTRAINT uq_entree        UNIQUE      (id_employe, date, demi_journee),
    CONSTRAINT fk_entree_emp    FOREIGN KEY (id_employe) REFERENCES Employe(id_employe)
                                    ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_entree_statut FOREIGN KEY (id_statut)  REFERENCES StatutJour(id_statut)
                                    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------
-- TRIGGER : conflit journee ↔ demi-journée
-- Empêche d'insérer 'journee' si 'matin' ou 'apres-midi' existe déjà
-- et vice-versa, pour le même (id_employe, date)
-- ----------------------------------------
DELIMITER //

CREATE TRIGGER trg_entree_no_overlap_insert
BEFORE INSERT ON EntreePlanning
FOR EACH ROW
BEGIN
    -- Insertion d'une journée complète : vérifier qu'aucune demi-journée n'existe
    IF NEW.demi_journee = 'journee' THEN
        IF EXISTS (
            SELECT 1 FROM EntreePlanning
            WHERE id_employe  = NEW.id_employe
              AND date        = NEW.date
              AND demi_journee IN ('matin', 'apres-midi')
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Conflit : une demi-journée existe déjà pour cet employé à cette date.';
        END IF;

    -- Insertion d'une demi-journée : vérifier qu'aucune journée complète n'existe
    ELSEIF NEW.demi_journee IN ('matin', 'apres-midi') THEN
        IF EXISTS (
            SELECT 1 FROM EntreePlanning
            WHERE id_employe  = NEW.id_employe
              AND date        = NEW.date
              AND demi_journee = 'journee'
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Conflit : une entrée journée complète existe déjà pour cet employé à cette date.';
        END IF;
    END IF;
END //

CREATE TRIGGER trg_entree_no_overlap_update
BEFORE UPDATE ON EntreePlanning
FOR EACH ROW
BEGIN
    IF NEW.demi_journee = 'journee' THEN
        IF EXISTS (
            SELECT 1 FROM EntreePlanning
            WHERE id_employe  = NEW.id_employe
              AND date        = NEW.date
              AND demi_journee IN ('matin', 'apres-midi')
              AND id_entree  != NEW.id_entree
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Conflit (UPDATE) : une demi-journée existe déjà pour cet employé à cette date.';
        END IF;

    ELSEIF NEW.demi_journee IN ('matin', 'apres-midi') THEN
        IF EXISTS (
            SELECT 1 FROM EntreePlanning
            WHERE id_employe  = NEW.id_employe
              AND date        = NEW.date
              AND demi_journee = 'journee'
              AND id_entree  != NEW.id_entree
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Conflit (UPDATE) : une entrée journée complète existe déjà pour cet employé à cette date.';
        END IF;
    END IF;
END //

DELIMITER ;

-- ----------------------------------------
-- 5. DEMANDECONGE
-- ----------------------------------------
CREATE TABLE DemandeConge (
    id_demande          INT      NOT NULL AUTO_INCREMENT,
    date_debut          DATE     NOT NULL,
    date_fin            DATE     NOT NULL,
    demi_journee_debut  ENUM('matin', 'apres-midi', 'journee') NOT NULL DEFAULT 'journee',
    demi_journee_fin    ENUM('matin', 'apres-midi', 'journee') NOT NULL DEFAULT 'journee',
    statut_demande      ENUM('en_attente', 'validee', 'refusee') NOT NULL DEFAULT 'en_attente',
    date_soumission     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motif               TEXT         NULL,
    id_employe          INT      NOT NULL,
    id_statut           INT      NOT NULL COMMENT 'Type de congé : CP, RTT, MAL…',
    id_manager_valideur INT          NULL COMMENT 'NULL si pas encore traité',

    CONSTRAINT pk_demande           PRIMARY KEY (id_demande),
    CONSTRAINT ck_dates_demande     CHECK       (date_debut <= date_fin),
    CONSTRAINT fk_demande_emp       FOREIGN KEY (id_employe)          REFERENCES Employe(id_employe)
                                        ON DELETE CASCADE  ON UPDATE CASCADE,
    CONSTRAINT fk_demande_statut    FOREIGN KEY (id_statut)           REFERENCES StatutJour(id_statut)
                                        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_demande_manager   FOREIGN KEY (id_manager_valideur) REFERENCES Employe(id_employe)
                                        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------
-- 6. SOLDECONGE
-- ----------------------------------------
CREATE TABLE SoldeConge (
    id_solde      INT            NOT NULL AUTO_INCREMENT,
    annee         YEAR           NOT NULL,
    jours_acquis  DECIMAL(5, 1)  NOT NULL DEFAULT 0,
    jours_pris    DECIMAL(5, 1)  NOT NULL DEFAULT 0,
    id_employe    INT            NOT NULL,
    id_statut     INT            NOT NULL COMMENT 'CP ou RTT uniquement',

    CONSTRAINT pk_solde             PRIMARY KEY (id_solde),
    CONSTRAINT uq_solde             UNIQUE      (id_employe, id_statut, annee),
    CONSTRAINT ck_jours_acquis      CHECK       (jours_acquis >= 0),
    CONSTRAINT ck_jours_pris        CHECK       (jours_pris   >= 0),
    CONSTRAINT ck_solde_positif     CHECK       (jours_acquis - jours_pris >= 0),
    CONSTRAINT fk_solde_emp         FOREIGN KEY (id_employe) REFERENCES Employe(id_employe)
                                        ON DELETE CASCADE  ON UPDATE CASCADE,
    CONSTRAINT fk_solde_statut      FOREIGN KEY (id_statut)  REFERENCES StatutJour(id_statut)
                                        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------
-- Vérification : afficher les tables créées
-- ----------------------------------------
SHOW TABLES;
