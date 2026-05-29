-- ====================================================
-- 05_demandeconge.sql — Table DemandeConge (dépend de Employe et StatutJour)
-- ====================================================
USE planning_entreprise;

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
