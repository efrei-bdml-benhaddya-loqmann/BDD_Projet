-- ====================================================
-- 04_entreeplanning.sql — Table EntreePlanning + triggers anti-chevauchement
-- (dépend de Employe et StatutJour)
-- Association ternaire matérialisée : Employe × Jour × StatutJour
-- ====================================================
USE planning_entreprise;

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
