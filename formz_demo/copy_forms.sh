

# Check if a directory name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 directory"
  exit 1
fi

directory=$1

# Check if the provided argument is a directory
if [ ! -d "$directory" ]; then
  echo "Error: $directory is not a directory"
  exit 1
fi

# Loop through all files in the directory
for exampledir in "$directory"/*; do
  if [ -d "$exampledir" ]; then
    string_file="$exampledir/strings.gleam"
    lustre_file="$exampledir/lustre.gleam"
    nakai_file="$exampledir/nakai.gleam"

    # echo $string_file
    # echo $lustre_file
    # echo $nakai_file

    cp $string_file $lustre_file
    cp $string_file $nakai_file

    sed -i '' 's|formz/string_generator|formz_lustre|g' "$lustre_file"
    sed -i '' 's|formz/string_generator|formz_nakai|g' "$nakai_file"

    echo "copied $string_file"
  fi
done
