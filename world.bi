 
 #Define MAXLINES   1000  ' max 1000  lines of scene. is it enough???   >:-?
 #Define MAXSPHERES 10000 ' max 10000 spheres , enough???

 Dim Shared As String scene(MAXLINES) ' to load scene file
 Dim Shared As Long nspheres=MAXSPHERES
 Dim Shared As sphere rtspheres(nspheres-1)
 
 Dim Shared As Integer scx,scy ' screen resolution
 Dim Shared As double  obsx,obsy,obsz ' observer position
 Dim Shared As Integer obsalt,obsazm ' altitude, azimut
 Dim Shared As Integer obsfl ' focal lenght
 
 Dim Shared As Double ambient(8) ' ambient color
 Dim Shared As Double lights(10,6) ' ambient lights (one or more, max 10)

 Dim Shared As Integer nlamps=9
 Dim Shared As lamp  rtlamps(nlamps) ' max ten(0-9)
 
 Dim Shared As patch rttiles(1) ' floor tiles colors (x2) in chess mode            

 Dim Shared As light rtambient ' ambient color
 Dim Shared As light rtskyzen  ' sky zenith color
 Dim Shared As light rtskyhor  ' sky horizon color
 
Sub read_scene()
	Dim As Integer a,f,g
	Dim As string sa,sb

	' in order to avoid format errors, reformat it
	Dim As String temp(MAXLINES)
	g=0
	For f=0 To MAXLINES
		sa=scene(f)
		a=1
		While a
			a=InStr(sa,Chr(9)) ' eliminate CHR(9) (tab)
			If a Then Mid(sa,a)=" "
		Wend
		sa=Trim(sa) ' eliminate spaces
		If Left(sa,1)=";" Then sa="" ' eliminate comments
		a=InStr(sa,";") 
		If a Then
			sa=Left(sa,a-1)
		EndIf
		If sa<>"" Then temp(g)=Trim(sa):g+=1 ' eliminate empty lines
	Next
	g-=1
	
	'For f=0 To g
	'	Print temp(f)
	'Next

	' create world
	For f=0 To g
		sa=temp(f)
		sa=Trim(sa)
		
		If sa="" Then Continue For
		
		If sa="[RESOLUTION]" Then
			sa=temp(f+1)
			scx=Val(sa)
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			scy=Val(sa)
			f+=1
		EndIf
		
		If sa="[OBSERVER]" Then
			sa=temp(f+1)
			obsx=Val(sa)
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			obsy=Val(sa)	
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			obsz=Val(sa)	
			f+=1		
		EndIf
		
		If sa="[ALTITUDE]" Then
			sa=temp(f+1)
			obsalt=Val(sa)		
			f+=1	
		EndIf
		
		If sa="[AZIMUT]" Then
			sa=temp(f+1)
			obsazm=Val(sa)		
			f+=1				
		EndIf
		
		If sa="[FOCAL]" Then
			sa=temp(f+1)
			obsfl=Val(sa)		
			f+=1			
		EndIf
		
		If sa="[TILES]" Then
			' primer azulejo
			sa=temp(f+1)
			a=InStr(sa,"(") ' --------- position XYZ
			sa=Mid(sa,a+1)
			rttiles(0).pos_(0)=Val(sa)
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			rttiles(0).pos_(1)=Val(sa)	
			a=Instr(sa,",")
			sa=Mid(sa,a+1)
			rttiles(0).pos_(2)=Val(sa)
			'----------
			a=InStr(sa,"(") ' --------- normal UVW
			sa=Mid(sa,a+1)
			rttiles(0).normal(0)=Val(sa)
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			rttiles(0).normal(1)=Val(sa)	
			a=Instr(sa,",")
			sa=Mid(sa,a+1)
			rttiles(0).normal(2)=Val(sa)
			'----------
			a=InStr(sa,"<") ' --------- color RGB
			sa=Mid(sa,a+1)
			rttiles(0).color_(0)=Val(sa)
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			rttiles(0).color_(1)=Val(sa)	
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			rttiles(0).color_(2)=Val(sa)						
						
						
			' segundo azulejo	
			sa=temp(f+2)
			a=InStr(sa,"(") ' --------- position XYZ
			sa=Mid(sa,a+1)
			rttiles(1).pos_(0)=Val(sa)
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			rttiles(1).pos_(1)=Val(sa)	
			a=Instr(sa,",")
			sa=Mid(sa,a+1)
			rttiles(1).pos_(2)=Val(sa)
			'----------
			a=InStr(sa,"(") ' --------- normal UVW
			sa=Mid(sa,a+1)
			rttiles(1).normal(0)=Val(sa)
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			rttiles(1).normal(1)=Val(sa)	
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			rttiles(1).normal(2)=Val(sa)
			'----------
			a=InStr(sa,"<") ' --------- color RGB
			sa=Mid(sa,a+1)
			rttiles(1).color_(0)=Val(sa)
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			rttiles(1).color_(1)=Val(sa)	
			a=Instr(sa,",")
			sa=Mid(sa,a+1)
			rttiles(1).color_(2)=Val(sa)	
			
			f+=2				
		EndIf
		   
		If sa="[AMBIENT]" Then
			sa=temp(f+1)
			a=InStr(sa,"<") ' --------- ambient color RGB
			sa=Mid(sa,a+1)
			rtambient.r=Val(sa)
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			rtambient.g=Val(sa)	
			a=Instr(sa,",")
			sa=Mid(sa,a+1)
			rtambient.b=Val(sa)
			'----------
			a=InStr(sa,"<") ' --------- sky zenith color
			sa=Mid(sa,a+1)
			rtskyzen.r=Val(sa)
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			rtskyzen.g=Val(sa)	
			a=Instr(sa,",")
			sa=Mid(sa,a+1)
			rtskyzen.b=Val(sa)
			'----------
			a=InStr(sa,"<") ' --------- sky horizon color
			sa=Mid(sa,a+1)
			rtskyhor.r=Val(sa)
			a=InStr(sa,",")
			sa=Mid(sa,a+1)
			rtskyhor.g=Val(sa)	
			a=Instr(sa,",")
			sa=Mid(sa,a+1)
			rtskyhor.b=Val(sa)
			f+=1		
		EndIf
		
		If sa="[LIGHTS]" Then
			nlamps=0 ' start with '0'
			sa=temp(f+1)
			While Left(sa,1)<>"[" ' look for all lights (min. 1)
				a=InStr(sa,"(") ' --------- light position XYZ
				sa=Mid(sa,a+1)
				rtlamps(nlamps).pos_(0)=Val(sa)
				a=InStr(sa,",")
				sa=Mid(sa,a+1)
				rtlamps(nlamps).pos_(1)=Val(sa)	
				a=Instr(sa,",")
				sa=Mid(sa,a+1)
				rtlamps(nlamps).pos_(2)=Val(sa)
				'----------			
				a=InStr(sa,":") ' --------- light radius
				sa=Mid(sa,a+1)
				rtlamps(nlamps).radius=Val(sa)
				'-----------
				a=InStr(sa,"<") ' --------- light color RGB
				sa=Mid(sa,a+1)
				rtlamps(nlamps).color_(0)=Val(sa)
				a=InStr(sa,",")
				sa=Mid(sa,a+1)
				rtlamps(nlamps).color_(1)=Val(sa)	
				a=Instr(sa,",")
				sa=Mid(sa,a+1)
				rtlamps(nlamps).color_(2)=Val(sa)	
				'-----------
				nlamps+=1 ' lamp created	
				If nlamps=10 Then Exit While ' max 10 lights		
				sa=temp(f+1+nlamps)	
			Wend
			f+=nlamps
		EndIf
		
		If sa="[SCENE]" Then
			' calculo de repeticiones de esferas en casos de lineas usando el comando "#"
			Dim As single x1,x2,x3,y1,y2,y3,z1,z2,z3,r1,r2,r3 ' uso SINGLE temporalmente, luego guardo como DOUBLE
			Dim As Integer repeticiones,primeraesfera=0
			Dim As Integer esferaactual
			nspheres=0 ' start with '0'
			f+=1
			sa=temp(f)
			While 1 ' infinito, ya no sale, dado que es la ultima entidad a tratar
				' si lleva "#" delante, es una repeticion (linea de esferas)
				If Left(sa,1)="#" Then 
					'Print "inicio:";sa
					esferaactual=nspheres-1 ' esfera anterior para repetir su color y tipo
					'----------			color_
					a=InStr(sa,"#") ' --------- repeticiones
					sa=Mid(sa,a+1)
					repeticiones=Val(Trim(sa))
					a=InStr(sa,"(") ' --------- sphere position XYZ
					sa=Mid(sa,a+1)
					rtspheres(nspheres).pos_(0)=Val(sa)
					a=InStr(sa,",")
					sa=Mid(sa,a+1)
					rtspheres(nspheres).pos_(1)=Val(sa)	
					a=Instr(sa,",")
					sa=Mid(sa,a+1)
					rtspheres(nspheres).pos_(2)=Val(sa)	
					a=InStr(sa,":") ' --------- sphere radius
					sa=Mid(sa,a+1)
					rtspheres(nspheres).radius=Val(sa)
					' guardo los datos de la esfera destino (hacia donde queremos llegar)
					x2=rtspheres(nspheres).pos_(0)
					y2=rtspheres(nspheres).pos_(1)
					z2=rtspheres(nspheres).pos_(2)
					r2=rtspheres(nspheres).radius
					' obtengo el factor de escala para llegar de la esfera 1 a la espera 2
					x3=(x2-x1)/repeticiones
					y3=(y2-y1)/repeticiones
					z3=(z2-z1)/repeticiones
					r3=(r2-r1)/repeticiones
					' y ahora la magia: creamos "n" esferas entre la 1 y la 2
					For g=1 To repeticiones
						x1=x1+x3
						y1=y1+y3
						z1=z1+z3
						r1=r1+r3
						rtspheres(nspheres).pos_(0)=x1
						rtspheres(nspheres).pos_(1)=y1	
						rtspheres(nspheres).pos_(2)=z1
						rtspheres(nspheres).radius =r1
						' el color y el tipo de esfera es el de la esfera inicial
						rtspheres(nspheres).color_(0)=rtspheres(esferaactual).color_(0)
						rtspheres(nspheres).color_(1)=rtspheres(esferaactual).color_(1)	
						rtspheres(nspheres).color_(2)=rtspheres(esferaactual).color_(2)
						rtspheres(nspheres).type_    =rtspheres(esferaactual).type_
						nspheres+=1
					Next
					'nspheres-=1
					'f+=1
					'Print "sig:";temp(f):sleep
					GoTo cont
				EndIf
				primeraesfera=0
				a=InStr(sa,"<") ' --------- sphere color RGB
				sa=Mid(sa,a+1)
				rtspheres(nspheres).color_(0)=Val(sa)
				a=InStr(sa,",")
				sa=Mid(sa,a+1)
				rtspheres(nspheres).color_(1)=Val(sa)	
				a=Instr(sa,",")
				sa=Mid(sa,a+1)
				rtspheres(nspheres).color_(2)=Val(sa)
				'----------			color_
				a=InStr(sa,">") ' --------- sphere type: 0=DULL, 1=BRIGHT, 2=MIRROR
				sa=Mid(sa,a+1)
				rtspheres(nspheres).type_=Val(Trim(sa))
				'----------
				a=InStr(sa,"(") ' --------- sphere position XYZ
				sa=Mid(sa,a+1)
				rtspheres(nspheres).pos_(0)=Val(sa)
				a=InStr(sa,",")
				sa=Mid(sa,a+1)
				rtspheres(nspheres).pos_(1)=Val(sa)	
				a=Instr(sa,",")
				sa=Mid(sa,a+1)
				rtspheres(nspheres).pos_(2)=Val(sa)	
				a=InStr(sa,":") ' --------- sphere radius
				sa=Mid(sa,a+1)
				rtspheres(nspheres).radius=Val(sa)
				'----------
				'If primeraesfera=0 Then
				'	primeraesfera=1
					' la primera esfera guardamos su posicion y radio
					x1=rtspheres(nspheres).pos_(0)
					y1=rtspheres(nspheres).pos_(1)
					z1=rtspheres(nspheres).pos_(2)
					r1=rtspheres(nspheres).radius
				'EndIf
				nspheres+=1 ' sphere created	
				cont:
				If nspheres=MAXSPHERES Then Exit While ' max 100000 spheres		
				f+=1
				sa=temp(f)'+nspheres)
				If sa="" Then f=10000: Exit While' end , no more data
			Wend
		EndIf
	Next
	
	Print "screen resolution:";scx;" , ";scy 
 	Print "observer position:";obsx;" , ";obsy;" , ";obsz 
 	Print "altitude, azimut :";obsalt;" , ";obsazm
 	Print "focal lenght     :";obsfl 
 	
	Print
	Print "pos    TILE 0:";rttiles(0).pos_(0)  ;" , ";rttiles(0).pos_(1)  ;" , ";rttiles(0).pos_(2) 
	Print "normal TILE 0:";rttiles(0).normal(0);" , ";rttiles(0).normal(1);" , ";rttiles(0).normal(2) 
	Print "color  TILE 0:";rttiles(0).color_(0);" , ";rttiles(0).color_(1);" , ";rttiles(0).color_(2)
	Print
	Print "pos    TILE 1:";rttiles(1).pos_(0)  ;" , ";rttiles(1).pos_(1)  ;" , ";rttiles(1).pos_(2)	
	Print "normal TILE 1:";rttiles(1).normal(0);" , ";rttiles(1).normal(1);" , ";rttiles(1).normal(2)
	Print "color  TILE 1:";rttiles(1).color_(0);" , ";rttiles(1).color_(1);" , ";rttiles(1).color_(2) 
	Print
	Print "ambient     :";rtambient.r;" , ";rtambient.g;" , ";rtambient.b 
	Print
	Print "sky zenith  :";rtskyzen.r;" , ";rtskyzen.g;" , ";rtskyzen.b
	Print
	Print "sky horizont:";rtskyhor.r;" , ";rtskyhor.g;" , ";rtskyhor.b 
	Print
	For f=0 To nlamps-1
	Print "Light pos";f;":";rtlamps(f).pos_(0);" , ";rtlamps(f).pos_(1);" , ";rtlamps(f).pos_(2)
	Print "Light rad";f;":";rtlamps(f).radius
	Print "Light col";f;":";rtlamps(f).color_(1);" , ";rtlamps(f).color_(0);" , ";rtlamps(f).color_(2)
	Next
	
End Sub
 

 
