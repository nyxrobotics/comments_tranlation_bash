#!/bin/bash

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
bash $SCRIPT_DIR/modules/cn2en_cpp.bash
bash $SCRIPT_DIR/modules/cn2en_launch.bash
