
/*******************************************************************************START USER PROCESS***********************************************************************************/
/*
-- when user first regs he gets a row in the regUsertable. The pk is outputed to the backend and it should be send at the email address. 
When the user clicks the email address, this pk is checked if eists in the regUser Table. If so the data si inserted into the t_populationtable.
After the insert si succcesul the row is marked as procesed. A daily process will come and delete the procesed rows(rStatus = 1)
*/
-- try to add republic schema

-- main user table
	CREATE TABLE republic.t_Population
		(
		  userID SERIAL 
		  ,pFirstName VARCHAR(255) NOT NULL
		  ,pLastName VARCHAR(255) NOT NULL
		  ,pUserName VARCHAR(255) NOT NULL UNIQUE
		  ,pEmailAddr VARCHAR(255) NOT NULL UNIQUE
		  ,pStreetName VARCHAR(255) NULL
		  ,pPassword VARCHAR(255) NOT NULL --  needs to be hashed
		  ,CONSTRAINT PK_pop PRIMARY KEY (userID) 
		);
	CREATE INDEX IX_uNmPass ON republic.t_Population(pUserName,pPassword);
	CREATE INDEX IX_email ON republic.t_Population(pEmailAddr);
-- comfirm reg table
	CREATE TABLE republic.t_RegUser
		(
		pk_unUsr UUID DEFAULT uuid_generate_v4()
		,rFirstName VARCHAR(255) NOT NULL
		,rLastName VARCHAR(255) NOT NULL
		,rUserName VARCHAR(255) NOT NULL UNIQUE
		,rEmailAddr VARCHAR(255) NOT NULL UNIQUE
		,rStreetName VARCHAR(255) NULL
		,rStatus BOOL  DEFAULT FALSE
		,rPassword VARCHAR(255) NOT NULL --  needs to be hashed
		,CONSTRAINT PK_rgUs PRIMARY KEY (pk_unUsr) 
		);
     CREATE INDEX IX_Status ON republic.t_RegUser(rStatus );
-- opened seesion token table
	CREATE TABLE republic.t_OpenSession
		(
		  pk_oSes UUID DEFAULT uuid_generate_v4() -- DEFAULT  UUID() -- SELECT UUID()
		  ,userID INTEGER NOT NULL
		  ,CONSTRAINT PK_opnSes PRIMARY KEY (pk_oSes)
		);
	CREATE INDEX IX_uId ON republic.t_OpenSession(userID);
-- ======================================================= START REG PROCESS ================================================================================

-- check if a email address exists
--DROP FUNCTION republic.sp_checkemailexists(character varying)
	CREATE OR REPLACE FUNCTION  republic.sp_CheckEmailExists(IN toCheck VARCHAR(255))
    RETURNS BOOL AS 
    $Body$
    BEGIN
      IF (SELECT p.userID FROM republic.t_Population AS p WHERE p.pEmailAddr = toCheck LIMIT 1) IS NULL THEN 
          RETURN FALSE ;
          ELSE  RETURN TRUE ; 
      END IF;
    END;
    $Body$ LANGUAGE plpgsql;
   
    
-- check if a username address exists
	CREATE OR REPLACE FUNCTION republic.sp_CheckUserNmExists(IN toCheck VARCHAR(255))
    RETURNS BOOL AS
    $Body$
    BEGIN
    	 IF (SELECT p.userID  FROM republic.t_Population AS p WHERE p.pUserName = toCheck LIMIT 1) IS NULL THEN
             RETURN FALSE;
             ELSE RETURN TRUE;
         END IF;
    END
    $Body$ LANGUAGE plpgsql;
    
 -- verify if unconfirmed email already exists
 
     CREATE OR REPLACE FUNCTION republic.sp_CheckEmailExistsUnCf(IN toCheck VARCHAR(255))
     RETURNS BOOL AS
     $Body$
     BEGIN
        IF (SELECT p.pk_unUsr FROM republic.t_RegUser AS p WHERE p.rEmailAddr = toCheck AND rStatus  = FALSE LIMIT 1) IS NULL THEN
            RETURN FALSE;
            ELSE RETURN TRUE;
        END IF;
     END
     $Body$ LANGUAGE plpgsql;
 
-- verify if unconfirmed username already exists
	CREATE OR REPLACE FUNCTION republic.sp_CheckUserNmExistsunCf(IN toCheck VARCHAR(255))
    RETURNS BOOL AS
    $body$
    BEGIN
    	  IF (SELECT p.pk_unUsr FROM republic.t_RegUser AS p WHERE p.rUserName  = toCheck  AND rStatus  = FALSE LIMIT 1) IS NULL THEN
              RETURN FALSE;
              ELSE RETURN TRUE;
          END IF;
    END 
    $body$ LANGUAGE plpgsql;

--verify confirmCode still exists in the unreg user table
	CREATE OR REPLACE FUNCTION republic.sp_CheckConfirmCodeStillActive(IN confirmCode UUID)
 	RETURNS BOOL AS
    $$
    BEGIN
    	IF (SELECT ru.pk_unUsr FROM republic.t_RegUser AS ru WHERE ru.pk_unUsr = confirmCode  AND rStatus  = FALSE LIMIT 1) IS NULL THEN
            RETURN FALSE;
            ELSE RETURN TRUE;
        END IF;
    END
    $$ LANGUAGE plpgsql;
-- create unconfirmed user
	CREATE OR REPLACE  FUNCTION republic.sp_insertUnconfirmedUser
    	(
         IN FirstName VARCHAR(255) 
		 ,IN LastName VARCHAR(255) 
		 ,IN UserName VARCHAR(255) 
		 ,IN EmailAddr VARCHAR(255) 
		 ,IN StreetName VARCHAR(255) 
		 ,IN Password VARCHAR(255)  --  needs to be hashed  
         ,OUT confirmCode UUID
        )
     RETURNS UUID AS
     $Body$
     	
        BEGIN
        	INSERT INTO republic.t_RegUser(rFirstName,rLastName,rUserName,rEmailAddr,rStreetName,rPassword) -- 
            SELECT  FirstName,LastName,UserName,EmailAddr,StreetName,Password -- 
            RETURNING  pk_unUsr INTO confirmCode;
            RETURN;
           
        END
     $Body$ LANGUAGE plpgsql;
--create confirmed user
	CREATE OR REPLACE FUNCTION republic.sp_insertConfirmedUser(IN confirmCode UUID, OUT ID INT)
    RETURNS INTEGER AS
    $$
    BEGIN
    	INSERT INTO republic.t_Population(pFirstName ,pLastName ,pUserName ,pEmailAddr ,pStreetName ,pPassword)  --  needs to be hashed
        SELECT ru.rFirstName 
        		,ru.rLastName 
                ,ru.rUserName 
                ,ru.rEmailAddr 
                ,ru.rStreetName 
                ,ru.rPassword
        FROM republic.t_RegUser AS ru
        WHERE ru.pk_unUsr = confirmCode
        		AND ru.rStatus  = FALSE
        RETURNING userID INTO ID;
        
        UPDATE republic.t_RegUser 
        SET rStatus  = TRUE
        WHERE pk_unUsr = confirmCode;
        
        RETURN;
    END
    $$ LANGUAGE plpgsql;
    
-- ======================================================= END REG PROCESS ================================================================================
/*******************************************************************************END USER PROCESS***********************************************************************************/
 