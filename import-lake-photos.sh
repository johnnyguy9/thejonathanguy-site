#!/usr/bin/env bash
# Copy only TODAY'S new image files from ~/Downloads into a staging folder.
# Filters by modification time within the last 24 hours so we don't pull old stuff.
set -e

DEST="/Users/rowdybot/Documents/Claude/Projects/TheJonathanGuy.com/static-bio/images/_lake-staging"
SRC="$HOME/Downloads"

mkdir -p "$DEST"
cd "$DEST"

echo "==> Source : $SRC"
echo "==> Dest   : $DEST"
echo "==> Filter : files modified in the last 24 hours only"
echo ""

count=0

# Find recent image files (last 1 day = 24 hours)
while IFS= read -r src; do
  [ -f "$src" ] || continue
  basename=$(basename "$src")
  ext="${basename##*.}"
  ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
  name="${basename%.*}"

  # Sanitize: lowercase, spaces -> dashes, only safe chars
  safe_name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-_')

  if [ "$ext_lower" = "heic" ]; then
    out="${safe_name}.jpg"
    if [ -f "$out" ]; then
      echo "  · skip   $basename (already in staging)"
      continue
    fi
    cp "$src" "/tmp/heic-tmp.heic"
    if sips -s format jpeg --resampleHeightWidthMax 2400 -s formatOptions 88 "/tmp/heic-tmp.heic" --out "$out" >/dev/null 2>&1; then
      echo "  ✓ heic   $basename  ->  $out"
      count=$((count+1))
    else
      echo "  ✗ FAIL   $basename"
    fi
  else
    out="${safe_name}.${ext_lower}"
    if [ -f "$out" ]; then
      echo "  · skip   $basename (already in staging)"
      continue
    fi
    cp -f "$src" "$out"
    sz=$(stat -f %z "$out")
    if [ "$sz" -gt 2500000 ]; then
      sips --resampleHeightWidthMax 2400 -s formatOptions 88 "$out" --out "$out" >/dev/null 2>&1 || true
    fi
    echo "  ✓ copy   $basename  ->  $out"
    count=$((count+1))
  fi
done < <(find "$SRC" -maxdepth 1 -type f \( \
    -iname '*.heic' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
  \) -mtime -1 2>/dev/null)

echo ""
echo "================================================================"
echo "DONE. $count new file(s) staged in:"
echo "  $DEST"
echo "================================================================"
ls -la "$DEST"/*.jpg "$DEST"/*.png 2>/dev/null | awk '{printf "  %-40s %s KB\n", $NF, int($5/1024)}'
