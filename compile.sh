#!/bin/bash
set -euo pipefail
set -x

which=${1:-all}
root=$(pwd)

# for openssl in opensslv111w opensslv302 opensslv313 opensslv321; do
for openssl in opensslv313; do
    if [ "$which" = all ] || [ "$which" = openssl ]; then
        pushd "$openssl"
        git clean -fdx
        CFLAGS='-g -O3' ./config \
            --prefix="${root}/install-${openssl}" \
            --libdir="${root}/install-${openssl}/lib"
        make -j "$(nproc)" && make install
        popd
    fi

    if [ "$which" = all ] || [ "$which" = curl ]; then
        pushd curl
        git clean -fdx
        autoreconf -fi
        CFLAGS='-g -O3' \
            PKG_CONFIG_PATH="${root}/install-${openssl}/lib/pkgconfig/" \
            ./configure \
            --with-openssl \
            --disable-threaded-resolver \
            --prefix="${root}/install-curl-${openssl}"
        make -j "$(nproc)" && make install
        popd
    fi

    if [ "$which" = all ] || [ "$which" = curl-test ]; then
        gcc -g -O0 \
            -L"${root}/install-${openssl}/lib" \
            -L"${root}/install-curl-${openssl}/lib" \
            -Wl,--disable-new-dtags \
            -Wl,-rpath="${root}/install-${openssl}/lib:${root}/install-curl-${openssl}/lib" \
            curl-test.c \
            -lcurl \
            -o "curl-test-${openssl}"
    fi
done

for wolfssl in wolfsslv572; do
    if [ "$which" = all ] || [ "$which" = openssl ]; then
        pushd "$wolfssl"
        git clean -fdx
        ./autogen.sh \
            && CFLAGS='-g -O3' ./configure \
            --prefix="${root}/install-${wolfssl}" \
            --libdir="${root}/install-${wolfssl}/lib" \
            --enable-curl
        make -j "$(nproc)" && make install
        popd
    fi

    if [ "$which" = all ] || [ "$which" = curl ]; then
        pushd curl
        git clean -fdx
        autoreconf -fi
        CFLAGS='-g -O3' \
            PKG_CONFIG_PATH="${root}/install-${wolfssl}/lib/pkgconfig/" \
            ./configure \
            --without-ssl \
            --with-wolfssl \
            --disable-threaded-resolver \
            --prefix="${root}/install-curl-${wolfssl}"
        make -j "$(nproc)" && make install
        popd
    fi

    if [ "$which" = all ] || [ "$which" = curl-test ]; then
        gcc -g -O0 \
            -L"${root}/install-${wolfssl}/lib" \
            -L"${root}/install-curl-${wolfssl}/lib" \
            -Wl,--disable-new-dtags \
            -Wl,-rpath="${root}/install-${wolfssl}/lib:${root}/install-curl-${wolfssl}/lib" \
            curl-test.c \
            -lcurl \
            -o "curl-test-${wolfssl}"
    fi
done
