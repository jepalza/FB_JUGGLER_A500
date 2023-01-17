

#define _BIG 1.0e10
#define _SMALL 1.0e-5 ' correccion mejora sombras Ernie Wright --> http://www.etwright.org/cghist/juggler_rt.html

#define _DULL    0
#define _BRIGHT  1
#define _MIRROR  2

Type light
	As Double r
	As Double g
	As Double b
End Type

Type lamp 'Field=4
    As Double pos_(2)       /' position of lamp '/
    As Double color_(2)     /' color of lamp '/
    As Double radius        /' size of lamp '/
End Type 

Type sphere 'Field=4
    As Double pos_(2)       /' position of sphere '/
    As Double color_(2)     /' color of sphere '/
    As Double radius        /' size of sphere '/
    As Long type_           /' type of surface, DULL, BRIGHT or MIRROR '/
End Type 

Type patch 'Field=4         /' As a small bit of something visible '/
    As Double pos_(2)       /' position '/
    As Double normal(2)     /' direction 90 degrees to surface '/
    As Double color_(2)     /' color of patch '/
End Type 

Type world 'Field=4      /' As everything in the universe, except observer '/
    As Long numsp        /' number of spheres '/
    As sphere Ptr sp     /' array of spheres '/
    As Long numlmp       /' number of lamps '/
    As lamp Ptr lmp      /' array of lamps '/
    As patch horizon(1)  /' alternate squares on the ground '/
    As Double illum(2)   /' background diffuse illumination '/
    As Double skyhor(2)  /' sky color at horizon '/
    As Double skyzen(2)  /' sky color overhead '/
End Type 

Type observer 'Field=4     /' As now the observer '/
    As Double obspos(2)    /' his position '/
    As Double viewdir(2)   /' direction he is looking '/
    As Double uhat(2)      /' left to right in view plane '/
    As Double vhat(2)      /' down to up in view plane '/
    As Double fl,px,py     /' focal length and pixel sizes '/
    As Long nx,ny          /' number of pixels '/
End Type 





' RT1
Declare Function dot( a As Double Ptr ,  b As Double Ptr) As Double    /' Vector dot product '/
Declare Function intsplin( t As Double Ptr , lines As Double Ptr , sp As sphere Ptr) As Long
Declare Function inthor( t As Double Ptr ,  lines As Double Ptr) As Long
Declare Function gingham( pos_ As Double Ptr) As Long
Declare Function glint_(brite() As Double , p As patch Ptr , w As world Ptr , spc_ As sphere Ptr , incident As Double Ptr) As Long
Declare Sub point_( pos_ As Double Ptr , t As Double , lines As Double Ptr)
Declare Sub veccopy( a As Double Ptr ,  b As Double Ptr)
Declare sub reflect( y As Double Ptr ,  n As Double Ptr ,  x As Double Ptr)
Declare Sub colorcpy( a As Double Ptr ,  b As Double Ptr)
Declare Sub setnorm(p As patch Ptr , s As sphere Ptr)
Declare Sub pixbrite(brite() As Double , p As patch Ptr , w As world Ptr , spc_ As sphere Ptr)
Declare Sub skybrite(brite() As Double , lines As Double Ptr , w As world Ptr)
Declare sub mirror(brite() As Double , p As patch Ptr , w As world Ptr , incident As Double Ptr)
Declare Sub pixline( lines As Double Ptr , o As observer Ptr , i As Long , j As Long)
Declare Sub vecsub( a As Double Ptr ,  b As Double Ptr ,  c As Double Ptr)
Declare Sub genline( l As Double Ptr ,  a As Double Ptr ,  b As Double Ptr)

' RT2
Declare Sub setup( o As observer Ptr , w As world Ptr)
Declare Sub ham(i As Long , j As Long , brite() As Double, o As observer Ptr)



