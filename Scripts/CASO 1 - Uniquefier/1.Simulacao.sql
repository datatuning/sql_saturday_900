-- 
-- ERROR 666
-- @datatuning
-- https://blog.datatuning.com.br/
-- 
USE dbUniquifier
GO
exec sp_help UniqTable
GO
EXEC sp_spaceused UniqTable
GO
SELECT * FROM dbo.UniqTable
GO
INSERT INTO UniqTable(Id,Id2)
SELECT 1,2 FROM GetNums(100000)
GO
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
GO
SELECT TOP 10 *
, sys.fn_physlocformatter(%%PHYSLOC%%) AS PhysLocation
,'DBCC PAGE('''+DB_NAME()+''',1,'+SUBSTRING(sys.fn_physlocformatter(%%PHYSLOC%%),4,CHARINDEX(':',sys.fn_physlocformatter(%%PHYSLOC%%),4)-4)+',3)' as DBCCPAGE
FROM dbo.UniqTable 
ORDER BY Id DESC, Id2 DESC
GO
DBCC TRACEON(3604)
DBCC PAGE('dbUniquifier',1,512,3)
GO

/***************************************
************Troubleshooting 1***********
****************************************/
ALTER INDEX idx_UniqTable ON UniqTable REBUILD
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
GO
ALTER INDEX idx_UniqTable ON UniqTable REBUILD PARTITION = ALL
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
GO
ALTER INDEX idx_UniqTable ON UniqTable REBUILD WITH(ONLINE=ON)
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
GO
ALTER INDEX idx_UniqTable ON UniqTable REBUILD PARTITION = ALL WITH(ONLINE=ON)
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
GO
ALTER INDEX ALL ON UniqTable REBUILD 
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
GO
ALTER INDEX ALL ON UniqTable REBUILD PARTITION = ALL 
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
GO
ALTER INDEX ALL ON UniqTable REBUILD PARTITION = ALL WITH(ONLINE=ON)
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
GO
/***************************************
************Troubleshooting 2***********
****************************************/
DROP INDEX idx_UniqTable ON UniqTable
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
GO
CREATE CLUSTERED INDEX IDX_UniqTable ON UniqTable(Id,Id2)
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
GO
SELECT top 10 *
, sys.fn_physlocformatter(%%PHYSLOC%%) AS PhysLocation
,'DBCC PAGE('''+DB_NAME()+''',1,'+SUBSTRING(sys.fn_physlocformatter(%%PHYSLOC%%),4,CHARINDEX(':',sys.fn_physlocformatter(%%PHYSLOC%%),4)-4)+',3)' as DBCCPAGE
FROM dbo.UniqTable 
ORDER BY Id DESC, Id2 DESC
GO
DBCC PAGE('dbUniquifier',1,24951,3)

