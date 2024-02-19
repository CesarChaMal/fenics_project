#!/bin/bash

# Function to check if a directory exists in Docker and copy it
copy_if_exists() {
    local docker_container=$1
    local docker_dir=$2
    local local_dir=$3

    # Find the directory dynamically
    local found_dir=$(docker exec "$docker_container" bash -c "find / -name '$docker_dir' -type d 2>/dev/null | head -n 1")

    # Check if the directory was found
    if [ -n "$found_dir" ]; then
        echo "Found '$docker_dir' at '$found_dir'. Copying to '$local_dir'..."
        mkdir -p "$local_dir"
        docker cp "$docker_container:$found_dir/." "$local_dir/"
    else
        echo "Directory '$docker_dir' not found in Docker container '$docker_container'."
    fi
}

# Validate a path exists and is a directory
validate_path() {
    if [ ! -d "$1" ]; then
        echo "Directory does not exist: $1"
        exit 1
    else
        echo "Validated directory exists: $1"
    fi
}

PROJECT_PATH=$(pwd)
cd "$PROJECT_PATH"

# Pull Docker image
docker pull quay.io/fenicsproject/stable:1.6.0

# Stop and remove existing Docker container, if it exists
DOCKER_CONTAINER=$(docker container ls -a --filter name=fenics_1.6.0 -q)
if [ ! -z "$DOCKER_CONTAINER" ]; then
    docker container stop "$DOCKER_CONTAINER" && docker container rm "$DOCKER_CONTAINER"
fi

# Ensure Docker is started before proceeding
# docker container stop fenics_1.6.0 || true
# docker container rm fenics_1.6.0 || true
# docker run -d -ti --name fenics_1.6.0 -v "$PROJECT_PATH:/home/fenics/project" quay.io/fenicsproject/stable:1.6.0

# Run a new FEniCS Docker container
docker run -d -ti --name fenics_1.6.0 -v "$PROJECT_PATH:/home/fenics/project" quay.io/fenicsproject/stable:1.6.0

# Initialize Conda environment
#if ! command -v conda &> /dev/null; then
#    echo "Conda is not in PATH. Attempting to initialize Conda..."
#    source ~/anaconda3/etc/profile.d/conda.sh || source ~/miniconda3/etc/profile.d/conda.sh
#fi

# Initialize Conda environment
if ! type conda >/dev/null 2>&1; then
    echo "Conda is not in PATH. Attempting to initialize Conda..."
    source ~/anaconda3/etc/profile.d/conda.sh || source ~/miniconda3/etc/profile.d/conda.sh
fi

# Create a Conda environment with Python 2.7
conda create --name fenics1.6 python=2.7 --yes

# Activate the Conda environment
#source activate fenics1.6
~/anaconda3/bin/activate fenics1.6

# Define the path to the Conda environment
CONDA_PATH=$(conda info --envs | grep 'fenics1.6' | awk '{print $3}')
CONDA_PYTHON_PATH="$CONDA_PATH/bin/python"
DOCKER_CONTAINER="fenics_1.6.0"

# Copy necessary files from Docker to the Conda environment
mkdir -p "$CONDA_PATH/lib/python2.7"
docker cp "fenics_1.6.0:/home/fenics/build/lib/python2.7/site-packages/." "$CONDA_PATH/lib/python2.7/site-packages/"
docker cp "fenics_1.6.0:/usr/lib/python2.7/." "$CONDA_PATH/lib/python2.7/"
mkdir -p "$CONDA_PATH/local/lib/python2.7"
docker cp "fenics_1.6.0:/usr/local/lib/python2.7/." "$CONDA_PATH/local/lib/python2.7/"

# Dynamically find and copy UFC directory
#UFC_DIR_DOCKER=$(docker exec fenics_1.6.0 bash -c "find / -name ufc-config.cmake 2>/dev/null | head -n 1 | xargs dirname" || echo "/home/fenics/build/share/ufc")
mkdir -p "$CONDA_PATH/share/ufc"
#docker cp "fenics_1.6.0:${UFC_DIR_DOCKER}/." "$CONDA_PATH/share/ufc/"

# Dynamically find and copy PETSc directory
#PETSC_DIR_DOCKER=$(docker exec fenics_1.6.0 bash -c "find / -name petscvariables 2>/dev/null | head -n 1 | xargs dirname" || echo "/usr/local/lib/petsc")
mkdir -p "$CONDA_PATH/share/petsc"
#docker cp "fenics_1.6.0:${PETSC_DIR_DOCKER}/." "$CONDA_PATH/share/petsc/"

# Dynamically find and copy DOLFIN directory
#DOLFIN_DIR=$(docker exec fenics_1.6.0 bash -c "find / -name DOLFINConfig.cmake 2>/dev/null | head -n 1 | xargs dirname" || echo "/home/fenics/build/share/dolfin/cmake")
mkdir -p "$CONDA_PATH/share/dolfin/cmake"
#docker cp "fenics_1.6.0:${DOLFIN_DIR}/." "$CONDA_PATH/share/dolfin/cmake/"

# UFC directory
copy_if_exists "$DOCKER_CONTAINER" "ufc-config.cmake" "$CONDA_PATH/share/ufc"

# PETSc directory
copy_if_exists "$DOCKER_CONTAINER" "petscvariables" "$CONDA_PATH/share/petsc"

# DOLFIN directory
copy_if_exists "$DOCKER_CONTAINER" "DOLFINConfig.cmake" "$CONDA_PATH/share/dolfin/cmake"

# Optionally, identify and set the PETSC_ARCH variable based on the Docker environment
# This step may require specific logic based on your setup and how PETSC_ARCH should be determined
PETSC_ARCH="linux-gnu-c-opt"

# Adjust PYTHONPATH to include the copied packages
export PYTHONPATH="$CONDA_PATH/lib/python2.7/site-packages:$PYTHONPATH"

# Set additional environment variables
export LD_LIBRARY_PATH="$CONDA_PATH/lib:$LD_LIBRARY_PATH"
export CMAKE_PREFIX_PATH="$CONDA_PATH/share/ufc:$CMAKE_PREFIX_PATH"
export PETSC_DIR="$CONDA_PATH/share/petsc"
export PETSC_ARCH="$PETSC_ARCH"
export DOLFIN_DIR="$CONDA_PATH/share/dolfin/cmake"

# Validate each path
for dir in "$CONDA_PATH/lib" "$CONDA_PATH/share/ufc" "$CONDA_PATH/share/petsc" "$CONDA_PATH/share/dolfin/cmake"; do
    validate_path "$dir"
done

# Proceed with your script if all directories are validated
echo "All required directories have been validated. Proceeding..."

conda install libpython

# Execute Python script within the Conda environment
$CONDA_PYTHON_PATH -c "from fenics import *; import dolfin; print(dolfin.__version__)"

~/anaconda3/bin/deactivate