* +----------------------------------------------------------------- 
* | ��������� | FixLite 
* | ����� | �������� �.�., �� "�������������", �.������ 
* | ���� | 23/01/95 08:24:25 
* | ���������� | ������������� ������ DBF � ������� ��������� 
* | | ������ Not table/DBF file. 
* | | ������� ��� Visual FoxPro 
* +----------------------------------------------------------------- 

#define debug .f. 

*--------- Define constants ------------* 

#define err_Rec 1 
#define err_Field 2 
#define err_Type 3 
#define err_Len 4 
#define err_Dec 5 
#define err_Offset 6 

#define true .t. 
#define yes .t. 
#define false .f. 
#define no .f. 

*---------- Define substitutes -----------* 
#define beep ?? chr(7) 
#define msg wait window nowait 

parameter m.filename 
private all 

if empty(m.filename) 
beep 
=msgbox("���� �� ���������.","������", 16) 
return false 
endif 

m.filename=fullpath(m.filename) 
m.fileext=right(m.filename,4) 
if not like ('.?', m.fileext) 
m.filename=m.filename+'.DBF' 
endif 
if !file(m.filename) 
beep 
=msgbox("���� "+m.filename+" �� ������.","������",16) 
return false 
endif 
w=0 
x=0 && file handle for READ 
if not open(m.filename) && �������� ����� 
return 
endif 

m.filesize=fseek(x,0,2) && ������ ����� 
=fseek(x,0,0) 

m.sign=asc(fread(x,1)) && ��������� 
m.yy=asc(fread(x,1)) && ��� 
m.mm=asc(fread(x,1)) && ����� 
m.dd=asc(fread(x,1)) && ����� 

m.OldRecCnt=T2N(fread(x,4)) && ��������� ���-�� ������� 
m.OldHdrLen=T2N(fread(x,2)) && ��������� ����� ��������� 
m.OldRecLen=T2N(fread(x,2)) && ��������� ����� ������ 
=fseek(x,28) 
m.CDX=fread(x,1) && ���� �� CDX ? 
m.CodePage=fread(x,2) && ������� �������� ����� 
m.vfptype=.f. 

if not inlist(m.sign, 3, 48, 131, 139, 245)&& ������ ���������� �������� 
beep 
=msgbox("��������� ��������� �����.","������",16) 
do done 
return false 
endif 

m.vfptype=(m.sign=48) && ��������� Visual FoxPro 
m.memofile="" 
do case 
case JustExt(m.filename)='DBF' 
m.memofile=iif(File(ForceExt(m.filename,'FPT')),ForceExt(m.filename,'FPT'),'') 
case JustExt(m.filename)='SCX' 
m.memofile=iif(File(ForceExt(m.filename,'SCT')),ForceExt(m.filename,'SCT'),'') 
case JustExt(m.filename)='MNX' 
m.memofile=iif(File(ForceExt(m.filename,'MNT')),ForceExt(m.filename,'MNT'),'') 
case JustExt(m.filename)='LBX' 
m.memofile=iif(File(ForceExt(m.filename,'LBT')),ForceExt(m.filename,'LBT'),'') 
case JustExt(m.filename)='FRX' 
m.memofile=iif(File(ForceExt(m.filename,'FRT')),ForceExt(m.filename,'FRT'),'') 
case JustExt(m.filename)='VCX' 
m.memofile=iif(File(ForceExt(m.filename,'VCT')),ForceExt(m.filename,'VCT'),'') 
case JustExt(m.filename)='DBC' 
m.memofile=iif(File(ForceExt(m.filename,'DCT')),ForceExt(m.filename,'DCT'),'') 
endcase 

=fseek(x, 32) 
m.NewRecLen=1 
m.name=fread(x, 11) 
m.NumFields=0 

**** ������ ����� ����� ��� ����������� ����� ������ 

do while asc(m.name) <> 13 and m.numfields < 256 and not feof(x) 
m.numfields=m.numfields+1 && ������� ����� 
=fread(x,5) 
u=ASC(Fread(x,1)) 
m.NewRecLen=m.NewRecLen+u && ����� ���� 
=fread(x,15) 
m.name=fread(x,11) && ��� ���� 

enddo 

if m.numfields = 256 or asc(m.name) # 13 
if m.oldhdrlen / 2 = int( m.oldhdrlen/2) 
beep 
=msgbox("��������� ������� � ����� dBase III ��� Clipper","������",16) 
else 
beep 
=msgbox("������ ! �� ���� ����� ����� ��������� !","������",16) 
endif 
Do Done 
return false 
endif 
if m.vfptype && ���� Visual - ����� 263 ������� ��������� 
=FSeek(x, m.NumFields*32+33, 0) 
m.vfpbuffer=FRead(x,263) 
endif 

m.DBFError=No && �������� ������ ��� 
if m.vfptype 
m.NewHdrLen=(m.numfields+1)*32+1+263 && ���������� ����� ������ � �������������� Visual 
else 
m.NewHdrLen=(m.numfields+1)*32+1 && ���������� ����� ������ 
endif 
m.NewNumRec=int((filesize-m.NewHdrLen)/m.newreclen) && ����� ���-�� ������� 

if m.OldRecCnt = m.NewNumRec and ; 
m.OldHdrLen = m.NewHdrLen and ; 
m.OldRecLen = m.NewRecLen 

* =msgbox('� �� ����� ������','������',16) 

else 
m.DBFError=Yes 
endif 

m.RenDBFName=ForceExt(m.filename,'OLD') 
m.RenFPTName=ForceExt(m.filename,'FPK') 

*--- ������ ����������� 

#if debug 
m.DBFError=Yes 
#endif 

if m.DBFError 

wait window nowait '������ ����������� ...' 

=fseek(x,0,0) 
w=fcreate('FIXED.$$$') 
=fwrite( w, chr(m.sign) ,1) 
=fwrite( w, chr(year(date())-1900),1) 
=fwrite( w, chr(month(date())),1) 
=fwrite( w, chr(day(date())),1) 
=fwrite( w, n2t(m.NewNumRec,4),4) 
=fwrite( w, n2t(m.NewHdrLen,2),2) 
=fwrite( w, n2t(m.NewRecLen,2),2) 
=fwrite( w, repl( chr(0),16), 16) 
=fwrite( w, m.CDX,1) 
=fwrite( w, m.CodePage, 2) 
=fwrite( w, chr(0), 1) 
=fseek( x, 32, 0) 
=fwrite( w, fread(x, m.numfields*32+1)) && ���������� ��������� 

if m.vfptype && ��� Visual - ���������� ��������� ��� ����� READ 
=fseek(x,263,1) 
=fwrite(w, m.vfpbuffer, 263) && � �������� ��� ��� CREATE 
endif 
for i=1 to m.NewNumRec 
=fwrite( w, fread( x, m.NewRecLen)) 
next 
=fwrite(w, chr(26)) && Table ShwartzNegger 
=fclose(x) 
=fclose(w) 

w=0 
x=0 
if file(m.renDBFName) 
erase (m.renDBFName) 
endif 
rename (m.filename) to (m.RenDBFName) 
rename FIXED.$$$ to (m.filename) 

wait clear 
else 
=fclose(x) 
x=0 
endif 

if not empty(m.memofile) && ���� ��������� ���� ���������� 
fpt_name=m.memofile && ���� �� ������������ 
if not file(fpt_name) 
beep 
=msgbox("�� ���� ����� ��������������� ���� ����������.","������",16) 
do done 
return false 
endif 
if file(m.RenFPTName) 
erase (m.RenFPTName) 
endif 
* ��������� ����� 
copy file (fpt_name) to (m.renFPTName) 
if not open( fpt_name, true ) && ������� �� ������ 
do done 
return false 
endif 
* ������ 4 ����� - ���-�� ������� 
oldrec=T2N(Fread( x, 4), true) && ������ ���-�� ������� 
* 2 ����� ���������� 
=fread( x, 2) 
* ������� ��������� 2 ����� 
reclen=T2N(fread( x, 2), true) && ����� ������ 
if reclen < 1 or reclen > 16384 
beep 
=msgbox("������������ ������ ����� � "+fpt_name,"������",16) 
Do Done 
return false 
endif 
if reclen < 33 
reclen=reclen*512 
endif 
filelen=fseek(x,0,2) 
numrecs=int(filelen/reclen) 
if numrecs < filelen/reclen 
numrecs=numrecs-1 
endif 
if numrecs # oldrec 
=fseek(x, 0, 0) 
=fwrite( x, N2T(numrecs,4,true), 4) 
* �������� ����� ���-�� ������� 
* =msgbox("���� ���������� ���������","������",16) 
endif 
=fclose(x) 
x=0 
endif 
flush 
do done 
olderr=on('error') 
on error do locerr with error() 
use (m.filename) 
on error &olderr 
use 
return true 

procedure locerr 
parameter m.nerr 
if inlist( m.nerr, 26, 114, 1707 ) 
return 
endif 
=msgbox("�� ���� ��������� ���������������� ���� "+m.filename,"������",16) 

* +----------------------------------------------------------------- 
* | ��������� | T2N 
* | ���������� | Convert text to internal number format 
* +----------------------------------------------------------------- 
procedure T2N 
parameter m.str, m.overside 
private i,j,k, m.start, m.end, m.step, m.str, m.overside 
store 0 to j,k 

if m.overside 
m.start=len(m.str) 
m.end=1 
m.step=-1 
else 
m.start=1 
m.end=len(m.str) 
m.step=1 
endif 

j=1 
for i=m.start to m.end step m.step 
k=k+asc(substr(m.str,i,1))*j 
j=j*256 
next 
return k 

* +----------------------------------------------------------------- 
* | ��������� | N2T 
* | ���������� | Convert number to internal number format (as ascii) 
* +----------------------------------------------------------------- 
procedure N2T 
parameter m.num, m.len, m.overside 
private i, s, j, l, m.len, m.overside 
s='' 
do while m.num > 0 
j=mod(m.num, 256) 
if m.overside 
s=chr(j)+s 
else 
s=s+chr(j) 
endif 
m.num=int(m.num/256) 
enddo 
if len(s) <> m.len 
if m.overside 
s=right(s,m.len) 
s=padl(s,m.len,chr(0)) 
else 
s=left(s,m.len) 
s=padr(s,m.len,chr(0)) 
endif 
endif 
return s 

* +----------------------------------------------------------------- 
* | ��������� | Open 
* | ���������� | Open file to X FCHAN handler 
* +----------------------------------------------------------------- 
procedure open 
parameter m.filename,m.ForRW && set m.forRW for Read and Write 
m.filename=upper(fullpath(m.filename)) 
x=fopen(m.filename,iif(m.ForRW,2,0)) 
if x < 0 
fr=ferror() 
do case 
case fr=2 
ms=m.filename+' �� ������.' 
case fr=4 
ms='������� ������� ����� ������.' 
case fr=5 
ms='��� ������� � '+m.filename 
case fr=8 
ms='�� ������� ������.' 
case fr=31 
ms='�� ���������� �������� ����� '+m.filename 
endcase 
beep 
=msgbox('������ ��� �������� ����� "'+ms+'"',"������",16) 
return .f. 
endif 

procedure Done 
if x > 0 
=fclose(x) 
endif[/code]

