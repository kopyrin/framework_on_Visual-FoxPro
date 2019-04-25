#define  C_FONTNAME        "Arial Cyr"
#define  C_FONTSIZE        10
PARAMETERS c������������������, ���������������������
IF EMPTY(C������������������)
    C������������������ = ""
ENDIF
IF EMPTY(���������������������)
    ��������������������� = ""
ENDIF

CLOSE ALL
CLEAR macros
CLEAR
SET DELETED ON
SET DATE GERMAN
SET EXCLUSIVE OFF
SET SAFETY OFF
SET EXACT OFF
SET STATUS OFF
SET STATUS BAR OFF
SET TALK OFF
*SET RESOURCE OFF
SET POINT TO "."
*SET POINT TO "-"
SET ESCAPE OFF
SET COLLATE TO "MACHINE"
SET PATH TO .\forms\;.\PLUGIN\;.\reports\
SET HOURS TO 24
ON ERROR DO APPERROR WITH    ERROR(),   PROG(), LINENO(), MESSAGE(), MESSAGE(1), SYS(2018)
* ���� ��������� ��� �������� ������������� �� ���
IF FindInstance()
    QUIT
ENDIF
* ���� ������ ? ���� �� ����� :(
*PUBLIC oErr AS Exception


_screen.closable=.f.
_screen.ControlBox =.f.

_Screen.Height=SYSMETRIC(2) - 70
_Screen.Picture = ''
*_Screen.Width = SYSMETRIC(1) - 8

DECLARE INTEGER GetPrivateProfileString IN Win32API AS GetPrivStr STRING, STRING, STRING, STRING @, INTEGER, STRING
DECLARE INTEGER WritePrivateProfileString IN Win32API AS WritePrivStr STRING, STRING, STRING, STRING

�APP = CREATEOBJECT("_app")
_SCREEN.CAPTION = �APP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "���������", " ��������� ��� ���������� ���������� �� Visual FoxPro ")

�APP.DBFS = �APP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "DBFS", "��")
IF �APP.DBFS="��"
    �APP.DBFS = .T.
ELSE
    �APP.DBFS = .F.
ENDIF
IF �APP.DBFS
    �APP.���� = ALLTRIM(�APP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "����", SYS(5)+SYS(2003)+"\dbfs\"))
ENDIF
�APP.������������� = �APP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "�������������", "")
�APP.������������ = �APP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "������������", "����������")
�APP.������ = �APP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "������", "")
�APP.������� = �APP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "�������", "00")

IF �APP.DBFS
    IF !FILE(�APP.���� + 'main.dbc') OR !FILE(�APP.���� + '����.dbf') OR !FILE(�APP.���� + '�������.dbf')
        DO apperror
    else
        OPEN DATABASE (�APP.���� + 'main.dbc') SHARED
        USE �APP.���� + "����.dbf" IN 0 AGAIN ALIAS ���� SHARED
        USE �APP.���� + "�������.dbf" IN 0 AGAIN ALIAS ������� SHARED
    endif
ENDIF


* �������� ��������� �������
* � ��� ��� ������� �������� :)
* ��� ���������� � ������� �� ���� �������� � ���������

SELECT �������
SCAN ALL FOR inlist(ALLTRIM(�������.����������),"����������","��������","�������")

    ������� = "O" + ALLTRIM(�������.��������) + " = .null."
    &�������
    ������� = "O" + ALLTRIM(�������.��������)+ [ = CREATEOBJECT('_motor')]
    &�������
    * ��� ����� ��������
    ������� = "O" + ALLTRIM(�������.��������)+ ".����� = " + STR(RECNO())
    &�������
    ������� = "O" + ALLTRIM(�������.��������)+ ".������� = ["+ALLTRIM(�������.��������) +"]"
    &�������

    * � ����� �������� �������������� ����� ������
    SELECT ����
    ������� = ""
    SCAN ALL FOR ALLTRIM(����.���_�) == ALLTRIM(�������.���)
        ������� = ������� + "ADDPROPERTY(O" + ALLTRIM(�������.��������)+ ",'" +ALLTRIM(����.��������)
        DO CASE
            CASE INLIST(ALLTRIM(����.���),"W","C","G","M","V")
                 ������� = ������� + "','')"  + CHR(13)
            CASE inlist(ALLTRIM(����.���),"Y","B","I","N","F","Q")
                 ������� = ������� + "',0)" + CHR(13)
            CASE INLIST(ALLTRIM(����.���),"D","T")
                 ������� = ������� + "',{})" + CHR(13)
            CASE ALLTRIM(����.���) = "L"
                 ������� = ������� + "',.F.)" + CHR(13)
        ENDCASE
    ENDSCAN
    * ������� ������ �������  � ������� ���� �� ���
    ������� = ������� + "O"+ALLTRIM(�������.��������) + ".�������()"
    =EXECSCRIPT(�������)
    SELECT �������
ENDSCAN

* �������� ��������� ������� ������������
SELECT �������
SCAN ALL FOR ALLTRIM(�������.����������) == "������������"
    LOCAL M.�������
    M.�������  = 0
    SELECT ����
    ������� = ""
    SCAN ALL FOR ALLTRIM(����.���_�) == ALLTRIM(�������.���)
        m.�������  = m.�������  + 1
        ������� = "DIMENSION c" +ALLTRIM(�������.��������) + " [" + STR(m.�������)+ ",2]"
        &�������
        ������� = "c" + ALLTRIM(�������.��������) + " [" + ALLTRIM(STR(m.�������))+",1] = '" + ALLTRIM(����.��������) + "'" + CHR(13) +;
                  "c" + ALLTRIM(�������.��������) + " [" + ALLTRIM(STR(m.�������))+",2] = "  + STR(m.�������)
        =EXECSCRIPT(�������)
    ENDSCAN
    SELECT �������
    RELEASE m.�������
ENDSCAN

�APP.�������������()
* ������������ �������� ��� �������
* ������������ ����������
m.c������������������ = UPPER(m.c������������������)
m.��������������������� = UPPER(m.���������������������)

* ���������� ��������� ������ � ��������� ������
IF m.c������������������ = "U" AND !EMPTY(m.���������������������)

    * ��������� ����� �����������
    IF �APP.DBFS
        IF !FILE(m.��������������������� + '�������.dbf')
            WAIT windows "�� ���������� ���� �� ���������� �������" + ALLTRIM(m.���������������������) + '�������.dbf'
            DO ����������������
        else
            USE m.��������������������� + "�������.dbf" IN 0 AGAIN ALIAS �������New SHARED
        endif
    ENDIF
    * ��������� ������ ����������� ������
    SELECT �������New
    SCAN ALL FOR inlist(ALLTRIM(�������New.����������),"����������","��������")
        ������� = ALLTRIM(�������New.��������)
        IF EMPTY(�������)
            SELECT �������New
            LOOP
        ENDIF
        * ��������� �������
        IF FILE(m.��������������������� + m.������� + ".dbf")
            USE (m.��������������������� + m.������� + ".dbf") ALIAS ( m.�������+"new" ) IN 0 EXCLUSIVE
            SELECT (m.������� +"new")
            * � ������� �� �� ��������� ������
            ZAP
        ELSE
            LOOP
        ENDIF

        * ��������� ���� �� ����� dbf ���� � ������ ��������
        IF FILE(�APP.���� + m.������� + ".dbf")
             * ���� ���� ����� ��������� �� ���� ������
             WAIT windows NOWAIT "�������� ������ ������� " + ALLTRIM(�������New.��������)
             APPEND from (�APP.���� + m.������� + ".dbf")
        ENDIF
        * ��������� ����� �������
           USE IN (m.�������+"new")

        SELECT �������New
    ENDSCAN
    * ��� ���������
    CLOSE DATABASES ALL

    * ������� ��� ����� �� �������� �� ������� �������
    WAIT windows NOWAIT " ������� ������� "
    ERASE (�APP.���� +  "*.*")

    * �������� ���� ������
    WAIT windows NOWAIT " �������� ����� ��������� "
    COPY FILE (m.��������������������� + '*.*') TO (�APP.����+'*.*')
    * ������� �� ���������
    DO ����������������
ENDIF

READ EVENTS
DO ����������������

**
FUNCTION apperror
PARAMETER M.ERRNUM, M.PROGRAM, M.LINE, M.MESS, M.MESS1, M.PARAM, M.SYS16
IF TYPE('M.ERRNUM')!="N"
    WAIT windows "�� ���������� �������. ��������� ���� � ����� main.ini."
    quit
ENDIF
DO CASE
    * �������� ���� ������� ��������� � �������
    CASE M.ERRNUM=1531
        RETURN .T.
    * �������� �� ������� ������������ �������
    CASE M.ERRNUM=1871
        RETURN .T.
    CASE M.ERRNUM=1707
        RETRY
    CASE M.ERRNUM=109
        IF MESSAGEBOX("������ �������������. ���������� �������.", WTITLE(""), 0+64+0)=1
            RETRY
        ELSE
            RETURN .f.
        ENDIF
ENDCASE
PRIVATE K, I
SET TEXTMERGE TO ERROR.LOG ADDITIVE
SET TEXTMERGE ON NOSHOW

\   Date :<<Date()>> <<Time()>>
\  Error :<<m.errnum>>
\ Module :<<m.program>>
\At Line :<<m.line>>
\Message :<<m.mess>>
\ Source :<<m.mess1>>
\  Param :<<m.param>>
\Execute :<<m.sys16>>
IF !EMPTY(m.�������) AND TYPE('�������') = "C"
\m.������� = <<m.�������>>
ENDIF

\stack
I = 1
DO WHILE  .NOT. EMPTY(SYS(16, I))
\<<i>> <<sys(16,i)>>
I = I+1
ENDDO
\
SET TEXTMERGE OFF
SET TEXTMERGE TO
K = MESSAGEBOX("���������� ������ # "+LTRIM(STR(M.ERRNUM))+' "'+M.MESS+'"', 0+64+0, "������")
DO CASE
    CASE K=3
        DO ����������������
    CASE K=4
        RETRY
    CASE K=5
        RETURN .T.
ENDCASE
RETURN .T.
ENDFUNC
**
PROCEDURE ����������������
    �APP.DISCONNECTSQL()
    SET SYSMENU TO DEFAULT
    ON ERROR
    SET STATUS BAR ON
    CLOSE ALL
    RELEASE all
    SET RESOURCE ON
    RESTORE MACROS
    POP KEY ALL
    *SET STEP ON

    *CLEAR ALL
    CANCEL
ENDPROC
**
DEFINE CLASS _App AS CUSTOM
    * �������� ������ � �������
    ���� = ""
    DBFS = .T.
    * ������� ����� ��� ������
    ������� = ""
    * �������� ���������� ����� ODBC
    ������������� = ""
    ���������� = 0
    * �������� �������� ������������
    ������������ = ""
    ������ = ""
    * �������� ��� ���������� ������
    ������� = ""
    ��������� = ""
    * ���� � ��������� ������� (EXCEL)
    �������� = ""
    * ���� � �������
    ������������������ = ""



    FUNCTION �������������

        * ��������� �������
        PRIVATE M.NAME, M.OLDERR, M.NERROR, M.PLUGINDIR
        PRIVATE M.PLUGINMODULES, M.PLUGINCOUNT
        m.PLUGINDIR = SYS(5)+SYS(2003)+"\plugin\"
        m.PLUGINMODULES = ADIR(PLGIN, M.PLUGINDIR+'*.*')
        IF M.PLUGINMODULES=0
            *RETURN .F.
        ELSE
            m.OLDERR = ON('ERROR')
            m.NERROR = 0
            ON ERROR STORE ERROR() TO M.NERROR
            FOR M.PLUGINCOUNT = 1 TO M.PLUGINMODULES
                IF  .NOT. ('D'$PLGIN(M.PLUGINCOUNT, 5)) .AND. INLIST(JUSTEXT(PLGIN(M.PLUGINCOUNT, 1)), "PRG", "APP", "EXE")
                    m.NAME = M.PLUGINDIR+PLGIN(M.PLUGINCOUNT, 1)
                    *���� ������� ���� �� ����� ��� ����������
                    DO INIT IN (M.NAME)
                ENDIF
            ENDFOR
        ENDIF
        RELEASE M.NAME, M.OLDERR, M.NERROR, M.PLUGINDIR
        RELEASE M.PLUGINMODULES, M.PLUGINCOUNT
        ON ERROR DO APPERROR WITH    ERROR(),   PROG(), LINENO(), MESSAGE(), MESSAGE(1), SYS(2018)
        * ������ �������� ������ ����
        SET SYSMENU TO DEFAULT
        DO menu_App.mpr
        DEFINE POPUP DATAS MARGIN RELATIVE SHADOW COLOR SCHEME 4

        * ���� ������ ������������
        SELECT ������������
        SCAN ALL FOR ALLTRIM(������������.��������) == ALLTRIM(�APP.������������)
            * ���� ����� ����
            SELECT ����
            SCAN ALL FOR ALLTRIM(����.��������) == ALLTRIM(������������.����)
                * ���� ����� ����
                SELECT ����
                SCAN ALL FOR ����.���_� == ����.���
                        ������� = "�APP.ADDBAR('"+ALLTRIM(����.��������)  +"',"+;
                            "'"+ALLTRIM(����.����������)+"',"+;
                            "'"+ALLTRIM(����.���������) +"'"
                        IF !EMPTY(ALLTRIM(����.����������))
                            ������� = ������� + ",'" + ALLTRIM(����.����������)+ "'"
                        ENDIF
                        IF !EMPTY(ALLTRIM(����.�������))
                            ������� = ������� + ",'" + ALLTRIM(����.�������) + "'"
                        ENDIF
                        ������� = ������� + ")"
                        &�������
                ENDSCAN && ����� ������ ����
                * ���� ������ �� ������ - ������� �� �������� ����
                RETURN .t.
            ENDSCAN && ����� ������ ����
            * ���� ������ �� ������ - ������� �� �������� ����
            RETURN .t.
        ENDSCAN && ����� ������ ������������
        * ���� ������ �� ������ - ������� �� �������� ����
        RETURN .t.

    ENDFUNC
    **
    FUNCTION getstr
        PARAMETER M.FILE, M.SECTION, M.ITEM, M.DEFAULT
        PRIVATE M.BUFF, M.LEN
        M.BUFF = CHR(0)
        M.LEN = 0
        M.BUFF = REPLICATE(CHR(0), 2048)
        M.LEN = GETPRIVSTR(M.SECTION, M.ITEM, M.DEFAULT, @M.BUFF, LEN(M.BUFF), M.FILE)
        RETURN IIF(M.LEN !=0, LEFT(M.BUFF, M.LEN), "")
    ENDFUNC
    **
    FUNCTION putstr
        PARAMETER M.FILE, M.SECTION, M.ITEM, M.DEFAULT
        PRIVATE M.LEN
        M.LEN = WRITEPRIVSTR(M.SECTION, M.ITEM, M.DEFAULT, M.FILE)
        RETURN M.LEN
    ENDFUNC
    **
    FUNCTION ������������
        SELECT �������
        SCAN ALL FOR inlist(alltrim(�������.����������),"����������","��������")
            ������� = "O" + ALLTRIM(�������.��������)+ [.�������()]
            &�������
            SET EXCLUSIVE ON
            ������� = "O" + ALLTRIM(�������.��������)+ [.�������()]
            IF  .NOT. EVALUATE(�������)
                DO ����������������
            ENDIF
            ������� = "SELECT " + ALLTRIM(�������.��������)
            &�������
            ������� = "PACK"
            &�������
            ������� = "O" + ALLTRIM(�������.��������)+ [.�������()]
            &�������
            SET EXCLUSIVE OFF
            ������� = "O" + ALLTRIM(�������.��������)+ [.�������()]
            IF  .NOT. EVALUATE(�������)
                DO ����������������
            ENDIF
            SELECT �������
        ENDSCAN
        DO ����������������
    ENDFUNC
    **

    PROCEDURE connectSql
        IF  .NOT. THIS.DBFS
            STORE SQLCONNECT(THIS.�������������, THIS.������, '') TO THIS.����������
            IF THIS.����������<=0
                = MESSAGEBOX('� �������� ����������� �� �������', 16, 'SQL Connect Error')
                DO ����������������
            ENDIF
        ENDIF
    ENDPROC
    **
    PROCEDURE disconnectSql
        IF  .NOT. THIS.DBFS
            = SQLDISCONNECT(THIS.����������)
        ENDIF
    ENDPROC
    **
    FUNCTION ���������
        IF THIS.DBFS
            SELECT (THIS.���������)
            RETURN FLOCK()
        ENDIF
    ENDFUNC
    **
    PROCEDURE ���������
        IF THIS.DBFS
            UNLOCK IN THIS.���������
        ENDIF
    ENDPROC
    **
    FUNCTION ���������
        IF THIS.DBFS
            M.������� = THIS.�������+THIS.���������
            &�������
        ELSE
            IF EMPTY(THIS.���������)
                RETURN IIF( -1 = SQLEXEC(THIS.����������, �������), .f., .t.)
            ELSE
                RETURN IIF( -1 = SQLEXEC(THIS.����������, �������,THIS.���������), .f., .t.)
            ENDIF
        ENDIF
    ENDFUNC
    **
    PROCEDURE addbar
        PARAMETER M.CPOPUPNAME, CPROMPT, CCOMMAND, KEYNAME, KEYCAPTION
        N = CNTBAR(M.CPOPUPNAME)+1
        KEYNAME = IIF(EMPTY(KEYNAME), "", KEYNAME)
        KEYCAPTION = IIF(EMPTY(KEYCAPTION), "", KEYCAPTION)
        IF  .NOT. EMPTY(KEYNAME)
            DEFINE BAR N OF (CPOPUPNAME) PROMPT CPROMPT KEY &KEYNAME, KEYCAPTION
        ELSE
            DEFINE BAR N OF (CPOPUPNAME) PROMPT CPROMPT
        ENDIF
        IF  .NOT. EMPTY(CCOMMAND)
            ON SELECTION BAR N OF (CPOPUPNAME) &CCOMMAND
        ENDIF
    ENDPROC

    PROCEDURE ����������������
        * �������� � ������ � ������� "�������"
        PARAMETERS m.�����
        * ������� �� ������� "�������"
        SELECT �������
        * ������ �� ��� ������
        GO m.�����
        LOCAL m.�������, m.�������, m.�������1, m.���������
        STORE "" TO m.�������, m.�������, m.�������1, m.���������
        * ��������� ��� ���� ������
        m.�������  = �������.���

        * ������� ��� ������ �� ������� "����"
        * ��������� � ������� � ������� "�������"
        * ������� ������ �������� ����
        SELECT ����.* ;
            FROM ����, ������� ;
            WHERE ALLTRIM(����.���_�) == ALLTRIM(�������.���) ;
                and �������.��� == m.�������  ;
                AND ����.����������� = .f. ;
            INTO CURSOR Temp����

        SELECT Temp����

        SCAN ALL
                �������  = ������� + IIF( !EMPTY(�������) , [,] , []) + ALLTRIM(Temp����.��������)
                �������1 = �������1 + IIF( !EMPTY(�������1), [,] , [])+IIF(�APP.DBFS,"","?")+"THIS." + ALLTRIM(Temp����.��������)
                ��������� = ��������� + IIF( !EMPTY(���������), [,] , []) +ALLTRIM(Temp����.��������) + " =" +IIF(�APP.DBFS,"","?") + "THIS." + ALLTRIM(Temp����.��������)
        ENDSCAN

        * ������������ ������� ��� �������
        IF !EMPTY(�������) AND !EMPTY(�������1)
            ������� = " INSERT INTO " + ALLTRIM(�������.��������)+" ( " + ������� + " ) VALUES ( " + �������1 +" )"
        ENDIF
        ������� = "O"+ ALLTRIM(�������.��������)+ ".����������������� =  ������� "
        &�������

        * ������������ ������� ��� ���������
        IF !EMPTY(���������)
            ��������� = " UPDATE "+ ALLTRIM(�������.��������)+" SET  " + ��������� + ;
                        " WHERE "+ALLTRIM(�������.��������)+ ".��� = "   + IIF(�APP.DBFS,"","?") + "THIS.��� "
        ENDIF
        ������� = "O"+ ALLTRIM(�������.��������)+ ".������������������� =  ��������� "
        &�������

        IF USED("Temp����")
            USE IN Temp����
        ENDIF
    ENDPROC
**
ENDDEFINE


DEFINE CLASS _motor AS CUSTOM
  �����   = 0
  ������� = ""
  ����������������� = ""
  ������������������� = ""
  ������������� = 0
  ������ = ""
  ������� = ""

    FUNCTION �������������
        SELECT �������
        GO THIS.�����
    ENDFUNC

    FUNCTION ���������
        THIS.�������������()
        LOCAL m.�������
        m.�������  = �������.���
*!*            SELECT ����.* ;
*!*                FROM ����, ������� ;
*!*                WHERE ALLTRIM(����.���_�) == ALLTRIM(�������.���) ;
*!*                AND �������.��� == m.�������  ;
*!*                AND ����.����������� = .F. ;
*!*                INTO CURSOR Temp����

        SELECT ����.* ;
            FROM ����, ������� ;
            WHERE ALLTRIM(����.���_�) == ALLTRIM(�������.���) ;
            AND �������.��� == m.�������  ;
            INTO CURSOR Temp����

        SELECT Temp����
        IF _TALLY = 0
            USE IN Temp����
        ENDIF
        RETURN IIF(_TALLY > 0, .T. , .F.)
    ENDFUNC

    FUNCTION �������
        ������� = ""
        IF THIS.���������()
            SCAN ALL
                ������� = ������� +IIF(EMPTY(�������),""," ,") + ALLTRIM(Temp����.��������)+" "
                DO CASE
                    CASE INLIST(ALLTRIM(Temp����.���), "W", "Y", "D", "T", "B", "G", "I", "L", "M")
                        ������� = ������� + ALLTRIM(Temp����.���)
                    CASE INLIST(ALLTRIM(Temp����.���), "C", "Q", "V")
                        ������� = ������� + ALLTRIM(Temp����.���) + "(" +ALLTRIM(Temp����.������)+")"
                    CASE INLIST(ALLTRIM(Temp����.���), "N", "F")
                        ������� = ������� + ALLTRIM(Temp����.���) + "(" +ALLTRIM(Temp����.������)+","+ALLTRIM(Temp����.��������)+")"
                ENDCASE
            ENDSCAN
            USE IN Temp����
        ENDIF
        * ���� ���� ��� �� �������, ������� �� �������.
        IF EMPTY(�������)
            RETURN .F.
        ENDIF
        IF �APP.DBFS
            ������� = " CREATE TABLE " + �APP.���� + ALLTRIM(�������.��������)+ ".dbf NAME " +ALLTRIM(�������.��������)+ " (" + ������� + ")"
            &�������
            RETURN .T.
        ELSE
            ������� = " CREATE TABLE " + ALLTRIM(�������.��������)+ " (" + ������� + ")"
            RETURN IIF( -1 = SQLEXEC(�APP.����������, �������), .F., .T.)
        ENDIF
    ENDFUNC
**
    PROCEDURE �����������������
        * ��������� ���� �� ����� dbf ����
        IF FILE(�APP.���� + THIS.������� + ".dbf")
            SET EXCLUSIVE ON
            SELECT 0
            USE �APP.���� + THIS.������� + ".dbf"
            SET EXCLUSIVE OFF
        ENDIF
        RETURN .t.
    ENDFUNC

    PROCEDURE �������
        * ���� � ��� DBF ������
        IF �APP.DBFS
            * ���� ������� ��� �������
            IF USED(UPPER(THIS.�������))
                SELECT (THIS.�������)
                * ������ �������
                RETURN .T.
            ENDIF
            * ��������� ���� �� ����� dbf ����
            IF FILE(�APP.���� + THIS.������� + ".dbf")
                SELECT 0
                * ���������
                USE �APP.���� + THIS.������� +".dbf"
            ELSE
                * �������� ��� �������
                RETURN THIS.�������()
            ENDIF
            * ���� �� ����� ��������� ����
            IF  .NOT. FILE(�APP.���� + THIS.������� + ".cdx")
                this.�������()
                this.�����������������()
                * ������� ������� ���� ����
                INDEX ON ��� TAG ��� COLLATE 'MACHINE'
                INDEX ON ���_� TAG ���_� COLLATE 'MACHINE'
                this.�������()
                this.�������()
            ENDIF
            * � ������� ��� ��� ����
            RETURN .T.
        ELSE
            * ���� SQL ������ �� ������ ����� ����� � �������
            THIS.�����()
            IF  .NOT. USED("c"+ALLTRIM(THIS.�������))
                RETURN THIS.�������()
            ENDIF
        ENDIF
    ENDPROC
**
    PROCEDURE �������
        IF �APP.DBFS .AND. USED(ALLTRIM(THIS.�������))
            SELECT ALLTRIM(THIS.�������)
            USE
        ENDIF
    ENDPROC
**

    PROCEDURE ��������

        IF THIS.���������()
            SELECT Temp����
            * ������� ��������� ������� ����������
            SCAN ALL
                ������� = "this." +ALLTRIM(Temp����.��������)
                DO CASE
                    CASE INLIST(ALLTRIM(Temp����.���),"W", "G", "Q", "V", "M")
                        ������� = ������� + " = []"
                    CASE ALLTRIM(Temp����.���) = "C"
                        ������� = ������� + " = ["+SPACE(VAL(Temp����.������))+"]"
                    CASE INLIST(ALLTRIM(Temp����.���),"Y", "B", "I", "N", "F")
                        ������� = ������� + " = 0"
                    CASE INLIST(ALLTRIM(Temp����.���),"D")
                        ������� = ������� + " = {}"
                    CASE INLIST(ALLTRIM(Temp����.���),"T")
                        ������� = ������� + " = datetime(null,null,null,null,null,null)"
                    CASE ALLTRIM(Temp����.���) = "L"
                        ������� = ������� + " = .f."
                ENDCASE
                &�������
            ENDSCAN
            USE IN Temp����
        ENDIF
        SELECT �������
        * � ����� �� ���������
        IF !EMPTY(�������.��������)
            ������� = "this.���_� = [" + EVALUATE("O" + ALLTRIM(�������.��������)+ ".��� ") +"]"
            &�������
        ENDIF
        ������� = "SELECT C" + THIS.�������
        &�������
    ENDPROC
**
    PROCEDURE �������������
        IF THIS.���������()
            SELECT Temp����
            SCAN ALL
                ������� = "this." +ALLTRIM(Temp����.��������)+ " = C" +ALLTRIM(�������.��������)+"." +ALLTRIM(Temp����.��������)
                &�������
            ENDSCAN
            USE IN Temp����
        ENDIF
        ������� = "SELECT C" + THIS.�������
        &�������
    ENDPROC
**
    FUNCTION ��������
        THIS.�������������()
        IF !EMPTY(�������.��������) AND EMPTY(THIS.���_�)
            RETURN .F.
        ENDIF
        IF NOT this.���������������������������������()
            RETURN .f.
        endif

        *********************** �������� ������� ������ � ����� ����� ********
        * ��� ����������, ���� �� ��������� ������ � ������ ������ � �� ����� �������� ���� ����������

        LOCAL m.��������
        m.�������� = .T.
        IF !EMPTY(THIS.���)
            ������� = "SELECT ��� AS ��� ;
                            where '" + THIS.��� + "' == " +  ALLTRIM(�������.��������) + ".��� ;
                            FROM  "+ALLTRIM(�������.��������)
            IF �APP.DBFS
                ������� = �������+" into cursor temp"
                &�������
            ELSE
                =IIF( -1 = SQLEXEC(�APP.����������, �������, TEMP), .F., .T.)
            ENDIF

            IF USED("temp")
                SELECT TEMP
                IF ISNULL(TEMP.���) OR EMPTY(TEMP.���)
                    * ��� ����� ������
                    m.�������� = .T.
                ELSE
                    * ���� ����� ������
                    m.�������� = .F.
                ENDIF
                USE IN TEMP
            ENDIF
        ENDIF
        **********************************************************************
        IF m.��������
            * �������� ����������
            IF THIS.�������������������("��������")
                THIS.�������������()
                *���������� ����� ��� ������
                IF EMPTY(THIS.���)
                    LOCAL m.����������
                    * ���������� ������ ������ � �������� 2 ������� �� �������
                    m.���������� = LEN(THIS.���)-2
                    IF �APP.DBFS
                        ������� = "SELECT MAX(VAL(SUBSTR(���,3,m.����������))) AS ��� FROM "+ALLTRIM(�������.��������)+ " into cursor temp"
                        &�������
                    ELSE
                        ������� = "SELECT MAX(VAL(SUBSTR(���,3,?����������))) AS ��� FROM "+ALLTRIM(�������.��������)
                        =IIF( -1 = SQLEXEC(�APP.����������, �������, TEMP), .F., .T.)
                    ENDIF

                    IF USED("temp")
                        SELECT TEMP
                        IF ISNULL(TEMP.���)
                            THIS.��� = 1
                        ELSE
                            THIS.��� = TEMP.���+1
                        ENDIF
                        USE IN TEMP
                    ELSE
                        THIS.��� = 1
                    ENDIF
                    THIS.��� = �APP.�������+REPLICATE("0", m.����������-LEN(ALLTRIM(STR(THIS.���)))) + ALLTRIM(STR(THIS.���))
                ENDIF
                IF EMPTY(THIS.�����������������)
                    �APP.����������������(THIS.�����)
                ENDIF
                m.������� = THIS.�����������������
                IF �APP.DBFS
                    &�������
                ELSE
                    = IIF( -1 = SQLEXEC(�APP.����������, �������), .F., .T.)
                ENDIF
            ENDIF
        ELSE
            IF THIS.�������������������("��������")
                IF EMPTY(THIS.�������������������)
                    �APP.����������������(THIS.�����)
                ENDIF
                m.������� = THIS.�������������������
                IF �APP.DBFS
                    &�������
                ELSE
                    = IIF( -1 = SQLEXEC(�APP.����������, �������), .F., .T.)
                ENDIF
            ENDIF
        ENDIF
        ������� = "SELECT C" + THIS.�������
        &�������
        IF m.��������
            RETURN "new"
        ELSE
            RETURN "old"
        ENDIF
    ENDFUNC
**
    FUNCTION ����������������
        IF 6=MESSAGEBOX("�� ������������� ������ ������� ������? ", 4+32+256, " ��������! ")
            RETURN THIS.�������()
        ELSE
            RETURN .f.
        ENDIF
    ENDFUNC
**
    FUNCTION �������
        * ��������� ����������
        IF !THIS.�������������������("�������")
            RETURN .F.
        ENDIF

        * ����� ������ �� ������
        THIS.�������������()
        * ��������� � ����� �������� �������� :)
        THIS.�������������()

        * ��� �� ��������� �� ����� ������� ������ �������
        m.������� = UPPER(ALLTRIM(�������.��������))

        * ������ ������� �� ������ � ������� ��� ������� �������� ���������� ��� ����
        ������� = "SELECT �������.�������� as ������� , ����.��������    as ���� ;
                       FROM �������, ���� ;
                       where �������.��� == ����.���_� and UPPER(ALLTRIM(����.��������)) ==  m.������� "

        IF �APP.DBFS
            ������� = �������+" into cursor temp"
            &�������
        ELSE
            =IIF( -1 = SQLEXEC(�APP.����������, �������, TEMP), .F., .T.)
        ENDIF

        * ���� ������� ����
        IF USED("temp") AND RECCOUNT("temp") > 0
            SELECT TEMP
            * ���� ��� ������� �������� ����������
            * �������� ���������� ������ �� ����� �� ����� � ������� ������  � ��������� ��������
            SCAN ALL FOR !ISNULL(TEMP.�������) AND !EMPTY(TEMP.�������)

               * ������� � ��� ������� � ��������� �������� ������� �������� ����� �� ��� � ���� ���?
                ������� = "SELECT ��� as ��� ;
                                 FROM " + ALLTRIM(TEMP.�������)+;
                    " where " + ALLTRIM(TEMP.�������)+"." + ALLTRIM(TEMP.����)+ " = [" +EVALUATE("O" + m.������� + ".��� ") + "]"+;
                    " into cursor temp1"

                &�������
                IF _TALLY >0
                    WAIT WINDOWS " �� ������� " + ALLTRIM(TEMP.�������) +" �� ������� ������ ��������� � ����."
                    USE IN temp1
                    USE IN TEMP
                    ������� = "SELECT C" + THIS.�������
                    &�������
                    RETURN .F.
                ENDIF
                SELECT TEMP
            ENDSCAN
        ENDIF
        * ��� ������, �� �� ��� �� ����������
        IF USED("Temp")
            USE IN TEMP
        ENDIF
        IF USED("Temp1")
            USE IN temp1
        ENDIF

        * ����� ������� ������
        ������� = "SELECT C" + THIS.�������
        &�������
        ������� = "THIS.��� = C" + THIS.�������+ ".���"
        &�������
        ������� = "THIS.���_� = C" + THIS.�������+ ".���_�"
        &�������
        IF �APP.DBFS
            ������� = " DELETE FROM " + THIS.������� + " WHERE " + THIS.������� + ".��� = THIS.���"
            &�������
        ELSE
            ������� = " DELETE FROM " + THIS.������� + " WHERE " + THIS.������� + ".��� = ?THIS.���"
            = SQLEXEC(�APP.����������, �������), .F., .T.)
        ENDIF
        ������� = "SELECT C" + THIS.�������
        &�������
        RETURN .T.
    ENDFUNC
**
    FUNCTION �����
        LPARAMETERS m.���
        IF !this.�������������������("�����")
            RETURN .f.
        endif
        this.�������������()
        ������� = ""
        IF INLIST(�������.����������,"�������", "����������", "��������")
              IF EMPTY(ALLTRIM(������))
                  WAIT WINDOWS " �� ������� ������� ��� ������ ������ "
                  RETURN .F.
              ELSE
                  ������� = ALLTRIM(�������.������)
              ENDIF
        ENDIF
        IF  !EMPTY(this.������)
            ������� = ������� + ' ' + this.������
        ENDIF
        IF  !EMPTY(this.�������)
            ������� = ������� + ' ' + this.�������
        ENDIF        
        IF �APP.DBFS
            ������� = ������� + " INTO CURSOR C" +THIS.������� 
            * + " readwrite "
            &�������
        ELSE
            = IIF( -1 = SQLEXEC(�APP.����������, �������, "C" + THIS.�������), .f., .t.)
        ENDIF
        ������� = "SELECT C" + THIS.�������
        &�������
        IF  !EMPTY(m.���)
            ������� = "m.���=C" + THIS.�������+ ".���"
            LOCATE FOR EVALUATE(�������)
            IF !FOUND()
                GO top
            endif
        ENDIF
        RETURN .T.
    ENDFUNC
**
    FUNCTION ��������
        LPARAMETERS m.���
        * ���� ����������� �� ������������ �� ����� ������ ����� ������
        IF EMPTY(m.���)
            * ������ ������ � ������� ������
            m.��� = THIS.���
        ENDIF
        IF THIS.�������������������("��������")
            THIS.�������������()
            IF (�������.���������� = "����������" OR �������.���������� = "��������" OR �������.���������� = "�������")
                IF this.������������� = 0
                    THIS.�����(m.���)
                    ������� = "SELECT C" + THIS.�������
                    &�������
                    ������� = "DO FORM .\forms\" + THIS.�������+ ".scx"
                       &�������
                   ENDIF
                   this.������������� = 1
            ENDIF
        ENDIF
    ENDFUNC
**
    FUNCTION �������������������
        LPARAMETERS m.����������
        PRIVATE m.�������, m.�����
        m.������� = ""
        m.����� = .F.

        THIS.�������������()
        m.������� = UPPER(ALLTRIM(�������.��������))

        SELECT ����������.* ;
            FROM ������������, ����������, ����;
            WHERE UPPER(ALLTRIM(�APP.������������)) == UPPER(ALLTRIM(������������.��������)); && ������� ���� ������ ������������
                and UPPER(ALLTRIM(����.��������)) == UPPER(ALLTRIM(������������.����)) ; && ����� ���� ����� ����
                AND ����.��� = ����������.���_� ; && ����� �� ���� ���������� ����������
                AND m.������� == UPPER(ALLTRIM(����������.��_�������)); && ��� ����� �� ����� �������
            INTO CURSOR Temp����������

        IF _TALLY > 0
            DO CASE
                CASE m.���������� = "�����"    AND Temp����������.��_�����
                    m.����� = .T.
                CASE m.���������� = "��������" AND Temp����������.��_��������
                    m.����� = .T.
                CASE m.���������� = "��������" AND Temp����������.��_��������
                    m.����� = .T.
                CASE m.���������� = "��������" AND Temp����������.��_��������
                    m.����� = .T.
                CASE m.���������� = "�������" AND Temp����������.��_�������
                    m.����� = .T.
            ENDCASE
        ENDIF
        IF USED("Temp����������")
            USE IN Temp����������
        ENDIF
        IF !m.�����
            WAIT WINDOWS NOWAIT "��� ��������� " + m.���������� + ". �������: " + ALLTRIM(�������.��������)
        ENDIF
        RETURN m.�����

    ENDFUNC

    FUNCTION �����������
        LPARAMETERS ���������
        ������� = "SELECT C" + THIS.�������
        &�������
        SCAN ALL FOR ��� == ���������
            THIS.�������������()
            RETURN .T.
        ENDSCAN
        RETURN .F.
    ENDFUNC

    FUNCTION ���������������������������������
        * � ��� ���� ������ � ����������� ����������
        * ���������� ������� �������� ������� ������� ��������� �� ������ �������
         THIS.�������������()
        LOCAL m.�������
        m.�������  = �������.���
        SELECT ����.��������, ����.�������� ;
            FROM ����, ������� ;
            WHERE ALLTRIM(����.���_�) == ALLTRIM(�������.���) ;
            AND �������.��� == m.�������  ;
            AND ����.����������� = .F. ;
            AND !empty(����.��������) ;
            INTO CURSOR Temp����

        SELECT Temp����
        IF _TALLY = 0
            USE IN Temp����
            RETURN .t.
        ENDIF
        * �������������� ���������� �������
        local m.��������, m.��������, m.���������
        m.��������� = ""

        SCAN all
            m.�������� = Temp����.��������
            m.�������� = Temp����.��������

            * � ��������� ���� �� � ������� �� ������� ��������� ����� ������
            ������� =           " select * from " + ALLTRIM(m.��������)
            ������� = ������� + " into cursor temp "
            ������� = ������� + " where ��� = this." + ALLTRIM(m.��������)
            &�������

            SELECT temp
            IF _TALLY = 0
                m.��������� = m.��������� + CHR(13) + " �� ������� ������ � " + ALLTRIM(m.��������) + " ��� " +ALLTRIM(m.��������)
            ENDIF
        endscan
           USE IN Temp����
           USE IN Temp
           IF !EMPTY(m.���������)
               WAIT windows m.���������
               RETURN .f.
           else
            RETURN .t.
        ENDIF

    ENDFUNC
ENDDEFINE

* ���������� ������������ �������
* ���������������� ������� � ������� ������, ���� :
* Column, Header
***************************************************

DEFINE CLASS MyColumn AS COLUMN
    FONTNAME=C_FONTNAME
    FONTSIZE=C_FONTSIZE
    VISIBLE=.T.
    INDEX=0
    

    PROCEDURE INIT(m.���, m.������ , m.�������)
        WITH THIS
            .REMOVEOBJECT('Header1')
            .ADDOBJECT("Header","MyHeader", m.������, m.�������)
            .REMOVEOBJECT("Text1")
            DO CASE
                CASE m.��� = "CheckBox"
                    .ADDOBJECT("CheckBox","MyGridCheckBox")
                    .CURRENTCONTROL="CheckBox"
                    .CHECKBOX.VISIBLE = .T.
                    .SPARSE = .F.
                OTHERWISE
                    .ADDOBJECT("Text","MyGridText")
                    .CURRENTCONTROL="Text"
                    .TEXT.VISIBLE=.T.

            ENDCASE
        ENDWITH

ENDDEFINE

DEFINE CLASS MyHeader AS HEADER
    FONTNAME=C_FONTNAME
    FONTSIZE=C_FONTSIZE
    FONTBOLD=.T.
    ALIGNMENT=2
    WORDWRAP=.T.
    ������ = ""
    ������� = ""
    
    PROCEDURE init(m.������, m.�������)
    WITH THIS
        .������ = m.������
        .������� = m.�������
    ENDWITH 
    
	PROCEDURE DblClick
	    ������� =  'o' +this.������+ '.�������  = " order by '+this.������� + '"'
	    &�������
	    THISFORMSET.��������()
	ENDPROC

ENDDEFINE

DEFINE CLASS MyGridText AS TEXTBOX
    FONTNAME=C_FONTNAME
    FONTSIZE=C_FONTSIZE

    MARGIN=0
    SPECIALEFFECT=1
    SELECTONENTRY=.T.
    BORDERSTYLE=0
    VISIBLE=.T.

    PROCEDURE KEYPRESS(nKeyCode, nShiftAltCtrl )
        THISFORMSET.�������(nKeyCode)
    ENDPROC

    PROCEDURE RIGHTCLICK
        THISFORMSET.�������(27)
    ENDPROC

    PROCEDURE DblClick
        THISFORMSET.�������(13)
    ENDPROC
    
    PROCEDURE Valid
        *thisformset.����������������()
    ENDPROC
       
ENDDEFINE

DEFINE CLASS MyGridCheckBox AS CHECKBOX

    FONTNAME=C_FONTNAME
    FONTSIZE=C_FONTSIZE

    VISIBLE=.T.
    CAPTION = ""
    ALIGNMENT = 2

    PROCEDURE KEYPRESS(nKeyCode, nShiftAltCtrl )
        THISFORMSET.�������(nKeyCode)
    ENDPROC

    PROCEDURE RIGHTCLICK
        THISFORMSET.�������(27)
    ENDPROC

    PROCEDURE DblClick
        THISFORMSET.�������(13)
    ENDPROC

ENDDEFINE


Procedure NtoC
 parameter m.nValue, m.Decimals
 private all
 *
 * m.nValue      - (N) ����� ��� �������������
 * m.Decimals    - (L) �������� � ��������� ?
 *
 * �������� �����
 if empty(m.nValue)
    return '���� ������'+iif(!empty(m.Decimals),' 00 ������','')+'.'
    * �������� ��� �������� �����
 else
    if type('m.nValue') # 'N'
        return ''
    endif
 endif

 store '' to ret
 store 0  to tmp, tv, i

 declare names[6,3], numbers[19], tens[10], hound[10]

 names[1,1]='�������'
 names[1,2]='�������'
 names[1,3]='������'

 names[2,1]='�����'
 names[2,2]='�����'
 names[2,3]='������'

 names[3,1]='������'
 names[3,2]='������'
 names[3,3]='�����'

 names[4,1]='�������'
 names[4,2]='��������'
 names[4,3]='���������'

 names[5,1]='��������'
 names[5,2]='���������'
 names[5,3]='����������'

 names[6,1]='��������'
 names[6,2]='���������'
 names[6,3]='����������'

*�������
 numbers[ 1]='����'
 numbers[ 2]='���'
 numbers[ 3]='���'
 numbers[ 4]='������'
 numbers[ 5]='����'
 numbers[ 6]='�����'
 numbers[ 7]='����'
 numbers[ 8]='������'
 numbers[ 9]='������'
 numbers[10]='������'
 numbers[11]='�����������'
 numbers[12]='����������'
 numbers[13]='����������'
 numbers[14]='������������'
 numbers[15]='����������'
 numbers[16]='�����������'
 numbers[17]='����������'
 numbers[18]='������������'
 numbers[19]='������������'

* �������
 tens[ 1]='�����'
 tens[ 2]='��������'
 tens[ 3]='��������'
 tens[ 4]='�����'
 tens[ 5]='���������'
 tens[ 6]='����������'
 tens[ 7]='���������'
 tens[ 8]='�����������'
 tens[ 9]='���������'

*�����
 hound[ 1]='���'
 hound[ 2]='������'
 hound[ 3]='������'
 hound[ 4]='���������'
 hound[ 5]='�������'
 hound[ 6]='��������'
 hound[ 7]='�������'
 hound[ 8]='���������'
 hound[ 9]='���������'

 *------------------------------------------------------------------------

 if !empty(m.Decimals)
    tmp=Round(mod( nValue * 100, 100),0)
    ret=' '+tran(tmp,'@L 99')+' '+x_end(tmp,1)+'.'
 else
    ret='.'
 endif

 i=2
 tmp=int(nValue)                       && ������� �������
 ret=x_end(mod(tmp,100),2,.t.)+ret

 do while tmp > 0
    tv=mod(tmp,1000)                   && �������� ��������� ������
    if tmp=0 and i=2                   && �������� 0
        ret='���� ������'+ret          && ������� �������
        exit
    else
        ret=iif(tv>0,x_str(tv)+' '+x_end(mod(tv,100),i)+iif(ret='.','',' ')+ret, ret)
    endif
    tmp=int(tmp/1000)
    i=i+1
 enddo
 ret=alltrim( ret)
 do while('  ' $ ret)
    ret=strtran(ret,'  ',' ')
 enddo
 return upper(left(ret,1))+substr(ret,2)

procedure x_Str
 parameter nx
 private nx, nh, s
 s=''
 if nx > 99
    nh=int(nx/100)
    s=hound[nh]
    nx=mod(nx,100)
 endif
 if nx > 19
    nh=int(nx/10)
    s=s+' '+tens[nh]
    nx=mod(nx,10)
 endif
 if nx > 0
    if i=3 and between(nx,1,2)
        do case
        case nx=1
            s=s+' '+'����'
        case nx=2
            s=s+' '+'���'
        endcase
    else
        s=s+' '+numbers[nx]
    endif
 endif
 return alltrim(s)

procedure x_End
 parameter nx, ni, nz
 private tmp, nx, ni, nz

 if nx < 20
    return x_end_x(nx)
 else
    return x_end_x(int(mod( nx, 10)))
 endif

procedure x_End_x
 parameter ny
 if ni=2 and !nz
    return ''
 endif
 do case
 case ny = 0 and ni=1
    return Names[ni,3]
 case ny = 1
    return Names[ni,1]
 case between(ny, 2, 4)
    return Names[ni,2]
 other
    return Names[ni,3]
 endcase

Procedure FindInstance
If _Vfp.StartMode=0
    Return .F.
ENDIF

*
* ����� ����� ���������, � ���� ��� �������� �� ������������� �� ���
*
#define GWL_USERDATA            (-21)
#define ERROR_ALREADY_EXISTS    183

Declare Integer CreateMutex         in Win32Api integer, integer, string
Declare Integer ReleaseMutex         in Win32Api integer
Declare Integer CloseHandle         in Win32Api integer

Declare Long     GetWindowLong         in Win32Api integer, integer
Declare Long     SetWindowLong         in Win32Api integer, integer, long
Declare Integer GetLastError         in Win32Api

Declare Integer GetTopWindow         in Win32Api integer
Declare Integer GetWindow             in Win32Api integer, integer
Declare Integer SetForegroundWindow in Win32Api integer
Declare Integer ShowWindow in Win32Api integer, integer

Local m.Mutex, m.Magic, hMutex, hwnd, m.ret

m.ret=.F.                    && ������������ ��������
m.Mutex="My.Mutex.0001"        && ��������� �����
m.Magic=0x12345678            && ���������� ����� (����� ����� ����� !)

hMutex=CreateMutex(0,0,m.Mutex)
* ���� Mutex ��� ������
If GetLastError()=ERROR_ALREADY_EXISTS
    CloseHandle(hMutex)                && ����� �����

    hwnd=GetTopWindow(0)            && ��������� ����
    DO While hwnd # 0
        hwnd=GetWindow(hwnd,2)        && ��������� ����
        If hwnd # 0                    && ���� hWnd
            If GetWindowLong(hwnd,GWL_USERDATA)=m.Magic  && � � ��� ���� ��������� �����
                * ������� ���������� ������ � ����� ������������������
                * ����� ������� ���� ����� �������� "�������"
                SetForegroundWindow(hwnd)    && ���������� ��� ��� ����� �����
                ShowWindow(hwnd,3)            && � �������� ������
                m.Ret=.T.
                Exit
            EndIf
        EndIf
    EndDo

Else
    SetWindowLong(_vfp.hwnd,GWL_USERDATA,m.Magic)    && ����� � ���� ��������� �����
    ReleaseMutex(hMutex)            && Mutex ��� ������ �� ����� - �� ����� ������� � ���������
EndIf
Return m.Ret



