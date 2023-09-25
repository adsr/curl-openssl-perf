#!/bin/bash
root=$(pwd)

for openssl in opensslv1 opensslv3; do
    # pushd "$openssl"
    # git clean -fdx
    # CFLAGS='-g -O0' ./config --prefix="${root}/install-${openssl}" --libdir="${root}/install-${openssl}/lib"
    # make -j "$(nproc)" && make install
    # popd

    # pushd curl
    # git clean -fdx
    # autoreconf -fi && PKG_CONFIG_PATH="${root}/install-${openssl}/lib/pkgconfig/" CFLAGS='-g -O0' ./configure --with-openssl --prefix="${root}/install-curl-${openssl}"
    # make -j "$(nproc)" && make install
    # popd

    gcc \
        -L"${root}/install-${openssl}/lib" \
        -L"${root}/install-curl-${openssl}/lib" \
        -Wl,--disable-new-dtags \
        -Wl,-rpath="${root}/install-${openssl}/lib:${root}/install-curl-${openssl}/lib" \
        curl-test.c \
        -lcurl \
        -o "curl-test-${openssl}"
done
