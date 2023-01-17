/'      RT2.C
        Copyright 1987 Eric Graham
        All rights reserved.
        This file may not be copied, modified or uploaded to a bulletin
        board system, except as provided below.
        Permission is granted to make a reasonable number of backup copies,
        in order that it may be used to generate executable code for use
        on a Double computer system.
        Permission is granted to modify this code and use the modified code
        for non commercial use by the original purchaser of this software,
        and provided that this notice is included in the modified version.
'/


/'This function is really a stub, you should, change it to suit your needs'/
Sub setup( o As observer Ptr , w As world Ptr)

 Dim As Double alt,azm,degtorad 
 Dim As Long i,j,k 
 Dim As Double t,r,tp(2),lampfac,pmin(2),pmax(2) 

 degtorad=0.0174533 ' PI/180
 
 for k=0 To 2
 	pmin(k)=_BIG
 	pmax(k)=-_BIG 
 Next


 ' -------------  WORLD DEFINITION ----------

 ' picture resolution
 o->nx=scx
 o->ny=scy

 ' pixels sizes ratio
 o->px= 1.0/o->nx 
 o->py=0.75/o->ny 
  
 ' observer position
 o->obspos(0)=obsx
 o->obspos(1)=obsy
 o->obspos(2)=obsz 

 ' altitude - azimuth
 alt=obsalt * degtorad
 azm=obsazm * degtorad

 ' focal length
 o->fl=0.028*obsfl 

 ' view point
 o->viewdir(0)=cos(azm)*cos(alt) 
 o->viewdir(1)=sin(azm)*cos(alt) 
 o->viewdir(2)=sin(alt) 

 o->uhat(0)= Sin(azm) 
 o->uhat(1)=-cos(azm) 
 o->uhat(2)=0.0 

 o->vhat(0)=-cos(azm)*sin(alt) 
 o->vhat(1)=-sin(azm)*sin(alt) 
 o->vhat(2)= Cos(alt) 


 ' define spheres
	w->numsp=nspheres
	w->sp=@rtspheres(0)

	w->numlmp=nlamps
	w->lmp=@rtlamps(0)

	w->horizon(0).pos_(0)=rttiles(0).pos_(0)
	w->horizon(0).pos_(1)=rttiles(0).pos_(1) 
	w->horizon(0).pos_(2)=rttiles(0).pos_(2) 
	w->horizon(1).pos_(0)=rttiles(1).pos_(0) 
	w->horizon(1).pos_(1)=rttiles(1).pos_(1) 
	w->horizon(1).pos_(2)=rttiles(1).pos_(2)
	
	w->horizon(0).normal(0)=rttiles(0).normal(0)
	w->horizon(0).normal(1)=rttiles(0).normal(1) 
	w->horizon(0).normal(2)=rttiles(0).normal(2) 
	w->horizon(1).normal(0)=rttiles(1).normal(0) 
	w->horizon(1).normal(1)=rttiles(1).normal(1) 
	w->horizon(1).normal(2)=rttiles(1).normal(2)
	
	w->horizon(0).color_(0)=rttiles(0).color_(0)
	w->horizon(0).color_(1)=rttiles(0).color_(1) 
	w->horizon(0).color_(2)=rttiles(0).color_(2)
	w->horizon(1).color_(0)=rttiles(1).color_(0)
	w->horizon(1).color_(1)=rttiles(1).color_(1)
	w->horizon(1).color_(2)=rttiles(1).color_(2) 
	
	w->illum(0)=rtambient.r
	w->illum(1)=rtambient.g
	w->illum(2)=rtambient.b 
	
	w->skyzen(0)=rtskyzen.r 
	w->skyzen(1)=rtskyzen.g
	w->skyzen(2)=rtskyzen.b
	
	w->skyhor(0)=rtskyhor.r
	w->skyhor(1)=rtskyhor.g 
	w->skyhor(2)=rtskyhor.b 


 lampfac=_BIG  /' modify the lamp brightness so as to '/
 for i=0 To w->numsp -1  /' get the right exposure '/
        for j=0 To w->numlmp -1      
					  vecsub(@tp(0),@w->sp[i].pos_(0),@w->lmp[j].pos_(0)) 
                 r=Sqr(dot(@tp(0),@tp(0)))
                 r-=w->sp[i].radius 
                 for k=0 To 2
								 t=w->sp[i].color_(k)*w->lmp[j].color_(k)/(r*r) 
                         if (t = 0.0) Then Continue For 
                         t=(1.0-w->sp[i].color_(k)*w->illum(k))/t 
                         if (t<lampfac) Then lampfac=t 
                 Next
        Next
 Next

 for j=0 To w->numlmp -1       
    For k=0 To 2
    	w->lmp[j].color_(k)*=lampfac 
    Next
 Next

 'print "lampfac=";lampfac
End Sub




Function MAX(a As Double, b As Double) As Double
	Return IIf(a>b,a,b)
End Function

Function MIN(a As Double, b As Double) As Double
	Return IIf(a<b,a,b)
End Function


' HAM!!! HAHA!!
Sub ham(i As Long , j As Long , brite() As Double, o As observer Ptr)

 Dim As Integer d,ch,level,pix(2)
 d=4*(j*o->nx+i)
 For ch=0 To 2
 	level=CInt(MAX(MIN(brite(ch)*255,255),0))
 	pix(ch)=level
 Next

 PSet(i,j),RGB(pix(0),pix(1),pix(2))
End Sub
