#!/bin/bash

PROJECT_PATH="/c/IdeaProjects/fenics_project"
cd "$PROJECT_PATH"

# Pull Docker image
docker pull quay.io/fenicsproject/stable:1.6.0

# Stop and remove existing Docker container, if it exists
DOCKER_CONTAINER=$(docker container ls -a --filter name=fenics_1.6.0 -q)
if [ ! -z "$DOCKER_CONTAINER" ]; then
    docker container stop "$DOCKER_CONTAINER" && docker container rm "$DOCKER_CONTAINER"
fi

# Run a new FEniCS Docker container
docker run -d -ti --name fenics_1.6.0 -v "$PROJECT_PATH:/home/fenics/project" quay.io/fenicsproject/stable:1.6.0

# Initialize Conda, if necessary
if ! command -v conda &> /dev/null; then
    echo "Conda is not in PATH. Attempting to initialize Conda..."
    source ~/anaconda3/etc/profile.d/conda.sh
fi

# Create a Conda environment with Python 2.7
conda create --name fenics1.6 python=2.7 --yes

# Activate the Conda environment
source activate fenics1.6

# Define the path to the Conda environment
CONDA_PATH="$(conda info --envs | grep fenics1.6 | awk '{print $2}')"
CONDA_PYTHON_PATH="$CONDA_PATH/bin/python"

# Copy necessary files from Docker to the Conda environment
mkdir -p "$CONDA_PATH/lib/python2.7"
docker cp "fenics_1.6.0:/home/fenics/build/lib/python2.7/site-packages/." "$CONDA_PATH/lib/python2.7/site-packages/"
docker cp "fenics_1.6.0:/usr/lib/python2.7/." "$CONDA_PATH/lib/python2.7/"
mkdir -p "$CONDA_PATH/local/lib/python2.7"
docker cp "fenics_1.6.0:/usr/local/lib/python2.7/." "$CONDA_PATH/local/lib/python2.7/"

# Determine the DOLFIN_DIR within the Docker container
DOLFIN_DIR=$(docker exec fenics_1.6.0 bash -c "find / -name DOLFINConfig.cmake 2>/dev/null | head -n 1 | xargs dirname")
mkdir -p "$CONDA_PATH/share/dolfin"
docker cp "fenics_1.6.0:${DOLFIN_DIR}/." "$CONDA_PATH/share/dolfin/cmake/"

# Adjust PYTHONPATH to include the copied packages
export PYTHONPATH="$CONDA_PATH/lib/python2.7/site-packages:$PYTHONPATH"

# Set additional environment variables
export LD_LIBRARY_PATH="/home/fenics/build/lib:$LD_LIBRARY_PATH"
export CMAKE_PREFIX_PATH="/home/fenics/build/share/ufc:$CMAKE_PREFIX_PATH"
export PETSC_DIR="/usr/local/lib/petsc"
export PETSC_ARCH="linux-gnu-c-opt"
export DOLFIN_DIR="$CONDA_PATH/share/dolfin/cmake"

# Execute Python script within the Conda environment
$CONDA_PYTHON_PATH -c "from fenics import *; import dolfin; print(dolfin.__version__)"

ls -ltra $LD_LIBRARY_PATH		  
ls -ltra $CMAKE_PREFIX_PATH
ls -ltra $PETSC_DIR
ls -ltra $PETSC_ARCH
ls -ltra $DOLFIN_DIR
