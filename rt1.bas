/'      RT1.C    Ray tracing program
        Copyright 1987 Eric Graham
        Permission is granted to copy and modify this file, provided
        that this notice is retained.
        
        FreeBasic Version By Jepalza_22 (gmail.com)
'/

#Include "defs.bi"
#Include "world.bi"
#Include "rt2.bas"




/' Do the raytracing '/
Sub raytrace(brite() As Double , lines As Double Ptr , w As world Ptr)

    Dim As Double t,tmin,pos_(2) 
	 Dim As Long k 
    Dim As patch ptch 
	 Dim As sphere Ptr spnear=0 
    Dim As lamp Ptr lmpnear=0 

    tmin=_BIG 

	 spnear=0    /' can we see some spheres '/
    for k=0 To w->numsp -1 
        if (intsplin(@t,lines,@w->sp[k])) Then 
            if (t<tmin) Then tmin=t: spnear=@w->sp[k] 
        EndIf 
    Next

    lmpnear=0   /' are we looking at a lamp '/
    for k=0 To w->numlmp -1
        if (intsplin(@t,lines,Cast(sphere Ptr,@w->lmp[k]) )) Then ' LMP necesita ser SPHERE para evitar advertencia
            if (t < tmin) Then tmin=t: lmpnear=@w->lmp[k] 
        EndIf
    Next

    if (lmpnear) Then   /' we see a lamp! '/
        For k=0 To 2
				brite(k)=lmpnear->color_(k)/(lmpnear->radius*lmpnear->radius) 
        Next
        Exit Sub 
    EndIf
  
    if (inthor(@t,lines)) Then  /' do we see the ground? '/
        If (t<tmin) Then 
            point_(@pos_(0),t,lines)
				k=gingham(@pos_(0))  /' cheap vinyl '/
            veccopy(@w->horizon(k).pos_(0),@pos_(0))
            pixbrite(brite(), @w->horizon(k),w,0) 
            Exit sub 
        EndIf
    EndIf

    If (spnear<>0) Then  /' we see a sphere '/
        point_(@ptch.pos_(0),tmin,lines) 
		  setnorm(@ptch,spnear) 
        colorcpy(@ptch.color_(0),@spnear->color_(0)) 
        Select Case (spnear->type_)    /' treat the surface type '/
        	Case _BRIGHT ' type 1 
                If glint_(brite(),@ptch,w,spnear,lines)=0 Then
                	 pixbrite(brite(),@ptch,w,spnear) 'DULL
                EndIf
        	Case _DULL ' type 0
                pixbrite(brite(),@ptch,w,spnear) 
        	Case _MIRROR ' type 2
                mirror(brite(),@ptch,w,lines)
        End Select
        Exit Sub 
    EndIf

    skybrite(brite(),lines,w)      /' nothing else, must be sky '/
End Sub

/' calculate sky color '/
Sub skybrite(brite() As Double , lines As Double Ptr , w As world Ptr)
   /' Blend a sky color from the zenith to the horizon '/
    Dim As Double sin2,cos2 
	 Dim As Long k 
    Sin2=lines[5]*lines[5]
    Sin2/=(lines[1]*lines[1]+lines[3]*lines[3]+sin2) 
    Cos2=1.0-Sin2 
    for k=0 To 2      
		  brite(k)=cos2*w->skyhor(k)+Sin2*w->skyzen(k) 
    Next

End Sub

/' calculate ray for pixel i,j '/
Sub pixline( lines As Double Ptr , o As observer Ptr , i As Long , j As Long)

    Dim As Double x,y,tp(3) 
	 Dim As Long k 
    y=(0.5*o->ny-j)*o->py 
    x=(i-0.5*o->nx)*o->px 
    for k=0 To 2       
		 tp(k)=o->viewdir(k) * o->fl + y * o->vhat(k) + x * o->uhat(k) + o->obspos(k) 
    Next

    genline(lines,@o->obspos(0),@tp(0))  /' generate equation of line '/
End Sub

/' a=b-c for vectors '/
Sub vecsub( a As Double Ptr ,  b As Double Ptr ,  c As Double Ptr)

    Dim As Long k 
    for k=0 To 2
    	a[k]=b[k]-c[k] 
    Next

End Sub

/' intersection of sphere and line '/
Function intsplin( t As Double Ptr ,  lines As Double Ptr , sp As sphere Ptr) As Long
	/' t returns the parameter for where on the line '/
    Dim As Double a,b,c,d,p,q,tt
	 Dim As Long k  /' the sphere is hit '/
    a=0.0
    b=0.0 
	 c=sp->radius
	 c=-c*c 
    for k=0 To 2        
        p=*lines - sp->pos_(k):lines+=1
		  q=*lines:lines+=1
        a=q*q+a 
		  tt=q*p 
		  b=tt+tt+b 
		  c=p*p+c 
    Next
    /' a,b,c are coefficients of quadratic equation for t '/
    d=b*b-4.0*a*c 
    if (d <= 0) Then return 0        /' line misses sphere '/
    d=Sqr(d) 
	 *t=-(b+d)/(a+a) 
    if (*t<_SMALL) Then *t=(d-b)/(a+a) 
    return IIf(*t >_SMALL,1,0)     /' is sphere is in front of us? '/
End Function


/' intersection of line with ground '/
Function inthor( t As Double Ptr ,  lines As Double Ptr) As Long
    if (lines[5] = 0.0) Then return 0 
    *t=-lines[4]/lines[5]
	 return IIf(*t > _SMALL,1,0)
End Function

/' generate the equation of a line through the two points a and b  '/
Sub genline( l As Double Ptr ,  a As Double Ptr ,  b As Double Ptr)

    Dim As Long k 
    for k=0 To 2         
    	*l=a[k]:l+=1
    	*l=b[k]-a[k]:l+=1 
    Next

End Sub

 /' dot product of 2 vectors '/
Function dot( a As Double Ptr ,  b As Double Ptr) As Double
 return a[0]*b[0] + a[1]*b[1] + a[2]*b[2]
End Function


/' calculate position of a point on the line with parameter t '/
Sub point_( pos_ As Double Ptr , t As Double , lines As Double Ptr)

    Dim As Long k
    Dim As Double a 
    for k=0 To 2         
       a=*lines:lines+=1
		 pos_[k]=a+(*lines)*t:lines+=1
    Next

End Sub


' ----------------------------------------------
' solo llega cuando la esfera usa el modo BRIGHT
/' are we looking at a highlight? '/
Function glint_(brite() As Double , p As patch Ptr , w As world Ptr , spc_ As sphere Ptr ,incident As Double Ptr) As Long

    Dim As Long k,lo,firstlite=1 
	 Dim As Double minglint=0.95 
    Dim As Double lines(5),t,r,lp(2) 
    Dim As Double Ptr pp
    Dim As Double Ptr ll
    Dim As Double cosi 
    Dim As Double incvec(2),refvec(2),ref2 

    for lo=0 To w->numlmp -1        
        ll=@w->lmp[lo].pos_(0) 
		  pp=@p->pos_(0)
        vecsub(@lp(0),ll,pp) 
		  cosi=dot(@lp(0),@p->normal(0)) 
        if (cosi <= 0.0) Then continue For /' not with this lamp! '/
        
        genline(@lines(0),pp,ll) 
        for k=0 To w->numsp -1 
            if (@w->sp[k] = spc_) Then Continue For
            if (intsplin(@t,@lines(0),@w->sp[k])) Then goto cont 
        Next

        if (firstlite) Then 
            incvec(0)=incident[1] 
				incvec(1)=incident[3] 
            incvec(2)=incident[5] 
            reflect(@refvec(0),@p->normal(0),@incvec(0)) 
            ref2=dot(@refvec(0),@refvec(0)) 
				firstlite=0 
        EndIf
  
        r=dot(@lp(0),@lp(0))
        t=dot(@lp(0),@refvec(0)) 
        t*=t/(dot(@lp(0),@lp(0))*ref2) 
        if (t > minglint) Then  /' it´s a highlight '/
            for k=0 To 2
            	brite(k)=1.0 
            Next
            return 1 
        EndIf
  
    cont:
   Next

    return 0 
End Function


' ----------------------------------------------
'  solo llega cuando la esfera usa el modo MIRROR 
/' bounce ray off mirror '/
Sub mirror(brite() As Double , p As patch Ptr , w As world Ptr , incident As Double Ptr)

    Dim As Long k 
	 Dim As Double lines(5),incvec(2),refvec(2),t 
	 
	 ' lines origin
    incvec(0)=incident[1] 
	 incvec(1)=incident[3] 
    incvec(2)=incident[5] 

	 t=dot(@p->normal(0),@incvec(0)) 
    if (t >= 0) Then  /' we´re inside a sphere, it´s dark '/
        for k=0 To 2
        	 brite(k)=0.0 
        Next
        Exit Sub
    EndIf
  
    reflect(@refvec(0),@p->normal(0),@incvec(0))
    
    ' lines origin
    lines(0)=p->pos_(0)
    lines(2)=p->pos_(1) 
	 lines(4)=p->pos_(2) 
	 
	 ' lines dir
	 lines(1)=refvec(0) 
    lines(3)=refvec(1) 
	 lines(5)=refvec(2) 
	 
	 Dim aa As Double=brite(0)
	 Dim bb As Double=brite(1)
	 Dim cc As Double=brite(2)

    raytrace(brite(),@lines(0),w)   /' recursion saves the day '/
    for k=0 To 2
    	brite(k)=brite(k)*p->color_(k) 
    Next

End Sub


' llamado con el modo normal (DULL) y al calcular el suelo (GROUND)
/' how bright is the patch? '/
Sub pixbrite(brite() As Double , p As patch Ptr , w As world Ptr , spc_ As sphere Ptr)

    Dim As Long k,lo
    Dim As Double lines(5),t,r,lp(2) 
    Dim As Double Ptr pp
    Dim As Double Ptr ll
    Dim As Double cosi,diffuse 
    Dim As Double zenith(2)={0.0 ,0.0 ,1.0}
    Dim As Double f1=1.5
    Dim As Double f2=0.4 
    
    diffuse=(dot(@zenith(0),@p->normal(0))+f1)*f2 
    for k=0 To 2
    	brite(k)=diffuse*w->illum(k)*p->color_(k) 
    Next

    'If (p<>0) And (w<>0) Then ' siempre existen P y W ?
        for lo=0 To w->numlmp -1         
            ll=@w->lmp[lo].pos_(0)
				pp=@p->pos_(0)
				vecsub(@lp(0),ll,pp) 
            cosi=dot(@lp(0),@p->normal(0)) 
				if (cosi <= 0.0) Then Continue For

            genline(@lines(0),pp,ll) 
            For k=0 To w->numsp-1         
                If (@w->sp[k] = spc_) Then Continue For ' sphere can't shadow itself
                if (intsplin(@t,@lines(0),@w->sp[k])) Then GoTo cont ' exit for: continue for
            Next

            r=Sqr(dot(@lp(0),@lp(0))) 
				cosi=cosi/(r*r*r) 
            For k=0 To 2      
					 brite(k)=brite(k) + cosi * p->color_(k) * w->lmp[lo].color_(k) 
            Next

            cont:
        Next
    'EndIf
  
End Sub


/' normal (radial) direction of sphere '/
Sub setnorm( p As patch Ptr , s As sphere Ptr)

    ' old from Eric Graham
    'Dim As Double Ptr t
    'Dim As Double a 
	 'Dim As Long k 
	 't=@p->normal(0)
    'vecsub(t,@p->pos_(0),@s->pos_(0)) 
	 'a=1.0/s->radius 
    'for k=0 To 2
    '	*t=(*t)*a:t+=1
    'Next
    
    ' new from  http://www.etwright.org/cghist/juggler_rt.html
    vecsub(@p->normal(0),@p->pos_(0),@s->pos_(0)) 
	 p->normal(0) /=s->radius
	 p->normal(1) /=s->radius
	 p->normal(2) /=s->radius
	 
	 
End Sub


/' a=b for colors '/
Sub colorcpy( a As Double Ptr , b As Double Ptr)

 Dim As Long k 
 for k=0 To 2
 	a[k]=b[k] 
 Next

End Sub

/' a=b for vectors '/
Sub veccopy( a As Double Ptr , b As Double Ptr)

	Dim As Long k 
	for k=0 To 2
		a[k]=b[k] 
   Next

End Sub

' floor square tiles
 /' are we on ´black´ or ´white´ tile? '/
Function gingham( pos_ As Double Ptr) As Long

	/' tiles are 3 units wide '/
    Dim As Double x,y 
	 Dim As Long kx,ky 
	 
    kx=0
    ky=0 
	 x=pos_[0]
	 y=pos_[1] 
	 
    if (x < 0) Then 
      x=-x
      kx+=1
	 EndIf
  
    if (y < 0.0) Then 
  		y=-y
  		ky+=1
    EndIf
  
    return ( cint((x+kx)\3) + cint((y+ky)\3) ) Mod 2 
End Function


/' ======================================================================
reflect()
Calculate the reflection ray 'Y' (incoming ray x reflected about the surface normal n).  
Eric's code had some wacky cross-product stuffgoing on, with a special case for x || n.  
I've replaced it with the standard calculation.  
See for example --> http://paulbourke.net/geometry/reflected/
====================================================================== '/
Sub reflect( y As Double Ptr ,  n As Double Ptr ,  x As Double Ptr)

    Dim As Double xx(2),d
	 Dim As Long k 

	 d=dot(x,n) 
    for k=0 To 2
    	y[k]=x[k] - 2 *d*n[k]
    Next

End Sub



  

 ' ==================================   MAIN   ====================================
 
 
 
	' read file with composition scene
	Dim As String fichero,sa
	fichero=Command
	'fichero="robot.txt" ' demo
	If fichero="" Then Print "Falta indicar el nombre del fichero con la escena":Sleep:End
	Dim As Integer nlin
	Open fichero For Input As 1
	While Not (Eof(1))
		Line Input #1,sa
		scene(nlin)=sa
		nlin+=1
	Wend


   ' initiate world    
    Dim As Double lines(5),brite(2) 
    Dim As observer o 
	 Dim As world w 
    Dim As Long ii,jj
	 Dim As Long si,sj 

	 ' create world from scene file
	 read_scene()
    setup(@o,@w)
    
    si=1+(o.nx-1)
    sj=1+(o.ny-1)
    ScreenRes si,sj,32 

    for jj=0 To o.ny -1        
        for ii=0 To o.nx -1      
            pixline(@lines(0),@o,ii,jj) 
				raytrace(brite(),@lines(0),@w) 
            ham(ii,jj,brite(),@o)  ' HAM=Original High Resolution from Amiga 500 ;-)
        Next
    Next
    
 	Beep
 	Sleep

