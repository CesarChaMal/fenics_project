#!/bin/bash

PROJECT_PATH="/c/IdeaProjects/fenics_project"
cd $PROJECT_PATH

# Determine OS and define the path to the Conda environment's Python interpreter accordingly
OS_NAME=$(uname -s)
if [ "$OS_NAME" = "Linux" ]; then
    # Linux/Ubuntu path
	CONDA_PATH="$HOME/anaconda3/envs/fenics1.6"
    CONDA_PYTHON_PATH="$HOME/anaconda3/envs/fenics1.6/bin/python"
#elif [ "$OS_NAME" = "MINGW64_NT-10.0-22631" ]; then
elif [[ "$OS_NAME" == *"MINGW64_NT"* ]]; then
    # Windows Git Bash path
	HOME="/c/Users/Ces_C"
	CONDA_PATH="$HOME/.conda/envs/fenics1.6"
    CONDA_PYTHON_PATH="$HOME/.conda/envs/fenics1.6/python.exe"
else
    echo "Unsupported operating system: $OS_NAME"
    exit 1
fi

# Check if the Conda Python interpreter exists
if [ ! -f "$CONDA_PYTHON_PATH" ]; then
    echo "Conda Python interpreter not found at $CONDA_PYTHON_PATH. Exiting."
    exit 1
fi

docker cp fenics_1.6.0:/home/fenics/build/lib/python2.7/site-packages/ $PROJECT_PATH

mkdir -p "$CONDA_PATH/lib/python2.7"
docker cp fenics_1.6.0:/usr/lib/python2.7 $CONDA_PATH/lib

mkdir -p "$CONDA_PATH/local/lib/python2.7"
docker cp fenics_1.6.0:/usr/local/lib/python2.7 $CONDA_PATH/local/lib

export PYTHONPATH=$PROJECT_PATH/site-packages:$CONDA_PATH/lib/python2.7/dist-packages:$CONDA_PATH/lib/python2.7:$CONDA_PATH/lib/python2.7/plat-x86_64-linux-gnu:$CONDA_PATH/lib/python2.7/lib-tk:$CONDA_PATH/lib/python2.7/lib-old:$CONDA_PATH/lib/python2.7/lib-dynload:$CONDA_PATH/local/lib/python2.7/dist-packages:$CONDA_PATH/lib/python2.7/dist-packages/PILcompat:$CONDA_PATH/lib/python2.7/dist-packages/gtk-2.0

# To view the content of the PYTHONPATH variable:
echo $PYTHONPATH

# To list the directories in PYTHONPATH individually:
echo $PYTHONPATH | tr ':' '\n' | while read line; do
    echo "Listing contents of $line:"
    ls -l $line
    echo "" # Print a newline for better readability
done

# Running main.py
echo "Running main.py..."
"$CONDA_PYTHON_PATH" -c "import dolfin; print(dolfin.__version__)"


#conda deactivate
