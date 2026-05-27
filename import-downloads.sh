#!/usr/bin/env bash
# Import photos & logos from ~/Downloads into the static-bio project.
# Re-runnable. Skips files that are already up to date.

set -e

DEST="/Users/rowdybot/Documents/Claude/Projects/TheJonathanGuy.com/static-bio/images"
SRC="$HOME/Downloads"

mkdir -p "$DEST"
cd "$DEST"

echo "==> Source : $SRC"
echo "==> Dest   : $DEST"
echo ""

# Find ImageMagick (macOS Homebrew or system)
MAGICK=""
for c in magick convert /opt/homebrew/bin/magick /opt/homebrew/bin/convert /usr/local/bin/magick /usr/local/bin/convert; do
  if command -v "$c" >/dev/null 2>&1; then MAGICK="$c"; break; fi
  if [ -x "$c" ]; then MAGICK="$c"; break; fi
done

# macOS sips fallback (always present on macOS)
SIPS="$(command -v sips || true)"

# Convert HEIC -> JPG using whichever tool is available
heic_to_jpg() {
  local src="$1"
  local out="$2"
  local maxdim="${3:-2400}"
  if [ -n "$MAGICK" ]; then
    "$MAGICK" "$src" -auto-orient -resize "${maxdim}x${maxdim}>" -quality 90 -strip "$out" 2>/dev/null && return 0
  fi
  if [ -n "$SIPS" ]; then
    cp "$src" "/tmp/heic-tmp.heic"
    "$SIPS" -s format jpeg --resampleHeightWidthMax "$maxdim" "/tmp/heic-tmp.heic" --out "$out" >/dev/null 2>&1 && return 0
  fi
  return 1
}

# Copy / convert one mapping. Args: src-basename(in Downloads, no ext) dest-name kind
copy_one() {
  local label="$1"   # source name without extension, e.g. "Surfing1"
  local out="$2"     # destination filename, e.g. "surfing.jpg"
  local kind="${3:-photo}"   # photo | logo | passthrough

  # Find the source file (any case, any HEIC/JPG ext)
  local found=""
  for ext in HEIC heic JPG jpg JPEG jpeg PNG png SVG svg; do
    if [ -f "$SRC/${label}.${ext}" ]; then found="$SRC/${label}.${ext}"; break; fi
  done
  if [ -z "$found" ]; then
    echo "  · skip   $label (not found in Downloads)"
    return 0
  fi

  local ext="${found##*.}"
  local lower_ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

  if [ "$lower_ext" = "heic" ]; then
    if heic_to_jpg "$found" "$out" 2400; then
      echo "  ✓ heic   $label  ->  $out"
    else
      echo "  ✗ FAIL   $label  (HEIC convert failed)"
    fi
  else
    cp -f "$found" "$out"
    echo "  ✓ copy   $label  ->  $out"
  fi
}

echo "== Family page hero =="
copy_one "Fam_portA"   "family-hero.jpg"

echo ""
echo "== Hill Country & Vacation =="
copy_one "Wimberely"      "wimberley.jpg"
copy_one "Wimberley"      "wimberley.jpg"
copy_one "FRedricksburg"  "fredericksburg.jpg"
copy_one "Fredericksburg" "fredericksburg.jpg"
copy_one "SADAYDead"      "sa-dayofdead.jpg"
copy_one "SARiverWalk"    "sa-riverwalk.jpg"
copy_one "TrailLights"    "trail-lights.jpg"
copy_one "TrailLights2"   "trail-lights-2.jpg"
copy_one "Fam_JC"         "johnson-city.jpg"
copy_one "UTGame"         "ut-game.jpg"
copy_one "Bali1"          "bali.jpg"
copy_one "Cozumel"        "cozumel.jpg"
copy_one "CowboysGame"    "cowboys-game.jpg"
copy_one "B_DayCL"        "birthday-canyon-lake.jpg"
copy_one "HomeCL"         "home-aerial.jpg"

echo ""
echo "== Lake Life =="
copy_one "BoatLakeA"      "boat-1.jpg"
copy_one "BoatLakeA1"     "boat-2.jpg"
copy_one "Surfing1"       "surfing.jpg"

echo ""
echo "== Portrait & headshot =="
copy_one "IMG_9665"       "img_9665.jpg"

echo ""
echo "== Logos (PointWake, Stonecastle) — drop these in Downloads with these names =="
for name in logo-pointwake logo-stonecastle; do
  found=""
  for ext in PNG png SVG svg JPG jpg JPEG jpeg; do
    if [ -f "$SRC/${name}.${ext}" ]; then found="$SRC/${name}.${ext}"; break; fi
  done
  if [ -z "$found" ]; then
    # Also try alternate names like "PW.png" or "PointWake.png"
    for alt in "PW" "PointWake" "PointWakeLogo" "Stonecastle" "StoneCastle" "StonecastleHC" "SCHC"; do
      for ext in PNG png SVG svg JPG jpg; do
        if [ -f "$SRC/${alt}.${ext}" ]; then
          ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
          if [ "$name" = "logo-pointwake" ] && [[ "$alt" =~ (PW|Point) ]]; then
            cp -f "$SRC/${alt}.${ext}" "${name}.${ext_lower}"
            echo "  ✓ logo   $alt  ->  ${name}.${ext_lower}"
            found="yes"; break
          fi
          if [ "$name" = "logo-stonecastle" ] && [[ "$alt" =~ (Stone|SC) ]]; then
            cp -f "$SRC/${alt}.${ext}" "${name}.${ext_lower}"
            echo "  ✓ logo   $alt  ->  ${name}.${ext_lower}"
            found="yes"; break
          fi
        fi
      done
      [ -n "$found" ] && break
    done
  else
    ext_lower=$(echo "${found##*.}" | tr '[:upper:]' '[:lower:]')
    cp -f "$found" "${name}.${ext_lower}"
    echo "  ✓ logo   ${name}.${ext_lower}"
  fi
  if [ -z "$found" ]; then
    echo "  · skip   $name (not in Downloads)"
  fi
done

echo ""
echo "================================================================"
echo "DONE. Final inventory in $DEST :"
ls -la "$DEST"/*.jpg "$DEST"/*.png "$DEST"/*.svg 2>/dev/null | awk '{print "  ", $NF, $5}'
echo "================================================================"
