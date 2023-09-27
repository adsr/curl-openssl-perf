#!/bin/bash
set -euo pipefail

which=${1:-all}
root=$(pwd)

for openssl in opensslv111w opensslv302 opensslv313; do
    if [ "$which" = all ] || [ "$which" = openssl ]; then
        pushd "$openssl"
        git clean -fdx
        CFLAGS='-g -O0' ./config --prefix="${root}/install-${openssl}" --libdir="${root}/install-${openssl}/lib"
        make -j "$(nproc)" && make install
        popd
    fi

    if [ "$which" = all ] || [ "$which" = curl ]; then
        pushd curl
        git clean -fdx
        autoreconf -fi && PKG_CONFIG_PATH="${root}/install-${openssl}/lib/pkgconfig/" CFLAGS='-g -O0' ./configure --with-openssl --prefix="${root}/install-curl-${openssl}"
        make -j "$(nproc)" && make install
        popd
    fi

    if [ "$which" = all ] || [ "$which" = curl-test ]; then
        gcc \
            -L"${root}/install-${openssl}/lib" \
            -L"${root}/install-curl-${openssl}/lib" \
            -Wl,--disable-new-dtags \
            -Wl,-rpath="${root}/install-${openssl}/lib:${root}/install-curl-${openssl}/lib" \
            curl-test.c \
            -lcurl \
            -o "curl-test-${openssl}"
    fi
done
