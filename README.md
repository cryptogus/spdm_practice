# SPDM TEST environments

## Docker

### socket: Permission denied (non-root user)
```bash
$ sudo chmod 666 /var/run/docker.sock
```

## SPDM test commands in container
- **`spdm/`**: Shared volume directory between the host and the Docker container. This directory contains the SPDM-related source code and build artifacts.
- **`setup_spdm.sh`**: Sets up the Docker environment and clones/builds the open-source SPDM projects into the shared volume.
- **`run.sh`**: Used to execute SPDM-related executables inside the Docker container.
- **`build.sh`**: Rebuilds the open-source SPDM projects when needed.

### Docker build & run

Docker volume 생성 후 SPDM 오픈 소스 clone & build
```bash
$ bash setup_spdm.sh
$ docker ps
```

**Not recommand**
```bash
$ docker build -t spdm_test:v1 . # --no-cache
$ docker run -v $(pwd)/spdm:/workspace/spdm -d spdm_test:v1
```

- **Note**: The `spdm` directory is a shared volume between the Docker container and the host. Any changes made in this directory on the host will be reflected inside the container at `/workspace/spdm`, and vice versa.

### Access the inside of a Docker container
```bash
$ docker exec -it <CONTAINER ID or NAMES> /bin/bash
```

### Container Stop & Start
- Stop
```bash
$ docker stop spdm_container_$(whoami)
```

- Start
```bash
$ docker start spdm_container_$(whoami)
```
- 확인
```bash
$ docker ps    # 현재 실행되고 있는 컨테이너를 조회
$ docker pa -a # 실행중이거나 중지된 모든 컨테이너를 조회
```
### Delete Docker container & image - Not recommand
```bash
$ docker rm -f $(docker ps -aq)     # 모든 docker container 강제 삭제
$ docker rmi -f $(docker images -q) # 모든 docker image 강제 삭제
```
## Build in container
```bash
$ build.sh --help
```
## Run executable file in container
```bash
$ run.sh --help
```
## Debbug in vscode
Default 실행 파일 경로 수정 필요
- .vscode/launch.json
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Docker GDB Debug",
            "type": "cppdbg",
            "request": "launch",
            "program": "/workspace/spdm/spdm-emu/build/bin/spdm_responder_emu", // 실행 파일 경로
            "args": [], // 실행 파일에 전달할 옵션
            "stopAtEntry": false,
            "cwd": "/workspace/spdm", // 컨테이너 내부의 작업 디렉터리
            "environment": [],
            "externalConsole": true, // 외부 터미널 사용
            "MIMode": "gdb",
            "miDebuggerPath": "/usr/bin/gdb", // 컨테이너 내부의 gdb 경로
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "pipeTransport": {
                "pipeProgram": "docker", // Docker를 통해 컨테이너에 접근
                "pipeArgs": [
                    "exec",
                    "-i",
                    "spdm_container_${env:USER}", // 동적으로 사용자 이름 기반 컨테이너 이름 사용
                    "sh",
                    "-c"
                ], // 컨테이너 내부에서 명령 실행
                "debuggerPath": "/usr/bin/gdb" // 컨테이너 내부의 gdb 경로
            },
            "sourceFileMap": {
                "/workspace": "${workspaceFolder}" // 컨테이너 내부 경로와 호스트 경로 매핑
            }
        }
    ]
}
```

## SPDM CPP
It is just project for changing "c library" to "cpp library".

### Reference
https://github.com/DMTF/libspdm
https://github.com/DMTF/spdm-emu
https://github.com/DMTF/spdm-dump