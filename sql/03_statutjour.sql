-- ====================================================
-- 03_statutjour.sql — Table StatutJour (référentiel)
-- ====================================================
USE planning_entreprise;

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
