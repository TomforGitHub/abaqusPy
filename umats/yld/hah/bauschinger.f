c------------------------------------------------------------------------
c     Bauschinger subroutines to be wrapped by f2py.
c     This module should be also used in Abaqus UMAT (under development...)
c     Find more information of Abaqus UMAT in
c       www.github.com/youngung/abaqusPy
c
c     General references
c     [1] Barlat et al. IJP 58, 2014 p201-218
c     [2] Jeong et al., IJP, 2016 (in press)

c     Youngung Jeong
c     youngung.jeong@gmail.com
c------------------------------------------------------------------------
c     subroutine that calculates fk parameter for HAH
c         --   Eq 7 in Ref. [1]
      subroutine calc_fk(gk,H,q,fk)
c     Arguments
c     gk
c     H
c     q  : the exponent
c     fk
      implicit none
      real*8 gk,H,q,fk
cf2py intent(in) gk,H
cf2py intent(out) fk
      fk = (dsqrt(H)/4d0 * (1d0/gk-1 )  ) ** (1d0/q)
      return
      end subroutine
c------------------------------------------------------------------------
c$$$c     subroutine that calculates gk parameter for HAH
c$$$c         --   Eq 8 in Ref. [1]
c$$$      subroutine calc_gk(dk,e_ik,gk)
c$$$c     Arguments
c$$$c     dk
c$$$c     e_ik
c$$$c     gk
c$$$      implicit none
c$$$      real*8 dk,e_ik,gk
c$$$cf2py intent(in) dk,e_ik
c$$$cf2py intent(out) gk
c$$$      gk = dk / e_ik
c$$$      return
c$$$      end subroutine calc_gk
c------------------------------------------------------------------------
c     subroutine that calculates gk parameter for HAH
c         --   Eqs 7/8 in Ref. [1]
      subroutine calc_bau(e_mic,target,gs,e_ks,q,ys_iso,ys_hah,debar,
     $     fks,gs_new)
c     Arguments
c     e_mic  : microstructure deviator
c     target : the target directino towards which the microstructure
c              deviator aims to realign.
c     gs     : state variables that quantifies the <flattening>
c     e_ks   : k1,k2,k3,k4,k5 parameters that controls the evolunary
c              behavior of gs
c     q      : exponent
c     ys_iso : \bar{\sigma}(0) - the initial yield surface (without HAH effect)
c     ys_hah : \bar{\sigma}(\bar{\varepsilon}) - current yield surface
c     debar  : incremental equivalent strain
c              (used as multiplier when updating the state variables...)
c     fks    : fks state variables for n+1 step
c     gs_new : gs state variables for n+1 step
c     Note
c     Both arguments should be 'hat' properties.
c     Use <bauschinger_lib.f / hat> to convert a tensor
c     to its hatted property.
      implicit none
c     Arguments passed into
      dimension e_mic(6)
      dimension target(6)
      dimension gs(4)
      dimension e_ks(5)
      dimension fks(2)
      dimension gs_new(4)
      real*8 e_mic,target,gs,e_ks,fks,gs_new
      real*8 q,ys_iso,ys_hah,debar
c     locals
      dimension dgs(4)
      real*8 dot_prod,dd,dgs
      integer k
      integer i
cf2py intent(in) e_mic,target,gs,e_ks,ys_iso,ys_hah
cf2py intent(out) fks,gs_new
      dd = dot_prod(e_mic,target,6)
c***  index k depends on the sign of (mic:target)
      if (sign(1d0,dd).ge.0) then
         k = 1
      else
         k = 2
      endif
c***  Eqs 14&15 in Ref. [1]
      if (k.eq.1) then
         dgs(1) = e_ks(2) * (e_ks(3) * ys_iso/ys_hah - gs(1))
         dgs(2) = e_ks(1) * (  gs(3) - gs(2)) / gs(2)
         dgs(4) = e_ks(5) * (e_ks(4) - gs(4))
      elseif(k.eq.2) then
         dgs(1) = e_ks(1) * ( gs(4) - gs(1)) / gs(1)
         dgs(2) = e_ks(2) * (e_ks(3) * ys_iso/ys_hah - gs(2))
         dgs(3) = e_ks(5) * (e_ks(4) - gs(3))
      else
         stop -1
      endif
      do 10 i=1,4
         gs_new(i) = gs(i) + dgs(i) * debar
 10   continue
      do 20 i=1,2
         call calc_fk(gs_new(i),8d0/3d0,q,fks(i))
 20   continue
      return
      end subroutine calc_bau
c------------------------------------------------------------------------
      include "bauschinger_lib.f"

c$$$      subroutine bauschinger(k1,k2)
c$$$      implicit none
c$$$      real*8 k1,k2
c$$$cf2py intent(in) k1,k2
c$$$      return
c$$$      end subroutine bauschinger
