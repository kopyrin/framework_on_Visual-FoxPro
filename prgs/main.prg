#define  C_FONTNAME        "Arial Cyr"
#define  C_FONTSIZE        10
PARAMETERS cДействиеПриЗапуске, сДополнительныеДанные
IF EMPTY(CДействиеПриЗапуске)
    CДействиеПриЗапуске = ""
ENDIF
IF EMPTY(сДополнительныеДанные)
    сДополнительныеДанные = ""
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
* если программа уже запущена переключаемся на нее
IF FindInstance()
    QUIT
ENDIF
* чего падает ? Сама не знает :(
*PUBLIC oErr AS Exception


_screen.closable=.f.
_screen.ControlBox =.f.

_Screen.Height=SYSMETRIC(2) - 70
_Screen.Picture = ''
*_Screen.Width = SYSMETRIC(1) - 8

DECLARE INTEGER GetPrivateProfileString IN Win32API AS GetPrivStr STRING, STRING, STRING, STRING @, INTEGER, STRING
DECLARE INTEGER WritePrivateProfileString IN Win32API AS WritePrivStr STRING, STRING, STRING, STRING

ОAPP = CREATEOBJECT("_app")
_SCREEN.CAPTION = ОAPP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "заголовок", " Фреймворк для разработки приложений на Visual FoxPro ")

ОAPP.DBFS = ОAPP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "DBFS", "Да")
IF ОAPP.DBFS="Да"
    ОAPP.DBFS = .T.
ELSE
    ОAPP.DBFS = .F.
ENDIF
IF ОAPP.DBFS
    ОAPP.ПУТЬ = ALLTRIM(ОAPP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "путь", SYS(5)+SYS(2003)+"\dbfs\"))
ENDIF
ОAPP.ИМЯСОЕДИНЕНИЯ = ОAPP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "имясоединения", "")
ОAPP.ПОЛЬЗОВАТЕЛЬ = ОAPP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "пользователь", "Специалист")
ОAPP.ПАРОЛЬ = ОAPP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "пароль", "")
ОAPP.ПРЕФИКС = ОAPP.GETSTR(SYS(5)+SYS(2003)+"\main.INI", "path", "префикс", "00")

IF ОAPP.DBFS
    IF !FILE(ОAPP.ПУТЬ + 'main.dbc') OR !FILE(ОAPP.ПУТЬ + 'поля.dbf') OR !FILE(ОAPP.ПУТЬ + 'таблицы.dbf')
        DO apperror
    else
        OPEN DATABASE (ОAPP.ПУТЬ + 'main.dbc') SHARED
        USE ОAPP.ПУТЬ + "поля.dbf" IN 0 AGAIN ALIAS Поля SHARED
        USE ОAPP.ПУТЬ + "таблицы.dbf" IN 0 AGAIN ALIAS Таблицы SHARED
    endif
ENDIF


* начинаем создавать объекты
* у нас тут фабрика объектов :)
* все одинаковые в методах но есть различия в свойствах

SELECT таблицы
SCAN ALL FOR inlist(ALLTRIM(таблицы.виддокумен),"Справочник","Документ","Система")

    команда = "O" + ALLTRIM(таблицы.Название) + " = .null."
    &команда
    команда = "O" + ALLTRIM(таблицы.Название)+ [ = CREATEOBJECT('_motor')]
    &команда
    * это общие свойства
    команда = "O" + ALLTRIM(таблицы.Название)+ ".МЕСТО = " + STR(RECNO())
    &команда
    команда = "O" + ALLTRIM(таблицы.Название)+ ".ТАБЛИЦА = ["+ALLTRIM(таблицы.Название) +"]"
    &команда

    * а потом свойства соотвествующие полям таблиц
    SELECT поля
    команда = ""
    SCAN ALL FOR ALLTRIM(Поля.код_г) == ALLTRIM(Таблицы.код)
        команда = команда + "ADDPROPERTY(O" + ALLTRIM(таблицы.Название)+ ",'" +ALLTRIM(поля.название)
        DO CASE
            CASE INLIST(ALLTRIM(Поля.Тип),"W","C","G","M","V")
                 команда = команда + "','')"  + CHR(13)
            CASE inlist(ALLTRIM(Поля.Тип),"Y","B","I","N","F","Q")
                 команда = команда + "',0)" + CHR(13)
            CASE INLIST(ALLTRIM(Поля.Тип),"D","T")
                 команда = команда + "',{})" + CHR(13)
            CASE ALLTRIM(Поля.Тип) = "L"
                 команда = команда + "',.F.)" + CHR(13)
        ENDCASE
    ENDSCAN
    * пробуем отрыть таблицу  и создать если ее нет
    команда = команда + "O"+ALLTRIM(таблицы.Название) + ".открыть()"
    =EXECSCRIPT(команда)
    SELECT таблицы
ENDSCAN

* начинаем создавать массивы перечислений
SELECT Таблицы
SCAN ALL FOR ALLTRIM(таблицы.виддокумен) == "Перечисление"
    LOCAL M.Позиция
    M.Позиция  = 0
    SELECT поля
    команда = ""
    SCAN ALL FOR ALLTRIM(Поля.код_г) == ALLTRIM(Таблицы.код)
        m.Позиция  = m.Позиция  + 1
        команда = "DIMENSION c" +ALLTRIM(таблицы.Название) + " [" + STR(m.Позиция)+ ",2]"
        &команда
        команда = "c" + ALLTRIM(таблицы.Название) + " [" + ALLTRIM(STR(m.Позиция))+",1] = '" + ALLTRIM(поля.название) + "'" + CHR(13) +;
                  "c" + ALLTRIM(таблицы.Название) + " [" + ALLTRIM(STR(m.Позиция))+",2] = "  + STR(m.Позиция)
        =EXECSCRIPT(команда)
    ENDSCAN
    SELECT таблицы
    RELEASE m.Позиция
ENDSCAN

ОAPP.инициализация()
* обрабатываем действия при запуске
* производится обновление
m.cДействиеПриЗапуске = UPPER(m.cДействиеПриЗапуске)
m.сДополнительныеДанные = UPPER(m.сДополнительныеДанные)

* обновление структуры таблиц с переносом данных
IF m.cДействиеПриЗапуске = "U" AND !EMPTY(m.сДополнительныеДанные)

    * Открываем новую кофигурацию
    IF ОAPP.DBFS
        IF !FILE(m.сДополнительныеДанные + 'таблицы.dbf')
            WAIT windows "По указанному пути не обнаружена таблица" + ALLTRIM(m.сДополнительныеДанные) + 'таблицы.dbf'
            DO ВЫХОДИЗПРОГРАММЫ
        else
            USE m.сДополнительныеДанные + "таблицы.dbf" IN 0 AGAIN ALIAS ТаблицыNew SHARED
        endif
    ENDIF
    * сканируем список исользуемых таблиц
    SELECT таблицыNew
    SCAN ALL FOR inlist(ALLTRIM(таблицыNew.виддокумен),"Справочник","Документ")
        команда = ALLTRIM(таблицыNew.Название)
        IF EMPTY(команда)
            SELECT таблицыNew
            LOOP
        ENDIF
        * открываем таблицу
        IF FILE(m.сДополнительныеДанные + m.команда + ".dbf")
            USE (m.сДополнительныеДанные + m.команда + ".dbf") ALIAS ( m.команда+"new" ) IN 0 EXCLUSIVE
            SELECT (m.команда +"new")
            * и очищаем ее от случайных заисей
            ZAP
        ELSE
            LOOP
        ENDIF

        * проверяем есть ли такой dbf файл в старом каталоге
        IF FILE(ОAPP.ПУТЬ + m.команда + ".dbf")
             * если есть тогда добавляем из него данные
             WAIT windows NOWAIT "Копируем данные таблицы " + ALLTRIM(таблицыNew.Название)
             APPEND from (ОAPP.ПУТЬ + m.команда + ".dbf")
        ENDIF
        * закрываем новую таблицу
           USE IN (m.команда+"new")

        SELECT таблицыNew
    ENDSCAN
    * все закрываем
    CLOSE DATABASES ALL

    * удаляем все файлы из каталога со старыми данными
    WAIT windows NOWAIT " Удаляем таблицы "
    ERASE (ОAPP.ПУТЬ +  "*.*")

    * копируем туда ДАННЫЕ
    WAIT windows NOWAIT " Копируем новую структуру "
    COPY FILE (m.сДополнительныеДанные + '*.*') TO (ОAPP.ПУТЬ+'*.*')
    * выходим из программы
    DO ВЫХОДИЗПРОГРАММЫ
ENDIF

READ EVENTS
DO ВЫХОДИЗПРОГРАММЫ

**
FUNCTION apperror
PARAMETER M.ERRNUM, M.PROGRAM, M.LINE, M.MESS, M.MESS1, M.PARAM, M.SYS16
IF TYPE('M.ERRNUM')!="N"
    WAIT windows "Не обнаружены таблицы. Настройти пути в файле main.ini."
    quit
ENDIF
DO CASE
    * удаление поля которое участвует в индексе
    CASE M.ERRNUM=1531
        RETURN .T.
    * УДАЛЕНИЕ ИЗ ТАБЛИЦЫ ЕДИНСТВЕННОЙ КОЛОНКИ
    CASE M.ERRNUM=1871
        RETURN .T.
    CASE M.ERRNUM=1707
        RETRY
    CASE M.ERRNUM=109
        IF MESSAGEBOX("Запись заблокирована. Попробуйте позднее.", WTITLE(""), 0+64+0)=1
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
IF !EMPTY(m.команда) AND TYPE('команда') = "C"
\m.команда = <<m.команда>>
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
K = MESSAGEBOX("Обнаружена ошибка # "+LTRIM(STR(M.ERRNUM))+' "'+M.MESS+'"', 0+64+0, "Ошибка")
DO CASE
    CASE K=3
        DO ВЫХОДИЗПРОГРАММЫ
    CASE K=4
        RETRY
    CASE K=5
        RETURN .T.
ENDCASE
RETURN .T.
ENDFUNC
**
PROCEDURE ВыходИзПрограммы
    ОAPP.DISCONNECTSQL()
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
    * свойства работы с данными
    ПУТЬ = ""
    DBFS = .T.
    * префикс кодов для данных
    ПРЕФИКС = ""
    * свойства соединения через ODBC
    ИМЯСОЕДИНЕНИЯ = ""
    СОЕДИНЕНИЕ = 0
    * свойства текущего пользователя
    ПОЛЬЗОВАТЕЛЬ = ""
    ПАРОЛЬ = ""
    * свойства для выполнения команд
    команда = ""
    РЕЗУЛЬТАТ = ""
    * путь к редактору отчетов (EXCEL)
    РЕДАКТОР = ""
    * путь к отчетам
    путькфайламотчетов = ""



    FUNCTION инициализация

        * добавляем плагины
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
                    *пока закроем чтоб не мешал при компиляции
                    DO INIT IN (M.NAME)
                ENDIF
            ENDFOR
        ENDIF
        RELEASE M.NAME, M.OLDERR, M.NERROR, M.PLUGINDIR
        RELEASE M.PLUGINMODULES, M.PLUGINCOUNT
        ON ERROR DO APPERROR WITH    ERROR(),   PROG(), LINENO(), MESSAGE(), MESSAGE(1), SYS(2018)
        * заодно заполним пункты меню
        SET SYSMENU TO DEFAULT
        DO menu_App.mpr
        DEFINE POPUP DATAS MARGIN RELATIVE SHADOW COLOR SCHEME 4

        * ищем такого пользователя
        SELECT пользователи
        SCAN ALL FOR ALLTRIM(Пользователи.название) == ALLTRIM(ОAPP.пользователь)
            * ищем такую роль
            SELECT роли
            SCAN ALL FOR ALLTRIM(Роли.название) == ALLTRIM(Пользователи.роль)
                * ищем такое меню
                SELECT меню
                SCAN ALL FOR Меню.код_г == Роли.код
                        команда = "ОAPP.ADDBAR('"+ALLTRIM(меню.название)  +"',"+;
                            "'"+ALLTRIM(меню.строкаменю)+"',"+;
                            "'"+ALLTRIM(меню.чтоделать) +"'"
                        IF !EMPTY(ALLTRIM(меню.комбинация))
                            команда = команда + ",'" + ALLTRIM(меню.комбинация)+ "'"
                        ENDIF
                        IF !EMPTY(ALLTRIM(меню.надпись))
                            команда = команда + ",'" + ALLTRIM(меню.надпись) + "'"
                        ENDIF
                        команда = команда + ")"
                        &команда
                ENDSCAN && конец поиска меню
                * если ничего не попало - выходим не заполняя меню
                RETURN .t.
            ENDSCAN && конец поиска роли
            * если ничего не попало - выходим не заполняя меню
            RETURN .t.
        ENDSCAN && конец поиска пользователя
        * если ничего не попало - выходим не заполняя меню
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
    FUNCTION ВсеУпаковать
        SELECT Таблицы
        SCAN ALL FOR inlist(alltrim(таблицы.виддокумен),"Справочник","Документ")
            команда = "O" + ALLTRIM(таблицы.Название)+ [.ЗАКРЫТЬ()]
            &команда
            SET EXCLUSIVE ON
            команда = "O" + ALLTRIM(таблицы.Название)+ [.ОТКРЫТЬ()]
            IF  .NOT. EVALUATE(команда)
                DO ВыходИзПрограммы
            ENDIF
            команда = "SELECT " + ALLTRIM(таблицы.Название)
            &команда
            команда = "PACK"
            &команда
            команда = "O" + ALLTRIM(таблицы.Название)+ [.ЗАКРЫТЬ()]
            &команда
            SET EXCLUSIVE OFF
            команда = "O" + ALLTRIM(таблицы.Название)+ [.ОТКРЫТЬ()]
            IF  .NOT. EVALUATE(команда)
                DO ВыходИзПрограммы
            ENDIF
            SELECT Таблицы
        ENDSCAN
        DO ВыходИзПрограммы
    ENDFUNC
    **

    PROCEDURE connectSql
        IF  .NOT. THIS.DBFS
            STORE SQLCONNECT(THIS.ИМЯСОЕДИНЕНИЯ, THIS.ПАРОЛЬ, '') TO THIS.СОЕДИНЕНИЕ
            IF THIS.СОЕДИНЕНИЕ<=0
                = MESSAGEBOX('С сервером соединиться не удалось', 16, 'SQL Connect Error')
                DO ВЫХОДИЗПРОГРАММЫ
            ENDIF
        ENDIF
    ENDPROC
    **
    PROCEDURE disconnectSql
        IF  .NOT. THIS.DBFS
            = SQLDISCONNECT(THIS.СОЕДИНЕНИЕ)
        ENDIF
    ENDPROC
    **
    FUNCTION захватить
        IF THIS.DBFS
            SELECT (THIS.РЕЗУЛЬТАТ)
            RETURN FLOCK()
        ENDIF
    ENDFUNC
    **
    PROCEDURE отпустить
        IF THIS.DBFS
            UNLOCK IN THIS.РЕЗУЛЬТАТ
        ENDIF
    ENDPROC
    **
    FUNCTION выполнить
        IF THIS.DBFS
            M.команда = THIS.команда+THIS.РЕЗУЛЬТАТ
            &команда
        ELSE
            IF EMPTY(THIS.РЕЗУЛЬТАТ)
                RETURN IIF( -1 = SQLEXEC(THIS.СОЕДИНЕНИЕ, команда), .f., .t.)
            ELSE
                RETURN IIF( -1 = SQLEXEC(THIS.СОЕДИНЕНИЕ, команда,THIS.РЕЗУЛЬТАТ), .f., .t.)
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

    PROCEDURE ЗаполнитьКоманды
        * передали № записи в таблице "Таблицы"
        PARAMETERS m.место
        * перешли на таблицу "Таблицы"
        SELECT таблицы
        * встали на эту запись
        GO m.МЕСТО
        LOCAL m.таблица, m.вставка, m.вставка1, m.изменение
        STORE "" TO m.таблица, m.вставка, m.вставка1, m.изменение
        * запомнили код этой записи
        m.таблица  = таблицы.код

        * выбрали все записи из таблицы "Поля"
        * связанные с записью в таблице "Таблицы"
        * выбрали только реальные поля
        SELECT поля.* ;
            FROM поля, Таблицы ;
            WHERE ALLTRIM(Поля.код_г) == ALLTRIM(Таблицы.код) ;
                and Таблицы.код == m.таблица  ;
                AND Поля.виртуальное = .f. ;
            INTO CURSOR TempПоля

        SELECT TempПоля

        SCAN ALL
                вставка  = вставка + IIF( !EMPTY(вставка) , [,] , []) + ALLTRIM(TempПоля.название)
                вставка1 = вставка1 + IIF( !EMPTY(вставка1), [,] , [])+IIF(ОAPP.DBFS,"","?")+"THIS." + ALLTRIM(TempПоля.название)
                изменение = изменение + IIF( !EMPTY(изменение), [,] , []) +ALLTRIM(TempПоля.название) + " =" +IIF(ОAPP.DBFS,"","?") + "THIS." + ALLTRIM(TempПоля.название)
        ENDSCAN

        * обрабатываем команду для вставки
        IF !EMPTY(вставка) AND !EMPTY(вставка1)
            вставка = " INSERT INTO " + ALLTRIM(таблицы.Название)+" ( " + вставка + " ) VALUES ( " + вставка1 +" )"
        ENDIF
        команда = "O"+ ALLTRIM(таблицы.Название)+ ".КомандаДляВставки =  вставка "
        &команда

        * обрабатываем команду для изменения
        IF !EMPTY(изменение)
            изменение = " UPDATE "+ ALLTRIM(таблицы.Название)+" SET  " + изменение + ;
                        " WHERE "+ALLTRIM(таблицы.Название)+ ".код = "   + IIF(ОAPP.DBFS,"","?") + "THIS.код "
        ENDIF
        команда = "O"+ ALLTRIM(таблицы.Название)+ ".КомандаДляИзменения =  изменение "
        &команда

        IF USED("TempПоля")
            USE IN TempПоля
        ENDIF
    ENDPROC
**
ENDDEFINE


DEFINE CLASS _motor AS CUSTOM
  МЕСТО   = 0
  ТАБЛИЦА = ""
  КомандаДляВставки = ""
  КомандаДляИзменения = ""
  ЭкраннаяФорма = 0
  Фильтр = ""
  Порядок = ""

    FUNCTION ВстатьНаМесто
        SELECT таблицы
        GO THIS.МЕСТО
    ENDFUNC

    FUNCTION ВзятьПоля
        THIS.ВстатьНаМесто()
        LOCAL m.таблица
        m.таблица  = таблицы.код
*!*            SELECT поля.* ;
*!*                FROM поля, таблицы ;
*!*                WHERE ALLTRIM(поля.код_г) == ALLTRIM(таблицы.код) ;
*!*                AND таблицы.код == m.таблица  ;
*!*                AND поля.виртуальное = .F. ;
*!*                INTO CURSOR TempПоля

        SELECT поля.* ;
            FROM поля, таблицы ;
            WHERE ALLTRIM(поля.код_г) == ALLTRIM(таблицы.код) ;
            AND таблицы.код == m.таблица  ;
            INTO CURSOR TempПоля

        SELECT TempПоля
        IF _TALLY = 0
            USE IN TempПоля
        ENDIF
        RETURN IIF(_TALLY > 0, .T. , .F.)
    ENDFUNC

    FUNCTION создать
        команда = ""
        IF THIS.ВзятьПоля()
            SCAN ALL
                команда = команда +IIF(EMPTY(команда),""," ,") + ALLTRIM(Tempполя.название)+" "
                DO CASE
                    CASE INLIST(ALLTRIM(Tempполя.Тип), "W", "Y", "D", "T", "B", "G", "I", "L", "M")
                        команда = команда + ALLTRIM(Tempполя.Тип)
                    CASE INLIST(ALLTRIM(Tempполя.Тип), "C", "Q", "V")
                        команда = команда + ALLTRIM(Tempполя.Тип) + "(" +ALLTRIM(Tempполя.Размер)+")"
                    CASE INLIST(ALLTRIM(Tempполя.Тип), "N", "F")
                        команда = команда + ALLTRIM(Tempполя.Тип) + "(" +ALLTRIM(Tempполя.Размер)+","+ALLTRIM(Tempполя.Точность)+")"
                ENDCASE
            ENDSCAN
            USE IN Tempполя
        ENDIF
        * Если поля еще не описаны, таблицу не создаем.
        IF EMPTY(команда)
            RETURN .F.
        ENDIF
        IF ОAPP.DBFS
            команда = " CREATE TABLE " + ОAPP.ПУТЬ + ALLTRIM(таблицы.название)+ ".dbf NAME " +ALLTRIM(таблицы.название)+ " (" + команда + ")"
            &команда
            RETURN .T.
        ELSE
            команда = " CREATE TABLE " + ALLTRIM(таблицы.название)+ " (" + команда + ")"
            RETURN IIF( -1 = SQLEXEC(ОAPP.СОЕДИНЕНИЕ, команда), .F., .T.)
        ENDIF
    ENDFUNC
**
    PROCEDURE ОткрытьЭкслюзивно
        * проверяем есть ли такой dbf файл
        IF FILE(ОAPP.ПУТЬ + THIS.ТАБЛИЦА + ".dbf")
            SET EXCLUSIVE ON
            SELECT 0
            USE ОAPP.ПУТЬ + THIS.ТАБЛИЦА + ".dbf"
            SET EXCLUSIVE OFF
        ENDIF
        RETURN .t.
    ENDFUNC

    PROCEDURE открыть
        * если у нас DBF версия
        IF ОAPP.DBFS
            * если область уже открыта
            IF USED(UPPER(THIS.ТАБЛИЦА))
                SELECT (THIS.ТАБЛИЦА)
                * просто выходим
                RETURN .T.
            ENDIF
            * проверяем есть ли такой dbf файл
            IF FILE(ОAPP.ПУТЬ + THIS.ТАБЛИЦА + ".dbf")
                SELECT 0
                * ОТКРЫВАЕМ
                USE ОAPP.ПУТЬ + THIS.ТАБЛИЦА +".dbf"
            ELSE
                * придется его создать
                RETURN THIS.СОЗДАТЬ()
            ENDIF
            * есть ли такой индексный файл
            IF  .NOT. FILE(ОAPP.ПУТЬ + THIS.ТАБЛИЦА + ".cdx")
                this.закрыть()
                this.открытьЭкслюзивно()
                * создаем индексы если чего
                INDEX ON КОД TAG КОД COLLATE 'MACHINE'
                INDEX ON КОД_Г TAG КОД_Г COLLATE 'MACHINE'
                this.закрыть()
                this.открыть()
            ENDIF
            * и говорим что все окей
            RETURN .T.
        ELSE
            * если SQL версия то просто берем файлы с сервера
            THIS.ВЗЯТЬ()
            IF  .NOT. USED("c"+ALLTRIM(THIS.ТАБЛИЦА))
                RETURN THIS.СОЗДАТЬ()
            ENDIF
        ENDIF
    ENDPROC
**
    PROCEDURE закрыть
        IF ОAPP.DBFS .AND. USED(ALLTRIM(THIS.ТАБЛИЦА))
            SELECT ALLTRIM(THIS.ТАБЛИЦА)
            USE
        ENDIF
    ENDPROC
**

    PROCEDURE добавить

        IF THIS.ВзятьПоля()
            SELECT TempПоля
            * сначала заполняем пустыми значениями
            SCAN ALL
                команда = "this." +ALLTRIM(TempПоля.название)
                DO CASE
                    CASE INLIST(ALLTRIM(TempПоля.Тип),"W", "G", "Q", "V", "M")
                        команда = команда + " = []"
                    CASE ALLTRIM(TempПоля.Тип) = "C"
                        команда = команда + " = ["+SPACE(VAL(TempПоля.размер))+"]"
                    CASE INLIST(ALLTRIM(TempПоля.Тип),"Y", "B", "I", "N", "F")
                        команда = команда + " = 0"
                    CASE INLIST(ALLTRIM(TempПоля.Тип),"D")
                        команда = команда + " = {}"
                    CASE INLIST(ALLTRIM(TempПоля.Тип),"T")
                        команда = команда + " = datetime(null,null,null,null,null,null)"
                    CASE ALLTRIM(TempПоля.Тип) = "L"
                        команда = команда + " = .f."
                ENDCASE
                &команда
            ENDSCAN
            USE IN TempПоля
        ENDIF
        SELECT Таблицы
        * а затем по умолчанию
        IF !EMPTY(Таблицы.Родитель)
            команда = "this.КОД_Г = [" + EVALUATE("O" + ALLTRIM(Таблицы.Родитель)+ ".код ") +"]"
            &команда
        ENDIF
        команда = "SELECT C" + THIS.ТАБЛИЦА
        &команда
    ENDPROC
**
    PROCEDURE редактировать
        IF THIS.ВзятьПоля()
            SELECT TempПоля
            SCAN ALL
                команда = "this." +ALLTRIM(TempПоля.название)+ " = C" +ALLTRIM(таблицы.название)+"." +ALLTRIM(TempПоля.название)
                &команда
            ENDSCAN
            USE IN TempПоля
        ENDIF
        команда = "SELECT C" + THIS.ТАБЛИЦА
        &команда
    ENDPROC
**
    FUNCTION записать
        THIS.ВстатьНаМесто()
        IF !EMPTY(Таблицы.Родитель) AND EMPTY(THIS.КОД_Г)
            RETURN .F.
        ENDIF
        IF NOT this.ПроверитьНаличиеЗаписейВИсточнике()
            RETURN .f.
        endif

        *********************** проверка наличия записи с таким кодом ********
        * это необходимо, если мы переносим данные с другой машины и не хотим получить кучу дубликатов

        LOCAL m.вставить
        m.вставить = .T.
        IF !EMPTY(THIS.код)
            команда = "SELECT код AS код ;
                            where '" + THIS.код + "' == " +  ALLTRIM(Таблицы.Название) + ".код ;
                            FROM  "+ALLTRIM(Таблицы.Название)
            IF ОAPP.DBFS
                команда = команда+" into cursor temp"
                &команда
            ELSE
                =IIF( -1 = SQLEXEC(ОAPP.СОЕДИНЕНИЕ, команда, TEMP), .F., .T.)
            ENDIF

            IF USED("temp")
                SELECT TEMP
                IF ISNULL(TEMP.код) OR EMPTY(TEMP.код)
                    * нет такой записи
                    m.вставить = .T.
                ELSE
                    * есть такая запись
                    m.вставить = .F.
                ENDIF
                USE IN TEMP
            ENDIF
        ENDIF
        **********************************************************************
        IF m.вставить
            * проверка привилегий
            IF THIS.проверитьпривилегии("вставить")
                THIS.ВстатьНаМесто()
                *генерируем новый код записи
                IF EMPTY(THIS.код)
                    LOCAL m.ДлиннаКода
                    * определяем длинну строки и отнимаем 2 символа на префикс
                    m.ДлиннаКода = LEN(THIS.код)-2
                    IF ОAPP.DBFS
                        команда = "SELECT MAX(VAL(SUBSTR(код,3,m.ДлиннаКода))) AS код FROM "+ALLTRIM(Таблицы.Название)+ " into cursor temp"
                        &команда
                    ELSE
                        команда = "SELECT MAX(VAL(SUBSTR(код,3,?ДлиннаКода))) AS код FROM "+ALLTRIM(Таблицы.Название)
                        =IIF( -1 = SQLEXEC(ОAPP.СОЕДИНЕНИЕ, команда, TEMP), .F., .T.)
                    ENDIF

                    IF USED("temp")
                        SELECT TEMP
                        IF ISNULL(TEMP.код)
                            THIS.код = 1
                        ELSE
                            THIS.код = TEMP.код+1
                        ENDIF
                        USE IN TEMP
                    ELSE
                        THIS.код = 1
                    ENDIF
                    THIS.код = ОAPP.префикс+REPLICATE("0", m.ДлиннаКода-LEN(ALLTRIM(STR(THIS.код)))) + ALLTRIM(STR(THIS.код))
                ENDIF
                IF EMPTY(THIS.КомандаДляВставки)
                    ОAPP.ЗаполнитьКоманды(THIS.МЕСТО)
                ENDIF
                m.команда = THIS.КомандаДляВставки
                IF ОAPP.DBFS
                    &команда
                ELSE
                    = IIF( -1 = SQLEXEC(ОAPP.СОЕДИНЕНИЕ, команда), .F., .T.)
                ENDIF
            ENDIF
        ELSE
            IF THIS.проверитьпривилегии("изменить")
                IF EMPTY(THIS.КомандаДляИзменения)
                    ОAPP.ЗаполнитьКоманды(THIS.МЕСТО)
                ENDIF
                m.команда = THIS.КомандаДляИзменения
                IF ОAPP.DBFS
                    &команда
                ELSE
                    = IIF( -1 = SQLEXEC(ОAPP.СОЕДИНЕНИЕ, команда), .F., .T.)
                ENDIF
            ENDIF
        ENDIF
        команда = "SELECT C" + THIS.ТАБЛИЦА
        &команда
        IF m.вставить
            RETURN "new"
        ELSE
            RETURN "old"
        ENDIF
    ENDFUNC
**
    FUNCTION УдалитьСЗапросом
        IF 6=MESSAGEBOX("Вы действительно хотите удалить запись? ", 4+32+256, " Внимание! ")
            RETURN THIS.УДАЛИТЬ()
        ELSE
            RETURN .f.
        ENDIF
    ENDFUNC
**
    FUNCTION удалить
        * проверили привилегии
        IF !THIS.проверитьпривилегии("удалить")
            RETURN .F.
        ENDIF

        * взяли данные из записи
        THIS.редактировать()
        * запомнили с какой таблицей работаем :)
        THIS.ВстатьНаМесто()

        * это мы запомнили из какой таблицы запись удаляем
        m.таблица = UPPER(ALLTRIM(таблицы.название))

        * делаем выборку из таблиц у которых эта таблица является источником для поля
        команда = "SELECT таблицы.название as таблица , поля.название    as поле ;
                       FROM таблицы, поля ;
                       where таблицы.код == поля.код_г and UPPER(ALLTRIM(поля.источник)) ==  m.таблица "

        IF ОAPP.DBFS
            команда = команда+" into cursor temp"
            &команда
        ELSE
            =IIF( -1 = SQLEXEC(ОAPP.СОЕДИНЕНИЕ, команда, TEMP), .F., .T.)
        ENDIF

        * если выборка есть
        IF USED("temp") AND RECCOUNT("temp") > 0
            SELECT TEMP
            * если эта таблица является источником
            * начинаем перебирать записи по одной по одной и считать записи  в связанных таблицах
            SCAN ALL FOR !ISNULL(TEMP.таблица) AND !EMPTY(TEMP.таблица)

               * сколько у нас записей в связанных таблицах которые содержат такой же код в поле код?
                команда = "SELECT код as код ;
                                 FROM " + ALLTRIM(TEMP.таблица)+;
                    " where " + ALLTRIM(TEMP.таблица)+"." + ALLTRIM(TEMP.поле)+ " = [" +EVALUATE("O" + m.таблица + ".код ") + "]"+;
                    " into cursor temp1"

                &команда
                IF _TALLY >0
                    WAIT WINDOWS " Из таблицы " + ALLTRIM(TEMP.таблица) +" не удалены записи связанные с этой."
                    USE IN temp1
                    USE IN TEMP
                    команда = "SELECT C" + THIS.таблица
                    &команда
                    RETURN .F.
                ENDIF
                SELECT TEMP
            ENDSCAN
        ENDIF
        * ВСЕ ПРОШЛИ, НЕ НА ЧЕМ НЕ ЗАЦЕПИЛИСЬ
        IF USED("Temp")
            USE IN TEMP
        ENDIF
        IF USED("Temp1")
            USE IN temp1
        ENDIF

        * ТОГДА УДАЛЯЕМ ЗАПИСЬ
        команда = "SELECT C" + THIS.таблица
        &команда
        команда = "THIS.КОД = C" + THIS.таблица+ ".КОД"
        &команда
        команда = "THIS.КОД_Г = C" + THIS.таблица+ ".КОД_Г"
        &команда
        IF ОAPP.DBFS
            команда = " DELETE FROM " + THIS.таблица + " WHERE " + THIS.таблица + ".КОД = THIS.код"
            &команда
        ELSE
            команда = " DELETE FROM " + THIS.таблица + " WHERE " + THIS.таблица + ".КОД = ?THIS.код"
            = SQLEXEC(ОAPP.СОЕДИНЕНИЕ, команда), .F., .T.)
        ENDIF
        команда = "SELECT C" + THIS.таблица
        &команда
        RETURN .T.
    ENDFUNC
**
    FUNCTION взять
        LPARAMETERS m.код
        IF !this.проверитьпривилегии("взять")
            RETURN .f.
        endif
        this.ВстатьНаМесто()
        команда = ""
        IF INLIST(таблицы.виддокумен,"Система", "Справочник", "Документ")
              IF EMPTY(ALLTRIM(запрос))
                  WAIT WINDOWS " Не указана команда для показа данных "
                  RETURN .F.
              ELSE
                  команда = ALLTRIM(таблицы.запрос)
              ENDIF
        ENDIF
        IF  !EMPTY(this.Фильтр)
            команда = команда + ' ' + this.Фильтр
        ENDIF
        IF  !EMPTY(this.Порядок)
            команда = команда + ' ' + this.Порядок
        ENDIF        
        IF ОAPP.DBFS
            команда = команда + " INTO CURSOR C" +THIS.ТАБЛИЦА 
            * + " readwrite "
            &команда
        ELSE
            = IIF( -1 = SQLEXEC(ОAPP.СОЕДИНЕНИЕ, команда, "C" + THIS.ТАБЛИЦА), .f., .t.)
        ENDIF
        команда = "SELECT C" + THIS.ТАБЛИЦА
        &команда
        IF  !EMPTY(m.КОД)
            команда = "m.КОД=C" + THIS.ТАБЛИЦА+ ".КОД"
            LOCATE FOR EVALUATE(команда)
            IF !FOUND()
                GO top
            endif
        ENDIF
        RETURN .T.
    ENDFUNC
**
    FUNCTION показать
        LPARAMETERS m.код
        * если программист не предусмотрел на какую запись нужно встать
        IF EMPTY(m.код)
            * возмем данные о текущей записи
            m.код = THIS.код
        ENDIF
        IF THIS.проверитьпривилегии("показать")
            THIS.ВстатьНаМесто()
            IF (таблицы.виддокумен = "Справочник" OR таблицы.виддокумен = "Документ" OR таблицы.виддокумен = "Система")
                IF this.ЭкраннаяФорма = 0
                    THIS.ВЗЯТЬ(m.код)
                    команда = "SELECT C" + THIS.ТАБЛИЦА
                    &команда
                    команда = "DO FORM .\forms\" + THIS.ТАБЛИЦА+ ".scx"
                       &команда
                   ENDIF
                   this.ЭкраннаяФорма = 1
            ENDIF
        ENDIF
    ENDFUNC
**
    FUNCTION проверитьпривилегии
        LPARAMETERS m.привилегия
        PRIVATE m.таблица, m.можно
        m.таблица = ""
        m.можно = .F.

        THIS.ВстатьНаМесто()
        m.таблица = UPPER(ALLTRIM(таблицы.название))

        SELECT Привилегии.* ;
            FROM Пользователи, Привилегии, Роли;
            WHERE UPPER(ALLTRIM(ОAPP.пользователь)) == UPPER(ALLTRIM(Пользователи.название)); && сначала ищем такого пользователя
                and UPPER(ALLTRIM(Роли.Название)) == UPPER(ALLTRIM(Пользователи.Роль)) ; && затем ищем такую роль
                AND Роли.код = Привилегии.код_г ; && затем по роли определяем привилегии
                AND m.таблица == UPPER(ALLTRIM(Привилегии.пр_таблица)); && для какой то одной таблицы
            INTO CURSOR TempПривилегии

        IF _TALLY > 0
            DO CASE
                CASE m.привилегия = "взять"    AND TempПривилегии.пр_взять
                    m.можно = .T.
                CASE m.привилегия = "показать" AND TempПривилегии.пр_показать
                    m.можно = .T.
                CASE m.привилегия = "вставить" AND TempПривилегии.пр_вставить
                    m.можно = .T.
                CASE m.привилегия = "изменить" AND TempПривилегии.пр_изменить
                    m.можно = .T.
                CASE m.привилегия = "удалить" AND TempПривилегии.пр_удалить
                    m.можно = .T.
            ENDCASE
        ENDIF
        IF USED("TempПривилегии")
            USE IN TempПривилегии
        ENDIF
        IF !m.можно
            WAIT WINDOWS NOWAIT "Вам запрещено " + m.привилегия + ". Таблица: " + ALLTRIM(таблицы.название)
        ENDIF
        RETURN m.можно

    ENDFUNC

    FUNCTION НайтиПоКоду
        LPARAMETERS НужныйКод
        команда = "SELECT C" + THIS.ТАБЛИЦА
        &команда
        SCAN ALL FOR код == НужныйКод
            THIS.редактировать()
            RETURN .T.
        ENDSCAN
        RETURN .F.
    ENDFUNC

    FUNCTION ПроверитьНаличиеЗаписейВИсточнике
        * у нас есть объект с заполнеными свойствами
        * необходимо выбрать свойства объекта которые ссылаются на другую таблицу
         THIS.ВстатьНаМесто()
        LOCAL m.таблица
        m.таблица  = таблицы.код
        SELECT поля.название, поля.источник ;
            FROM поля, таблицы ;
            WHERE ALLTRIM(поля.код_г) == ALLTRIM(таблицы.код) ;
            AND таблицы.код == m.таблица  ;
            AND поля.виртуальное = .F. ;
            AND !empty(поля.источник) ;
            INTO CURSOR TempПоля

        SELECT TempПоля
        IF _TALLY = 0
            USE IN TempПоля
            RETURN .t.
        ENDIF
        * просканировать полученную таблицу
        local m.название, m.источник, m.результат
        m.результат = ""

        SCAN all
            m.название = TempПоля.название
            m.источник = TempПоля.источник

            * и проверить есть ли в таблице на которую ссылаются такие записи
            команда =           " select * from " + ALLTRIM(m.источник)
            команда = команда + " into cursor temp "
            команда = команда + " where код = this." + ALLTRIM(m.название)
            &команда

            SELECT temp
            IF _TALLY = 0
                m.результат = m.результат + CHR(13) + " Не найдена запись в " + ALLTRIM(m.источник) + " для " +ALLTRIM(m.название)
            ENDIF
        endscan
           USE IN TempПоля
           USE IN Temp
           IF !EMPTY(m.результат)
               WAIT windows m.результат
               RETURN .f.
           else
            RETURN .t.
        ENDIF

    ENDFUNC
ENDDEFINE

* БИБЛИОТЕКА НЕВИЗУАЛЬНЫХ КЛАССОВ
* ПОЛЬЗОВАТЕЛЬСКИЕ ОБЪЕКТЫ И БАЗОВЫЕ КЛАССЫ, ТИПА :
* Column, Header
***************************************************

DEFINE CLASS MyColumn AS COLUMN
    FONTNAME=C_FONTNAME
    FONTSIZE=C_FONTSIZE
    VISIBLE=.T.
    INDEX=0
    

    PROCEDURE INIT(m.тип, m.объект , m.порядок)
        WITH THIS
            .REMOVEOBJECT('Header1')
            .ADDOBJECT("Header","MyHeader", m.объект, m.порядок)
            .REMOVEOBJECT("Text1")
            DO CASE
                CASE m.тип = "CheckBox"
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
    объект = ""
    порядок = ""
    
    PROCEDURE init(m.объект, m.порядок)
    WITH THIS
        .объект = m.объект
        .порядок = m.порядок
    ENDWITH 
    
	PROCEDURE DblClick
	    команда =  'o' +this.объект+ '.порядок  = " order by '+this.порядок + '"'
	    &команда
	    THISFORMSET.обновить()
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
        THISFORMSET.событие(nKeyCode)
    ENDPROC

    PROCEDURE RIGHTCLICK
        THISFORMSET.событие(27)
    ENDPROC

    PROCEDURE DblClick
        THISFORMSET.событие(13)
    ENDPROC
    
    PROCEDURE Valid
        *thisformset.РассчитатьСтроку()
    ENDPROC
       
ENDDEFINE

DEFINE CLASS MyGridCheckBox AS CHECKBOX

    FONTNAME=C_FONTNAME
    FONTSIZE=C_FONTSIZE

    VISIBLE=.T.
    CAPTION = ""
    ALIGNMENT = 2

    PROCEDURE KEYPRESS(nKeyCode, nShiftAltCtrl )
        THISFORMSET.событие(nKeyCode)
    ENDPROC

    PROCEDURE RIGHTCLICK
        THISFORMSET.событие(27)
    ENDPROC

    PROCEDURE DblClick
        THISFORMSET.событие(13)
    ENDPROC

ENDDEFINE


Procedure NtoC
 parameter m.nValue, m.Decimals
 private all
 *
 * m.nValue      - (N) число для преобразовани
 * m.Decimals    - (L) выводить с копейками ?
 *
 * проверка суммы
 if empty(m.nValue)
    return 'Ноль рублей'+iif(!empty(m.Decimals),' 00 копеек','')+'.'
    * проверка что прислали число
 else
    if type('m.nValue') # 'N'
        return ''
    endif
 endif

 store '' to ret
 store 0  to tmp, tv, i

 declare names[6,3], numbers[19], tens[10], hound[10]

 names[1,1]='копейка'
 names[1,2]='копейки'
 names[1,3]='копеек'

 names[2,1]='рубль'
 names[2,2]='рубля'
 names[2,3]='рублей'

 names[3,1]='тысяча'
 names[3,2]='тысячи'
 names[3,3]='тысяч'

 names[4,1]='миллион'
 names[4,2]='миллиона'
 names[4,3]='миллионов'

 names[5,1]='миллиард'
 names[5,2]='миллиарда'
 names[5,3]='миллиардов'

 names[6,1]='триллион'
 names[6,2]='триллиона'
 names[6,3]='триллионов'

*единицы
 numbers[ 1]='один'
 numbers[ 2]='два'
 numbers[ 3]='три'
 numbers[ 4]='четыре'
 numbers[ 5]='пять'
 numbers[ 6]='шесть'
 numbers[ 7]='семь'
 numbers[ 8]='восемь'
 numbers[ 9]='девять'
 numbers[10]='десять'
 numbers[11]='одиннадцать'
 numbers[12]='двенадцать'
 numbers[13]='тринадцать'
 numbers[14]='четырнадцать'
 numbers[15]='пятнадцать'
 numbers[16]='шестнадцать'
 numbers[17]='семнадцать'
 numbers[18]='восемнадцать'
 numbers[19]='девятнадцать'

* десятки
 tens[ 1]='десть'
 tens[ 2]='двадцать'
 tens[ 3]='тридцать'
 tens[ 4]='сорок'
 tens[ 5]='пятьдесят'
 tens[ 6]='шестьдесят'
 tens[ 7]='семьдесят'
 tens[ 8]='восемьдесят'
 tens[ 9]='девяносто'

*сотни
 hound[ 1]='сто'
 hound[ 2]='двести'
 hound[ 3]='триста'
 hound[ 4]='четыреста'
 hound[ 5]='пятьсот'
 hound[ 6]='шестьсот'
 hound[ 7]='семьсот'
 hound[ 8]='восемьсот'
 hound[ 9]='девятьсот'

 *------------------------------------------------------------------------

 if !empty(m.Decimals)
    tmp=Round(mod( nValue * 100, 100),0)
    ret=' '+tran(tmp,'@L 99')+' '+x_end(tmp,1)+'.'
 else
    ret='.'
 endif

 i=2
 tmp=int(nValue)                       && убираем копейки
 ret=x_end(mod(tmp,100),2,.t.)+ret

 do while tmp > 0
    tv=mod(tmp,1000)                   && выделяем следующую тысячу
    if tmp=0 and i=2                   && значение 0
        ret='Ноль рублей'+ret          && готовим возврат
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
            s=s+' '+'одна'
        case nx=2
            s=s+' '+'две'
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
* Поиск копии программы, и если она работает то переключаемся на нее
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

m.ret=.F.                    && Возвращаемое значение
m.Mutex="My.Mutex.0001"        && Волшебное слово
m.Magic=0x12345678            && Магическое число (прямо Гарри Потер !)

hMutex=CreateMutex(0,0,m.Mutex)
* Если Mutex уже создан
If GetLastError()=ERROR_ALREADY_EXISTS
    CloseHandle(hMutex)                && Убъем хэндл

    hwnd=GetTopWindow(0)            && Начальное окно
    DO While hwnd # 0
        hwnd=GetWindow(hwnd,2)        && Следующее окно
        If hwnd # 0                    && Есть hWnd
            If GetWindowLong(hwnd,GWL_USERDATA)=m.Magic  && И в нем наше волшебное число
                * Функции вызываются только в такой последовательности
                * Иначе главное окно фокса остается "дырявым"
                SetForegroundWindow(hwnd)    && Переместим его под глаза юзера
                ShowWindow(hwnd,3)            && И распхнем пошире
                m.Ret=.T.
                Exit
            EndIf
        EndIf
    EndDo

Else
    SetWindowLong(_vfp.hwnd,GWL_USERDATA,m.Magic)    && Пишем в окно Волшебное число
    ReleaseMutex(hMutex)            && Mutex нам больше не нужен - он умрет вмсесте с процессом
EndIf
Return m.Ret



