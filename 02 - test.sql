	INSERT INTO republic.t_Population (pFirstName ,pLastName ,pUserName ,pEmailAddr ,pStreetName ,pPassword)
  	VALUES('TestFisrtName','TestLastName','testUserName','testEmail','testStreet','testPass');
   SELECT * FROM republic.t_Population;
   
  INSERT INTO republic.t_RegUser (rFirstName ,rLastName ,rUserName ,rEmailAddr ,rStreetName ,rPassword)
  VALUES('TestFisrtName','TestLastName','testUserName','testEmail','testStreet','testPass');
  SELECT * FROM republic.t_RegUser;
  
  
  DO $$
  declare 
  test1 integer = 5;
  test2 integer = 2;
  test3 integer;
  BEGIN
  	IF test1>test2 THEN 
    SELECT test1 into test3
    SELECT test3;
    ELSE raise notice 'test2';
    END IF ;
   
  END $$
  
  SELECT republic.sp_CheckEmailExists('testEmail');
  SELECT republic.sp_CheckUserNmExists('testUserName');
  SELECT republic.sp_CheckEmailExistsUnCf('testEmail');
  SELECT republic.sp_CheckUserNmExistsunCf('testUserName');
  
  SELECT republic.sp_CheckEmailExists('testEmail2');
  SELECT republic.sp_CheckUserNmExists('testUserName2');
  SELECT republic.sp_CheckEmailExistsUnCf('testEmail2');
  SELECT republic.sp_CheckUserNmExistsunCf('testUserName2');
  
  SELECT republic.sp_insertUnconfirmedUser('TestFisrtName2','TestLastName2','testUserName2','testEmail2','testStreet2','testPass2');
   --SELECT * FROM republic.t_RegUser;
 --  TRUNCATE TABLE republic.t_RegUser;
  --DELETE FROM republic.t_RegUser WHERE pk_unusr IN('9acc17eb-86dd-4533-9bb9-f449cc5d7cef','fc8a098a-ba74-46c7-9e4e-8feb844ce1a9')

TRUNCATE TABLE republic.t_Population;
SELECT * FROM republic.t_Population;
SELECT republic.sp_insertConfirmedUser ('da23713e-327f-4eab-96d8-40e222e586ce')