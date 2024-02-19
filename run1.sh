#!/bin/bash

# Function to copy and display compile logs from the container
function display_compile_logs() {
    local log_path_inside_container=$1
    local log_filename=$(basename $log_path_inside_container)
    local local_log_path="/tmp/$log_filename"
    docker cp fenics_1.6.0:$log_path_inside_container $local_log_path
    echo "Displaying compilation log ($log_path_inside_container):"
    cat $local_log_path
    echo "----------------"
}

PROJECT_PATH="/c/IdeaProjects/fenics_project"
cd $PROJECT_PATH

docker pull quay.io/fenicsproject/stable:1.6.0

DOCKER_CONTAINER_ID=$(docker ps -a | grep fenics | awk '{print $1}')

if [ -z "$DOCKER_CONTAINER_ID" ]; then
    echo "Container does not exist."
else
    docker stop $DOCKER_CONTAINER_ID && docker rm -f $DOCKER_CONTAINER_ID
fi

echo "Running a new fenics container..."
docker run -d -ti --name fenics_1.6.0 -v $PROJECT_PATH:/home/fenics/project quay.io/fenicsproject/stable:1.6.0

LD_LIB_PATH="/home/fenics/build/lib"
FENICS_PYTHON_PKG_DIR="/home/fenics/build/lib/python2.7/site-packages"
UFC_DIR="/home/fenics/build/share/ufc"
PETSC_DIR="/usr/local/lib/petsc"
PETSC_ARCH="linux-gnu-c-opt"
DOLFIN_DIR="/home/fenics/build/share/dolfin/cmake"

# Set and export all necessary environment variables before executing Python scripts
ENV_VARS="export LD_LIBRARY_PATH=${LD_LIB_PATH}:\$LD_LIBRARY_PATH && \
          export PYTHONPATH=${FENICS_PYTHON_PKG_DIR}:\$PYTHONPATH && \
          export CMAKE_PREFIX_PATH=${UFC_DIR}:\$CMAKE_PREFIX_PATH && \
          export PETSC_DIR=${PETSC_DIR} && \
          export PETSC_ARCH=${PETSC_ARCH} && \
          export DOLFIN_DIR=${DOLFIN_DIR}"

docker exec fenics_1.6.0 bash -c "$ENV_VARS && python -c 'from fenics import *; import dolfin; print(dolfin.__version__)'"

# Attempt to run demo and capture compilation logs if errors occur
if ! docker exec fenics_1.6.0 bash -c "$ENV_VARS && cd /home/fenics/demo/documented/poisson/python/ && python demo_poisson.py"; then
    display_compile_logs '/root/.instant/error/dolfin_compile_code_c8b988ab6016262c9eebd6dc8482b98c0cf05c33/compile.log'
fi

# Attempt to run solve_poisson.py and capture compilation logs if errors occur
if ! docker exec fenics_1.6.0 bash -c "$ENV_VARS && cd /home/fenics/project && python solve_poisson.py"; then
    # Adjust the log path dynamically if possible
    display_compile_logs '/root/.instant/error/dolfin_compile_code_<unique_identifier>/compile.log'
fi