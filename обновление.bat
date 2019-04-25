@ECHO off
title Обновление программы
cls

	echo         [][][][][][][][]
	echo         Создание архива............

if not exist Arhiv md Arhiv


@RAR a -r -ag[dd.MM.yyyy] .\Arhiv\arhiv.rar .\forms\*.* .\dbfs\*.* .\reports\*.* .\main.exe >nul
	@rem Архивируем все что нужно


cls

	echo         [][][][][][][][][][][][][]
	echo         Создание архива.................OK



        if exist temp\forms cls
	if exist temp\forms echo         [][][][][][][][][][][][][][][]                                          
	if exist temp\forms echo         Создание архива.................OK 
	if exist temp\forms echo         Обновление экранных форм..........


if exist temp\forms copy temp\forms\*.* forms\ >nul
	@rem Если в temp есть Forms то копируем


        if exist temp\forms cls
	if exist temp\forms echo         [][][][][][][][][][][][][][][][][][]  
	if exist temp\forms echo         Создание архива.................OK
	if exist temp\forms echo         Обновление экранных форм........OK 



        if exist temp\reports cls
	if exist temp\reports echo         [][][][][][][][][][][][][][][][][][][]  
	
	if exist temp\reports echo         Создание архива.................OK
	if exist temp\reports echo         Обновление экранных форм........OK
	if exist temp\reports echo         Обновление файлов отчета..........

if exist temp\reports copy temp\reports\*.* reports\ >nul

	

@rem Если в temp есть reports то копируем

	if exist temp\reports echo         [][][][][][][][][][][][][][][][][][][][][][]  

	if exist temp\reports echo         Создание архива.................OK
	if exist temp\reports echo         Обновление экранных форм........OK
	if exist temp\reports echo         Обновление файлов отчета........OK


        if exist temp\main.exe cls
	if exist temp\main.exe echo         [][][][][][][][][][][][][][][][][][][][][][][][][]  
	
	if exist temp\main.exe echo         Создание архива.................OK
	if exist temp\main.exe echo         Обновление экранных форм........OK
	if exist temp\main.exe echo         Обновление файлов отчета........OK
	if exist temp\main.exe echo         Обновление файлов отчета........OK
	if exist temp\main.exe echo         Обновление исполняемого файла...OK


if exist temp\main.exe copy temp\main.exe >nul

        if exist temp\main.exe cls
	if exist temp\main.exe echo         [][][][][][][][][][][][][][][][][][][][][][][][][][][][]  
	
	if exist temp\main.exe echo         Создание архива.................OK
	if exist temp\main.exe echo         Обновление экранных форм........OK
	if exist temp\main.exe echo         Обновление файлов отчета........OK
	if exist temp\main.exe echo         Обновление файлов отчета........OK
	if exist temp\main.exe echo         Обновление исполняемого файла...OK


        if exist temp\dbfs cls
	if exist temp\dbfs echo         [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]  
	
	if exist temp\dbfs echo         Создание архива.................OK
	if exist temp\dbfs echo         Обновление экранных форм........OK
	if exist temp\dbfs echo         Обновление файлов отчета........OK
	if exist temp\dbfs echo         Обновление файлов отчета........OK
	if exist temp\dbfs echo         Обновление исполняемого файла...OK
	if exist temp\dbfs echo         Обновление структуры баз..........



if exist temp\dbfs call main.exe u ".\Temp\dbfs\" >nul
	@rem Если в temp есть dbfs то запускаем main.exe с ключом "u"

        if exist temp\dbfs cls

	if exist temp\dbfs echo         [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]  
	
	if exist temp\dbfs echo         Создание архива.................OK
	if exist temp\dbfs echo         Обновление экранных форм........OK
	if exist temp\dbfs echo         Обновление файлов отчета........OK
	if exist temp\dbfs echo         Обновление файлов отчета........OK
	if exist temp\dbfs echo         Обновление исполняемого файла...OK
	if exist temp\dbfs echo         Обновление структуры баз........OK
	                   echo         Удаление временных файлов.......ОК
                          

if exist temp\forms echo Y|del temp\forms\*.* >nul
if exist temp\forms rd temp\forms\

if exist temp\reports echo Y|del temp\reports\*.* >nul
if exist temp\reports rd temp\reports\

if exist temp\dbfs echo Y|del temp\dbfs\*.* >nul
if exist temp\dbfs rd temp\dbfs\

if exist temp\main.exe echo Y|del temp\*.* >nul

