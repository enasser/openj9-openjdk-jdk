#
# ===========================================================================
# (c) Copyright IBM Corp. 2018, 2018 All Rights Reserved
# ===========================================================================
#
# Copyright (c) 2011, 2018, Oracle and/or its affiliates. All rights reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
#
# This code is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 2 only, as
# published by the Free Software Foundation.  Oracle designates this
# particular file as subject to the "Classpath" exception as provided
# by Oracle in the LICENSE file that accompanied this code.
#
# This code is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# version 2 for more details (a copy is included in the LICENSE file that
# accompanied this code).
#
# You should have received a copy of the GNU General Public License version
# 2 along with this work; if not, write to the Free Software Foundation,
# Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
# or visit www.oracle.com if you need additional information or have any
# questions.
#

################################################################################
# Setup OpenSSL Library - implementation of the SSL and TLS protocols
################################################################################
AC_DEFUN_ONCE([LIB_SETUP_OPENSSL],
[
  AC_ARG_WITH(openssl, [AS_HELP_STRING([--with-openssl],
    [Use either fetched | system | <path to openssl 1.1.0 (and above)])])
   AC_ARG_ENABLE(openssl-bundling, [AS_HELP_STRING([--enable-openssl-bundling],
      [enable bundling of the openssl crypto library with the jdk build])])
   WITH_OPENSSL=yes
   if test "x$with_openssl" = x; then
    # User doesn't want to build with OpenSSL.. Ensure that jncrypto library is not built
    WITH_OPENSSL=no
  else
    AC_MSG_CHECKING([for OPENSSL])
    BUNDLE_OPENSSL="$enable_openssl_bundling"
    BUILD_OPENSSL=no
     # If not specified, default is to not bundle openssl
    if test "x$BUNDLE_OPENSSL" = x; then
      BUNDLE_OPENSSL=no
    fi
     # if --with-openssl=fetched
    if test "x$with_openssl" = xfetched; then
      if test "x$OPENJDK_BUILD_OS" = xwindows; then
        AC_MSG_RESULT([no])
        printf "On Windows, value of \"fetched\" is currently not supported with --with-openssl. Please build OpenSSL using VisualStudio outside cygwin and specify the path with --with-openssl\n"
        AC_MSG_ERROR([Cannot continue])
      fi
       if test -d "$SRC_ROOT/openssl" ; then
        OPENSSL_DIR=$SRC_ROOT/openssl
        FOUND_OPENSSL=yes
        OPENSSL_CFLAGS="-I${OPENSSL_DIR}/include"
        OPENSSL_LIBS="-L${OPENSSL_DIR} -lssl -lcrypto"
        if test -s $OPENSSL_DIR/${LIBRARY_PREFIX}crypto${SHARED_LIBRARY_SUFFIX}.1.1; then
          BUILD_OPENSSL=no
        else
          BUILD_OPENSSL=yes
        fi
        AC_MSG_RESULT([yes])
      else
        AC_MSG_RESULT([no])
        printf "$SRC_ROOT/openssl is not found.\n"
        printf "  run get_source.sh --openssl-version=1.1.0h\n"
        printf "  Then, run configure with '--with-openssl=fetched'\n"
        AC_MSG_ERROR([Cannot continue])
      fi
    fi
     # if --with-openssl=system
    if test "x$FOUND_OPENSSL" != xyes && test "x$with_openssl" = xsystem; then
      if test "x$OPENJDK_BUILD_OS" = xwindows; then
        AC_MSG_RESULT([no])
        printf "On Windows, value of \"system\" is currently not supported with --with-openssl. Please build OpenSSL using VisualStudio outside cygwin and specify the path with --with-openssl\n"
        AC_MSG_ERROR([Cannot continue])
      fi
       # Check modules using pkg-config, but only if we have it
      PKG_CHECK_MODULES(OPENSSL, openssl >= 1.1.0, [FOUND_OPENSSL=yes], [FOUND_OPENSSL=no])
       if test "x$FOUND_OPENSSL" != xyes; then
        AC_MSG_ERROR([Unable to find openssl 1.1.0(and above) installed on System. Please use other options for '--with-openssl'])
      fi
    fi
     # if --with-openssl=/custom/path/where/openssl/is/present
    if test "x$FOUND_OPENSSL" != xyes; then
      # User specified path where openssl is installed
      OPENSSL_DIR=$with_openssl
      BASIC_FIXUP_PATH(OPENSSL_DIR)
      if test -s "$OPENSSL_DIR/include/openssl/evp.h"; then
        if test "x$OPENJDK_BUILD_OS_ENV" = xwindows.cygwin; then
          # On Windows, check for libcrypto.lib
          if test -s "$OPENSSL_DIR/lib/libcrypto.lib"; then
            FOUND_OPENSSL=yes
            OPENSSL_CFLAGS="-I${OPENSSL_DIR}/include"
            OPENSSL_LIBS="-libpath:${OPENSSL_DIR}/lib libssl.lib libcrypto.lib"
          fi
        else
          if test -s "$OPENSSL_DIR/${LIBRARY_PREFIX}crypto${SHARED_LIBRARY_SUFFIX}.1.1"; then
            FOUND_OPENSSL=yes
            OPENSSL_CFLAGS="-I${OPENSSL_DIR}/include"
            OPENSSL_LIBS="-L${OPENSSL_DIR} -lssl -lcrypto"
          fi
        fi
      fi
       #openssl is not found in user specified location. Abort.
      if test "x$FOUND_OPENSSL" != xyes; then
        AC_MSG_RESULT([no])
        AC_MSG_ERROR([Unable to find openssl in specified location $OPENSSL_DIR])
      fi
      AC_MSG_RESULT([yes])
    fi
     if test "x$OPENSSL_DIR" != x; then
      AC_MSG_CHECKING([if we should bundle openssl])
      if test "x$BUNDLE_OPENSSL" = xyes; then
         if test "x$OPENJDK_BUILD_OS_ENV" = xwindows.cygwin; then
           OPENSSL_BUNDLE_LIB_PATH=$OPENSSL_DIR/bin
           BASIC_FIXUP_PATH(OPENSSL_BUNDLE_LIB_PATH)
         else
           OPENSSL_BUNDLE_LIB_PATH=$OPENSSL_DIR
         fi
      fi
      AC_MSG_RESULT([$BUNDLE_OPENSSL])
    fi
  fi
   AC_SUBST(OPENSSL_BUNDLE_LIB_PATH)
  AC_SUBST(OPENSSL_DIR)
  AC_SUBST(WITH_OPENSSL)
  AC_SUBST(BUILD_OPENSSL)
  AC_SUBST(OPENSSL_CFLAGS)
  AC_SUBST(OPENSSL_LIBS)
 ])