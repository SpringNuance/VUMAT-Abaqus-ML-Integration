module ml_module
    use TF_Types
    use TF_Interface

    public ml_module_init, &
        ml_module_calc, &
        ml_module_finish, &
        associate_tensor

    ! Interface for `associate_tensor` functions
    interface associate_tensor
        module procedure r32_3_associate_tensor
    end interface associate_tensor

    ! Each model needs a session and a graph variable.
    ! Model: LSTM
    
    logical :: is_initialized = .false.
    type(TF_Session) :: model_session_1
    type(TF_Graph) :: model_graph_1

    ! Input and output details
    type(TF_Output), dimension(1) :: inputs_1
    type(TF_Output), dimension(1) :: outputs_1
    
    contains

    subroutine ml_module_init()
        ! Filenames for directories containing models
        character(100), dimension(1) :: model_dirs

        character(5), dimension(1, 1) :: tags
        integer :: i

        ! Assign the tags
        tags(1, 1) = 'serve'

        ! Rather than hard-coding the filenames here, you probably
        ! want to load them from a config file or similar.
        model_dirs(1) = '/scratch/project_2004956/test_VUMAT_ML/LSTM'

        ! Load all the models.
        ! If you have a model with different needs (tags, etc)
        ! edit this to handle that model separately.

        ! Model: LSTM
        model_graph_1 = TF_NewGraph()
        call load_model(model_session_1, &
            model_graph_1, &
            tags(:, 1), model_dirs(1))

        ! Populate the input / output operations.
        ! Input for 'LSTM' input 'lstm_input'
        inputs_1(1)%oper = TF_GraphOperationByName( &
            model_graph_1, &
            'serving_default_lstm_input' &
        )
        if (.not.c_associated(inputs_1(1)%oper%p)) then
            write(*,*)'inputs_1(1) not associated'
            stop
        endif
        inputs_1(1)%index = 0

        ! Output for 'LSTM' output 'dense'
        outputs_1(1)%oper = TF_GraphOperationByName( &
            model_graph_1, &
            'StatefulPartitionedCall' &
        )
        if (.not.c_associated(outputs_1(1)%oper%p)) then
            write(*,*)'outputs_1(1) not associated'
            stop
        endif
        outputs_1(1)%index = 0

    end subroutine ml_module_init

    subroutine load_model(session, graph, tags, model_dir)

        type(TF_Session) :: session
        type(TF_Graph) :: graph
        character(*), dimension(:) :: tags
        character(*) :: model_dir

        type(TF_SessionOptions) :: sessionoptions
        type(TF_Status) :: stat
        character(100) :: message

        sessionoptions = TF_NewSessionOptions()
        stat = TF_NewStatus()

        session = TF_LoadSessionFromSavedModel(sessionoptions, &
            model_dir, &
            tags, size(tags, 1), graph, stat)

        if (TF_GetCode( stat ) .ne. TF_OK) then
            call TF_Message( stat, message )
            write(*,*) TF_GetCode( stat ), message
            stop
        endif

        call TF_DeleteSessionOptions(sessionoptions)
        call TF_DeleteStatus(stat)

    end subroutine load_model


    subroutine ml_module_calc( &
        session, inputs, input_tensors, outputs, output_tensors &
    )

        type(TF_Session) :: session
        type(TF_Output), dimension(:) :: inputs, outputs
        type(TF_Tensor), dimension(:) :: input_tensors, output_tensors

        type(TF_Status) :: stat
        character(100) :: message
        type(TF_Operation), dimension(1) :: target_opers

        stat = TF_NewStatus()

        call TF_SessionRun( &
            session, &
            inputs, input_tensors, &
            size(input_tensors), &
            outputs, output_tensors, &
            size(output_tensors), &
            target_opers, 0, stat &
        )
        if (TF_GetCode(stat) .ne. TF_OK) then
            call TF_Message(stat, message)
            write(*,*) TF_GetCode(stat), message
            stop
        endif
        call TF_DeleteStatus(stat)

    end subroutine ml_module_calc

    subroutine ml_module_finish()

        type(TF_Status) :: stat
        character(100) :: message

        stat = TF_NewStatus()
        ! Delete the model variables.
        ! Model: LSTM
        call TF_DeleteGraph(model_graph_1)
        call TF_DeleteSession(model_session_1, &
            stat)
        if (TF_GetCode(stat) .ne. TF_OK) then
            call TF_Message(stat, message)
            write(*,*) TF_GetCode(stat), message
            ! we don't stop here so all resources can try to delete
        endif
        call TF_DeleteStatus(stat)

    end subroutine ml_module_finish
    
    ! This function reads as "subroutine for converting floating point 32 bit to Tensorflow TF_Tensor"
    function r32_3_associate_tensor(input_array, input_shape, input_size)
        type(TF_Tensor) :: r32_3_associate_tensor
        real(kind=c_float), dimension(:, :, :), target :: input_array
        integer(kind=c_int64_t), dimension(3), optional :: input_shape
        integer(kind=c_size_t), optional :: input_size

        integer(kind=c_int64_t), dimension(3) :: input_shape_act
        integer(kind=c_int64_t) :: swap
        integer :: i, sz_inp_act
        integer(kind=c_size_t) :: input_size_act

        if (.not.present(input_shape)) then
            input_shape_act = shape(input_array)
        else
            input_shape_act = input_shape
        end if

        ! Reverse the index order of the shape.
        sz_inp_act = size(input_shape_act) + 1 ! 1-indexed arrays
        do i = 1, sz_inp_act / 2
            swap = input_shape_act(i)
            input_shape_act(i) = input_shape_act(sz_inp_act - i)
            input_shape_act(sz_inp_act - i) = swap
        enddo

        if (.not.present(input_size)) then
            ! sizeof is non-standard but seems to be widely supported.
            input_size_act = int(sizeof(input_array), kind=c_size_t)
        else
            input_size_act = input_size
        end if

        r32_3_associate_tensor = TF_NewTensor(TF_FLOAT, input_shape_act, 3, &
            c_loc(input_array), input_size_act)

    end function r32_3_associate_tensor

end module ml_module
