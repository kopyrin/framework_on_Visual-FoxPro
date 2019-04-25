*
* Всякие там разные прибамбасы
* © Пирожков В.В. 2000
* 18.04.2000 23:37
*
*
*


Define class progressform as form
	Desktop=.t.
	AlwaysOnTop=.t.
	MinButton=.f.
	MaxButton=.f.
	Closable=.f.
	ControlBox=.f.
	BorderStyle=2
	AutoCenter=.t.
	Caption='Состояние процесса'
	Width=300
	Height=100
	CancelButton=.F.
	Cancel=.F.
	Text=""
	Value=0
	
	add object label as label with ;
		fontname='MS Sans Serif',;
		fontsize=8,;
		alignment=2,;
		wordwrap=.t.,;
		top=5,;
		left=5,;
		width=290,;
		height=40,;
		caption='Процесс выполнения',;
		autosize=.t.		
		
	Procedure Init( m.nValue, m.cText, m.cCaption, m.lCancelButton)
	with this
		.addobject('progress','progress')
		with .progress
			.top=70
			.left=10
			.width=this.width-20
			.height=22
			.BorderWidth=0
*			.backcolor=getsyscolor(5)
			.visible=.t.
		endwith
		if vartype(m.cText)='C'
			.Text=m.cText
		endif
		if vartype(m.cCaption)='C'
			.Caption=m.cCaption
		endif
	endwith

	Procedure CancelButton_Assign( NewVal )
	NewVal=!empty(NewVal)
	with this
		if NewVal
			.height=.height+30
			.addobject("cmdCancel","CancelButton")
			.cmdCancel.Top=.Height-24-5
			.cmdCancel.Left=(.Width-.cmdCancel.Width)/2
			.cmdCancel.Visible=.t.
		else
			if .height>300
				if vartype(cmdCancel)='O'
					.RemoveObject('cmdCancel')
				endif
				.Cancel=.F.
				.CancelButton=.F.
				.height=300
			endif
		endif
	endwith

	procedure Text_Assign( m.cText)
	with this
		if vartype(m.cText)='C'
			.text=m.cText
			with .label
				.autosize=.F.
				.caption=m.cText
				.left=5
				.top=5
				.width=290
				.height=40
				.autosize=.T.
			endwith
		endif				
	
	endwith

	Procedure Value_Assign( m.nValue )
	with this
		if vartype(m.nValue)='N'
			.progress.value=m.nValue
		endif
	endwith

enddefine
	
Define class CancelButton as commandbutton
	FontName='MS Sans Serif'
	FontSize=8
	Caption='\<Отмена'
	Cancel=.t.
	Width=80
	Height=24
	
	Procedure Click
	thisform.cancel=.t.

enddefine

Define class Info as Form 
	DeskTop=.t.
	AlwaysOnTop=.t.
	MinButton=.f.
	MaxButton=.f.
	Closable=.f.
	ControlBox=.f.
	AutoCenter=.t.
	BorderStyle=2
	TitleBar=0
	Width=300
	Height=60
	Text=""

	add object label as label with ;
		fontname='MS Sans Serif',;
		fontsize=8,;
		alignment=2,;
		wordwrap=.t.,;
		top=2,;
		left=2,;
		width=296,;
		height=56,;
		caption='',;
		autosize=.t.		

	Procedure Init( m.cText)
	with this
		if not empty(m.cText)
			.text=m.cText
		else
			.text="Немного подождите ..."
		endif
	endwith
		
	Procedure Text_Assign( m.cText )
	with this
		If PCount()=0
			This.Release
		endif

		if vartype(m.cText)='C'
			.text=m.cText
			with .label
				.autosize=.f.
				.left=2
				.top=2
				.width=296
				.height=56
				.caption=m.cText
				.autosize=.t.
			endwith
		endif				
	
	endwith

enddefine


**************************************************
*-- Class:        progress (v:\vcr\classes\basectrl.vcx)
*-- ParentClass:  control
*-- BaseClass:    control
*-- Time Stamp:   10/18/00 04:40:00 PM
*
*
DEFINE CLASS progress AS control


	Width = 294
	Height = 31
	BorderWidth = 1
	SpecialEffect = 1
	*-- Specifies the current state of a control.
	value = 0
	*-- Specifies the name of the font used to display text.
	fontname = 'MS Sans Serif'
	*-- Specifies the font size for text displayed with an object.
	fontsize = 8
	Name = "progress"

	*-- Specifies if the text is bold.
	fontbold = .F.


	ADD OBJECT bar AS shape WITH ;
		Top = 1, ;
		Left = 1, ;
		Height = 31, ;
		Width = 135, ;
		BorderStyle = 0, ;
		BorderWidth = 0, ;
		BackColor = RGB(0,0,128), ;
		Name = "Bar"


	ADD OBJECT lblperc1 AS label WITH ;
		FontName = "MS Sans Serif", ;
		FontSize = 8, ;
		BackStyle = 0, ;
		Caption = "0", ;
		Height = 15, ;
		Left = 128, ;
		Top = 7, ;
		Width = 30, ;
		Name = "lblPerc1"


	ADD OBJECT lblperc2 AS label WITH ;
		FontName = "MS Sans Serif", ;
		FontSize = 8, ;
		BackStyle = 0, ;
		Caption = "0", ;
		Height = 15, ;
		Left = 128, ;
		Top = 7, ;
		Width = 30, ;
		Name = "lblPerc2"


	ADD OBJECT topline AS line WITH ;
		Height = 0, ;
		Left = 0, ;
		Top = 0, ;
		Width = 294, ;
		Name = "TopLine"


	ADD OBJECT leftline AS line WITH ;
		Height = 35, ;
		Left = 0, ;
		Top = 0, ;
		Width = 0, ;
		Name = "LeftLine"


	ADD OBJECT bottomline AS line WITH ;
		Height = 0, ;
		Left = 0, ;
		Top = 30, ;
		Width = 292, ;
		Name = "BottomLine"


	ADD OBJECT rightline AS line WITH ;
		Height = 30, ;
		Left = 293, ;
		Top = 0, ;
		Width = 0, ;
		Name = "RightLine"


	HIDDEN PROCEDURE value_assign
		LPARAMETERS vNewVal
		* vNewVal must be value from 0 to 1
		if vartype(m.vNewVal)#'N'
			Return .F.
		endif
		if not between(m.vNewVal,0,1)
			Return .F.
		endif
		with this
			.value = m.vNewVal
			.lblPerc1.Caption=tran(.Value*100,'999%')
			.lblPerc2.Caption=.lblPerc1.Caption

			.Bar.Width=(.width-1)*m.vNewVal

			if .Bar.Width > .lblPerc2.Left
				if .Bar.Left + .Bar.Width - 1 >= ;
					.lblPerc2.Left + .lblPerc1.Width - 1

					.lblPerc2.Width = .lblPerc1.Width
				else

					.lblPerc2.Width = ;
						.Bar.Left + .Bar.Width - ;
						.lblPerc2.Left - 1

				endif
			else
				.lblPerc2.width=0
			endif
		endwith
	ENDPROC


	HIDDEN PROCEDURE fontname_assign
		LPARAMETERS vNewVal
		*To do: Modify this routine for the Assign method
		THIS.FontName = m.vNewVal
		THIS.lblPerc1.FontName = m.vNewVal
		THIS.lblPerc2.FontName = m.vNewVal
	ENDPROC


	HIDDEN PROCEDURE fontsize_assign
		LPARAMETERS vNewVal
		*To do: Modify this routine for the Assign method
		THIS.FontSize = m.vNewVal
		THIS.lblPerc1.FontSize = m.vNewVal
		THIS.lblPerc2.FontSize = m.vNewVal
	ENDPROC


	HIDDEN PROCEDURE fontbold_assign
		LPARAMETERS vNewVal
		*To do: Modify this routine for the Assign method
		THIS.FontBold = m.vNewVal
		THIS.lblPerc1.FontBold = m.vNewVal
		THIS.lblPerc2.FontBold = m.vNewVal
	ENDPROC


	PROCEDURE borderwidth_assign
		LPARAMETERS vNewVal
		*To do: Modify this routine for the Assign method
		with this
			.BorderWidth = m.vNewVal
			.TopLine.Visible=.BorderWidth=0
			.LeftLine.Visible=.BorderWidth=0
			.BottomLine.Visible=.BorderWidth=0
			.RightLine.Visible=.BorderWidth=0

		endwith
	ENDPROC


	PROCEDURE Init
		DECLARE long GetSysColor in Win32api integer iColorIndex 
		with this
			.fontname=iif(empty(.fontname),_fontname,.fontname)
			.fontsize=iif(empty(.fontsize),8,.fontsize)
			.fontbold=iif(empty(.fontbold),.f.,.fontbold)
			.BackColor=.BackColor
			.BackStyle=.BackStyle

			.lblPerc1.ForeColor=GetSysColor(18)
			.lblPerc2.ForeColor=GetSysColor(14)
			.lblPerc2.width=0

			.TopLine.BorderColor=GetSysColor(3)
			.LeftLine.BorderColor=GetSysColor(3)
			.BottomLine.BorderColor=GetSysColor(5)
			.RightLine.BorderColor=GetSysColor(5)

			.BorderWidth=.BorderWidth

			.Bar.BackColor=GetSysColor(13)
			.resize

		endwith
	ENDPROC


	PROCEDURE Resize
		with this
			.Bar.Width=0
			.Bar.Height=.Height-1

			.TopLine.Width=.Width
			.LeftLine.Height=.Height
			.BottomLine.Top=.Height-1
			.BottomLine.Width=.Width
			.RightLine.Left=.Width-1
			.RightLine.Height=.Height

			.lblPerc1.Left=int(.width/2-.lblPerc1.width/2)
			.lblPerc1.Top=int(.height/2-.lblPerc1.height/2)
			.lblPerc2.Left=.lblPerc1.Left
			.lblPerc2.Top=.lblPerc1.Top
			.lblPerc1.Caption=tran(.Value*100,'999%')
			.lblPerc2.Caption=.lblPerc1.Caption

		endwith
	ENDPROC


ENDDEFINE
*
*-- EndDefine: progress
**************************************************
