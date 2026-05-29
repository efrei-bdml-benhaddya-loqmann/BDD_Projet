-- ====================================================
-- 06_soldeconge.sql — Table SoldeConge (porteur d'attributs ; dépend de Employe et StatutJour)
-- ====================================================
USE planning_entreprise;

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
