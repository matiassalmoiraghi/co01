--Prop�sito. Transacciones contables que incluye cuentas puc y nits
--24/6/10 JCF Creaci�n

------------------------------------------------------------------------------

IF OBJECT_ID ('dbo.f_obtieneDatosTerceros') IS NOT NULL
   DROP function dbo.f_obtieneDatosTerceros
GO

create function dbo.f_obtieneDatosTerceros (@p_series smallint, @p_TERCTYPE smallint, @p_CUSTVNDR varchar(15))
returns table
as 
--Prop�sito. Obtiene el c�digo de impuesto de clientes o proveedores. 
--			En la localizaci�n andina es posible registrar diferentes nit por cada cuenta de un asiento contable desde el financiero, compras o ventas.
--Requisito. @p_CUSTVNDR debe indicar el c�digo de cliente o proveedor
--25/6/10 JCF Creaci�n
--30/6/10 JCF Obtiene nit de tablas de localizaci�n
--09/4/13 jcf Agrega direcciones y optimiza consulta. Ya no utiliza par�metros p_series, p_terctype.
--
return(
	select top 1 dt.TXRGNNUM, dt.ADDRESS1, dt.ADDRESS2, dt.ADDRESS3, dt.CITY, dt.[STATE], dt.ZIPCODE, dt.COUNTRY 
	from (
		select np.nsaIFNit TXRGNNUM, ms.ADDRESS1, ms.ADDRESS2, ms.ADDRESS3, ms.CITY, ms.[STATE], ms.ZIPCODE, ms.COUNTRY 
		from nsaIF01666	np			--nit proveedores
			right join PM00200 ms
			on ms.vendorid = np.vendorid
		where ms.VENDORID = @p_CUSTVNDR
		--and (@p_series = 4			--compras
		--	or (@p_series = 2		--financiero
		--	and @p_TERCTYPE = 2))	--proveedores
			
		union all
		
		select nc.nsaIFNit TXRGNNUM, ms.ADDRESS1, ms.ADDRESS2, ms.ADDRESS3, ms.CITY, ms.[STATE], ms.ZIP ZIPCODE, ms.COUNTRY
		from nsaIF02666	nc			--nit clientes
			right join RM00101 ms
			on ms.custnmbr = nc.custnmbr
		where ms.CUSTNMBR = @p_CUSTVNDR
		--and (@p_series = 3			--ventas
		--	or (@p_series = 2		--financiero
		--	and @p_TERCTYPE = 1))	--clientes
		) dt
)
go
IF (@@Error = 0) PRINT 'Creaci�n exitosa de: f_obtieneDatosTerceros'
ELSE PRINT 'Error en la creaci�n de: f_obtieneDatosTerceros'
GO
---------------------------------------------------------------------------------------------------------------
--Prop�sito. Transacciones contables que incluye cuentas puc y nit de localizaci�n andina
--24/06/10 JCF Creaci�n
--21/07/10 jcf Agrega puc_y_desc
--24/11/10 jcf Agrega asientos hist�ricos
--07/12/10 jcf Agrega campo rctrxseq
--09/4/13 jcf Agrega direcciones y optimiza consulta. Ya no utiliza par�metros p_series, p_terctype.
--
IF (OBJECT_ID ('dbo.vwLocAndinaGLLibroDiario', 'V') IS NULL)
   exec('create view dbo.vwLocAndinaGLLibroDiario as SELECT 1 as t');
go
alter view dbo.vwLocAndinaGLLibroDiario as
SELECT ta.origen,ta.jrnentry, ta.rctrxseq, ta.refrence,ta.trxdate,ta.OPENYEAR, ta.mes, ta.bachnumb,ta.dscriptn,
	ta.curncyid,ta.debitamt,ta.crdtamnt,ta.ORDBTAMT,ta.ORCRDAMT,ta.xchgrate,ta.exchdate,
	ta.sqncline,ta.ACTNUMST,ta.actdescr,ta.actindx,ta.ACCTTYPE,
    ta.ACTNUMBR_1, ta.ACTNUMBR_2, ta.ACTNUMBR_3, ta.USRDEFS1,
	ta.ORGNATYP,ta.ORTRXTYP,ta.ORCTRNUM,ta.ORDOCNUM,ta.ORMSTRID,ta.ORMSTRNM,ta.ORTRXSRC,
	ta.SOURCDOC,ta.trxsorce,ta.series,
	isnull(dt.TXRGNNUM, ta.ORMSTRID) registroImpuesto,			--si no existe nit registrado en tablas de localizaci�n, muestra el id de maestro
	isnull(dt.TXRGNNUM, '') TXRGNNUM,
	dt.ADDRESS1, dt.ADDRESS2, dt.ADDRESS3, dt.CITY, dt.[STATE], dt.ZIPCODE, dt.COUNTRY, 
	isnull(ep.nsa_Codigo, '') nsa_Codigo, isnull(ep.nsa_Descripcion_Codigo, '') nsa_Descripcion_Codigo, 
	rtrim(isnull(ep.nsa_Codigo, '')) +' '+ rtrim(isnull(ep.nsa_Descripcion_Codigo, '')) puc_y_desc,
	isnull(ep.nsa_Nivel_Cuenta, '') nsa_Nivel_Cuenta, isnull(ep.nsa_Descripcion_Nivel, 'nsa_Descripcion_Nivel') nsa_Descripcion_Nivel,
	ta.fecha
FROM dbo.vwFINAsientosTAH ta		--trx gp en trabajo, abiertas e hist�rico
left join nsaPUC_GL00100	rp		--Loc And. relaci�n entre PUC y plan de cuentas gp
	on rp.ACTINDX = ta.ACTINDX 
left join nsaPUC_GL10000 ep			--Loc And. estructura PUC
	on ep.nsa_Codigo = rp.PUCCODE
left join IF10001 tr				--Loc And. IF_GL_TRX_WORK_LINE Informaci�n fiscal terceros
	on tr.JRNENTRY = ta.jrnentry
	and tr.SQNCLINE = ta.sqncline
outer apply dbo.f_obtieneDatosTerceros (ta.series, isnull(tr.TERCTYPE, 0), ISNULL(tr.CUSTVNDR, ta.ORMSTRID)) dt

go
---------------------------------------------------------------------------------------------------------------

grant select on dbo.vwLocAndinaGLLibroDiario to dyngrp
go

IF (@@Error = 0) PRINT 'Creaci�n exitosa de: vwLocAndinaGLLibroDiario'
ELSE PRINT 'Error en la creaci�n de: vwLocAndinaGLLibroDiario'
GO

------------------------------------------------------------------------------
--PRUEBAS
--select TXRGNNUM, count(*)
--from vwLocAndinaGLLibroDiario
--group by TXRGNNUM
--order by 1

--select *
--from dbo.vwLocAndinaGLLibroDiario
--where origen = 'Abrir'
--and OPENYEAR = 2010
--AND nsa_Codigo = '41559511'

--select puccode, *
--from dbo.vwLocAndinaGLSaldosPucYTerceros 
--where a�oAbierto = 2010
--and puccode = '41559511'
----and mes = 'Enero'
