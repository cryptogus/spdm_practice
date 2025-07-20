#!/bin/bash

# 현재 사용자 이름 가져오기
USERNAME=$(whoami)

IMAGE_TAG="dmtf_spdm:${USERNAME}"
CONTAINER_NAME="spdm_container_${USERNAME}"

# Docker build
docker build -t $IMAGE_TAG .

# Run container in detached mode
docker run -v $(pwd)/spdm:/workspace/spdm --name $CONTAINER_NAME -dit $IMAGE_TAG --net host

# Execute commands inside the running container
docker exec $CONTAINER_NAME bash -c "
    sudo chown -R devuser:devgroup /workspace/spdm &&
    sudo chmod -R 777 /workspace/spdm &&
    cd /workspace/spdm &&

    # Clone repositories
    git clone --recurse-submodules https://github.com/DMTF/spdm-emu.git &&
    git clone --recurse-submodules https://github.com/DMTF/libspdm.git &&
    git clone --recurse-submodules https://github.com/DMTF/spdm-dump.git &&
    
    # Build the SPDM library project
    cd libspdm &&
    cmake -B build -S . -DARCH=x64 -DTOOLCHAIN=GCC -DTARGET=Debug -DCRYPTO=mbedtls &&
    cd build &&
    make -j$(nproc) &&
    cp ../unit_test/sample_key/auto_gen_cert.sh /workspace &&
    chmod +x /workspace/auto_gen_cert.sh &&
    
    # Build the SPDM emulator project
    cd ../../spdm-emu &&
    cmake -B build -S . -DARCH=x64 -DTOOLCHAIN=GCC -DTARGET=Debug -DCRYPTO=mbedtls &&
    cd build &&
    make -j$(nproc) &&
    
    # Build the SPDM dump tool
    cd ../../spdm-dump &&
    cmake -B build -S . -DARCH=x64 -DTOOLCHAIN=GCC -DTARGET=Debug -DCRYPTO=mbedtls &&
    cd build &&
    make -j$(nproc) &&
    
    # sample certificate
    cd ../../spdm-emu/build/ &&
    make copy_sample_key &&
    cd ../../libspdm/build/ &&
    make copy_sample_key
"