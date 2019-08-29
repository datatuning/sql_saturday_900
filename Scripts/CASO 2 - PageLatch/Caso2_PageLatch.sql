
-- 
-- Lab Scripts - SQL Sat 900 - Vitória - Caso 2 (PageLatch)
-- @datatuning
-- https://blog.datatuning.com.br/
-- 

use SQLSat900
GO
--Criação da tabela
if exists(select 1 from sys.tables where name = 'Pedidos')
begin
	drop table dbo.Pedidos
end
create table dbo.Pedidos (
	idPedido		int identity(1,1)	not null
,	CodTransacao	uniqueidentifier	not null
,	DtPedido		datetime
,	ValorTotal		numeric(14,2)
	constraint PK_Pedidos PRIMARY KEY(idPedido)
)
go

/*************************************************************************
Procedure para inser��o de novos pedidos com valores rand�micos
*************************************************************************/
create or alter procedure dbo.spInserePedido
as
begin

	set nocount on;

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

end
go

-- Vamos testar o tempo de execu��ao da procedure
exec SQLSat900.dbo.spInserePedido

-- Conferindo o tempo de execu��o
exec master.dbo.spGetProcStats @ProcName = 'spInserePedido'

-- Limpando o cache (CUIDADO!!! NAO FACA ISSO EM PRODUCAO)
CHECKPOINT; 
DBCC DROPCLEANBUFFERS(); 
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

------------------------------------------------------------------------------------------------------------------------------------------
--                   |  TABELA COM PRIMARY KEY SEQUENCIAL   |     TABELA PARTICIONADA COM HASH     |     OPTIMIZE_FOR_SEQUENTIAL_KEY      |
-- -------------------------------------------------------- |------------------------------------- | ------------------------------------ |
--	Threads  Execs   |	AvgElapsedTimeMs  MaxElapsedTimeMs  |  AvgElapsedTimeMs  MaxElapsedTimeMs  |  AvgElapsedTimeMs  MaxElapsedTimeMs  |
--	-------  ------- |	----------------  ----------------- |  ----------------  ----------------- |  ----------------  ----------------- |
--	1	     1000	 |	2				  4				    |  6			  	 64			       |  5  		  		41 		          |
--	50       250	 |	47				  240			    |  14			  	 145		       |  28  			  	204				  |
--	256      250	 |	173				  595			    |  22			  	 187	           |  117  			  	582				  |
--	512      250	 |	482				  2057			    |  77				 446	           |  336  				3037			  |
------------------------------------------------------------------------------------------------------------------------------------------


exec master.dbo.spGetProcStats @ProcName = 'spInserePedido'

exec master.dbo.sp_requests

exec SQLSat900.dbo.spSnapshotWaitStats @Tempo = '00:00:30'

-- select wait_resource,count(0) as totalrequests from sys.dm_exec_requests r group by wait_resource order by count(0) desc


--=========== Como resolver?
-- https://support.microsoft.com/pt-br/help/4460004/how-to-resolve-last-page-insert-pagelatch-ex-contention-in-sql-server


/******************************************************************
Cria��o do campo Hash para ser o campo de particionamento da tabela
*******************************************************************/

exec sp_spaceused Pedidos

ALTER TABLE dbo.Pedidos ADD hashValue AS (CONVERT([INT], abs([idPedido])%(40))) PERSISTED NOT NULL

/*
select 1%40
select 2%40
select 3%40
select 40%40
select 41%40
select 50%40
select 80%40
*/

ALTER TABLE dbo.Pedidos DROP CONSTRAINT PK_Pedidos
GO
--DROP PARTITION SCHEME [PS_hashValue]
--GO
--DROP PARTITION FUNCTION [PF_hashValue]
--GO
CREATE PARTITION FUNCTION PF_hashValue (int)  
AS RANGE LEFT FOR VALUES (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39) ;  
GO  
CREATE PARTITION SCHEME PS_hashValue   
AS PARTITION PF_hashValue ALL TO([PRIMARY]) ;  
GO

ALTER TABLE dbo.Pedidos ADD CONSTRAINT PK_Pedidos PRIMARY KEY(idPedido,hashValue) ON PS_hashValue(hashValue)
go

/**************************************************************
Query para consultar a distribui��o dos registros nas parti��es
**************************************************************/
SELECT
 T.OBJECT_ID,
 T.NAME,
 P.PARTITION_ID,
 P.PARTITION_NUMBER,
 P.ROWS
FROM SYS.PARTITIONS P
INNER JOIN SYS.TABLES T ON P.OBJECT_ID = T.OBJECT_ID
WHERE P.PARTITION_ID IS NOT NULL
AND T.NAME = 'Pedidos'
AND P.index_id = 1
ORDER BY P.partition_number
GO





/**************************************************************
    OPTIMIZE_FOR_SEQUENTIAL_KEY - SQL Server 2019 CTP 3.1
**************************************************************/
-- https://techcommunity.microsoft.com/t5/SQL-Server/Behind-the-Scenes-on-OPTIMIZE-FOR-SEQUENTIAL-KEY/ba-p/806888


--Cria��o da tabela
if exists(select 1 from sys.tables where name = 'Pedidos')
begin
	drop table dbo.Pedidos
end
create table dbo.Pedidos (
	idPedido		int identity(1,1)	not null
,	CodTransacao	uniqueidentifier	not null
,	DtPedido		datetime
,	ValorTotal		numeric(14,2)
	constraint PK_Pedidos PRIMARY KEY(idPedido)
	WITH (OPTIMIZE_FOR_SEQUENTIAL_KEY = ON)
)
go

