        subroutine vumat(
C Read only (unmodifiable)variables -
     1  nblock, ndir, nshr, nstatev, nfieldv, nprops, lanneal,
     2  stepTime, totalTime, dt, cmname, coordMp, charLength,
     3  props, density, strainInc, relSpinInc,
     4  tempOld, stretchOld, defgradOld, fieldOld,
     5  stressOld, stateOld, enerInternOld, enerInelasOld,
     6  tempNew, stretchNew, defgradNew, fieldNew,
C Write only (modifiable) variables -
     7  stressNew, stateNew, enerInternNew, enerInelasNew )
C
      include 'vaba_param.inc'
C     nprops = 4 (four constants: E, nu, syield0, hard)
C     nstatev = 1 (one state variable: peeq)
C     nfieldv = 0 (no field variables)
C     ndir = 3 (number of normal stress/strain in symmetric tensor)
C     nshr = 3 (number of shear stress/strain in symmetric tensor)
C	  nblock = number of material integration points to be processed in each element
      dimension props(nprops), 
     1          density(nblock), 
     1          coordMp(nblock,*),
     1          charLength(nblock), 
     1          strainInc(nblock,ndir+nshr),
     1          relSpinInc(nblock,nshr), 
     1          tempOld(nblock),
     1          stretchOld(nblock,ndir+nshr),
     1          defgradOld(nblock,ndir+nshr+nshr),
     1          fieldOld(nblock,nfieldv), 
     1          stressOld(nblock,ndir+nshr),
     1          stateOld(nblock,nstatev), 
     1          enerInternOld(nblock),
     1          enerInelasOld(nblock), 
     1          tempNew(nblock),
     1          stretchNew(nblock,ndir+nshr),
     1          defgradNew(nblock,ndir+nshr+nshr),
     1          fieldNew(nblock,nfieldv),
     1          stressNew(nblock,ndir+nshr), 
     1          stateNew(nblock,nstatev),
     1          enerInternNew(nblock), 
     1          enerInelasNew(nblock)
C
C   The matrices used in this subroutine are
C   strainInc(nblock,ndir+nshr) - strain increment Δε
C   stressOld(nblock,ndir+nshr) - stress at the beginning of the increment (σ'_old)
C   stressNew(nblock,ndir+nshr) - stress at the end of the increment (σ'_new)
C   stateOld(nblock,nstatev) - state variables at the beginning of the increment
C   stateNew(nblock,nstatev) - state variables at the end of the increment
C   enerInternOld(nblock) - specific internal energy at the beginning of the increment
C   enerInternNew(nblock) - specific internal energy at the end of the increment
C   enerInelasOld(nblock) - specific inelastic energy at the beginning of the increment
C   enerInelasNew(nblock) - specific inelastic energy at the end of the increment
C
C   The constants used in this subroutine are
C   nblock - number of material integration points to be processed in each element
C   stepTime - Value of time since the step began
C   stepTime changes with each increment, representing the current time within the ongoing step.
C
C   Possible constants to consider
C   totalTime - Value of total time. The time at the beginning of the step is given by totalTime - stepTime
C   totalTime accumulates across the simulation, increasing with each increment. In a single-step analysis, it will be equal to stepTime.   
C   dt - time increment size
C   dt is the time increment for each simulation increment. Its value can vary depending on the 
C   solver's time-stepping algorithm and the specific requirements of the simulation at each increment.
        character*80 cmname
C
        parameter( zero = 0.d0, one = 1.d0, two = 2.d0,
     1  third = 1.d0 / 3.d0, half = 0.5d0, op5 = 1.5d0)
C
C 	For plane strain, axisymmetric, and 3D cases using
C 	the J2 Mises Plasticity with piecewise-linear isotropic hardening.
C
C 	The state variable is stored as:
C
C 	STATE(*,1) = equivalent plastic strain
C
C 	User needs to input
C 	props(1) Young’s modulus
C 	props(2) Poisson’s ratio
C 	props(3) syield0
C	props(4) hard
	  e       = props(1)
	  xnu     = props(2)
	  hard    = props(3)
	  syield0 = props(4)
C
	  twomu   = e / ( one + xnu )
	  alamda  = xnu * twomu / ( one - two * xnu )
	  thremu  = op5 * twomu
C	nvalue = nprops/2-1
C
C -----------------------------------------------------------------------
C   Elastic Constitutive Relationship:
C   σ'_new = σ'_old + 2μ Δε' + λ tr(Δε)
C -----------------------------------------------------------------------
C
	  if ( stepTime .eq. zero ) then
C   nblock: Number of material points to be processed in this call to VUMAT
	  	do k = 1, nblock
C	
	      trace = strainInc(k,1) + strainInc(k,2) + strainInc(k,3)
C
	      stressNew(k,1) = stressOld(k,1) +
     1    twomu * strainInc(k,1) + alamda * trace
C
	      stressNew(k,2) = stressOld(k,2) +
     1    twomu * strainInc(k,2) + alamda * trace
C
	      stressNew(k,3) = stressOld(k,3) +
     1    twomu * strainInc(k,3) + alamda * trace
C     
	      stressNew(k,4)=stressOld(k,4) + twomu * strainInc(k,4)
C
	      if ( nshr .gt. 1 ) then
	        stressNew(k,5)=stressOld(k,5) + twomu * strainInc(k,5)
	        stressNew(k,6)=stressOld(k,6) + twomu * strainInc(k,6)
	      end if
C
	    end do
C	  
	  else
C
	    do k = 1, nblock
	      peeqOld = stateOld(k,1)
	      trace = strainInc(k,1) + strainInc(k,2) + strainInc(k,3)
          s11 = stressOld(k,1) + twomu * strainInc(k,1) + 
     1          alamda * trace
	      s22 = stressOld(k,2) + twomu * strainInc(k,2) +
     1          alamda * trace
	      s33 = stressOld(k,3) + twomu * strainInc(k,3) +
     1          alamda * trace
          s12 = stressOld(k,4) + twomu * strainInc(k,4)
C
		  if ( nshr .gt. 1 ) then
	        s13 = stressOld(k,5) + twomu * strainInc(k,5)
			s23 = stressOld(k,6) + twomu * strainInc(k,6)
	      end if
C
	      smean = third * ( s11 + s22 + s33 )
	      s11 = s11 - smean
	      s22 = s22 - smean
	      s33 = s33 - smean
C
	      if ( nshr .eq. 1 ) then
	        vmises = sqrt( op5*(s11*s11+s22*s22+s33*s33+two*s12*s12) )
	      else
C
            vmises = sqrt( op5 * ( s11 * s11 + s22 * s22 + s33 * s33 +
     1         two * s12 * s12 + two * s13 * s13 + two * s23 * s23 ) )
	      end if
C
	      sigdif = vmises - yieldOld
	      facyld = zero
C
	      if ( sigdif .gt. zero ) facyld = one
	        deqps = facyld * sigdif / ( thremu + hard )
	        syield =syield0 + hard*deqps	
C
C	 Update the stress
C
	        yieldNew = yieldOld + hard * deqps
	        factor = yieldNew / ( yieldNew + thremu * deqps )
	        stressNew(k,1) = s11 * factor + smean
	        stressNew(k,2) = s22 * factor + smean
	        stressNew(k,3) = s33 * factor + smean
	        stressNew(k,4) = s12 * factor
C
	        if ( nshr .gt. 1 ) then
	          stressNew(k,5) = s13 * factor
	          stressNew(k,6) = s23 * factor
	        end if
C
C	 Update the state variables
C
	        stateNew(k,1) = stateOld(k,1) + deqps
C
C Update the specific internal energy -
C
 	        if ( nshr .eq. 1 ) then
		      stressPower = half * (
     1        (stressOld(k,1) + stressNew(k,1) ) * strainInc(k,1) +
     2        (stressOld(k,2) + stressNew(k,2) ) * strainInc(k,2) +
     3        (stressOld(k,3) + stressNew(k,3) ) * strainInc(k,3)) +
     4        (stressOld(k,4) + stressNew(k,4) ) * strainInc(k,4)
		    else
		      stressPower = half * (
     5        (stressOld(k,1) + stressNew(k,1) ) * strainInc(k,1) +
     6        (stressOld(k,2) + stressNew(k,2) ) * strainInc(k,2) +
     7        (stressOld(k,3) + stressNew(k,3) ) * strainInc(k,3)) +
     8        (stressOld(k,4) + stressNew(k,4) ) * strainInc(k,4) +
     9        (stressOld(k,5) + stressNew(k,5) ) * strainInc(k,5) +
     1        (stressOld(k,6) + stressNew(k,6) ) * strainInc(k,6)
		    end if
C
		      enerInternNew(k) = enerInternOld(k) +
     1			                 stressPower / density(k)
C
C	 Update the dissipated inelastic specific energy -
C
	          plasticWorkInc = half * ( yieldOld + yieldNew ) * deqps
	          enerInelasNew(k) = enerInelasOld(k) +
     1                           plasticWorkInc / density(k)
C
	    end do
C
	  end if
C
	  return
	  end