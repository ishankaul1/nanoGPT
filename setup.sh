#!/bin/bash

# setup.sh
# ====================================
# Run this once to create the virtual environment
# and install dependencies

echo "Creating virtual environment 'nanogpt-env'..."
python3 -m venv nanogpt-env

echo "Activating virtual environment..."
source nanogpt-env/bin/activate

echo "Upgrading pip..."
pip install --upgrade pip

echo "Installing requirements from requirements.txt..."
pip install -r requirements.txt

echo ""
echo "Setup complete!"
echo "Run 'source nanogpt-env/bin/activate' or 'source start_venv.sh' to activate the environment in the future."