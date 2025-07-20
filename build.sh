#!/bin/bash

USERNAME=$(whoami)

IMAGE_TAG="dmtf_spdm:${USERNAME}"
CONTAINER_NAME="spdm_container_${USERNAME}"

# Build in docker container

# 기본값 설정
DEFAULT_BUILD_DIR="spdm/libspdm"
DEFAULT_BUILD_TYPE="Debug"
DEFAULT_CRYPTO="mbedtls"
DEFAULT_ARCH="x64"
DEFAULT_TOOLCHAIN="GCC"
CLEAN_BUILD=false

usage() {
    echo "Usage: $0 [OPTIONS] [BUILD_DIR] [BUILD_TYPE] [CRYPTO] [ARCH] [TOOLCHAIN]"
    echo
    echo "Arguments:"
    echo "  BUILD_DIR    Directory to build (default: $DEFAULT_BUILD_DIR)"
    echo "  BUILD_TYPE   Build type (Debug, Release, etc.) (default: $DEFAULT_BUILD_TYPE)"
    echo "  CRYPTO       Crypto library to use (mbedtls, openssl, etc.) (default: $DEFAULT_CRYPTO)"
    echo "  ARCH         Target architecture (x64, arm64, etc.) (default: $DEFAULT_ARCH)"
    echo "  TOOLCHAIN    Toolchain to use (GCC, Clang, etc.) (default: $DEFAULT_TOOLCHAIN)"
    echo
    echo "Options:"
    echo "  --clean      Remove the existing build directory before building"
    echo "  -h, --help   Show this help message and exit"
    echo
    echo "Example:"
    echo "  $0 --clean spdm/libspdm Debug mbedtls x64 GCC"
    echo "  $0 spdm/spdm-emu Release openssl arm64 Clang"
    exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# --clean 옵션 처리
if [[ "$1" == "--clean" ]]; then
    CLEAN_BUILD=true
    shift # 첫 번째 인자 제거
fi

BUILD_DIR=${1:-$DEFAULT_BUILD_DIR}
BUILD_TYPE=${2:-$DEFAULT_BUILD_TYPE}
CRYPTO=${3:-$DEFAULT_CRYPTO}
ARCH=${4:-$DEFAULT_ARCH}
TOOLCHAIN=${5:-$DEFAULT_TOOLCHAIN}

echo -e "\nBuild Directory: $BUILD_DIR"
echo "Build Type: $BUILD_TYPE"
echo "Crypto Library: $CRYPTO"
echo "Architecture: $ARCH"
echo -e "Toolchain: $TOOLCHAIN\n"

docker exec $CONTAINER_NAME bash -c "
    cd $BUILD_DIR &&
    $(if $CLEAN_BUILD; then echo 'rm -rf build &&'; fi) \
    cmake -B build -S . -DARCH=$ARCH -DTOOLCHAIN=$TOOLCHAIN -DTARGET=$BUILD_TYPE -DCRYPTO=$CRYPTO &&
    cd build &&
    make -j\$(nproc)
"