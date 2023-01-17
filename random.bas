
Dim As String sa
Dim As Integer a
Dim As Single fa, fb, fc
Dim As Single r,g,b,diam
Dim As Integer tipo

Randomize timer

Open "random.txt" For Output As 2


Print #2,"[RESOLUTION]"
Print #2,"640,480"
Print #2,"[OBSERVER]"
Print #2,"-2,-2,5.5"
Print #2,"[ALTITUDE]"
Print #2,"-10"
Print #2,"[AZIMUT]"
Print #2,"45"
Print #2,"[FOCAL]"
Print #2,"35"
Print #2,"[LIGHTS]"
Print #2,"(-100,-100,100):10 <1,1,1>"
Print #2,"[TILES]"
Print #2,"(0.,0.,0.) (0.,0.,1.) <0.8,0.8,0.0>"
Print #2,"(0.,0.,0.) (0.,0.,1.) <0.4,0.8,0.2>"
Print #2,"[AMBIENT]"
Print #2,"<.7,.7,.7> <0.1,0.1,1.0> <0.4,0.4,0.8>"
Print #2,"[SCENE]"


a=Int(Rnd(1)*7)+5 ' minimo 5
While a
	fa=Rnd(1)*6+4
	fb=Rnd(1)*6+4
	fc=Rnd(1)*6+1

	r=Rnd(1)
	g=Rnd(1)
	b=Rnd(1)
	tipo=Int(Rnd(1)*3)
	diam=Rnd(1)*2
	Print #2,"<";r;",";g;",";b;"> ";tipo;" (";fa;",";fb;",";fc;"):";diam

	a-=1
Wend

Close 2
