@ECHO off
title ���������� �ணࠬ��
cls

	echo         [][][][][][][][]
	echo         �������� ��娢�............

if not exist Arhiv md Arhiv


@RAR a -r -ag[dd.MM.yyyy] .\Arhiv\arhiv.rar .\forms\*.* .\dbfs\*.* .\reports\*.* .\main.exe >nul
	@rem ��娢��㥬 �� �� �㦭�


cls

	echo         [][][][][][][][][][][][][]
	echo         �������� ��娢�.................OK



        if exist temp\forms cls
	if exist temp\forms echo         [][][][][][][][][][][][][][][]                                          
	if exist temp\forms echo         �������� ��娢�.................OK 
	if exist temp\forms echo         ���������� �࠭��� ��..........


if exist temp\forms copy temp\forms\*.* forms\ >nul
	@rem �᫨ � temp ���� Forms � �����㥬


        if exist temp\forms cls
	if exist temp\forms echo         [][][][][][][][][][][][][][][][][][]  
	if exist temp\forms echo         �������� ��娢�.................OK
	if exist temp\forms echo         ���������� �࠭��� ��........OK 



        if exist temp\reports cls
	if exist temp\reports echo         [][][][][][][][][][][][][][][][][][][]  
	
	if exist temp\reports echo         �������� ��娢�.................OK
	if exist temp\reports echo         ���������� �࠭��� ��........OK
	if exist temp\reports echo         ���������� 䠩��� ����..........

if exist temp\reports copy temp\reports\*.* reports\ >nul

	

@rem �᫨ � temp ���� reports � �����㥬

	if exist temp\reports echo         [][][][][][][][][][][][][][][][][][][][][][]  

	if exist temp\reports echo         �������� ��娢�.................OK
	if exist temp\reports echo         ���������� �࠭��� ��........OK
	if exist temp\reports echo         ���������� 䠩��� ����........OK


        if exist temp\main.exe cls
	if exist temp\main.exe echo         [][][][][][][][][][][][][][][][][][][][][][][][][]  
	
	if exist temp\main.exe echo         �������� ��娢�.................OK
	if exist temp\main.exe echo         ���������� �࠭��� ��........OK
	if exist temp\main.exe echo         ���������� 䠩��� ����........OK
	if exist temp\main.exe echo         ���������� 䠩��� ����........OK
	if exist temp\main.exe echo         ���������� �ᯮ��塞��� 䠩��...OK


if exist temp\main.exe copy temp\main.exe >nul

        if exist temp\main.exe cls
	if exist temp\main.exe echo         [][][][][][][][][][][][][][][][][][][][][][][][][][][][]  
	
	if exist temp\main.exe echo         �������� ��娢�.................OK
	if exist temp\main.exe echo         ���������� �࠭��� ��........OK
	if exist temp\main.exe echo         ���������� 䠩��� ����........OK
	if exist temp\main.exe echo         ���������� 䠩��� ����........OK
	if exist temp\main.exe echo         ���������� �ᯮ��塞��� 䠩��...OK


        if exist temp\dbfs cls
	if exist temp\dbfs echo         [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]  
	
	if exist temp\dbfs echo         �������� ��娢�.................OK
	if exist temp\dbfs echo         ���������� �࠭��� ��........OK
	if exist temp\dbfs echo         ���������� 䠩��� ����........OK
	if exist temp\dbfs echo         ���������� 䠩��� ����........OK
	if exist temp\dbfs echo         ���������� �ᯮ��塞��� 䠩��...OK
	if exist temp\dbfs echo         ���������� �������� ���..........



if exist temp\dbfs call main.exe u ".\Temp\dbfs\" >nul
	@rem �᫨ � temp ���� dbfs � ����᪠�� main.exe � ���箬 "u"

        if exist temp\dbfs cls

	if exist temp\dbfs echo         [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]  
	
	if exist temp\dbfs echo         �������� ��娢�.................OK
	if exist temp\dbfs echo         ���������� �࠭��� ��........OK
	if exist temp\dbfs echo         ���������� 䠩��� ����........OK
	if exist temp\dbfs echo         ���������� 䠩��� ����........OK
	if exist temp\dbfs echo         ���������� �ᯮ��塞��� 䠩��...OK
	if exist temp\dbfs echo         ���������� �������� ���........OK
	                   echo         �������� �६����� 䠩���.......��
                          

if exist temp\forms echo Y|del temp\forms\*.* >nul
if exist temp\forms rd temp\forms\

if exist temp\reports echo Y|del temp\reports\*.* >nul
if exist temp\reports rd temp\reports\

if exist temp\dbfs echo Y|del temp\dbfs\*.* >nul
if exist temp\dbfs rd temp\dbfs\

if exist temp\main.exe echo Y|del temp\*.* >nul

