# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.20

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /projappl/project_2004956/fortran-tf-lib/fortran-tf-lib

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu

# Include any dependencies generated for this target.
include CMakeFiles/test_load_model_f.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include CMakeFiles/test_load_model_f.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/test_load_model_f.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/test_load_model_f.dir/flags.make

CMakeFiles/test_load_model_f.dir/tests/load_model_f.F90.o: CMakeFiles/test_load_model_f.dir/flags.make
CMakeFiles/test_load_model_f.dir/tests/load_model_f.F90.o: ../tests/load_model_f.F90
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building Fortran object CMakeFiles/test_load_model_f.dir/tests/load_model_f.F90.o"
	/appl/spack/v018/install-tree/gcc-8.5.0/gcc-11.3.0-i44hho/bin/gfortran $(Fortran_DEFINES) $(Fortran_INCLUDES) $(Fortran_FLAGS) -c /projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/tests/load_model_f.F90 -o CMakeFiles/test_load_model_f.dir/tests/load_model_f.F90.o

CMakeFiles/test_load_model_f.dir/tests/load_model_f.F90.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing Fortran source to CMakeFiles/test_load_model_f.dir/tests/load_model_f.F90.i"
	/appl/spack/v018/install-tree/gcc-8.5.0/gcc-11.3.0-i44hho/bin/gfortran $(Fortran_DEFINES) $(Fortran_INCLUDES) $(Fortran_FLAGS) -E /projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/tests/load_model_f.F90 > CMakeFiles/test_load_model_f.dir/tests/load_model_f.F90.i

CMakeFiles/test_load_model_f.dir/tests/load_model_f.F90.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling Fortran source to assembly CMakeFiles/test_load_model_f.dir/tests/load_model_f.F90.s"
	/appl/spack/v018/install-tree/gcc-8.5.0/gcc-11.3.0-i44hho/bin/gfortran $(Fortran_DEFINES) $(Fortran_INCLUDES) $(Fortran_FLAGS) -S /projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/tests/load_model_f.F90 -o CMakeFiles/test_load_model_f.dir/tests/load_model_f.F90.s

# Object files for target test_load_model_f
test_load_model_f_OBJECTS = \
"CMakeFiles/test_load_model_f.dir/tests/load_model_f.F90.o"

# External object files for target test_load_model_f
test_load_model_f_EXTERNAL_OBJECTS =

test_load_model_f: CMakeFiles/test_load_model_f.dir/tests/load_model_f.F90.o
test_load_model_f: CMakeFiles/test_load_model_f.dir/build.make
test_load_model_f: libfortran-tf.so.0.1
test_load_model_f: CMakeFiles/test_load_model_f.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking Fortran executable test_load_model_f"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/test_load_model_f.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/test_load_model_f.dir/build: test_load_model_f
.PHONY : CMakeFiles/test_load_model_f.dir/build

CMakeFiles/test_load_model_f.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/test_load_model_f.dir/cmake_clean.cmake
.PHONY : CMakeFiles/test_load_model_f.dir/clean

CMakeFiles/test_load_model_f.dir/depend:
	cd /projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /projappl/project_2004956/fortran-tf-lib/fortran-tf-lib /projappl/project_2004956/fortran-tf-lib/fortran-tf-lib /projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu /projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu /projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/build_gnu/CMakeFiles/test_load_model_f.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/test_load_model_f.dir/depend
