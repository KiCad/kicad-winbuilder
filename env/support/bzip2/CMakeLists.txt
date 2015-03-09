
project( bz2 )

cmake_minimum_required( VERSION 2.6.2 )

set( VERSION_MAJOR  1 )
set( VERSION_MINOR  0 )
set( VERSION_PATCH  6 )

add_definitions( -D_FILE_OFFSET_BITS=64 )

add_library( bz2 SHARED
    blocksort.c
    bzlib.c
    compress.c
    crctable.c
    decompress.c
    huffman.c
    randtable.c
    bzlib.h
    bzlib_private.h )

