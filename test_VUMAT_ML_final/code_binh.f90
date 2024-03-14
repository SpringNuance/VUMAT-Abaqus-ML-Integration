subroutine vexternaldb(lOp, i_Array, niArray, r_Array, nrArray)

	use tf_types
	use tf_interface
	use iso_c_binding
	use ml_module

    include 'vaba_param.inc'

    dimension i_Array(niArray), r_Array(nrArray)
	
    ! Parameters for contents of i_Array
    i_int_nTotalNodes     = 1
    i_int_nTotalElements  = 2
    i_int_kStep           = 3
    i_int_kInc            = 4
    i_int_iStatus         = 5
    i_int_lWriteRestart   = 6

    ! Possible values for the lOp argument
    j_int_StartAnalysis    = 0
    j_int_StartStep        = 1
    j_int_SetupIncrement   = 2
    j_int_StartIncrement   = 3
    j_int_EndIncrement     = 4
    j_int_EndStep          = 5
    j_int_EndAnalysis      = 6

    ! Possible values for i_Array(i_int_iStatus)
    j_int_Continue          = 0
    j_int_TerminateStep     = 1
    j_int_TerminateAnalysis = 2

    ! Contents of r_Array
    i_flt_TotalTime   = 1
    i_flt_StepTime    = 2
    i_flt_dTime       = 3

    kStep = i_Array(i_int_kStep)
    kInc  = i_Array(i_int_kInc)

! print *, 'lOp = ', lOp
! User subroutine body
! Check the operation type (lOp) to determine the analysis stage
if (lOp == j_int_StartAnalysis) then
    !if (kInc == 0) then
    ! Called at the start of the analysis
    ! Initialize the ML module here
    call ml_module_init()
	print *, 'Initialize TensorFlow modules successfully'
	
	!endif 

else if (lOp == j_int_EndAnalysis) then
    ! Called at the end of the analysis
    ! Clean up the ML module here
    call ml_module_finish()
	print *, 'Cleaning TensorFlow modules successfully'

endif

return
end



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
use ml_module

include 'vaba_param.inc'

dimension props(nprops)
dimension density(nblock)
dimension coordMp(nblock, *)
dimension charLength(nblock)
dimension strainInc(nblock, ndir+nshr)
dimension relSpinInc(nblock, nshr)
dimension tempOld(nblock)
dimension stretchOld(nblock, ndir+nshr)
dimension defgradOld(nblock, ndir+nshr+nshr)
dimension fieldOld(nblock, nfieldv)
dimension stressOld(nblock, ndir+nshr)
dimension stateOld(nblock, nstatev)
dimension enerInternOld(nblock)
dimension enerInelasOld(nblock)
dimension tempNew(nblock)
dimension stretchNew(nblock, ndir+nshr)
dimension defgradNew(nblock, ndir+nshr+nshr)
dimension fieldNew(nblock, nfieldv)
dimension stressNew(nblock, ndir+nshr)
dimension stateNew(nblock, nstatev)
dimension enerInternNew(nblock)
dimension enerInelasNew(nblock)

character(len=80) :: cmname

real, parameter :: zero = 0.d0, one = 1.d0, two = 2.d0, &
                  third = 1.d0 / 3.d0, half = 0.5d0, op5 = 1.5d0

real :: e, xnu, hard, syield0, k
real :: log_PEEQ_min, log_PEEQ_max, log_strain_rate_min, log_strain_rate_max
real :: stress_min, stress_max, init_temp_min, init_temp_max, delta_temp_min, delta_temp_max
real :: twomu, alamda, thremu

real :: new_PEEQ, new_strain_rate
real :: old_PEEQ, old_strain_rate, old_temp, old_stress
real :: log_old_PEEQ, log_old_strain_rate, norm_PEEQ, norm_strain_rate, norm_temp
real :: norm_new_stress, norm_delta_temp
real :: new_stress, delta_temp, new_temp
real :: trace, s11, s22, s33, s12, s13, s23, smean
real :: vmises, sigdif, facyld, delta_PEEQ, syield, yieldOld, yieldNew
real :: factor, stressPower, plasticWorkInc, deqps

real(kind=c_float), dimension(3, 1, 1), target :: input_array
type(TF_Tensor), dimension(1) :: input_tensors, output_tensors

integer(kind=c_int64_t), dimension(3) :: input_shape, output_shape


! Bind output tensor
real, dimension(:), pointer :: output_data_ptr
! type(c_ptr) :: input_array_ptr, output_c_data_ptr

e       = props(1)
xnu     = props(2)
hard    = props(3)
syield0 = props(4)


log_PEEQ_min = props(5)
log_PEEQ_max = props(6)
log_strain_rate_min = props(7)
log_strain_rate_max = props(8)
stress_min = props(9)
stress_max = props(10)
init_temp_min = props(11)
init_temp_max = props(12)
delta_temp_min = props(13)
delta_temp_max = props(14)

twomu   = e / (one + xnu)
alamda  = xnu * twomu / (one - two * xnu)
thremu  = op5 * twomu

!	nvalue = nprops/2-1

! -----------------------------------------------------------------------
!   Elastic Constitutive Relationship:
!   σ'_new = σ'_old + 2μ Δε' + λ tr(Δε)
! -----------------------------------------------------------------------

! state(k, 1) is PEEQ, updated by von Mises model
! state(k, 2) is strain rate, updated by (PPEQ new - PEEQ old)/dt
! state(k, 3) is stress, updated by ML output
! state(k, 4) is evolved temperature, updated by ML output


if (.not. is_initialized) then
    ! Initialize the ML module
	write(*,*) 
	print *, 'User subroutine constants'
	write(*,*) 
	print *, 'E = ', e
	print *, 'xnu = ', xnu
	print *, 'hard = ', hard
	print *, 'syield0 = ', syield0
	print *, 'log_PEEQ_min = ', log_PEEQ_min
	print *, 'log_PEEQ_max = ', log_PEEQ_max
	print *, 'log_strain_rate_min = ', log_strain_rate_min
	print *, 'log_strain_rate_max = ', log_strain_rate_max
	print *, 'stress_min = ', stress_min
	print *, 'stress_max = ', stress_max
	print *, 'init_temp_min = ', init_temp_min
	print *, 'init_temp_max = ', init_temp_max
	print *, 'delta_temp_min = ', delta_temp_min
	print *, 'delta_temp_max = ', delta_temp_max

    ! call ml_module_init()
    
	! write(*,*) 
    ! print *, 'Initialize TensorFlow modules successfully'

	! Get initial PEEQ
	old_PEEQ = stateOld(k,1)
	! Get initial strain rate
	old_strain_rate = stateOld(k,2)
	! Get old stress
	old_stress = stateOld(k,3)
	! Get old temperature
	old_temp = stateOld(k,4)
	
	write(*,*) 

	print *, 'Initial values of state dependent variables'
	write(*,*)
	
	print *, 'initial PEEQ = ', old_PEEQ
	print *, 'initial strain rate = ', old_strain_rate
	print *, 'initial stress = ', old_stress
	print *, 'initial temperature = ', old_temp

	write(*,*) 
    ! Set the control variable to indicate that initialization is done
    is_initialized = .true.

endif

if (stepTime == zero) then


    ! nblock: Number of material points to be processed in this call to VUMAT
    do k = 1, nblock
        				
		!-----------------!
		! von Mises model !
		!-----------------!
        
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

	do k = 1, nblock

	
        ! Get initial PEEQ
	! old_PEEQ = stateOld(k,1)
	! Get initial strain rate
	! old_strain_rate = stateOld(k,2)
	! Get old stress
	! old_stress = stateOld(k,3)
	! Get old temperature
	! old_temp = stateOld(k,4)

	!print *, 'initial PEEQ = ', old_PEEQ
	!print *, 'initial strain rate = ', old_strain_rate
	!print *, 'initial stress = ', old_stress
	!print *, 'initial temperature = ', old_temp

		!-----------------!
		! von Mises model !
		!-----------------!

		old_PEEQ = stateOld(k,1)
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

		delta_PEEQ = facyld * sigdif / (thremu + hard)
		syield = syield0 + hard * delta_PEEQ

		! Update the stress
		yieldNew = yieldOld + hard * delta_PEEQ
		factor = yieldNew / (yieldNew + thremu * delta_PEEQ)
		stressNew(k,1) = s11 * factor + smean
		stressNew(k,2) = s22 * factor + smean
		stressNew(k,3) = s33 * factor + smean
		stressNew(k,4) = s12 * factor

		if (nshr > 1) then
			stressNew(k,5) = s13 * factor
			stressNew(k,6) = s23 * factor
		end if

!	    Update PEEQ new (common to both vM and ML model)
        new_PEEQ = old_PEEQ + delta_PEEQ
	    stateNew(k,1) = new_PEEQ

		!-----------------!
		! ML output model !
		!-----------------! 
        

!       Update strain rate
        new_strain_rate = delta_PEEQ / dt
		stateNew(k,2) = new_strain_rate

		! Extract the old temp
		old_temp = stateOld(k,4)
		
! Transform and normalize inputs for ML model
		log_new_PEEQ = log10(new_PEEQ)
		log_new_strain_rate = log10(new_strain_rate)
		norm_PEEQ = (log_new_PEEQ - log_PEEQ_min) / log_PEEQ_max
		norm_strain_rate = (log_new_strain_rate - log_strain_rate_min) / log_strain_rate_max
		norm_temp = (old_temp - init_temp_min) / init_temp_max


! 	    Obtain the ML output prediction for new stress and delta temperature
		
!       output is normalized stress and delta temperature
!       they are output from the ML model in predict_tensorflow.inc		
!       norm_new_stress, norm_delta_temp = ml_model(ML_input)

		! Fill your input_array array with the actual input values
		input_array = reshape([norm_PEEQ, norm_strain_rate, norm_temp], [3, 1, 1])
                
        ! print *, 'input array', input_array
   
		! print *, 'input array initialized OK'

		! Define the shape of the input tensor
		input_shape = [3, 1, 1]
		output_shape = [2, 1, 1]
        
		! Place the single tensor into an array
		input_tensors(1) = r32_3_associate_tensor(input_array, input_shape)

		! print *, 'input tensor initialized OK'

		! print *, 'Input tensors:', input_tensors(1)

		! Call the subroutine with the arrays
		call ml_module_calc(model_session_1, inputs_1, input_tensors, outputs_1, output_tensors)
        
		! print *, 'ML inference OK'

        call c_f_pointer(TF_TensorData( output_tensors(1)), output_data_ptr, shape(output_data_ptr))

		! print *, 'Output binding pointers OK'

		norm_new_stress = output_data_ptr(1)
		norm_delta_temp = output_data_ptr(2)
                
		! print *, 'Extracting output OK'


!       descaling the output
		new_stress = norm_new_stress * stress_max + stress_min
		delta_temp = norm_delta_temp * delta_temp_max + delta_temp_min
		new_temp = old_temp + delta_temp
                
                ! print *, 'norm_new_stress', norm_new_stress
                ! print *, 'norm_delta_temp', norm_delta_temp

                !print *, 'new_stress', new_stress
                !print *, 'new_temp', new_temp
! 	    Update stress from ML output
		stateNew(k,3) = new_stress

! 	    Update temperature from ML output
		stateNew(k,4) = new_temp

! Update the specific internal energy - only vM model

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

! Update the dissipated inelastic specific energy - only vM model

		plasticWorkInc = half * (yieldOld + yieldNew) * deqps
		enerInelasNew(k) = enerInelasOld(k) + plasticWorkInc / density(k)

	end do

end if

return
end