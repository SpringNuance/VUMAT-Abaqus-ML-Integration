subroutine vumat(&
! Read only (unmodifiable)variables -
     nblock, ndir, nshr, nstatev, nfieldv, nprops, lanneal, &
     stepTime, totalTime, dt, cmname, coordMp, charLength, &
     props, density, strainInc, relSpinInc, &
     tempOld, stretchOld, defgradOld, fieldOld, &
     stressOld, stateOld, enerInternOld, enerInelasOld, &
     tempNew, stretchNew, defgradNew, fieldNew, &
! Write only (modifiable) variables -
     stressNew, stateNew, enerInternNew, enerInelasNew)

! Include TensorFlow Fortran interface modules
use tf_types
use tf_interface
use iso_c_binding

include 'vaba_param.inc'

real, dimension(nprops) :: props
real, dimension(nblock) :: density
real, dimension(nblock, *) :: coordMp
real, dimension(nblock) :: charLength
real, dimension(nblock, ndir+nshr) :: strainInc
real, dimension(nblock, nshr) :: relSpinInc
real, dimension(nblock) :: tempOld
real, dimension(nblock, ndir+nshr) :: stretchOld
real, dimension(nblock, ndir+nshr+nshr) :: defgradOld
real, dimension(nblock, nfieldv) :: fieldOld
real, dimension(nblock, ndir+nshr) :: stressOld
real, dimension(nblock, nstatev) :: stateOld
real, dimension(nblock) :: enerInternOld
real, dimension(nblock) :: enerInelasOld
real, dimension(nblock) :: tempNew
real, dimension(nblock, ndir+nshr) :: stretchNew
real, dimension(nblock, ndir+nshr+nshr) :: defgradNew
real, dimension(nblock, nfieldv) :: fieldNew
real, dimension(nblock, ndir+nshr) :: stressNew
real, dimension(nblock, nstatev) :: stateNew
real, dimension(nblock) :: enerInternNew
real, dimension(nblock) :: enerInelasNew

character(len=80) :: cmname
!
real, parameter :: zero = 0.d0, one = 1.d0, two = 2.d0, &
                  third = 1.d0 / 3.d0, half = 0.5d0, op5 = 1.5d0

real :: e, xnu, hard, syield0, k
real :: twomu, alamda, thremu

e       = props(1)
xnu     = props(2)
hard    = props(3)
syield0 = props(4)

twomu   = e / (one + xnu)
alamda  = xnu * twomu / (one - two * xnu)
thremu  = op5 * twomu

!	nvalue = nprops/2-1

! -----------------------------------------------------------------------
!   Elastic Constitutive Relationship:
!   σ'_new = σ'_old + 2μ Δε' + λ tr(Δε)
! -----------------------------------------------------------------------

if (stepTime == zero) then
    ! nblock: Number of material points to be processed in this call to VUMAT
    do k = 1, nblock
        
        trace = strainInc(k,1) + strainInc(k,2) + strainInc(k,3)
        
        stressNew(k,1) = stressOld(k,1) + twomu * strainInc(k,1) + alamda * trace
        
        stressNew(k,2) = stressOld(k,2) + twomu * strainInc(k,2) + alamda * trace
        
        stressNew(k,3) = stressOld(k,3) + twomu * strainInc(k,3) + alamda * trace
        
        stressNew(k,4) = stressOld(k,4) + twomu * strainInc(k,4)
        ! Check if this is 2D or 3D.
        ! If 2D then ndir = 3, nshr = 1
        ! If 3D then ndir = 3, nshr = 3
        if (nshr > 1) then
            stressNew(k,5) = stressOld(k,5) + twomu * strainInc(k,5)
            stressNew(k,6) = stressOld(k,6) + twomu * strainInc(k,6)
        end if
        
    end do
    
else
!
	do k = 1, nblock
		peeqOld = stateOld(k,1)
		stateNew(k,2) = 0.1
		stateNew(k,3) = 100
		trace = strainInc(k,1) + strainInc(k,2) + strainInc(k,3)
		s11 = stressOld(k,1) + twomu * strainInc(k,1) + alamda * trace
		s22 = stressOld(k,2) + twomu * strainInc(k,2) + alamda * trace
		s33 = stressOld(k,3) + twomu * strainInc(k,3) + alamda * trace
		s12 = stressOld(k,4) + twomu * strainInc(k,4)

		if (nshr > 1) then
			s13 = stressOld(k,5) + twomu * strainInc(k,5)
			s23 = stressOld(k,6) + twomu * strainInc(k,6)
		end if

		smean = third * (s11 + s22 + s33)
		s11 = s11 - smean
		s22 = s22 - smean
		s33 = s33 - smean

		if (nshr == 1) then
			vmises = sqrt(op5 * (s11 * s11 + s22 * s22 + s33 * s33 + two * s12 * s12))
		else
			vmises = sqrt(op5 * (s11 * s11 + s22 * s22 + s33 * s33 + two * s12 * s12 + two * s13 * s13 + two * s23 * s23))
		end if

		sigdif = vmises - yieldOld
		facyld = zero

		if (sigdif > zero) then 
		    facyld = one
		end if

		deqps = facyld * sigdif / (thremu + hard)
		syield = syield0 + hard * deqps

		! Update the stress
		yieldNew = yieldOld + hard * deqps
		factor = yieldNew / (yieldNew + thremu * deqps)
		stressNew(k,1) = s11 * factor + smean
		stressNew(k,2) = s22 * factor + smean
		stressNew(k,3) = s33 * factor + smean
		stressNew(k,4) = s12 * factor

		if (nshr > 1) then
			stressNew(k,5) = s13 * factor
			stressNew(k,6) = s23 * factor
		end if

!	 Update the state variables

	    stateNew(k,1) = stateOld(k,1) + deqps

! Update the specific internal energy -

		if (nshr == 1) then
			stressPower = half * ((stressOld(k,1) + stressNew(k,1)) * strainInc(k,1) + &
								(stressOld(k,2) + stressNew(k,2)) * strainInc(k,2) + &
								(stressOld(k,3) + stressNew(k,3)) * strainInc(k,3)) + &
								(stressOld(k,4) + stressNew(k,4)) * strainInc(k,4)
		else
			stressPower = half * ((stressOld(k,1) + stressNew(k,1)) * strainInc(k,1) + &
								(stressOld(k,2) + stressNew(k,2)) * strainInc(k,2) + &
								(stressOld(k,3) + stressNew(k,3)) * strainInc(k,3)) + &
								(stressOld(k,4) + stressNew(k,4)) * strainInc(k,4) + &
								(stressOld(k,5) + stressNew(k,5)) * strainInc(k,5) + &
								(stressOld(k,6) + stressNew(k,6)) * strainInc(k,6)
		end if

		enerInternNew(k) = enerInternOld(k) + stressPower / density(k)

! Update the dissipated inelastic specific energy -

		plasticWorkInc = half * (yieldOld + yieldNew) * deqps
		enerInelasNew(k) = enerInelasOld(k) + plasticWorkInc / density(k)

	end do

end if

return
end