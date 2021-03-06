IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'dbo'
     AND SPECIFIC_NAME = N'spColBaseSaldosARAgrupadoXCliente' 
)
   DROP PROCEDURE dbo.spColBaseSaldosARAgrupadoXCliente
GO

--Propósito. Obtiene saldos AR
--07/10/19 jcf Creación
--
CREATE PROCEDURE dbo.spColBaseSaldosARAgrupadoXCliente
 @I_dAgingDate datetime     = NULL,   
 @I_cStartCustomerNumber char(15)  = NULL,   @I_cEndCustomerNumber char(15)   = NULL,   @I_cStartCustomerName  char(65)  = NULL,   @I_cEndCustomerName  char(65)   = NULL,  
 @I_cStartClassID  char(15)    = NULL,   @I_cEndClassID char(15)    = NULL,   @I_cStartSalesPersonID char(15)  = NULL,   @I_cEndSalesPersonID char(15)   = NULL,  
 @I_cStartSalesTerritory char(15)  = NULL,   @I_cEndSalesTerritory char(15)   = NULL,   @I_cStartShortName char(15)   = NULL,   @I_cEndShortName char(15)    = NULL,   
 @I_cStartState char(5)     = NULL,   @I_cEndState char(5)     = NULL,   @I_cStartZipCode char(11)    = NULL,   @I_cEndZipCode char(11)    = NULL,   
 @I_cStartPhoneNumber char(21)   = NULL,   @I_cEndPhoneNumber char(21)   = NULL,   @I_cStartUserDefined char(15)   = NULL,   @I_cEndUserDefined char(15)   = NULL,  
 @I_tUsingDocumentDate tinyint   = NULL,   @I_dStartDate datetime     = NULL,   @I_dEndDate datetime     = NULL,   
 @I_sIncludeBalanceTypes smallint  = NULL,   @I_tExcludeNoActivity tinyint   = NULL,   @I_tExcludeMultiCurrency tinyint  = NULL,   @I_tExcludeZeroBalanceCustomer tinyint = NULL,  
 @I_tExcludeFullyPaidTrxs tinyint  = NULL,   @I_tExcludeCreditBalance tinyint  = NULL,   @I_tExcludeUnpostedAppldCrDocs tinyint = NULL,   
 @I_tConsolidateNAActivity tinyint  = NULL  
 as   

--declare @I_dAgingDate datetime     = '2019.12.31',   
-- @I_cStartCustomerNumber char(15)  = '',   @I_cEndCustomerNumber char(15)   = 'ÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞ',   @I_cStartCustomerName  char(65)  = '',   @I_cEndCustomerName  char(65)   = 'ÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞ',  
-- @I_cStartClassID  char(15)    = '',   @I_cEndClassID char(15)    = 'ÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞ',   @I_cStartSalesPersonID char(15)  = '',   @I_cEndSalesPersonID char(15)   = 'ÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞ',  
-- @I_cStartSalesTerritory char(15)  = '',   @I_cEndSalesTerritory char(15)   = 'ÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞ',   @I_cStartShortName char(15)   = '',   @I_cEndShortName char(15)    = 'ÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞ',   
-- @I_cStartState char(5)     = '',   @I_cEndState char(5)     = 'ÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞ',   @I_cStartZipCode char(11)    = '',   @I_cEndZipCode char(11)    = 'ÞÞÞÞÞÞÞÞÞÞÞ',   
-- @I_cStartPhoneNumber char(21)   = '',   @I_cEndPhoneNumber char(21)   = 'ÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞ',   @I_cStartUserDefined char(15)   = '',   @I_cEndUserDefined char(15)   = 'ÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞ',  
-- @I_tUsingDocumentDate tinyint   = 1,   @I_dStartDate datetime     = '1900.01.01',   @I_dEndDate datetime     = '2019.12.31',   
-- @I_sIncludeBalanceTypes smallint  = 0,   @I_tExcludeNoActivity tinyint   = 1,   @I_tExcludeMultiCurrency tinyint  = 1,   @I_tExcludeZeroBalanceCustomer tinyint = 1,  
-- @I_tExcludeFullyPaidTrxs tinyint  = 1,   @I_tExcludeCreditBalance tinyint  = 0,   @I_tExcludeUnpostedAppldCrDocs tinyint = 1,   
-- @I_tConsolidateNAActivity tinyint  = 0  
 
	 
DECLARE @FUNLCURR char(12)
CREATE TABLE #RMHATBAP([APFRDCNM] [char](21) NOT NULL,
                       [APFRDCTY] [smallint] NOT NULL,
                       [FROMCURR] [char](15) NOT NULL,
                       [APTODCNM] [char](21) NOT NULL,
                       [APTODCTY] [smallint] NOT NULL,
                       [APPTOAMT] [numeric](19, 5) NOT NULL,
                       [CURNCYID] [char](15) NOT NULL,
                       [DATE1] [datetime] NOT NULL,
                       [POSTED] [tinyint] NOT NULL,
                       [DISTKNAM] [numeric](19, 5) NOT NULL,
                       [WROFAMNT] [numeric](19, 5) NOT NULL,
                       [PPSAMDED] [numeric](19, 5) NOT NULL,
                       [GSTDSAMT] [numeric](19, 5) NOT NULL,
                       [CURRNIDX] [smallint] NOT NULL,
                       [XCHGRATE] [numeric](19, 7) NOT NULL,
                       [RLGANLOS] [numeric](19, 5) NOT NULL,
                       [ORAPTOAM] [numeric](19, 5) NOT NULL,
                       [ORDISTKN] [numeric](19, 5) NOT NULL,
                       [ORWROFAM] [numeric](19, 5) NOT NULL,
                       [DENXRATE] [numeric](19, 7) NOT NULL,
                       [MCTRXSTT] [smallint] NOT NULL,
                       [DEX_ROW_ID] [int] IDENTITY(1, 1) NOT NULL)
CREATE UNIQUE NONCLUSTERED INDEX [PK#RMHATBAP] ON #RMHATBAP ([APFRDCNM] ASC, [APFRDCTY] ASC, [APTODCNM] ASC, [APTODCTY] ASC)
CREATE UNIQUE NONCLUSTERED INDEX [AK1#RMHATBAP] ON #RMHATBAP ([APTODCTY] ASC, [APTODCNM] ASC, [APFRDCTY] ASC, [APFRDCNM] ASC, [DEX_ROW_ID] ASC)
CREATE TABLE #RMHATBDO([CUSTNMBR] [char](15) NOT NULL,
                       [CHCUMNUM] [char](15) NOT NULL,
                       [DOCNUMBR] [char](21) NOT NULL,
                       [RMDTYPAL] [smallint] NOT NULL,
                       [DSCRIPTN] [char](31) NOT NULL,
                       [CURNCYID] [char](15) NOT NULL,
                       [ORTRXAMT] [numeric](19, 5) NOT NULL,
                       [CURTRXAM] [numeric](19, 5) NOT NULL,
                       [AGNGBUKT] [smallint] NOT NULL,
                       [CASHAMNT] [numeric](19, 5) NOT NULL,
                       [COMDLRAM] [numeric](19, 5) NOT NULL,
                       [SLSAMNT] [numeric](19, 5) NOT NULL,
                       [COSTAMNT] [numeric](19, 5) NOT NULL,
                       [FRTAMNT] [numeric](19, 5) NOT NULL,
                       [MISCAMNT] [numeric](19, 5) NOT NULL,
                       [TAXAMNT] [numeric](19, 5) NOT NULL,
                       [DISAVAMT] [numeric](19, 5) NOT NULL,
                       [DISTKNAM] [numeric](19, 5) NOT NULL,
                       [WROFAMNT] [numeric](19, 5) NOT NULL,
                       [TRXDSCRN] [char](31) NOT NULL,
                       [DOCABREV] [char](3) NOT NULL,
                       [CHEKNMBR] [char](21) NOT NULL,
                       [DOCDATE] [datetime] NOT NULL,
                       [DUEDATE] [datetime] NOT NULL,
                       [GLPOSTDT] [datetime] NOT NULL,
                       [DISCDATE] [datetime] NOT NULL,
                       [POSTDATE] [datetime] NOT NULL,
                       [DINVPDOF] [datetime] NOT NULL,
                       [CURRNIDX] [smallint] NOT NULL,
                       [XCHGRATE] [numeric](19, 7) NOT NULL,
                       [ORCASAMT] [numeric](19, 5) NOT NULL,
                       [ORSLSAMT] [numeric](19, 5) NOT NULL,
                       [ORCSTAMT] [numeric](19, 5) NOT NULL,
                       [ORDAVAMT] [numeric](19, 5) NOT NULL,
                       [ORFRTAMT] [numeric](19, 5) NOT NULL,
                       [ORMISCAMT] [numeric](19, 5) NOT NULL,
                       [ORTAXAMT] [numeric](19, 5) NOT NULL,
                       [ORCTRXAM] [numeric](19, 5) NOT NULL,
                       [ORORGTRX] [numeric](19, 5) NOT NULL,
                       [ORDISTKN] [numeric](19, 5) NOT NULL,
                       [ORWROFAM] [numeric](19, 5) NOT NULL,
                       [DENXRATE] [numeric](19, 7) NOT NULL,
                       [MCTRXSTT] [smallint] NOT NULL,
                       [Aging_Period_Amount] [numeric](19, 5) NOT NULL,
                       [DEX_ROW_ID] [int] IDENTITY(1, 1) NOT NULL)
CREATE UNIQUE NONCLUSTERED INDEX [PK#RMHATBDO] ON #RMHATBDO ([RMDTYPAL] ASC, [DOCNUMBR] ASC)
CREATE UNIQUE NONCLUSTERED INDEX [AK1#RMHATBDO] ON #RMHATBDO ([CUSTNMBR] ASC, [CURNCYID] ASC, [DSCRIPTN] ASC, [DEX_ROW_ID] ASC)
CREATE UNIQUE NONCLUSTERED INDEX [AK2#RMHATBDO] ON #RMHATBDO ([CURNCYID] ASC, [DSCRIPTN] ASC, [DEX_ROW_ID] ASC)
CREATE TABLE #RMHATBCU([CUSTNMBR] [char](15) NOT NULL,
                       [DSCRIPTN] [char](31) NOT NULL,
                       [AGNGDATE] [datetime] NOT NULL,
                       [DEX_ROW_ID] [int] IDENTITY(1, 1) NOT NULL)
CREATE UNIQUE NONCLUSTERED INDEX [PK#RMHATBCU] ON #RMHATBCU ([DSCRIPTN] ASC, [CUSTNMBR] ASC)
SELECT @FUNLCURR = rtrim(FUNLCURR)
FROM MC40000 

IF @I_cEndCustomerNumber = '' 
BEGIN
SET @I_cEndCustomerNumber = 'þþþþþþþþþþþþþþþ' END  IF @I_cEndCustomerName = '' BEGIN
SET @I_cEndCustomerName = 'þþþþþþþþþþþþþþþ' END  IF @I_cEndClassID = '' BEGIN
SET @I_cEndClassID = 'þþþþþþþþþþþþþþþ' END  IF @I_cEndSalesPersonID = '' BEGIN
SET @I_cEndSalesPersonID = 'þþþþþþþþþþþþþþþ' END  IF @I_cEndSalesTerritory = '' BEGIN
SET @I_cEndSalesTerritory = 'þþþþþþþþþþþþþþþ' END  IF @I_cEndShortName = '' BEGIN
SET @I_cEndShortName = 'þþþþþþþþþþþþþþþ' END  IF @I_cEndState = '' BEGIN
SET @I_cEndState = 'þþþþþþþþþþþþþþþ' END  IF @I_cEndZipCode = '' BEGIN
SET @I_cEndZipCode = 'þþþþþþþþþþþþþþþ' END  IF @I_cEndPhoneNumber = '' BEGIN
SET @I_cEndPhoneNumber = 'þþþþþþþþþþþþþþþ' END  

IF @I_cEndUserDefined = '' BEGIN
SET @I_cEndUserDefined = 'þþþþþþþþþþþþþþþ' END 

EXEC [rmHistoricalAgedTrialBalance] '#RMHATBCU',
                                                                                   '#RMHATBDO',
                                                                                   '#RMHATBAP',
                                                                                   '',
                                                                                   @I_dAgingDate,
                                                                                   @I_cStartCustomerNumber,
                                                                                   @I_cEndCustomerNumber,
                                                                                   @I_cStartCustomerName,
                                                                                   @I_cEndCustomerName,
                                                                                   @I_cStartClassID,
                                                                                   @I_cEndClassID,
                                                                                   @I_cStartSalesPersonID,
                                                                                   @I_cEndSalesPersonID,
                                                                                   @I_cStartSalesTerritory,
                                                                                   @I_cEndSalesTerritory,
                                                                                   @I_cStartShortName,
                                                                                   @I_cEndShortName,
                                                                                   @I_cStartState,
                                                                                   @I_cEndState,
                                                                                   @I_cStartZipCode,
                                                                                   @I_cEndZipCode,
                                                                                   @I_cStartPhoneNumber,
                                                                                   @I_cEndPhoneNumber,
                                                                                   @I_cStartUserDefined,
                                                                                   @I_cEndUserDefined,
                                                                                   1,
                                                                                   0,
                                                                                   @I_tUsingDocumentDate,
                                                                                   @I_dStartDate,
                                                                                   @I_dEndDate,
                                                                                   @I_sIncludeBalanceTypes,
                                                                                   @I_tExcludeNoActivity,
                                                                                   @I_tExcludeMultiCurrency,
                                                                                   @I_tExcludeZeroBalanceCustomer,
                                                                                   @I_tExcludeFullyPaidTrxs,
                                                                                   @I_tExcludeCreditBalance,
                                                                                   @I_tExcludeUnpostedAppldCrDocs,
                                                                                   @I_tConsolidateNAActivity,
                                                                                   @FUNLCURR,
                                                                                   0,
                                                                                   0,
                                                                                   1.0000,
                                                                                   0,
                                                                                   2,
                                                                                   0
SELECT RMHATB.* INTO #RMHATB
FROM
  (SELECT CASE
              WHEN D.RMDTYPAL <> 2 THEN isnull(A.APPTOAMT, 0)
              ELSE 0
          END AS APPLY_AMOUNT,
          CASE
              WHEN D.RMDTYPAL <> 2 THEN isnull(D.Aging_Period_Amount, 0)
              ELSE 0
          END AS AGING_AMOUNT,
          isnull([CU].[CUSTNMBR], '') AS [CUSTNMBR],
          isnull([C].[CUSTNAME], '') AS [CUSTNAME],
          isnull([C].[CUSTCLAS], '') AS [CUSTCLAS],
          isnull([C].[ZIP], '') AS [ZIP],
          isnull([C].[STATE], '') AS [STATE],
		  isnull([C].address1, '') ADDRESS1,
		  datosc.cityCode,
		  datosc.dptoCode,
		  isnull([C].[COUNTRY], '') country,
		  isnull(datosc.nsaif_type_nit, '') nsaif_type_nit,
          isnull(datosc.nsaIfNitSinDV, '') nsaIfNitSinDV,
		  isnull(datosc.digitoVerificador, '') digitoVerificador,
		  isnull(datosc.Fname, '') Fname,
		  isnull(datosc.Oname, '') Oname,
		  isnull(datosc.Fsurname, '') Fsurname,
		  isnull(datosc.Ssurname, '') Ssurname,
          isnull([CU].[DSCRIPTN], '') AS [CUDSCRIPTN],
          isnull([CU].[AGNGDATE], '1900-01-01') AS [AGNGDATE],
          isnull([D].[CHCUMNUM], '') AS [CHCUMNUM],
          isnull([D].[DOCNUMBR], '') AS [DOCNUMBR],
          isnull([D].[RMDTYPAL], 0) AS [RMDTYPAL],
          isnull([D].[DSCRIPTN], '') AS [DSCRIPTN],
          isnull([D].[CURNCYID], '') AS [DCURNCYID],
          isnull([D].[ORTRXAMT], 0) AS [ORTRXAMT],
          isnull([D].[CURTRXAM], 0) AS [CURTRXAM],
          isnull([D].[AGNGBUKT], 0) AS [AGNGBUKT],
          isnull([D].[CASHAMNT], 0) AS [CASHAMNT],
          isnull([D].[COMDLRAM], 0) AS [COMDLRAM],
          isnull([D].[SLSAMNT], 0) AS [SLSAMNT],
          isnull([D].[COSTAMNT], 0) AS [COSTAMNT],
          isnull([D].[FRTAMNT], 0) AS [FRTAMNT],
          isnull([D].[MISCAMNT], 0) AS [MISCAMNT],
          isnull([D].[TAXAMNT], 0) AS [TAXAMNT],
          isnull([D].[DISAVAMT], 0) AS [DISAVAMT],
          isnull([D].[DISTKNAM], 0) AS [DDISTKNAM],
          isnull([D].[WROFAMNT], 0) AS [DWROFAMNT],
          isnull([D].[TRXDSCRN], '') AS [TRXDSCRN],
          isnull([D].[DOCABREV], '') AS [DOCABREV],
          isnull([D].[CHEKNMBR], '') AS [CHEKNMBR],
          isnull([D].[DOCDATE], '1900-01-01') AS [DOCDATE],
          isnull([D].[DUEDATE], '1900-01-01') AS [DUEDATE],
          isnull([D].[GLPOSTDT], '1900-01-01') AS [GLPOSTDT],
          isnull([D].[DISCDATE], '1900-01-01') AS [DISCDATE],
          isnull([D].[POSTDATE], '1900-01-01') AS [POSTDATE],
          isnull([D].[DINVPDOF], '1900-01-01') AS [DINVPDOF],
          isnull([D].[CURRNIDX], 0) AS [DCURRNIDX],
          isnull([D].[XCHGRATE], 0) AS [DXCHGRATE],
          isnull([D].[ORCASAMT], 0) AS [ORCASAMT],
          isnull([D].[ORSLSAMT], 0) AS [ORSLSAMT],
          isnull([D].[ORCSTAMT], 0) AS [ORCSTAMT],
          isnull([D].[ORDAVAMT], 0) AS [ORDAVAMT],
          isnull([D].[ORFRTAMT], 0) AS [ORFRTAMT],
          isnull([D].[ORMISCAMT], 0) AS [ORMISCAMT],
          isnull([D].[ORTAXAMT], 0) AS [ORTAXAMT],
          isnull([D].[ORCTRXAM], 0) AS [ORCTRXAM],
          isnull([D].[ORORGTRX], 0) AS [ORORGTRX],
          isnull([D].[ORDISTKN], 0) AS [DORDISTKN],
          isnull([D].[ORWROFAM], 0) AS [DORWROFAM],
          isnull([D].[DENXRATE], 0) AS [DDENXRATE],
          isnull([D].[MCTRXSTT], 0) AS [DMCTRXSTT],
          isnull([D].[Aging_Period_Amount], 0) AS [Aging_Period_Amount],
          isnull([A].[APFRDCNM], '') AS [APFRDCNM],
          isnull([A].[APFRDCTY], 0) AS [APFRDCTY],
          isnull([A].[FROMCURR], '') AS [FROMCURR],
          isnull([A].[APTODCNM], '') AS [APTODCNM],
          isnull([A].[APTODCTY], 0) AS [APTODCTY],
          isnull([A].[APPTOAMT], 0) AS [APPTOAMT],
          isnull([A].[CURNCYID], '') AS [ACURNCYID],
          isnull([A].[DATE1], '1900-01-01') AS [DATE1],
          isnull([A].[POSTED], 0) AS [POSTED],
          isnull([A].[DISTKNAM], 0) AS [ADISTKNAM],
          isnull([A].[WROFAMNT], 0) AS [AWROFAMNT],
          isnull([A].[PPSAMDED], 0) AS [PPSAMDED],
          isnull([A].[GSTDSAMT], 0) AS [GSTDSAMT],
          isnull([A].[CURRNIDX], 0) AS [ACURRNIDX],
          isnull([A].[XCHGRATE], 0) AS [AXCHGRATE],
          isnull([A].[RLGANLOS], 0) AS [RLGANLOS],
          isnull([A].[ORAPTOAM], 0) AS [ORAPTOAM],
          isnull([A].[ORDISTKN], 0) AS [AORDISTKN],
          isnull([A].[ORWROFAM], 0) AS [AORWROFAM],
          isnull([A].[DENXRATE], 0) AS [ADENXRATE],
          isnull([A].[MCTRXSTT], 0) AS [AMCTRXSTT]
   FROM #RMHATBCU CU
   LEFT JOIN #RMHATBDO D ON CU.CUSTNMBR = D.CUSTNMBR
   LEFT JOIN #RMHATBAP A ON D.RMDTYPAL = A.APTODCTY
   AND D.DOCNUMBR = A.APTODCNM
   LEFT JOIN RM00101 C ON CU.CUSTNMBR = C.CUSTNMBR
   outer apply dbo.fnLocColombiaDatosCliente (CU.CUSTNMBR, C.CITY, C.[STATE]) datosc
	) RMHATB 
   
   WHILE
	  (SELECT COUNT(*)
	   FROM
		 (SELECT CUSTNMBR,
				 DOCNUMBR,
				 RMDTYPAL,
				 ORTRXAMT
		  FROM #RMHATB
		  WHERE ORTRXAMT<>0
		  GROUP BY CUSTNMBR,
				   DOCNUMBR,
				   RMDTYPAL,
				   ORTRXAMT
		  HAVING COUNT(*)>1) A)<>0 
	BEGIN
		UPDATE #RMHATB
		SET AGING_AMOUNT=0,
			ORTRXAMT=0,
			CURTRXAM=0,
			Aging_Period_Amount=0
		FROM #RMHATB
		JOIN
		  (SELECT CUSTNMBR,
				  DOCNUMBR,
				  RMDTYPAL,
				  MAX(APFRDCNM) AS APFRDCNM
		   FROM #RMHATB
		   GROUP BY CUSTNMBR,
					DOCNUMBR,
					RMDTYPAL,
					ORTRXAMT
		   HAVING COUNT(*)>1) PARTIALLY_APPLIED ON PARTIALLY_APPLIED.CUSTNMBR = #RMHATB.CUSTNMBR
		AND PARTIALLY_APPLIED.DOCNUMBR = #RMHATB.DOCNUMBR
		AND PARTIALLY_APPLIED.RMDTYPAL = #RMHATB.RMDTYPAL
		AND PARTIALLY_APPLIED.APFRDCNM = #RMHATB.APFRDCNM 
	END

select 	nsaif_type_nit [Tipo de Documento],
          nsaIfNitSinDV [Número Identificación],
		  digitoVerificador [DV],
		  Fsurname [Primer apellido],
		  Ssurname [Segundo apellido],  
		  Fname [Primer nombre],
		  Oname [Otros nombres],
          [CUSTNAME] [Razón Social],
		  ADDRESS1 [Dirección],
		  dptoCode [Código dpto.],
		  cityCode [Código mcp.],
		  country [País],
		sum(curtrxam) Saldo
from #RMHATB
group by 
          [CUSTNAME],
		  ADDRESS1,
		  cityCode,
		  dptoCode,
		  country,
		  nsaif_type_nit,
          nsaIfNitSinDV,
		  digitoVerificador,
		  Fname,
		  Oname,
		  Fsurname,
		  Ssurname

GO

IF (@@Error = 0) PRINT 'Creación exitosa de: spColBaseSaldosARAgrupadoXCliente'
ELSE PRINT 'Error en la creación de: spColBaseSaldosARAgrupadoXCliente'
GO


