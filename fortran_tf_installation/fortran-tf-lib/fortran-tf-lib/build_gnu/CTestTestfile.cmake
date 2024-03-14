# CMake generated Testfile for 
# Source directory: /projappl/project_2004956/fortran-tf-lib/fortran-tf-lib
# Build directory: /projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(process_model_exists "process_model" "--help")
set_tests_properties(process_model_exists PROPERTIES  FIXTURES_SETUP "process_model" _BACKTRACE_TRIPLES "/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/CMakeLists.txt;110;add_test;/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/CMakeLists.txt;0;")
add_test(process_model_output "process_model" "-o" "/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu/test_fortran_gen.F90" "/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/my_model")
set_tests_properties(process_model_output PROPERTIES  FIXTURES_REQUIRED "process_model" FIXTURES_SETUP "process_model_output" WORKING_DIRECTORY "/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu" _BACKTRACE_TRIPLES "/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/CMakeLists.txt;119;add_test;/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/CMakeLists.txt;0;")
add_test(load_model_f "/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu/test_load_model_f")
set_tests_properties(load_model_f PROPERTIES  PASS_REGULAR_EXPRESSION "SUCCESS" _BACKTRACE_TRIPLES "/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/CMakeLists.txt;137;add_test;/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/CMakeLists.txt;0;")
add_test(process_model_1 "/usr/bin/ctest" "--build-and-test" "/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/tests/generated_code_test" "/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu/tests/generated_code_test/build" "--build-generator" "Unix Makefiles" "--test-command" "/usr/bin/ctest" "--output-on-failure" "--build-options" "-DFORTRAN_TF_LIB=/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu/libfortran-tf.so.0.1" "-DFORTRAN_TF_LIB_DIR=/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu" "-DGENERATED_CODE_FILE=/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu/test_fortran_gen.F90" "-DCMAKE_Fortran_COMPILER=/appl/spack/v018/install-tree/gcc-8.5.0/gcc-11.3.0-i44hho/bin/gfortran" "-DCMAKE_C_COMPILER=/appl/spack/v018/install-tree/gcc-8.5.0/gcc-11.3.0-i44hho/bin/gcc")
set_tests_properties(process_model_1 PROPERTIES  FIXTURES_REQUIRED "process_model_output" _BACKTRACE_TRIPLES "/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/CMakeLists.txt;145;add_test;/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/CMakeLists.txt;0;")
