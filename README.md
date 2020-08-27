# bash-libs

## About

Bash libs

### Prerequisites

You need to install:

```sh
$ sudo apt update -y
$ sudo apt install -y git
```

### Installing

Add git submodule

```sh
$ cd your_project_git_repo
$ mkdir ./lib
$ cd ./lib
$ git submodule add git@github.com:yunielrc/bash-libs.git
$ git submodule update --init --recursive
```

## Usage

Include the library in your script

```sh
$ cd your_project_git_repo
$ tree
.
├── lib
│   └── bash-libs
│       ├── dcrun
│       └── dist
│           └── bl.bash
└── main-script

$ vim ./main-script
...
readonly BASE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${BASE_PATH}/lib/bash-libs/dist/bl.bash"

## for example
bl::recursive_slink "$from_dir1" "$to_dir2"
...
```
