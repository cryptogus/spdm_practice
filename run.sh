#!/bin/bash

USERNAME=$(whoami)

IMAGE_TAG="dmtf_spdm:${USERNAME}"
CONTAINER_NAME="spdm_container_${USERNAME}"

DEFAULT_EXECUTABLE_PATH="spdm/libspdm/build/bin"
DEFAULT_EXECUTABLE_NAME="test_crypt"

usage() {
    echo "Usage: $0 <Executable file path> <Executable file name> [Executable options]"
    echo
    echo "Arguments:"
    echo "  <Executable file path>   Path to the directory containing the executable (default: $DEFAULT_EXECUTABLE_PATH)"
    echo "  <Executable file name>   Name of the executable file to run (default: $DEFAULT_EXECUTABLE_NAME)"
    echo "  [Executable options]     Additional options to pass to the executable"
    echo
    echo "Examples:"
    echo "  $0 spdm/spdm-emu/build/bin spdm_responder_emu"
    echo "  $0 spdm/spdm-emu/build/bin spdm_requester_emu --option1 --option2"
    exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

EXECUTABLE_PATH=${1:-$DEFAULT_EXECUTABLE_PATH}
EXECUTABLE_NAME=${2:-$DEFAULT_EXECUTABLE_NAME}
shift 2 # 첫 번째와 두 번째 인자를 제거하고 나머지 인자를 옵션으로 처리
EXECUTABLE_OPTIONS="$@"

echo -e "\nPath: $EXECUTABLE_PATH"
echo "Executable: $EXECUTABLE_NAME"
echo -e "Options: $EXECUTABLE_OPTIONS\n"

docker exec $CONTAINER_NAME bash -c "
    cd $EXECUTABLE_PATH &&
    ./$EXECUTABLE_NAME $EXECUTABLE_OPTIONS
"