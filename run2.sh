#!/bin/bash

# Function to check if a path (directory or file) exists in Docker container
check_path_exists() {
    local container=$1
    local path=$2

    # Execute command in Docker container to check if path exists
    docker exec "$container" bash -c "[ -e '$path' ] && echo 'Path exists: $path' || echo 'Path does NOT exist: $path'"
}

# List of paths to check (both directories and files)
declare -a paths=(
    "/home/fenics/build/lib/python2.7/site-packages"
    "/usr/lib/python2.7/dist-packages"
    "/usr/lib/python2.7"
    "/usr/lib/python2.7/plat-x86_64-linux-gnu"
    "/usr/lib/python2.7/lib-tk"
    "/usr/lib/python2.7/lib-old"
    "/usr/lib/python2.7/lib-dynload"
    "/usr/lib/python2.7/dist-packages/PILcompat"
    "/usr/lib/python2.7/dist-packages/gtk-2.0"
    "/usr/local/lib/python2.7/dist-packages"
)

## Function to check if a directory exists in Docker and copy it
#copy_directory_if_exists() {
#    local container="$1"
#    local source_dir="$2"
#    local target_dir="$3"
#
#    echo "Checking if directory exists in container: $source_dir"
#    if docker exec "$container" bash -c "[ -d '$source_dir' ]"; then
#        echo "Directory exists: $source_dir. Copying to $target_dir..."
#        docker cp "$container:$source_dir" "$target_dir"
#        echo "Copy operation completed."
#        # Verify and log the outcome
#        if [ -d "$target_dir" ]; then
#            echo "Successfully copied to: $target_dir"
#            ls -l "$target_dir"
#        else
#            echo "Failed to copy directory: $source_dir to $target_dir"
#        fi
#    else
#        echo "Directory does not exist in container: $source_dir"
#    fi
#}

# Function to check and copy a directory from Docker container if it exists
#copy_directory_if_exists() {
#    local container="$1"
#    local source_dir="$2"
#    local target_dir="$3"
#
#    echo "Checking if directory exists in container: $source_dir"
#    if docker exec "$container" bash -c "[ -d '$source_dir' ]"; then
#        echo "Directory exists: $source_dir. Copying to $target_dir..."
#        docker cp "$container:$source_dir" "$target_dir"
#        echo "Copy operation completed."
#        # Verify and log the outcome
#        if [ -d "$target_dir" ]; then
#            echo "Successfully copied to: $target_dir"
#            ls -l "$target_dir"
#        else
#            echo "Failed to copy directory: $source_dir to $target_dir"
#        fi
#    else
#        echo "Directory does not exist in container: $source_dir"
#    fi
#}

# Function to check and copy a directory from Docker container if it exists
copy_directory_if_exists() {
    local container="$1"
    local source_dir="$2"
    local target_dir="$3"

    echo "Starting copy operation..."
    echo "Container: $container"
    echo "Source directory: $source_dir"
    echo "Target directory: $target_dir"
	
    echo "Checking if directory exists in container: $source_dir"
    if docker exec "$container" bash -c "[ -d '$source_dir' ]"; then
        echo "Directory exists: $source_dir. Copying to $target_dir..."

        # Step 1: Copy the entire directory excluding symbolic links
		#docker cp "$container:$source_dir" "$target_dir"
        #docker exec "$container" tar --exclude='*/*' -czf - "$source_dir" | tar xzf - -C "$target_dir"
        #echo "Copy operation for files and directories (excluding symbolic links) completed."
		docker exec "$container" bash -c "cd $(dirname $source_dir) && tar czf - $(basename $source_dir)" | tar xzf - -C "$target_dir"
        echo "Copy operation for files and directories completed."

        # Check if copy was successful
        if [ "$(ls -A $target_dir)" ]; then
            echo "Copy operation successful. Contents of $target_dir:"
            ls -l "$target_dir"
        else
            echo "Copy operation failed or directory is empty."
        fi
		
        # Step 2: Handle symbolic links
        docker exec "$container" find "$source_dir" -type l | while read -r symlink; do
            local link_target=$(docker exec "$container" readlink "$symlink")
            local relative_path="${symlink#$source_dir/}"
            local symlink_dir=$(dirname "$relative_path")

            # Ensure the directory exists for the symbolic link
            mkdir -p "$target_dir/$symlink_dir"
            # Recreate the symbolic link relative to the new base directory
            ln -sfn "$link_target" "$target_dir/$relative_path" 2>/dev/null || echo "Failed to create symlink for $relative_path"
        done

        echo "Successfully handled symbolic links."
        ls -l "$target_dir"
    else
        echo "Directory does not exist in container: $source_dir"
    fi
}

## Function to check if a file exists in Docker and copy it
#copy_file_if_exists() {
#    local docker_container=$1
#    local search_pattern=$2
#    local local_dir=$3
#
#    # Find the file dynamically
#    local found_file=$(docker exec "$docker_container" bash -c "find / -type f -name '$search_pattern' 2>/dev/null | head -n 1")
#
#    # Check if the file was found
#    if [ -n "$found_file" ]; then
#        echo "Found '$search_pattern' at '$found_file'. Copying to '$local_dir'..."
#        docker cp "$docker_container:$found_file" "$local_dir"
#    else
#        echo "File '$search_pattern' not found in Docker container '$docker_container'."
#    fi
#}

# Function to check and copy a file from Docker container if it exists
copy_file_if_exists() {
    local docker_container="$1"
    local search_pattern="$2"
    local local_dir="$3"

    echo "Searching for file '$search_pattern' in Docker container '$docker_container'..."
    local found_file=$(docker exec "$docker_container" bash -c "find / -type f -name '$search_pattern' 2>/dev/null | head -n 1")

    if [ -n "$found_file" ]; then
        echo "Found file at '$found_file'. Copying to '$local_dir'..."
        docker cp "$docker_container:$found_file" "$local_dir"
        echo "Copy operation completed."

        # Direct verification after copying
        local copied_file_path="$local_dir/$(basename "$found_file")"
        if [ -f "$copied_file_path" ]; then
            echo "Successfully copied file to: $copied_file_path"
        else
            echo "Failed to copy file to: $copied_file_path"
        fi
    else
        echo "File '$search_pattern' not found in Docker container '$docker_container'."
    fi
}

# Function to copy Python package directory if exists in Docker
copy_python_package_if_exists() {
    local docker_container=$1
    local package_name=$2
    local conda_env_path=$3

    # Attempt to find the package directory in the Docker container
    local package_dir=$(docker exec "$docker_container" bash -c "python -c 'import $package_name; print($package_name.__path__[0])'" 2>/dev/null)

    # Check if the package directory was found and is not empty
    if [[ -n "$package_dir" && "$package_dir" != "[]" ]]; then
        echo "Found Python package '$package_name' at '$package_dir'. Copying to Conda environment..."
        docker cp "$docker_container:$package_dir" "$conda_env_path/lib/python2.7/site-packages/"
    else
        echo "Python package '$package_name' not found in Docker container '$docker_container'."
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

rm -rf CONDA_PATH

# Iterate over paths and check each one
for path in "${paths[@]}"; do
    check_path_exists "$DOCKER_CONTAINER" "$path"
done

# Copy necessary files from Docker to the Conda environment
mkdir -p "$CONDA_PATH/lib/site-packages"
#docker cp "fenics_1.6.0:/home/fenics/build/lib/python2.7/site-packages/." "$CONDA_PATH/lib/site-packages/"
copy_directory_if_exists "$DOCKER_CONTAINER" "/home/fenics/build/lib/python2.7/site-packages/." "$CONDA_PATH/lib/site-packages/"
echo "Verifying contents of $CONDA_PATH/lib/site-packages:"
ls -ltra $CONDA_PATH/lib/site-packages || echo "site-packages not found in $CONDA_PATH/lib/site-packages"
echo "Verifying contents of /home/fenics/build/lib/python2.7/site-packages:"
docker exec fenics_1.6.0 ls -ltra /home/fenics/build/lib/python2.7/site-packages

mkdir -p "$CONDA_PATH/lib/python2.7"
#docker cp "fenics_1.6.0:/usr/lib/python2.7/." "$CONDA_PATH/lib/python2.7/"
copy_directory_if_exists "$DOCKER_CONTAINER" "/usr/lib/python2.7/." "$CONDA_PATH/lib/python2.7/"
echo "Verifying contents of $CONDA_PATH/lib/site-packages/:"
ls -ltra $CONDA_PATH/lib/python2.7 || echo "python2.7 not found in $CONDA_PATH/lib/python2.7"
echo "Verifying contents of /usr/lib/python2.7/:"
docker exec fenics_1.6.0 ls -ltra /usr/lib/python2.7/

#mkdir -p "$CONDA_PATH/lib/python2.7/dist-packages"
#copy_directory_if_exists "$DOCKER_CONTAINER" "/usr/lib/python2.7/dist-packages" "$CONDA_PATH/lib/python2.7/dist-packages"
#echo "Verifying contents of $CONDA_PATH/lib/python2.7/dist-packages:"
#ls -ltra "$CONDA_PATH/lib/python2.7/dist-packages" || echo "dist-packages not found in $CONDA_PATH/lib/python2.7/dist-packages"
#echo "Verifying contents of /usr/lib/python2.7/dist-packages:"
#docker exec fenics_1.6.0 ls -ltra /usr/lib/python2.7/dist-packages

mkdir -p "$CONDA_PATH/local/lib/python2.7"
#docker cp "fenics_1.6.0:/usr/local/lib/python2.7/." "$CONDA_PATH/local/lib/python2.7/"
copy_directory_if_exists "$DOCKER_CONTAINER" "/usr/local/lib/python2.7/." "$CONDA_PATH/local/lib/python2.7/"
echo "Verifying contents of $CONDA_PATH/local/lib/python2.7:"
ls -ltra "$CONDA_PATH/local/lib/python2.7" || echo "python2.7 not found in $CONDA_PATH/local/lib/python2.7"
echo "Verifying contents of /usr/local/lib/python2.7:"
docker exec fenics_1.6.0 ls -ltra /usr/local/lib/python2.7

#mkdir -p "$CONDA_PATH/local/lib/python2.7/dist-packages"
#copy_directory_if_exists "$DOCKER_CONTAINER"  "/usr/local/lib/python2.7/dist-packages" "$CONDA_PATH/local/lib/python2.7/dist-packages"
#echo "Verifying contents of $CONDA_PATH/local/lib/python2.7/dist-packages:"
#ls -ltra "$CONDA_PATH/local/lib/python2.7/dist-packages" || echo "dist-packages not found in $CONDA_PATH/local/lib/python2.7/dist-packages"
#echo "Verifying contents of /usr/local/lib/python2.7/dist-packages:"
#docker exec fenics_1.6.0 ls -ltra /usr/local/lib/python2.7/dist-packages

# Dynamically find and copy UFC directory
#UFC_DIR_DOCKER=$(docker exec fenics_1.6.0 bash -c "find / -name ufc-config.cmake 2>/dev/null | head -n 1 | xargs dirname" || echo "/home/fenics/build/share/ufc")
UFC_DIR_DOCKER=$(docker exec fenics_1.6.0 bash -c "find / -name ufc-config.cmake 2>/dev/null | head -n 1" || echo "/home/fenics/build/share/ufc")
mkdir -p "$CONDA_PATH/share/ufc"
#docker cp "fenics_1.6.0:${UFC_DIR_DOCKER}/." "$CONDA_PATH/share/ufc/"
copy_directory_if_exists "$DOCKER_CONTAINER" "ufc-config.cmake" "$CONDA_PATH/share/ufc"
echo "Verifying contents of $CONDA_PATH/share/ufc:"
ls "$CONDA_PATH/share/ufc" || echo "ufc not found in $CONDA_PATH/share/ufc"

# Dynamically find and copy PETSc directory
#PETSC_DIR_DOCKER=$(docker exec fenics_1.6.0 bash -c "find / -name petscvariables 2>/dev/null | head -n 1 | xargs dirname" || echo "/usr/local/lib/petsc")
PETSC_DIR_DOCKER=$(docker exec fenics_1.6.0 bash -c "find / -name petscvariables 2>/dev/null | head -n 1 " || echo "/usr/local/lib/petsc")
mkdir -p "$CONDA_PATH/share/petsc"
#docker cp "fenics_1.6.0:${PETSC_DIR_DOCKER}/." "$CONDA_PATH/share/petsc/"
copy_directory_if_exists "$DOCKER_CONTAINER" "petscvariables" "$CONDA_PATH/share/petsc"
echo "Verifying contents of $CONDA_PATH/share/petsc:"
ls -ltra "$CONDA_PATH/share/petsc" || echo "petsc not found in $CONDA_PATH/share/petsc"
echo "Verifying contents of /usr/local/lib/petsc:"
docker exec fenics_1.6.0 ls -ltra /usr/local/lib/petsc

# Dynamically find and copy DOLFIN directory
#DOLFIN_DIR=$(docker exec fenics_1.6.0 bash -c "find / -name DOLFINConfig.cmake 2>/dev/null | head -n 1 | xargs dirname" || echo "/home/fenics/build/share/dolfin/cmake")
DOLFIN_DIR=$(docker exec fenics_1.6.0 bash -c "find / -name DOLFINConfig.cmake 2>/dev/null | head -n 1" || echo "/home/fenics/build/share/dolfin/cmake")
mkdir -p "$CONDA_PATH/share/dolfin/cmake"
#docker cp "fenics_1.6.0:${DOLFIN_DIR}/." "$CONDA_PATH/share/dolfin/cmake/"
copy_directory_if_exists "$DOCKER_CONTAINER" "DOLFINConfig.cmake" "$CONDA_PATH/share/dolfin/cmake"
echo "Verifying contents of $CONDA_PATH/share/dolfin/cmake:"
ls -ltra "$CONDA_PATH/share/dolfin/cmake" || echo "cmake not found in $CONDA_PATH/share/dolfin/cmake"
echo "Verifying contents of /home/fenics/build/share/dolfin/cmake:"
docker exec fenics_1.6.0 ls -ltra /home/fenics/build/share/dolfin/cmake

copy_file_if_exists "$DOCKER_CONTAINER" "_sysconfigdata_nd.py" "$CONDA_PATH/lib/python2.7"
echo "Verifying contents of ls $CONDA_PATH/lib/python2.7/_sysconfigdata_nd.py:"
ls "$CONDA_PATH/lib/python2.7/_sysconfigdata_nd.py" || echo "_sysconfigdata_nd.py not found in $CONDA_PATH/lib/python2.7/_sysconfigdata_nd.py"

# Copy necessary Python packages from Docker to the Conda environment
copy_python_package_if_exists "$DOCKER_CONTAINER" "numpy" "$CONDA_PATH"
echo "Verifying contents of $CONDA_PATH/lib/python2.7/site-packages/numpy:"
ls "$CONDA_PATH/lib/python2.7/site-packages/numpy" || echo "numpy not found in $CONDA_PATH/lib/python2.7/site-packages/numpy"

# Optionally, identify and set the PETSC_ARCH variable based on the Docker environment
# This step may require specific logic based on your setup and how PETSC_ARCH should be determined
PETSC_ARCH="linux-gnu-c-opt"

# Adjust PYTHONPATH to include the copied packages

# Set additional environment variables
export LD_LIBRARY_PATH="$CONDA_PATH/lib:$LD_LIBRARY_PATH"
export CMAKE_PREFIX_PATH="$CONDA_PATH/share/ufc:$CMAKE_PREFIX_PATH"
export PETSC_DIR="$CONDA_PATH/share/petsc"
export PETSC_ARCH="$PETSC_ARCH"
export DOLFIN_DIR="$CONDA_PATH/share/dolfin/cmake"

#export PYTHONPATH="$CONDA_PATH/lib:$CONDA_PATH/lib/site-packages:$CONDA_PATH/local/lib/python2.7/dist-packages:$CONDA_PATH/lib/python2.7/dist-packages:$CONDA_PATH/lib/python2.7/dist-packages/PILcompat:$CONDA_PATH/lib/python2.7/dist-packages/gtk-2.0:$CONDA_PATH/lib/python2.7:$CONDA_PATH/lib/python2.7/plat-x86_64-linux-gnu:$CONDA_PATH/lib/python2.7/lib-tk:$CONDA_PATH/lib/python2.7/lib-dynload:$LD_LIBRARY_PATH:$CMAKE_PREFIX_PATH:$PETSC_DIR:$PETSC_ARCH:$DOLFIN_DIR:$PYTHONPATH"

echo "Verifying contents of $CONDA_PATH/lib/python2.7/plat-x86_64-linux-gnu:"
ls $CONDA_PATH/lib/python2.7/plat-x86_64-linux-gnu || echo "plat-x86_64-linux-gnu not found in $CONDA_PATH/lib/python2.7/plat-x86_64-linux-gnu"

echo "Verifying contents of $CONDA_PATH/lib/python2.7/lib-tk:"
ls $CONDA_PATH/lib/python2.7/lib-tk || echo "lib-tk not found in $CONDA_PATH/lib/python2.7/lib-tk"

echo "Verifying contents of $CONDA_PATH/lib/python2.7/lib-dynload"
ls $CONDA_PATH/lib/python2.7/lib-dynload || echo "lib-dynload found in $CONDA_PATH/lib/python2.7/lib-dynload"

echo "Verifying contents of $CONDA_PATH/lib/python2.7/dist-packages/PILcompat"
ls $CONDA_PATH/lib/python2.7/dist-packages/PILcompat || echo "PILcompat found in $CONDA_PATH/lib/python2.7/dist-packages/PILcompat"

echo "Verifying contents of $CONDA_PATH/lib/python2.7/dist-packages/gtk-2.0"
ls $CONDA_PATH/lib/python2.7/dist-packages/gtk-2.0 || echo "gtk-2.0 found in $CONDA_PATH/lib/python2.7/dist-packages/gtk-2.0"

# Validate each path
for dir in "$CONDA_PATH/lib" "$CONDA_PATH/share/ufc" "$CONDA_PATH/share/petsc" "$CONDA_PATH/share/dolfin/cmake" "$CONDA_PATH/lib/site-packages" "$CONDA_PATH/local/lib/python2.7/dist-packages" "$CONDA_PATH/lib/python2.7/dist-packages"; do
    validate_path "$dir"
done

# Proceed with your script if all directories are validated
echo "All required directories have been validated. Proceeding..."

conda install python=2.7 --force-reinstall -y
"$CONDA_PYTHON_PATH" --version
"$CONDA_PYTHON_PATH" -m pip --version

#conda install libpython
"$CONDA_PYTHON_PATH" -m pip install numpy
"$CONDA_PYTHON_PATH" -m pip install ufl
"$CONDA_PYTHON_PATH" -m pip install six==1.6.0
"$CONDA_PYTHON_PATH" -m pip install ffc
"$CONDA_PYTHON_PATH" -m pip install sympy==1.5.1
"$CONDA_PYTHON_PATH" -m pip install ply

copy_directory_if_exists "$DOCKER_CONTAINER" "/home/fenics/build/lib/." "$CONDA_PATH/lib/"
docker exec fenics_1.6.0 ls -ltra /home/fenics/build/lib

#$lib_path=$(docker exec fenics_1.6.0 bash -c "find / -name libboost_system.so.1.58.0 2>/dev/null | head -n 1" | tr '\n' ' ')
#/usr/lib/x86_64-linux-gnu/libboost_system.so.1.58.0
#copy_file_if_exists "$DOCKER_CONTAINER" "$lib_path" "$CONDA_PATH/lib/"
#copy_file_if_exists "$DOCKER_CONTAINER" /usr/lib/x86_64-linux-gnu/libboost_system.so.1.58.0 "$CONDA_PATH/lib/"
docker cp "fenics_1.6.0:/usr/lib/x86_64-linux-gnu/libboost_system.so.1.58.0" "$CONDA_PATH/lib/"
#docker exec -u 0 fenics_1.6.0 ls -ltra $lib_path
ls -ltra "$CONDA_PATH/lib/libboost_system.so.1.58.0"
docker exec fenics_1.6.0 ls -ltra /usr/lib/x86_64-linux-gnu/libboost_system.so.1.58.0

docker cp "fenics_1.6.0:/usr/local/lib/libpetsc.so.3.6" "$CONDA_PATH/lib/"
ls -ltra "$CONDA_PATH/lib/libpetsc.so.3.6"
docker exec fenics_1.6.0 ls -ltra /usr/local/lib/libpetsc.so.3.6

export PYTHONPATH="$CONDA_PREFIX/lib/site-packages:$CONDA_PREFIX/lib/python2.7/site-packages:$PYTHONPATH"

#ls /root/anaconda3/envs/fenics1.6/lib/site-packages
#ls /root/anaconda3/envs/fenics1.6/lib/python2.7/dist-packages
#ls /root/anaconda3/envs/fenics1.6/lib/python2.7/dist-packages/dist-packages
#ls /root/anaconda3/envs/fenics1.6/local/lib/python2.7/dist-packages
#ls /root/anaconda3/envs/fenics1.6/local/lib/python2.7/dist-packages/dist-packages

#$CONDA_PYTHON_PATH -c "import _sysconfigdata_nd"
$CONDA_PYTHON_PATH -c "import numpy; print(numpy.__version__)"
$CONDA_PYTHON_PATH -c "import dolfin; print(dolfin.__version__)"
$CONDA_PYTHON_PATH -c "import ffc; print(ffc.__version__)"

#~/anaconda3/bin/deactivate