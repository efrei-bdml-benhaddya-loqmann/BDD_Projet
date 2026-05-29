-- ====================================================
-- 01_service.sql — Table Service
-- ====================================================
USE planning_entreprise;

CREATE TABLE Service (
    id_service   INT          NOT NULL AUTO_INCREMENT,
    code_service VARCHAR(3)   NOT NULL,
    libelle      VARCHAR(100) NOT NULL,

    CONSTRAINT pk_service       PRIMARY KEY (id_service),
    CONSTRAINT uq_code_service  UNIQUE      (code_service),
    CONSTRAINT ck_code_service  CHECK       (code_service REGEXP '^S[0-9]{2}$')
) ENGINE=InnoDB;
