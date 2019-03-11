ALTER procedure [dbo].[ProcessAllOpenYears] ( @IN_Msg		char(10) )as begin  	
DECLARE @M1 		int 	
DECLARE @M2 		int 	
DECLARE @TRXDATE 	datetime  	
DECLARE @CRDT		VARCHAR(12) 	DECLARE @DBT		VARCHAR(12) 	DECLARE @SI		VARCHAR(12) 	DECLARE @SF		VARCHAR(12) 	DECLARE @OPENYEAR	INT 	DECLARE @OPENYEAR1	INT 	DECLARE	@ORMSTRID 	VARCHAR(30) 	DECLARE @COUNT	 	INT 	DECLARE @sCOLS		VARCHAR(8000) 	DECLARE @C1		INT 	DECLARE @NIT		VARCHAR(16) 	DECLARE	@NITTYPE	VARCHAR(5) 	DECLARE	@SQL		VARCHAR(8000) 	DECLARE @sSQL		VARCHAR(3000) 	DECLARE @CName		char(15) 	DECLARE	@COLS		VARCHAR(8000) 	DECLARE	@SQL1		VARCHAR(3000) 	DECLARE @SI1		VARCHAR(3000) 	DECLARE @SI2		VARCHAR(3000) 	DECLARE @SF1		VARCHAR(3000) 	DECLARE @COLS1		VARCHAR(8000)  	SET @SQL1 = '' 	SET @TRXDATE = ''  	SET @CRDT = 'nsaIF_SCred_' 	SET @DBT= 'nsaIF_SDeb_' 	SET @SI= 'nsaIF_SI_' 	SET @SF= 'nsaIF_SF_' 	SET @COUNT = 0 	SET @C1 = 0 	SET @NIT = '' 	SET @NITTYPE = '' 	SET @SQL ='' 	SET @sSQL = ''   	/*ACTNUMBER BEGIN*/ 	DECLARE c CURSOR FAST_FORWARD FOR   	SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='GL00100' AND COLUMN_NAME LIKE 'ACTNUMBR%'  	OPEN c  	FETCH NEXT FROM c INTO @CName  	
WHILE @@FETCH_STATUS=0  	BEGIN  		SET @sSQL = @sSQL + ltrim(rtrim(@CName))  		
IF EXISTS (( SELECT * FROM SY00300 WHERE SGMTNUMB = substring(@CName, CHARINDEX('_',@CName) + 1,len(@CName))))  		BEGIN	  			SET @SQL = @SQL+ ltrim(rtrim(@CName))  		END	  		SET @SQL1 = @SQL1 +' N1.'+ltrim(rtrim(@CName))  		FETCH NEXT FROM c INTO @CName  		
if @@FETCH_STATUS=0  		BEGIN  			SET @sSQL = @sSQL + ','  			
IF EXISTS (( SELECT * FROM SY00300 WHERE SGMTNUMB = substring(@CName, CHARINDEX('_',@CName) + 1,len(@CName))))  			BEGIN	   				SET @SQL = 'ltrim(rtrim(' + @SQL +' ))' + '+''-''+'  			END	  			SET @SQL1 =  @SQL1 + ','  		END  	END 	  	close c  	deallocate c   	/*END*/    	DECLARE C1 CURSOR FAST_FORWARD FOR  	SELECT DISTINCT MONTH(GL.TRXDATE),GL.OPENYEAR  	FROM GL20000 GL, SY40101 SY 	WHERE GL.OPENYEAR = SY.YEAR1 AND GL.SOURCDOC <> 'BBF'  	ORDER BY GL.OPENYEAR 	OPEN C1 	FETCH NEXT FROM C1 INTO @M1,@OPENYEAR 	
WHILE @@FETCH_STATUS = 0  	BEGIN 		 		SET @C1 = @M1 + 1 		SET @SI1 = '' 		SET @SF1 = '('+@DBT+LTRIM(STR(@M1))+ '+ GL.DEBITAMT) - ('+@CRDT+LTRIM(STR(@M1))+ '+ GL.CRDTAMNT) + '+ @SI+LTRIM(STR(@M1)) 		SET @sCOLS = '' 		SET @COLS = '' 		SET @COLS1 = '' 		SET @M2 = 1 		SET @SI2 = 'N2.nsaIF_SF_12' 		
WHILE @C1 < 13  		BEGIN 			SET @SI1 = @SF1 			SET @SF1 = (@DBT+LTRIM(STR(@C1))+' - '+@CRDT+LTRIM(STR(@C1))+' + '+@SF1) 			SET @sCOLS = @sCOLS+', '+@SI+LTRIM(STR(@C1))+ ' = '+@SI1+', '+@SF+LTRIM(STR(@C1))+' = '+@SF1 			SET @C1 = @C1 + 1 		END 		
WHILE @M2 < 12  		BEGIN 			SET @SI2 =('nsaIF_GL00050.'+@DBT+LTRIM(STR(@M2))+' - nsaIF_GL00050.'+@CRDT+LTRIM(STR(@M2))+' + '+@SI2) 			SET @SF1 = ('nsaIF_GL00050.'+@DBT+LTRIM(STR(@M2+1))+' - nsaIF_GL00050.'+@CRDT+LTRIM(STR(@M2+1))+' + '+@SI2) 			
IF @M2 < 9 			BEGIN 				SET @COLS = @COLS+', nsaIF_GL00050.'+@SI+LTRIM(STR(@M2+1))+ ' = '+@SI2+', nsaIF_GL00050.'+@SF+LTRIM(STR(@M2+1))+' = '+@SF1 			END 			ELSE 			BEGIN 				SET @COLS1 = @COLS1+', nsaIF_GL00050.'+@SI+LTRIM(STR(@M2+1))+ ' = '+@SI2+', nsaIF_GL00050.'+@SF+LTRIM(STR(@M2+1))+' = '+@SF1 			END 			SET @M2 = @M2 + 1 		END  		 		
EXEC ('INSERT INTO nsaIF_GL00050 (nsaIF_YEAR, ACTINDX, ORMSTRID, ORMSTRNM, 			nsaIF_SCred_1,nsaIF_SCred_2,nsaIF_SCred_3,nsaIF_SCred_4,nsaIF_SCred_5,nsaIF_SCred_6,nsaIF_SCred_7,nsaIF_SCred_8,nsaIF_SCred_9,nsaIF_SCred_10,nsaIF_SCred_11,nsaIF_SCred_12, 			nsaIF_SDeb_1,nsaIF_SDeb_2,nsaIF_SDeb_3,nsaIF_SDeb_4,nsaIF_SDeb_5,nsaIF_SDeb_6,nsaIF_SDeb_7,nsaIF_SDeb_8,nsaIF_SDeb_9,nsaIF_SDeb_10,nsaIF_SDeb_11,nsaIF_SDeb_12, 			nsaIF_SF_1,nsaIF_SF_2,nsaIF_SF_3,nsaIF_SF_4,nsaIF_SF_5,nsaIF_SF_6,nsaIF_SF_7,nsaIF_SF_8,nsaIF_SF_9,nsaIF_SF_10,nsaIF_SF_11,nsaIF_SF_12, 			nsaIF_SI_1,nsaIF_SI_2,nsaIF_SI_3,nsaIF_SI_4,nsaIF_SI_5,nsaIF_SI_6,nsaIF_SI_7,nsaIF_SI_8,nsaIF_SI_9,nsaIF_SI_10,nsaIF_SI_11,nsaIF_SI_12, 			nsaIF_SI0,nsaIF_SF0,nsaIF_SDeb0,nsaIF_SDeb01,nsaIF_Type_Nit,nsaIFNit,'+ @sSQL+ ',ACTNUMST) 			SELECT distinct GL.OPENYEAR,GL.ACTINDX, GL.ORMSTRID, '''', 			''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'', 			''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'', 			''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'', 			''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'', 			''0.00'',''0.00'',''0.00'',''0.00'','''','''','+@sSQL+','+@SQL+' FROM GL20000 GL, GL00100   			WHERE GL.SOURCDOC <> ''BBF'' AND OPENYEAR = '+@OPENYEAR+' AND GL.ACTINDX = GL00100.ACTINDX   			AND NOT EXISTS (SELECT GL1.TRXDATE FROM GL20000 GL1,nsaIF_GL00050 NGL1 WHERE GL1.SOURCDOC <> ''BBF'' AND GL1.ACTINDX = NGL1.ACTINDX AND  			GL1.ORMSTRID = NGL1.ORMSTRID AND GL1.OPENYEAR = NGL1.nsaIF_YEAR AND GL1.DEX_ROW_ID = GL.DEX_ROW_ID) AND MONTH(TRXDATE)=' +@M1)   		
EXECUTE('UPDATE nsaIF_GL00050 SET '+ @CRDT+@M1  +' = ('+ @CRDT+@M1 + ' + GL.CRDTAMNT ), 			'+ @DBT+@M1 +' = ('+ @DBT+@M1 + ' + GL.DEBITAMT ),'+ @SF+@M1 +' = '+ 			'('+@DBT+@M1+ '+ GL.DEBITAMT) - ('+@CRDT+@M1+ '+ GL.CRDTAMNT) + '+ @SI+@M1 +', nsaIF_SDeb01 = (nsaIF_SDeb01 + GL.CRDTAMNT),  			nsaIF_SDeb0 = (nsaIF_SDeb0 + GL.DEBITAMT)' + @sCOLS + ', nsaIFNit =''' + 			@NIT + ''',nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050 NGL,  			(select sum(CRDTAMNT) as CRDTAMNT, sum(DEBITAMT) as DEBITAMT, 			ACTINDX,OPENYEAR,ORMSTRID FROM GL20000 where MONTH(TRXDATE)='+ @M1 + ' AND OPENYEAR = '+ @OPENYEAR+ 			' AND SOURCDOC not in (''BBF'', ''P/L'') GROUP BY ACTINDX, OPENYEAR, ORMSTRID) GL  			WHERE NGL.ORMSTRID = GL.ORMSTRID AND NGL.ACTINDX = GL.ACTINDX AND NGL.nsaIF_YEAR = '+@OPENYEAR)  			 		
/*THE BELOW EXECUTE STATEMENT IS ADDED FOR P/L ACCOUNT UPDATE*/	 		
EXECUTE('UPDATE nsaIF_GL00050 SET '+ @SF+@M1 +' = '+ 			'('+@DBT+@M1+ '+ GL.DEBITAMT) - ('+@CRDT+@M1+ '+ GL.CRDTAMNT) + '+ @SI+@M1 +', nsaIF_SDeb01 = (nsaIF_SDeb01 + GL.CRDTAMNT),  			nsaIF_SDeb0 = (nsaIF_SDeb0 + GL.DEBITAMT)' + @sCOLS + ', nsaIFNit =''' + 			@NIT + ''',nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050 NGL,  			(select sum(CRDTAMNT) as CRDTAMNT, sum(DEBITAMT) as DEBITAMT, 			ACTINDX,OPENYEAR,ORMSTRID FROM GL20000 where MONTH(TRXDATE)='+ @M1 + ' AND OPENYEAR = '+ @OPENYEAR+ 			' AND SOURCDOC = ''P/L'' GROUP BY ACTINDX, OPENYEAR, ORMSTRID) GL  			WHERE NGL.ORMSTRID = GL.ORMSTRID AND NGL.ACTINDX = GL.ACTINDX AND NGL.nsaIF_YEAR = '+@OPENYEAR)  			 		
EXECUTE('UPDATE nsaIF_GL00050 SET nsaIF_GL00050.nsaIF_SI_1 = N2.nsaIF_SF_12, nsaIF_GL00050.nsaIF_SF_1 = (nsaIF_GL00050.nsaIF_SDeb_1 - nsaIF_GL00050.nsaIF_SCred_1 + N2.nsaIF_SF_12),  			nsaIF_GL00050.nsaIF_SDeb01 = N2.nsaIF_SDeb01, nsaIF_GL00050.nsaIF_SDeb0 = N2.nsaIF_SDeb0' + @COLS + @COLS1 +',nsaIF_GL00050.nsaIFNit =''' + 			@NIT + ''',nsaIF_GL00050.nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050,nsaIF_GL00050 N2, GL00100,GL20000 GL 			WHERE nsaIF_GL00050.ORMSTRID = N2.ORMSTRID AND N2.ACTINDX = GL00100.ACTINDX AND 			N2.ORMSTRID = GL.ORMSTRID AND N2.ACTINDX = GL.ACTINDX AND N2.nsaIF_YEAR = GL.OPENYEAR AND GL.SOURCDOC = ''P/L''    			AND GL00100.PSTNGTYP = 0 AND nsaIF_GL00050.ACTINDX = N2.ACTINDX AND nsaIF_GL00050.nsaIF_YEAR = N2.nsaIF_YEAR AND  			N2.nsaIF_YEAR = '+@OPENYEAR)  		/*ADD_TRX_NEW_YEAR*/  		
IF EXISTS (select YEAR1 from SY40101 where YEAR1 > @OPENYEAR) 		BEGIN 			DECLARE C2 CURSOR FAST_FORWARD FOR  			select YEAR1 from SY40101 where YEAR1 > @OPENYEAR 			OPEN C2 			SET @COUNT = @@ROWCOUNT 			FETCH NEXT FROM C2 INTO @OPENYEAR1 			
WHILE @@FETCH_STATUS = 0  			BEGIN  				
EXEC ('INSERT INTO nsaIF_GL00050 (nsaIF_YEAR, ACTINDX, ORMSTRID, ORMSTRNM, 					nsaIF_SCred_1,nsaIF_SCred_2,nsaIF_SCred_3,nsaIF_SCred_4,nsaIF_SCred_5,nsaIF_SCred_6,nsaIF_SCred_7,nsaIF_SCred_8,nsaIF_SCred_9,nsaIF_SCred_10,nsaIF_SCred_11,nsaIF_SCred_12, 					nsaIF_SDeb_1,nsaIF_SDeb_2,nsaIF_SDeb_3,nsaIF_SDeb_4,nsaIF_SDeb_5,nsaIF_SDeb_6,nsaIF_SDeb_7,nsaIF_SDeb_8,nsaIF_SDeb_9,nsaIF_SDeb_10,nsaIF_SDeb_11,nsaIF_SDeb_12, 					nsaIF_SF_1,nsaIF_SF_2,nsaIF_SF_3,nsaIF_SF_4,nsaIF_SF_5,nsaIF_SF_6,nsaIF_SF_7,nsaIF_SF_8,nsaIF_SF_9,nsaIF_SF_10,nsaIF_SF_11,nsaIF_SF_12, 					nsaIF_SI_1,nsaIF_SI_2,nsaIF_SI_3,nsaIF_SI_4,nsaIF_SI_5,nsaIF_SI_6,nsaIF_SI_7,nsaIF_SI_8,nsaIF_SI_9,nsaIF_SI_10,nsaIF_SI_11,nsaIF_SI_12, 					nsaIF_SI0,nsaIF_SF0,nsaIF_SDeb0,nsaIF_SDeb01,nsaIF_Type_Nit,nsaIFNit,'+ @sSQL+ ',ACTNUMST) 					SELECT '+@OPENYEAR1+', N1.ACTINDX, N1.ORMSTRID, N1.ORMSTRNM, 					''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'', 					''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'', 					''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'', 					''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'', 					''0.00'',''0.00'',''0.00'',''0.00'','''','''','+@SQL1+', N1.ACTNUMST FROM nsaIF_GL00050 N1, GL00100   					WHERE N1.ACTINDX = GL00100.ACTINDX   					AND NOT EXISTS (SELECT N2.nsaIF_YEAR FROM nsaIF_GL00050 N2 WHERE N1.ACTINDX = N2.ACTINDX AND  					N1.ORMSTRID = N2.ORMSTRID AND N2.nsaIF_YEAR = '+@OPENYEAR1+') AND  					GL00100.PSTNGTYP = 0 AND N1.nsaIF_YEAR = '+@OPENYEAR)  				
EXECUTE('UPDATE nsaIF_GL00050 SET nsaIF_GL00050.nsaIF_SI_1 = N2.nsaIF_SF_12, nsaIF_GL00050.nsaIF_SF_1 = (nsaIF_GL00050.nsaIF_SDeb_1 - nsaIF_GL00050.nsaIF_SCred_1 + N2.nsaIF_SF_12),  					nsaIF_GL00050.nsaIF_SDeb01 = N2.nsaIF_SDeb01, nsaIF_GL00050.nsaIF_SDeb0 = N2.nsaIF_SDeb0' + @COLS + @COLS1 +',nsaIF_GL00050.nsaIFNit =''' + 					@NIT + ''',nsaIF_GL00050.nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050,nsaIF_GL00050 N2, GL00100 					 WHERE nsaIF_GL00050.ORMSTRID = N2.ORMSTRID AND N2.ACTINDX = GL00100.ACTINDX AND 					GL00100.PSTNGTYP = 0 AND nsaIF_GL00050.ACTINDX = N2.ACTINDX AND nsaIF_GL00050.nsaIF_YEAR = '+@OPENYEAR1+' AND  					N2.nsaIF_YEAR = '+@OPENYEAR)   				FETCH NEXT FROM C2 INTO @OPENYEAR1 			END 
/*WHILE*/ 			CLOSE C2 			DEALLOCATE C2 		END 		ELSE 		BEGIN 			SET @OPENYEAR1 = @OPENYEAR + 1 			
EXEC ('INSERT INTO nsaIF_GL00050 (nsaIF_YEAR, ACTINDX, ORMSTRID, ORMSTRNM, 				nsaIF_SCred_1,nsaIF_SCred_2,nsaIF_SCred_3,nsaIF_SCred_4,nsaIF_SCred_5,nsaIF_SCred_6,nsaIF_SCred_7,nsaIF_SCred_8,nsaIF_SCred_9,nsaIF_SCred_10,nsaIF_SCred_11,nsaIF_SCred_12, 				nsaIF_SDeb_1,nsaIF_SDeb_2,nsaIF_SDeb_3,nsaIF_SDeb_4,nsaIF_SDeb_5,nsaIF_SDeb_6,nsaIF_SDeb_7,nsaIF_SDeb_8,nsaIF_SDeb_9,nsaIF_SDeb_10,nsaIF_SDeb_11,nsaIF_SDeb_12, 				nsaIF_SF_1,nsaIF_SF_2,nsaIF_SF_3,nsaIF_SF_4,nsaIF_SF_5,nsaIF_SF_6,nsaIF_SF_7,nsaIF_SF_8,nsaIF_SF_9,nsaIF_SF_10,nsaIF_SF_11,nsaIF_SF_12, 				nsaIF_SI_1,nsaIF_SI_2,nsaIF_SI_3,nsaIF_SI_4,nsaIF_SI_5,nsaIF_SI_6,nsaIF_SI_7,nsaIF_SI_8,nsaIF_SI_9,nsaIF_SI_10,nsaIF_SI_11,nsaIF_SI_12, 				nsaIF_SI0,nsaIF_SF0,nsaIF_SDeb0,nsaIF_SDeb01,nsaIF_Type_Nit,nsaIFNit,'+ @sSQL+ ',ACTNUMST) 				SELECT '+@OPENYEAR1+', N1.ACTINDX, N1.ORMSTRID, N1.ORMSTRNM, 				''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'', 				''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'', 				''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'', 				''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'',''0.00'', 				''0.00'',''0.00'',''0.00'',''0.00'','''','''','+@SQL1+', N1.ACTNUMST FROM nsaIF_GL00050 N1, GL00100   				WHERE N1.ACTINDX = GL00100.ACTINDX   				AND NOT EXISTS (SELECT N2.nsaIF_YEAR FROM nsaIF_GL00050 N2 WHERE N1.ACTINDX = N2.ACTINDX AND  				N1.ORMSTRID = N2.ORMSTRID AND N2.nsaIF_YEAR = '+@OPENYEAR1+') AND  				GL00100.PSTNGTYP = 0 AND N1.nsaIF_YEAR = '+@OPENYEAR)  			
EXECUTE('UPDATE nsaIF_GL00050 SET nsaIF_GL00050.nsaIF_SI_1 = N2.nsaIF_SF_12, nsaIF_GL00050.nsaIF_SF_1 = (nsaIF_GL00050.nsaIF_SDeb_1 - nsaIF_GL00050.nsaIF_SCred_1 + N2.nsaIF_SF_12),  				nsaIF_GL00050.nsaIF_SDeb01 = N2.nsaIF_SDeb01, nsaIF_GL00050.nsaIF_SDeb0 = N2.nsaIF_SDeb0' + @COLS + @COLS1 +',nsaIF_GL00050.nsaIFNit =''' + 				@NIT + ''',nsaIF_GL00050.nsaIF_Type_Nit = '''+ @NITTYPE + ''' FROM nsaIF_GL00050,nsaIF_GL00050 N2, GL00100 				 WHERE nsaIF_GL00050.ORMSTRID = N2.ORMSTRID AND N2.ACTINDX = GL00100.ACTINDX AND 				GL00100.PSTNGTYP = 0 AND nsaIF_GL00050.ACTINDX = N2.ACTINDX AND nsaIF_GL00050.nsaIF_YEAR = '+@OPENYEAR1+' AND  				N2.nsaIF_YEAR = '+@OPENYEAR)  		END  		FETCH NEXT FROM C1 INTO @M1,@OPENYEAR  	END 
/*WHILE*/ 	CLOSE C1 	DEALLOCATE C1 	/* To update the NIT and NIT TYPE values in table nsaIF_GL00050*/ 	update nsaIF_GL00050 set nsaIF_Type_Nit = NV.nsaIF_Type_Nit, nsaIFNit = NV.nsaIFNit  from nsaIF_GL00050, nsaIF01666 NV 	where ORMSTRID = NV.VENDORID  	update nsaIF_GL00050 set nsaIF_Type_Nit = NC.nsaIF_Type_Nit, nsaIFNit = NC.nsaIFNit  from nsaIF_GL00050, nsaIF02666 NC 	where ORMSTRID = NC.CUSTNMBR  	UPDATE nsaIF_GL00050 SET nsaIF_GL00050.ORMSTRNM = PM.VENDNAME FROM nsaIF_GL00050, PM00200 PM WHERE nsaIF_GL00050.ORMSTRID = PM.VENDORID  	UPDATE nsaIF_GL00050 SET nsaIF_GL00050.ORMSTRNM = RM.CUSTNAME FROM nsaIF_GL00050, RM00101 RM WHERE nsaIF_GL00050.ORMSTRID = RM.CUSTNMBR   end /*end of SP*/    
