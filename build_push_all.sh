#!/bin/bash

# Ensure script exits if any command fails
set -e

# # Execute each script
./img_delete.sh

# Navigate to planta_chat directory
cd planta_chat
../build_push_planta.sh
cd ..

cd tg_bot
../build_push_tg.sh

# Navigate back to parent directory
cd ..

echo "All scripts executed successfully!"
