-- ====================================================
-- 02_employe.sql — Table Employe (dépend de Service, auto-référence)
-- ====================================================
USE planning_entreprise;

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
