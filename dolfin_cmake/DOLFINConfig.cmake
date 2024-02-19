# - Build details for DOLFIN: Dynamic Object-oriented Library for
# - FINite element computation
#
# This file has been automatically generated.

# FIXME: Check that naming conforms to CMake standards

# Library dependencies (contains definitions for IMPORTED targets)
# NOTE: DOLFIN demo CMakeLists.txt are written to be stand-alone, as
# well as the build system building the demo. Therefore, we need the
# below guard to avoid exporting the targets twice.
if (NOT TARGET dolfin)
  include("/home/fenics/build/share/dolfin/cmake/DOLFINTargets.cmake")
endif()

# Compilers
set(DOLFIN_CXX_COMPILER "/usr/bin/c++")

# Compiler defintions
set(DOLFIN_CXX_DEFINITIONS "-DDOLFIN_VERSION=\"1.6.0\";-DNDEBUG;-DDOLFIN_SIZE_T=8;-DDOLFIN_LA_INDEX_SIZE=4;-DHAS_HDF5;-D_LARGEFILE64_SOURCE;-D_LARGEFILE_SOURCE;-D_FORTIFY_SOURCE=2;-DHAS_SLEPC;-DHAS_PETSC;-DENABLE_PETSC_TAO;-DHAS_UMFPACK;-DHAS_CHOLMOD;-DHAS_SCOTCH;-DHAS_PARMETIS;-DHAS_ZLIB;-DHAS_MPI;-DHAS_OPENMP")

# Compiler flags
set(DOLFIN_CXX_FLAGS " -std=c++11   -fopenmp")

# Linker flags
set(DOLFIN_LINK_FLAGS " ")

# Include directories
set(DOLFIN_INCLUDE_DIRS "/home/fenics/build/include")

# Third party include directories
set(DOLFIN_3RD_PARTY_INCLUDE_DIRS "/home/fenics/build/include;/usr/local/include;/usr/local/include;/usr/local/include;/usr/local/include;/usr/include;/usr/include/mpich;/usr/include/eigen3;/usr/include;/usr/include/hdf5/mpich;/usr/local/include;/usr/include/mpich;/usr/local/include;/usr/include/mpich")

# Python include directories
set(DOLFIN_PYTHON_INCLUDE_DIRS "/usr/lib/python2.7/dist-packages/numpy/core/include;/usr/include/python2.7;/usr/local/lib/python2.7/dist-packages/petsc4py/include;/usr/local/lib/python2.7/dist-packages/slepc4py/include")

# Python definitions
set(DOLFIN_PYTHON_DEFINITIONS "-DHAS_PETSC4PY;-DHAS_SLEPC4PY;-DNUMPY_VERSION_MAJOR=1;-DNUMPY_VERSION_MINOR=11;-DNUMPY_VERSION_MICRO=0;-DNPY_NO_DEPRECATED_API=NPY_1_11_API_VERSION")

# Python libraries
set(DOLFIN_PYTHON_LIBRARIES "/usr/lib/x86_64-linux-gnu/libpython2.7.so")

set(DOLFIN_SWIG_EXECUTABLE "/usr/local/bin/swig")

# DOLFIN library
set(DOLFIN_LIBRARIES dolfin)

# Version
set(DOLFIN_VERSION_MAJOR "1")
set(DOLFIN_VERSION_MINOR "6")
set(DOLFIN_VERSION_MICRO "0")
set(DOLFIN_VERSION_STR   "1.6.0")

# The location of the UseDOLFIN.cmake file
set(DOLFIN_USE_FILE "/home/fenics/build/share/dolfin/cmake/UseDOLFIN.cmake")
