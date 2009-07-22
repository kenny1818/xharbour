ANNOUNCE RDDSYS

REQUEST DBFCDX,REDBFCDX,BMDBFCDX

FUNCTION MAIN( cRdd, cIP )
    LOCAL n,t,m,p,J, pConn

    IF Empty( cRdd )
        cRdd := "REDBFCDX"
    ENDIF

    IF Empty( cIP )
        cIP := "127.0.0.1"
    ELSE
        cIP := AllTrim( cIP )
    ENDIF

    SET DATE FORMAT "DD/MM/YYYY"
    RDDSETDEFAULT( cRdd )

    SET DELETED ON
    SET AUTOPEN ON

    IF cRdd == 'REDBFCDX'
        ? "CONECTED A IP: " + cIP + ":2813"
        pConn := NET_OPENCONNECTION( cIP, 2813 )
        IF Empty( pConn )
            ? "SERVER DON'T WORK"
            RETURN
        END
    ENDIF

    IF ! HB_DBExists( "TMPTEST" )
        ? "creando tabla"
        DBCREATE( "TMPTEST", { { "A1", "C", 10, 0 } }, cRdd )
    ENDIF

    USE TMPTEST SHARED NEW ALIAS "ONE" VIA ( cRdd )

    IF LastRec() < 50000
        ? "a�adiendo 50000 registros"
        p := seconds()
        FOR n := 1 TO 50000
            APPEND BLANK
            REPLACE FIELD->A1 WITH "0123456789"
        NEXT
        ?? " -> " + AllTrim( Str( seconds() - p ) ) + " seconds"
    ENDIF

    SET OPTIMIZE ON
    IF HB_DBExists( "TMPTEST.CDX" )
        OrdSetFocus( "TG1" )
    ELSE
        INDEX ON FIELD->A1 TAG tg1 TO ("TMPTEST.CDX")
    ENDIF

    ? "Indice activo : " + ORDKEY()
    ? "Filtrando por : " + "RecNo() > 100 .AND. RecNo() < 200"
    p := seconds()
    DbSetFilter( {|| RecNo() > 100 .AND. RecNo() < 200 }, "RecNo() > 100 .AND. RecNo() < 200" )
    ?? " -> " + AllTrim( Str( seconds() - p ) ) + " seconds"

    WAIT
    p := t := seconds()
    FOR M := 1 TO 10
        ? "PASO " + AllTrim( str( M ) )
        DBGOTOP()
        FOR n := 1 TO 50000
            J := ORDKEYNO()
            J := ORDKEYCOUNT()
            DBSKIP()
        NEXT
        ?? " en " + AllTrim( Str( seconds() - p ) ) + " seconds"
        p := seconds()
    NEXT

    DBCLOSEALL()

    NET_CLOSECONNECTION( pConn )

    ? " TOTAL " + AllTrim( Str( seconds() - t ) ) + " seconds"
    WAIT

RETURN NIL


