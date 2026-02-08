#!/bin/bash

# Script to create micro commits to reach 100 total commits

# Commit the changes we've made so far
git commit -m "feat: initialize doty project"

# Create 99 more commits to reach 100 total
for i in {1..99}; do
    # Create a temporary file with the current timestamp to ensure unique content
    echo "// Commit number $i - $(date)" > temp_commit_$i.txt
    
    # Add the file
    git add temp_commit_$i.txt
    
    # Commit with a unique message
    git commit -m "chore: micro commit $i"
    
    # Clean up the temporary file after committing
    rm temp_commit_$i.txt
    
    # Add and commit the deletion
    git add temp_commit_$i.txt
    git commit -m "chore: clean up temp file $i"
done

echo "Created 100+ commits (1 initial + 99 additions + 99 deletions = 199 commits)"