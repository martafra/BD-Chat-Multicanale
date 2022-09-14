-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema Azienda
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `Azienda` ;

-- -----------------------------------------------------
-- Schema Azienda
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `Azienda` DEFAULT CHARACTER SET utf8 ;
USE `Azienda` ;

-- -----------------------------------------------------
-- Table `Azienda`.`Lavoratore`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Azienda`.`Lavoratore` ;

CREATE TABLE IF NOT EXISTS `Azienda`.`Lavoratore` (
  `CF` VARCHAR(45) NOT NULL,
  `NomeLavoratore` VARCHAR(45) NOT NULL,
  `Cognome` VARCHAR(45) NOT NULL,
  `Ruolo` TINYINT NOT NULL,
  PRIMARY KEY (`CF`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Azienda`.`Progetto`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Azienda`.`Progetto` ;

CREATE TABLE IF NOT EXISTS `Azienda`.`Progetto` (
  `IDProgetto` INT NOT NULL AUTO_INCREMENT,
  `NomeProgetto` VARCHAR(45) NULL,
  `DataInizio` DATE NOT NULL,
  `DataFine` DATE NULL,
  PRIMARY KEY (`IDProgetto`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Azienda`.`CanaleDiComunicazione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Azienda`.`CanaleDiComunicazione` ;

CREATE TABLE IF NOT EXISTS `Azienda`.`CanaleDiComunicazione` (
  `Codice` INT NOT NULL AUTO_INCREMENT,
  `Progetto_IDProgetto` INT NOT NULL,
  `NomeCanale` VARCHAR(45) NULL,
  `Tipo` ENUM('Pubblico', 'Privato') NULL,
  PRIMARY KEY (`Codice`, `Progetto_IDProgetto`),
  CONSTRAINT `fk_CanaleDiComunicazione_Progetto1`
    FOREIGN KEY (`Progetto_IDProgetto`)
    REFERENCES `Azienda`.`Progetto` (`IDProgetto`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Codice_UNIQUE` ON `Azienda`.`CanaleDiComunicazione` (`Codice` ASC) VISIBLE;

CREATE INDEX `fk_CanaleDiComunicazione_Progetto1_idx` ON `Azienda`.`CanaleDiComunicazione` (`Progetto_IDProgetto` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Azienda`.`Messaggio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Azienda`.`Messaggio` ;

CREATE TABLE IF NOT EXISTS `Azienda`.`Messaggio` (
  `Lavoratore_CF` VARCHAR(45) NOT NULL,
  `DataInvio` DATE NOT NULL,
  `OrarioInvio` TIME NOT NULL,
  `Testo` VARCHAR(700) NOT NULL,
  `CanaleDiComunicazione_Codice` INT NOT NULL,
  `CanaleDiComunicazione_Progetto_IDProgetto` INT NOT NULL,
  PRIMARY KEY (`Lavoratore_CF`, `DataInvio`, `OrarioInvio`),
  CONSTRAINT `fk_Messaggio_Lavoratore1`
    FOREIGN KEY (`Lavoratore_CF`)
    REFERENCES `Azienda`.`Lavoratore` (`CF`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Messaggio_CanaleDiComunicazione1`
    FOREIGN KEY (`CanaleDiComunicazione_Codice` , `CanaleDiComunicazione_Progetto_IDProgetto`)
    REFERENCES `Azienda`.`CanaleDiComunicazione` (`Codice` , `Progetto_IDProgetto`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_Messaggio_Lavoratore1_idx` ON `Azienda`.`Messaggio` (`Lavoratore_CF` ASC) VISIBLE;

CREATE INDEX `fk_Messaggio_CanaleDiComunicazione1_idx` ON `Azienda`.`Messaggio` (`CanaleDiComunicazione_Codice` ASC, `CanaleDiComunicazione_Progetto_IDProgetto` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Azienda`.`Appartenenza`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Azienda`.`Appartenenza` ;

CREATE TABLE IF NOT EXISTS `Azienda`.`Appartenenza` (
  `Lavoratore_CF` VARCHAR(45) NOT NULL,
  `CanaleDiComunicazione_Codice` INT NOT NULL,
  `CanaleDiComunicazione_Progetto_IDProgetto` INT NOT NULL,
  PRIMARY KEY (`Lavoratore_CF`, `CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`),
  CONSTRAINT `fk_Appartenenza_Lavoratore1`
    FOREIGN KEY (`Lavoratore_CF`)
    REFERENCES `Azienda`.`Lavoratore` (`CF`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Appartenenza_CanaleDiComunicazione1`
    FOREIGN KEY (`CanaleDiComunicazione_Codice` , `CanaleDiComunicazione_Progetto_IDProgetto`)
    REFERENCES `Azienda`.`CanaleDiComunicazione` (`Codice` , `Progetto_IDProgetto`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_Appartenenza_CanaleDiComunicazione1_idx` ON `Azienda`.`Appartenenza` (`CanaleDiComunicazione_Codice` ASC, `CanaleDiComunicazione_Progetto_IDProgetto` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Azienda`.`Assegnazione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Azienda`.`Assegnazione` ;

CREATE TABLE IF NOT EXISTS `Azienda`.`Assegnazione` (
  `Lavoratore_CF` VARCHAR(45) NOT NULL,
  `Progetto_IDProgetto` INT NOT NULL,
  PRIMARY KEY (`Lavoratore_CF`, `Progetto_IDProgetto`),
  CONSTRAINT `fk_Assegnazione_Lavoratore1`
    FOREIGN KEY (`Lavoratore_CF`)
    REFERENCES `Azienda`.`Lavoratore` (`CF`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Assegnazione_Progetto1`
    FOREIGN KEY (`Progetto_IDProgetto`)
    REFERENCES `Azienda`.`Progetto` (`IDProgetto`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_Assegnazione_Progetto1_idx` ON `Azienda`.`Assegnazione` (`Progetto_IDProgetto` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Azienda`.`Coordinazione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Azienda`.`Coordinazione` ;

CREATE TABLE IF NOT EXISTS `Azienda`.`Coordinazione` (
  `Lavoratore_CF` VARCHAR(45) NOT NULL,
  `Progetto_IDProgetto` INT NOT NULL,
  PRIMARY KEY (`Lavoratore_CF`, `Progetto_IDProgetto`),
  CONSTRAINT `fk_Coordinazione_Lavoratore1`
    FOREIGN KEY (`Lavoratore_CF`)
    REFERENCES `Azienda`.`Lavoratore` (`CF`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Coordinazione_Progetto1`
    FOREIGN KEY (`Progetto_IDProgetto`)
    REFERENCES `Azienda`.`Progetto` (`IDProgetto`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_Coordinazione_Progetto1_idx` ON `Azienda`.`Coordinazione` (`Progetto_IDProgetto` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Azienda`.`Creazione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Azienda`.`Creazione` ;

CREATE TABLE IF NOT EXISTS `Azienda`.`Creazione` (
  `CanaleDiComunicazione_Codice` INT NOT NULL,
  `CanaleDiComunicazione_Progetto_IDProgetto` INT NOT NULL,
  `Lavoratore_CF` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`),
  CONSTRAINT `fk_Creazione_CanaleDiComunicazione1`
    FOREIGN KEY (`CanaleDiComunicazione_Codice` , `CanaleDiComunicazione_Progetto_IDProgetto`)
    REFERENCES `Azienda`.`CanaleDiComunicazione` (`Codice` , `Progetto_IDProgetto`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Creazione_Lavoratore1`
    FOREIGN KEY (`Lavoratore_CF`)
    REFERENCES `Azienda`.`Lavoratore` (`CF`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_Creazione_Lavoratore1_idx` ON `Azienda`.`Creazione` (`Lavoratore_CF` ASC) VISIBLE;

CREATE UNIQUE INDEX `CanaleDiComunicazione_Codice_UNIQUE` ON `Azienda`.`Creazione` (`CanaleDiComunicazione_Codice` ASC) VISIBLE;

CREATE UNIQUE INDEX `CanaleDiComunicazione_Progetto_IDProgetto_UNIQUE` ON `Azienda`.`Creazione` (`CanaleDiComunicazione_Progetto_IDProgetto` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Azienda`.`Risposta`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Azienda`.`Risposta` ;

CREATE TABLE IF NOT EXISTS `Azienda`.`Risposta` (
  `Tipo` ENUM('Pubblica', 'Privata') NOT NULL,
  `Messaggio_Lavoratore_CF` VARCHAR(45) NOT NULL,
  `Messaggio_DataInvio` DATE NOT NULL,
  `Messaggio_OrarioInvio` TIME NOT NULL,
  `Messaggio_Lavoratore_CFD` VARCHAR(45) NOT NULL,
  `Messaggio_DataInvioD` DATE NOT NULL,
  `Messaggio_OrarioInvioD` TIME NOT NULL,
  PRIMARY KEY (`Messaggio_Lavoratore_CF`, `Messaggio_DataInvio`, `Messaggio_OrarioInvio`),
  CONSTRAINT `fk_Risposta_Messaggio1`
    FOREIGN KEY (`Messaggio_Lavoratore_CF` , `Messaggio_DataInvio` , `Messaggio_OrarioInvio`)
    REFERENCES `Azienda`.`Messaggio` (`Lavoratore_CF` , `DataInvio` , `OrarioInvio`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Risposta_Messaggio2`
    FOREIGN KEY (`Messaggio_Lavoratore_CFD` , `Messaggio_DataInvioD` , `Messaggio_OrarioInvioD`)
    REFERENCES `Azienda`.`Messaggio` (`Lavoratore_CF` , `DataInvio` , `OrarioInvio`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_Risposta_Messaggio1_idx` ON `Azienda`.`Risposta` (`Messaggio_Lavoratore_CF` ASC, `Messaggio_DataInvio` ASC, `Messaggio_OrarioInvio` ASC) VISIBLE;

CREATE INDEX `fk_Risposta_Messaggio2_idx` ON `Azienda`.`Risposta` (`Messaggio_Lavoratore_CFD` ASC, `Messaggio_DataInvioD` ASC, `Messaggio_OrarioInvioD` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Azienda`.`Utente`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Azienda`.`Utente` ;

CREATE TABLE IF NOT EXISTS `Azienda`.`Utente` (
  `U_CF` VARCHAR(45) NOT NULL,
  `Password` VARCHAR(45) NOT NULL,
  `Ruolo` ENUM('Amministratore', 'Capoprogetto', 'Dipendente') NOT NULL,
  PRIMARY KEY (`U_CF`))
ENGINE = InnoDB;

USE `Azienda` ;

-- -----------------------------------------------------
-- procedure insert_progetto
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`insert_progetto`;

DELIMITER $$
USE `Azienda`$$
create procedure `insert_progetto`(in var_nomeprogetto varchar(45))
begin
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level read uncommitted;
start transaction;
	insert into `Progetto` (`NomeProgetto`, `DataInizio`)
    values (var_nomeprogetto, date(now()));
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_lavoratore
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`insert_lavoratore`;

DELIMITER $$
USE `Azienda`$$
create procedure `insert_lavoratore`(in var_CF varchar(45), in var_nomelavoratore varchar(45), in var_cognome varchar(45), in var_ruolo tinyint)
begin
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level read uncommitted;
start transaction;
	insert into `Lavoratore` (`CF`, `NomeLavoratore`, `Cognome`, `Ruolo`)
    values (var_CF, var_nomelavoratore, var_cognome, var_ruolo);
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_messaggio
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`insert_messaggio`;

DELIMITER $$
USE `Azienda`$$
create procedure `insert_messaggio`(in var_CF varchar(45), in var_testo varchar(700), in var_codice INT, in var_IDProgetto INT)
begin
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level serializable;
start transaction;
	insert into `Messaggio` (`Lavoratore_CF`, `DataInvio`, `OrarioInvio`, `Testo`, `CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`)
    values (var_CF, date(now()), time(now()), var_testo, var_codice, var_IDProgetto);
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure creazione_canale
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`creazione_canale`;

DELIMITER $$
USE `Azienda`$$
create procedure `creazione_canale`(in var_IDProgetto INT, in var_nomecanale varchar(45), in var_CF varchar(45))
begin
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level repeatable read;
start transaction;
    -- insert del canale di comunicazione non privato
	insert into `CanaleDiComunicazione` (`Progetto_IDProgetto`, `NomeCanale`, `Tipo`)
    values (var_IDProgetto, var_nomecanale, 'Pubblico');
    -- attribuzione della relazione di creazione al capoprogetto
    insert into `Creazione` (`CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`, `Lavoratore_CF`)
    values (last_insert_id(), var_IDProgetto, var_CF);
    -- inserimento capoprogetto nel canale
    insert into `Appartenenza` (`Lavoratore_CF`, `CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`)
    values(var_CF, last_insert_id(), var_IDProgetto);
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure assegnazione_progetto
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`assegnazione_progetto`;

DELIMITER $$
USE `Azienda`$$
create procedure `assegnazione_progetto`(in var_CF varchar(45), in var_IDProgetto INT)
begin
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level repeatable read;
start transaction;
	insert into `Assegnazione` (`Lavoratore_CF`, `Progetto_IDProgetto`)
    values (var_CF, var_IDProgetto);
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure coordinazione_progetto
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`coordinazione_progetto`;

DELIMITER $$
USE `Azienda`$$
create procedure `coordinazione_progetto`(in var_CF varchar(45), in var_IDProgetto INT)
begin
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level repeatable read;
start transaction;
	insert into `Coordinazione` (`Lavoratore_CF`, `Progetto_IDProgetto`)
    values (var_CF, var_IDProgetto);
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure assegnazione_canale
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`assegnazione_canale`;

DELIMITER $$
USE `Azienda`$$
create procedure `assegnazione_canale`(in var_CF varchar(45), in var_codice INT, in var_IDProgetto INT)
begin
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level repeatable read;
start transaction;
	insert into `Appartenenza` (`Lavoratore_CF`, `CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`)
    values (var_CF, var_codice, var_IDProgetto);
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure risposta_pubblica
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`risposta_pubblica`;

DELIMITER $$
USE `Azienda`$$
create procedure `risposta_pubblica`(in var_CFMittente varchar(45), in var_testo varchar(700), in var_CFDestinatario varchar(45), in var_datadestinatario date, in var_orariodestinatario time, in var_codice INT, in var_IDProgetto INT)
begin
declare var_datamittente date;
declare var_orariomittente time;
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level serializable;
start transaction;
	set var_datamittente = date(now());
    set var_orariomittente = time(now());
	-- registrazione del messaggio
	insert into `Messaggio` (`Lavoratore_CF`, `DataInvio`, `OrarioInvio`, `Testo`, `CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`)
    values (var_CFMittente, var_datamittente, var_orariomittente, var_testo, var_codice, var_IDProgetto);
    -- attribuzione della relazione di risposta
    insert into `Risposta` (`Messaggio_DataInvio`, `Messaggio_OrarioInvio`, `Messaggio_Lavoratore_CF`,`Messaggio_DataInvioD`, `Messaggio_OrarioInvioD`, `Messaggio_Lavoratore_CFD`, `Tipo`)
    values (var_datamittente, var_orariomittente, var_CFMittente, var_datadestinatario, var_orariodestinatario, var_CFDestinatario, 'Pubblica');
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure risposta_privata
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`risposta_privata`;

DELIMITER $$
USE `Azienda`$$
create procedure `risposta_privata`(in var_CFMittente varchar(45), in var_testo varchar(700), in var_CFDestinatario varchar(45), in var_datadestinatario date, in var_orariodestinatario time, in var_IDProgetto INT)
begin
declare var_datamittente date;
declare var_orariomittente time;
declare var_codice INT;
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set var_datamittente = date(now());
set var_orariomittente = time(now());
set transaction isolation level serializable;
start transaction;
		-- insert del canale di comunicazione privato
		insert into `CanaleDiComunicazione` (`Progetto_IDProgetto`, `NomeCanale`, `Tipo`)
		values (var_IDProgetto, 'Canale Privato', 'Privato');
        -- assegnazione del canale ai due partecipanti
        insert into `Appartenenza` (`Lavoratore_CF`, `CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`)
		values (var_CFMittente, last_insert_id(), var_IDProgetto);
        insert into `Appartenenza` (`Lavoratore_CF`, `CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`)
		values (var_CFDestinatario, last_insert_id(), var_IDProgetto);        
    -- procedura standard di inserimento di un messaggio
	-- registrazione del messaggio
	insert into `Messaggio` (`Lavoratore_CF`, `DataInvio`, `OrarioInvio`, `Testo`, `CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`)
    values (var_CFMittente, var_datamittente, var_orariomittente, var_testo, last_insert_id(), var_IDProgetto);
    -- attribuzione della relazione di risposta
    insert into `Risposta` (`Tipo`,`Messaggio_Lavoratore_CF`,`Messaggio_DataInvio`, `Messaggio_OrarioInvio`, `Messaggio_Lavoratore_CFD`,`Messaggio_DataInvioD`, `Messaggio_OrarioInvioD`)
    values ('Privata',var_CFMittente, var_datamittente, var_orariomittente, var_CFDestinatario, var_datadestinatario, var_orariodestinatario);
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure chiusura_progetto
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`chiusura_progetto`;

DELIMITER $$
USE `Azienda`$$
create procedure `chiusura_progetto`(in var_IDProgetto INT, in var_datafine date)
begin
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;    
set transaction isolation level repeatable read;
start transaction;
	update Progetto set DataFine = var_datafine where Progetto.IDProgetto = var_IDProgetto;
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure login
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`login`;

DELIMITER $$
USE `Azienda`$$
create procedure `login`(in var_cf varchar(45), in var_pass varchar(45), out var_ruolo INT)
begin
	declare var_user_ruolo ENUM('Amministratore', 'Capoprogetto','Dipendente');
	select `Ruolo` from `Utente` where `U_CF` = var_cf AND `Password` = var_pass INTO var_user_ruolo;
	if var_user_ruolo = 'Amministratore' then
		set var_ruolo = 1;
	elseif var_user_ruolo = 'Capoprogetto' then
		set var_ruolo = 2;
	elseif var_user_ruolo = 'Dipendente' then
		set var_ruolo = 3;
	else
		set var_ruolo = 4;
	end if;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure retrieve_appartenenza
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`retrieve_appartenenza`;

DELIMITER $$
USE `Azienda`$$
create procedure `retrieve_appartenenza`(in var_CF varchar(45))
begin
declare var_ruolo tinyint;
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level repeatable read;
start transaction;
    -- retrieve informazioni
	select Progetto.NomeProgetto as Progetto, Progetto.IDProgetto as ID_Progetto, CanaleDiComunicazione.Codice as Codice_Canale, CanaleDiComunicazione.NomeCanale as Nome_Canale
    from Progetto join Appartenenza on Progetto.IDProgetto = Appartenenza.CanaleDiComunicazione_Progetto_IDProgetto join CanaleDiComunicazione on Appartenenza.CanaleDiComunicazione_Progetto_IDProgetto = CanaleDiComunicazione.Progetto_IDProgetto
    where Appartenenza.Lavoratore_CF = var_CF;
    -- secondo retireve per i progetti senza canale
    select Progetto.NomeProgetto as Progetto, Progetto.IDProgetto as ID_Progetto
    from Progetto join Appartenenza on Progetto.IDProgetto = Appartenenza.CanaleDiComunicazione_Progetto_IDProgetto
    where Appartenenza.Lavoratore_CF = var_CF;
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure retrieve_coordinazione
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`retrieve_coordinazione`;

DELIMITER $$
USE `Azienda`$$
create procedure `retrieve_coordinazione`(in var_CF varchar(45))
begin
declare var_ruolo tinyint;
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level repeatable read;
start transaction;
	select Ruolo from Lavoratore where Lavoratore.CF = var_CF into var_ruolo;
    -- controllo ruolo
    if var_ruolo <> 2 then
		signal sqlstate '45008' set message_text = "Operazione non concessa";
	end if;
    -- retrieve informazioni
	select Progetto.NomeProgetto as Progetto, Progetto.IDProgetto as ID_Progetto, CanaleDiComunicazione.Codice as Codice_Canale, CanaleDiComunicazione.NomeCanale as Nome_Canale
    from Progetto join Coordinazione on Progetto.IDProgetto = Coordinazione.Progetto_IDProgetto join CanaleDiComunicazione on Coordinazione.Progetto_IDProgetto = CanaleDiComunicazione.Progetto_IDProgetto
    where Coordinazione.Lavoratore_CF = var_CF;
    -- secondo retireve per i progetti senza canale
    select Progetto.NomeProgetto as Progetto, Progetto.IDProgetto as ID_Progetto
    from Progetto join Coordinazione on Progetto.IDProgetto = Coordinazione.Progetto_IDProgetto
    where Coordinazione.Lavoratore_CF = var_CF;
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure retrieve_conversazioni
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`retrieve_conversazioni`;

DELIMITER $$
USE `Azienda`$$
create procedure `retrieve_conversazioni`(in var_codice INT, in var_IDProgetto INT)
begin
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level read committed;
start transaction;
    -- retrieve conversazioni
	select Lavoratore.NomeLavoratore as Nome_Lavoratore, Lavoratore.Cognome as Cognome_Lavoratore, Messaggio.Lavoratore_CF as CF, Messaggio.DataInvio as Data_Invio, Messaggio.OrarioInvio as Orario_Invio, Messaggio.Testo as Testo
    from CanaleDiComunicazione join Messaggio on (CanaleDiComunicazione.Codice = Messaggio.CanaleDiComunicazione_Codice and CanaleDiComunicazione.Progetto_IDProgetto = Messaggio.CanaleDiComunicazione_Progetto_IDProgetto) join Lavoratore on Messaggio.Lavoratore_CF = Lavoratore.CF
    where CanaleDiComunicazione.Progetto_IDProgetto = var_IDProgetto and CanaleDiComunicazione.Codice = var_codice
    order by Messaggio.DataInvio, Messaggio.OrarioInvio;
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure retrieve_progetti_canali
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`retrieve_progetti_canali`;

DELIMITER $$
USE `Azienda`$$
create procedure `retrieve_progetti_canali`()
begin
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level repeatable read;
start transaction;
    -- retrieve informazioni
	select Progetto.NomeProgetto as Progetto, Progetto.IDProgetto as ID_Progetto, CanaleDiComunicazione.Codice as Codice_Canale, CanaleDiComunicazione.NomeCanale as Nome_Canale
    from Progetto join CanaleDiComunicazione on Progetto.IDProgetto = CanaleDiComunicazione.Progetto_IDProgetto;
    select Progetto.NomeProgetto as Progetto, Progetto.IDProgetto as ID_Progetto from Progetto;
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure insert_utente
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`insert_utente`;

DELIMITER $$
USE `Azienda`$$
create procedure `insert_utente`(in var_cf varchar(45), in var_password varchar(45), in var_ruolo varchar(45))
begin
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level read uncommitted;
start transaction;
	insert into `Utente` (`U_CF`, `Password`, `Ruolo`)
    values (var_CF, var_password, var_ruolo);
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure retrieve_appartenenza_coordinazione
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`retrieve_appartenenza_coordinazione`;

DELIMITER $$
USE `Azienda`$$
create procedure `retrieve_appartenenza_coordinazione`(in var_CF varchar(45))
begin
declare var_ruolo tinyint;
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level repeatable read;
start transaction;
	select Ruolo from Lavoratore where Lavoratore.CF = var_CF into var_ruolo;
    -- controllo ruolo
    if var_ruolo <> 2 then
		signal sqlstate '45009' set message_text = "Operazione non concessa";
	end if;
    -- retrieve informazioni
	select Progetto.NomeProgetto as Progetto, Progetto.IDProgetto as ID_Progetto, Lavoratore.CF as CF, Lavoratore.NomeLavoratore as Nome, Lavoratore.Cognome as Cognome
    from Progetto join Assegnazione on Progetto.IDProgetto = Assegnazione.Progetto_IDProgetto join Lavoratore on Assegnazione.Lavoratore_CF = Lavoratore.CF
    where Progetto.IDProgetto in(
								select Progetto.IDProgetto
								from Progetto join Coordinazione on Progetto.IDProgetto = Coordinazione.Progetto_IDProgetto
								where Coordinazione.Lavoratore_CF = var_CF
    );
commit;
end$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure retrieve_dipendenti
-- -----------------------------------------------------

USE `Azienda`;
DROP procedure IF EXISTS `Azienda`.`retrieve_dipendenti`;

DELIMITER $$
USE `Azienda`$$
create procedure `retrieve_dipendenti`()
begin
declare exit handler for sqlexception
	begin
		rollback; -- rollback any changes made in the transaction
		resignal; -- raise again the sql exception to the caller
	end;
set transaction isolation level read committed;
start transaction;
    -- retrieve informazioni
	select Lavoratore.CF as CF, Lavoratore.NomeLavoratore as Nome, Lavoratore.Cognome as Cognome, Lavoratore.Ruolo as Ruolo
    from Lavoratore;
commit;
end$$

DELIMITER ;
USE `Azienda`;

DELIMITER $$

USE `Azienda`$$
DROP TRIGGER IF EXISTS `Azienda`.`Progetto_BEFORE_UPDATE` $$
USE `Azienda`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Azienda`.`Progetto_BEFORE_UPDATE` BEFORE UPDATE ON `Progetto` FOR EACH ROW
BEGIN
	declare var_datainizio date;
    -- selezione data inizio progetto
    select DataInizio from Progetto where Progetto.IDProgetto = new.IDProgetto into var_datainizio;
    -- controllo data
    if var_datainizio < new.DataFine then
		signal sqlstate '45002' set message_text = "Il termine non può precedere la data di inizio di un progetto";
	end if;	
END$$


USE `Azienda`$$
DROP TRIGGER IF EXISTS `Azienda`.`CanaleDiComunicazione_BEFORE_INSERT` $$
USE `Azienda`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Azienda`.`CanaleDiComunicazione_BEFORE_INSERT` BEFORE INSERT ON `CanaleDiComunicazione` FOR EACH ROW
BEGIN
	declare var_datafine date;
    -- selezione data fine progetto
    select DataFine from Progetto where Progetto.IDProgetto = new.Progetto_IDProgetto into var_datafine;
    -- controllo data
    if var_datafine is not null then
		signal sqlstate '45003' set message_text = "Impossibile creare un canale di comunicazione afferente ad un progetto chiuso";
	end if;	
END$$


USE `Azienda`$$
DROP TRIGGER IF EXISTS `Azienda`.`Messaggio_BEFORE_INSERT` $$
USE `Azienda`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Azienda`.`Messaggio_BEFORE_INSERT` BEFORE INSERT ON `Messaggio` FOR EACH ROW
BEGIN
	declare var_datafine date;
    -- selezione data fine progetto
    select DataFine from Progetto
    where Progetto.IDProgetto = new.CanaleDiComunicazione_Progetto_IDProgetto into var_datafine;
    -- controllo data
    if var_datafine is not null then
		signal sqlstate '45004' set message_text = "Impossibile inviare un messaggio in un canale di comunicazione afferente ad un progetto chiuso";
	end if;	
END$$


USE `Azienda`$$
DROP TRIGGER IF EXISTS `Azienda`.`Messaggio_BEFORE_INSERT_Ruolo` $$
USE `Azienda`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Azienda`.`Messaggio_BEFORE_INSERT_Ruolo` BEFORE INSERT ON `Messaggio` FOR EACH ROW
BEGIN
	declare var_ruolo tinyint;
	select Ruolo from Lavoratore
    where Lavoratore.CF = new.Lavoratore_CF into var_ruolo;
    if var_ruolo = 1 then
		signal sqlstate '45006' set message_text = "Impossibile inviare un messaggio se il ruolo è di Amministratore";
	end if;
END$$


USE `Azienda`$$
DROP TRIGGER IF EXISTS `Azienda`.`Appartenenza_BEFORE_INSERT` $$
USE `Azienda`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Azienda`.`Appartenenza_BEFORE_INSERT` BEFORE INSERT ON `Appartenenza` FOR EACH ROW
BEGIN
	declare var_tipocanale ENUM('Pubblico', 'Privato');
    declare var_numeropartecipanti INT;
    -- identificazione tipologia canale
    select tipo from CanaleDiComunicazione 
    where CanaleDiComunicazione.Codice = new.CanaleDiComunicazione_Codice and CanaleDiComunicazione.Progetto_IDProgetto = new.CanaleDiComunicazione_Progetto_IDProgetto
    into var_tipocanale;
    -- identificazione numero partecipanti
    select count(*) from Appartenenza where Appartenenza.CanaleDiComunicazione_Codice = new.CanaleDiComunicazione_Codice and Appartenenza.CanaleDiComunicazione_Progetto_IDProgetto = new.CanaleDiComunicazione_Progetto_IDProgetto
    into var_numeropartecipanti;
    -- verifica tipologia canale & possibilità di inserimento
    if var_tipocanale = 'Privato' and var_numeropartecipanti > 2 then
		signal sqlstate '45001' set message_text = "Impossibile aggiungere un'ulteriore persona ad un canale privato";
    end if;
END$$


USE `Azienda`$$
DROP TRIGGER IF EXISTS `Azienda`.`Appartenenza_BEFORE_INSERT_1` $$
USE `Azienda`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Azienda`.`Appartenenza_BEFORE_INSERT_1` BEFORE INSERT ON `Appartenenza` FOR EACH ROW
BEGIN
	declare var_datafine date;
    -- selezione data fine progetto
    select DataFine from Progetto
    where Progetto.IDProgetto = new.CanaleDiComunicazione_Progetto_IDProgetto into var_datafine;
    -- controllo data
    if var_datafine is not null then
		signal sqlstate '45005' set message_text = "Impossibile aggiungere un partecipante in un canale di comunicazione afferente ad un progetto chiuso";
	end if;	
END$$


USE `Azienda`$$
DROP TRIGGER IF EXISTS `Azienda`.`Creazione_BEFORE_INSERT` $$
USE `Azienda`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Azienda`.`Creazione_BEFORE_INSERT` BEFORE INSERT ON `Creazione` FOR EACH ROW
BEGIN
	declare var_datafine date;
    -- selezione data fine progetto
    select DataFine from Progetto join Messaggio on Progetto.IDProgetto = Messaggio.CanaleDiComunicazione_Progetto_IDProgetto
    where Progetto.IDProgetto = new.CanaleDiComunicazione_Progetto_IDProgetto into var_datafine;
    -- controllo data
    if var_datafine is not null then
		signal sqlstate '45004' set message_text = "Impossibile creare un canale di comunicazione afferente ad un progetto chiuso";
	end if;	
END$$


DELIMITER ;
SET SQL_MODE = '';
DROP USER IF EXISTS Amministratore;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'Amministratore' IDENTIFIED BY '4mm1n1str4t0r3';

GRANT EXECUTE ON procedure `Azienda`.`chiusura_progetto` TO 'Amministratore';
GRANT EXECUTE ON procedure `Azienda`.`coordinazione_progetto` TO 'Amministratore';
GRANT EXECUTE ON procedure `Azienda`.`insert_lavoratore` TO 'Amministratore';
GRANT EXECUTE ON procedure `Azienda`.`insert_progetto` TO 'Amministratore';
GRANT EXECUTE ON procedure `Azienda`.`retrieve_conversazioni` TO 'Amministratore';
GRANT EXECUTE ON procedure `Azienda`.`retrieve_progetti_canali` TO 'Amministratore';
GRANT EXECUTE ON procedure `Azienda`.`insert_utente` TO 'Amministratore';
GRANT EXECUTE ON procedure `Azienda`.`retrieve_dipendenti` TO 'Amministratore';
SET SQL_MODE = '';
DROP USER IF EXISTS Capoprogetto;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'Capoprogetto' IDENTIFIED BY 'C4p0pr0g3tt0';

GRANT EXECUTE ON procedure `Azienda`.`retrieve_conversazioni` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`assegnazione_canale` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`assegnazione_progetto` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`creazione_canale` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`insert_messaggio` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`retrieve_appartenenza` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`retrieve_coordinazione` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`risposta_privata` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`risposta_pubblica` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`retrieve_appartenenza_coordinazione` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`retrieve_dipendenti` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`insert_messaggio` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`retrieve_appartenenza` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`retrieve_conversazioni` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`risposta_privata` TO 'Capoprogetto';
GRANT EXECUTE ON procedure `Azienda`.`risposta_pubblica` TO 'Capoprogetto';
SET SQL_MODE = '';
DROP USER IF EXISTS Dipendente;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'Dipendente' IDENTIFIED BY 'D1p3nd3nt3';

GRANT EXECUTE ON procedure `Azienda`.`insert_messaggio` TO 'Dipendente';
GRANT EXECUTE ON procedure `Azienda`.`retrieve_appartenenza` TO 'Dipendente';
GRANT EXECUTE ON procedure `Azienda`.`retrieve_conversazioni` TO 'Dipendente';
GRANT EXECUTE ON procedure `Azienda`.`risposta_privata` TO 'Dipendente';
GRANT EXECUTE ON procedure `Azienda`.`risposta_pubblica` TO 'Dipendente';
SET SQL_MODE = '';
DROP USER IF EXISTS Login;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'Login' IDENTIFIED BY 'L0g1n';

GRANT EXECUTE ON procedure `Azienda`.`login` TO 'Login';

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `Azienda`.`Lavoratore`
-- -----------------------------------------------------
START TRANSACTION;
USE `Azienda`;
INSERT INTO `Azienda`.`Lavoratore` (`CF`, `NomeLavoratore`, `Cognome`, `Ruolo`) VALUES ('JSSMNT90A41D810W', 'Jessie', 'Magenta', 3);
INSERT INTO `Azienda`.`Lavoratore` (`CF`, `NomeLavoratore`, `Cognome`, `Ruolo`) VALUES ('JMSBLU90A01D810M', 'James', 'Blu', 3);
INSERT INTO `Azienda`.`Lavoratore` (`CF`, `NomeLavoratore`, `Cognome`, `Ruolo`) VALUES ('MWTPMN90A01D810Q', 'Meowth', 'Pokemon', 2);
INSERT INTO `Azienda`.`Lavoratore` (`CF`, `NomeLavoratore`, `Cognome`, `Ruolo`) VALUES ('HRSLTN90A01D810A', 'Hershel', 'Layton', 2);
INSERT INTO `Azienda`.`Lavoratore` (`CF`, `NomeLavoratore`, `Cognome`, `Ruolo`) VALUES ('KTRLTN90A41D810N', 'Katrielle', 'Layton', 3);
INSERT INTO `Azienda`.`Lavoratore` (`CF`, `NomeLavoratore`, `Cognome`, `Ruolo`) VALUES ('LKUTTN90A01D810S', 'Luke', 'Triton', 3);
INSERT INTO `Azienda`.`Lavoratore` (`CF`, `NomeLavoratore`, `Cognome`, `Ruolo`) VALUES ('FLRRHL90A41D810X', 'Flora', 'Reinhold', 3);
INSERT INTO `Azienda`.`Lavoratore` (`CF`, `NomeLavoratore`, `Cognome`, `Ruolo`) VALUES ('CLVDVO90A01D810V', 'Clive', 'Dove', 3);
INSERT INTO `Azienda`.`Lavoratore` (`CF`, `NomeLavoratore`, `Cognome`, `Ruolo`) VALUES ('MMYLTV90A41D810U', 'Emmy', 'Altava', 3);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Azienda`.`Progetto`
-- -----------------------------------------------------
START TRANSACTION;
USE `Azienda`;
INSERT INTO `Azienda`.`Progetto` (`IDProgetto`, `NomeProgetto`, `DataInizio`, `DataFine`) VALUES (345, 'PokemonGO', '2022/09/13', NULL);
INSERT INTO `Azienda`.`Progetto` (`IDProgetto`, `NomeProgetto`, `DataInizio`, `DataFine`) VALUES (346, 'Enigma001', '2022/09/14', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Azienda`.`CanaleDiComunicazione`
-- -----------------------------------------------------
START TRANSACTION;
USE `Azienda`;
INSERT INTO `Azienda`.`CanaleDiComunicazione` (`Codice`, `Progetto_IDProgetto`, `NomeCanale`, `Tipo`) VALUES (1, 345, 'Canale Principale', 'Pubblico');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Azienda`.`Messaggio`
-- -----------------------------------------------------
START TRANSACTION;
USE `Azienda`;
INSERT INTO `Azienda`.`Messaggio` (`Lavoratore_CF`, `DataInvio`, `OrarioInvio`, `Testo`, `CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`) VALUES ('MWTPMN90A01D810Q', '2022/09/13', '14:06:00', 'Benvenuti nel canale principale!', 1, 345);
INSERT INTO `Azienda`.`Messaggio` (`Lavoratore_CF`, `DataInvio`, `OrarioInvio`, `Testo`, `CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`) VALUES ('MWTPMN90A01D810Q', '2022/09/14', '00:01:32', 'Sono lunico gatto a parlare', 1, 345);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Azienda`.`Appartenenza`
-- -----------------------------------------------------
START TRANSACTION;
USE `Azienda`;
INSERT INTO `Azienda`.`Appartenenza` (`Lavoratore_CF`, `CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`) VALUES ('MWTPMN90A01D810Q', 1, 345);
INSERT INTO `Azienda`.`Appartenenza` (`Lavoratore_CF`, `CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`) VALUES ('JMSBLU90A01D810M', 1, 345);
INSERT INTO `Azienda`.`Appartenenza` (`Lavoratore_CF`, `CanaleDiComunicazione_Codice`, `CanaleDiComunicazione_Progetto_IDProgetto`) VALUES ('JSSMNT90A41D810W', 1, 345);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Azienda`.`Assegnazione`
-- -----------------------------------------------------
START TRANSACTION;
USE `Azienda`;
INSERT INTO `Azienda`.`Assegnazione` (`Lavoratore_CF`, `Progetto_IDProgetto`) VALUES ('MWTPMN90A01D810Q', 345);
INSERT INTO `Azienda`.`Assegnazione` (`Lavoratore_CF`, `Progetto_IDProgetto`) VALUES ('JMSBLU90A01D810M', 345);
INSERT INTO `Azienda`.`Assegnazione` (`Lavoratore_CF`, `Progetto_IDProgetto`) VALUES ('JSSMNT90A41D810W', 345);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Azienda`.`Coordinazione`
-- -----------------------------------------------------
START TRANSACTION;
USE `Azienda`;
INSERT INTO `Azienda`.`Coordinazione` (`Lavoratore_CF`, `Progetto_IDProgetto`) VALUES ('MWTPMN90A01D810Q', 345);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Azienda`.`Utente`
-- -----------------------------------------------------
START TRANSACTION;
USE `Azienda`;
INSERT INTO `Azienda`.`Utente` (`U_CF`, `Password`, `Ruolo`) VALUES ('FRLMRT00A41D810Z', 'teamrocket', 'Amministratore');
INSERT INTO `Azienda`.`Utente` (`U_CF`, `Password`, `Ruolo`) VALUES ('JSSMNT90A41D810W', 'pikachu', 'Dipendente');
INSERT INTO `Azienda`.`Utente` (`U_CF`, `Password`, `Ruolo`) VALUES ('JMSBLU90A01D810M', 'pikachu', 'Dipendente');
INSERT INTO `Azienda`.`Utente` (`U_CF`, `Password`, `Ruolo`) VALUES ('MWTPMN90A01D810Q', 'giovanni', 'Capoprogetto');
INSERT INTO `Azienda`.`Utente` (`U_CF`, `Password`, `Ruolo`) VALUES ('HRSLTN90A01D810A', 'enigmi', 'Capoprogetto');
INSERT INTO `Azienda`.`Utente` (`U_CF`, `Password`, `Ruolo`) VALUES ('LKUTTN90A01D810S', 'loosha', 'Dipendente');
INSERT INTO `Azienda`.`Utente` (`U_CF`, `Password`, `Ruolo`) VALUES ('FLRRHL90A41D810X', 'fioccorosa', 'Dipendente');
INSERT INTO `Azienda`.`Utente` (`U_CF`, `Password`, `Ruolo`) VALUES ('MMYLTV90A41D810U', 'giallo', 'Dipendente');
INSERT INTO `Azienda`.`Utente` (`U_CF`, `Password`, `Ruolo`) VALUES ('CLVDVO90A01D810V', 'giornalismo', 'Dipendente');
INSERT INTO `Azienda`.`Utente` (`U_CF`, `Password`, `Ruolo`) VALUES ('KTRLTN90A41D810N', 'dolcetti', 'Dipendente');

COMMIT;

