#!/bin/bash

# Build and Push Docker Images for ai_chat and tg_bot Services
# This script orchestrates the building and pushing of Docker images for the ai_chat and tg_bot services.
# It first deletes any existing images, then navigates into the respective service directories,
# runs the build and push scripts, and returns to the original directory.

set -e

# Define paths relative to the parent directory of the current script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
parent_dir="$(dirname "$script_dir")"

./img_delete.sh

# Navigate into 'ai_chat', run the script from 'infrastructure', then return back
cd "$parent_dir/ai_chat"
"$script_dir/build_push_ai_chat.sh"
cd "$script_dir"

# Navigate into 'tg_bot', run the script from 'infrastructure', then return back
cd "$parent_dir/tg_bot"
"$script_dir/build_push_tg_bot.sh"
cd "$script_dir"
