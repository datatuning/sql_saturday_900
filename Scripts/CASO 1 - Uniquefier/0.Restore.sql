-- 
-- ERROR 666
-- @datatuning
-- https://blog.datatuning.com.br/
-- 
USE [master]
GO
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'dbUniquifier')
BEGIN
	ALTER DATABASE dbUniquifier SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE dbUniquifier
END
GO
/*Modificar o local de onde está o arquivo de backup*/
RESTORE DATABASE [dbUniquifier] FROM  DISK = N'..\Backup\dbUniquifier.bak' WITH  FILE = 1
,  MOVE N'dbMeetupDT' TO N'E:\SQLDADOS01\dbUniquifier.mdf'
,  MOVE N'dbMeetupDT_log' TO N'E:\SQLLOG01\dbUniqueifier.ldf',  NOUNLOAD,  STATS = 5
GO


