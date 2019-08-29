
-- 
-- Lab Scripts - SQL Sat 900 - Vitória - Extra (InMemory)
-- @datatuning
-- https://blog.datatuning.com.br/
-- 



USE [master]
GO
ALTER DATABASE SQLSat900 ADD FILEGROUP [FG_InMemory] CONTAINS MEMORY_OPTIMIZED_DATA 
GO
 
ALTER DATABASE SQLSat900 ADD FILE ( NAME = [InMemory_File], FILENAME = 'E:\MSSQL\FG_InMemory\' ) TO FILEGROUP [FG_InMemory]
GO

USE SQLSat900
GO

sp_spaceused Pedidos

--Cria��o da tabela (Alterando estrutura para InMemory)
if exists(select 1 from sys.tables where name = 'Pedidos_InMemory')
begin
	drop table dbo.Pedidos_InMemory
end
create table dbo.Pedidos_InMemory (
	idPedido		int identity(1,1)	not null PRIMARY KEY NONCLUSTERED HASH WITH(BUCKET_COUNT = 20000000)
,	CodTransacao	uniqueidentifier	not null
,	DtPedido		datetime
,	ValorTotal		numeric(14,2)
)
WITH ( MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA );
go


/*************************************************************************
Procedure para inser��o de novos pedidos com valores rand�micos - InMemory
*************************************************************************/
create or alter procedure dbo.spInserePedido_InMemory
as
begin

	set nocount on

	insert into dbo.Pedidos_InMemory (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos_InMemory (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos_InMemory (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos_InMemory (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos_InMemory (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos_InMemory (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos_InMemory (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos_InMemory (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos_InMemory (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

	insert into dbo.Pedidos_InMemory (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 81778)

end
go

exec dbo.spInserePedido_InMemory


exec master.dbo.spGetProcStats @ProcName = 'spInserePedido_InMemory'


