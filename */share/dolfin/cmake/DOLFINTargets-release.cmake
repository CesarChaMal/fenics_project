#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "dolfin" for configuration "Release"
set_property(TARGET dolfin APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(dolfin PROPERTIES
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "/usr/lib/x86_64-linux-gnu/libboost_filesystem.so;/usr/lib/x86_64-linux-gnu/libboost_program_options.so;/usr/lib/x86_64-linux-gnu/libboost_system.so;/usr/lib/x86_64-linux-gnu/libboost_thread.so;/usr/lib/x86_64-linux-gnu/libboost_iostreams.so;/usr/lib/x86_64-linux-gnu/libboost_timer.so;/usr/lib/x86_64-linux-gnu/libboost_chrono.so;/usr/lib/x86_64-linux-gnu/libboost_date_time.so;/usr/lib/x86_64-linux-gnu/libboost_atomic.so;/usr/lib/x86_64-linux-gnu/libboost_regex.so;/usr/lib/x86_64-linux-gnu/libpthread.so;/usr/lib/x86_64-linux-gnu/hdf5/mpich/lib/libhdf5.so;/usr/lib/x86_64-linux-gnu/libsz.so;/usr/lib/x86_64-linux-gnu/libz.so;/usr/lib/x86_64-linux-gnu/libdl.so;/usr/lib/x86_64-linux-gnu/libm.so;/usr/local/lib/libslepc.so;/usr/local/lib/libpetsc.so;/usr/local/lib/libumfpack.a;/usr/local/lib/libamd.a;/usr/lib/libblas.so;/usr/local/lib/libcholmod.a;/usr/local/lib/libamd.a;/usr/local/lib/libcamd.a;/usr/local/lib/libcolamd.a;/usr/local/lib/libccolamd.a;/usr/local/lib/libsuitesparseconfig.a;/usr/lib/x86_64-linux-gnu/librt.so;/usr/local/lib/libparmetis.so;/usr/local/lib/libmetis.so;/usr/lib/liblapack.so;/usr/lib/libblas.so;/usr/lib/libblas.so;/usr/lib/gcc/x86_64-linux-gnu/5/libgfortran.so;/usr/local/lib/libsuitesparseconfig.a;/usr/lib/gcc/x86_64-linux-gnu/5/libgfortran.so;/usr/local/lib/libcholmod.a;/usr/local/lib/libamd.a;/usr/local/lib/libcamd.a;/usr/local/lib/libcolamd.a;/usr/local/lib/libccolamd.a;/usr/local/lib/libsuitesparseconfig.a;/usr/lib/x86_64-linux-gnu/librt.so;/usr/local/lib/libparmetis.so;/usr/local/lib/libmetis.so;/usr/lib/liblapack.so;/usr/lib/libblas.so;/usr/lib/libblas.so;/usr/lib/gcc/x86_64-linux-gnu/5/libgfortran.so;/usr/local/lib/libptscotch.a;/usr/local/lib/libscotch.a;/usr/local/lib/libptscotcherr.a;/usr/local/lib/libparmetis.so;/usr/local/lib/libmetis.so;/usr/lib/x86_64-linux-gnu/libz.so;/usr/lib/x86_64-linux-gnu/libmpichcxx.so;/usr/lib/x86_64-linux-gnu/libmpich.so"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libdolfin.so.1.6.0"
  IMPORTED_SONAME_RELEASE "libdolfin.so.1.6"
  )

list(APPEND _IMPORT_CHECK_TARGETS dolfin )
list(APPEND _IMPORT_CHECK_FILES_FOR_dolfin "${_IMPORT_PREFIX}/lib/libdolfin.so.1.6.0" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
