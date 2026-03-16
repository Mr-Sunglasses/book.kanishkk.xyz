#!/bin/bash

# convert_image.sh — Convert images to webp, png, or jpeg
#
# DESCRIPTION:
#   A CLI tool to convert images between formats (webp, png, jpeg).
#   Supports single file conversion and batch conversion of a directory.
#   Relies on 'cwebp' (for webp output) and 'ffmpeg' (for png/jpeg output).
#
# DEPENDENCIES:
#   - ffmpeg  : https://ffmpeg.org/         (brew install ffmpeg)
#   - cwebp   : https://developers.google.com/speed/webp  (brew install webp)
#
# USAGE:
#   ./convert_image.sh [OPTIONS] -i <input> -f <format>
#
# EXAMPLES:
#   ./convert_image.sh -i photo.png -f webp
#   ./convert_image.sh -i photo.jpg -f webp -q 85
#   ./convert_image.sh -i photo.png -f jpeg -o output.jpg
#   ./convert_image.sh -i ./images/ -f webp -b
#   ./convert_image.sh -i ./images/ -f png -b -o ./converted/

set -euo pipefail

# ─── Colours ────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# ─── Helpers ────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
die()     { error "$*"; exit 1; }

# ─── Usage ──────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF

${BOLD}USAGE${RESET}
    $(basename "$0") [OPTIONS] -i <input> -f <format>

${BOLD}REQUIRED${RESET}
    -i <path>       Input file or directory (use with -b for directories)
    -f <format>     Target format: ${BOLD}webp${RESET}, ${BOLD}png${RESET}, or ${BOLD}jpeg${RESET}

${BOLD}OPTIONS${RESET}
    -o <path>       Output file path or directory (default: same dir as input)
    -q <1-100>      Quality level for lossy formats — webp/jpeg (default: 80)
    -b              Batch mode: convert all images in the input directory
    -r              Recurse into subdirectories (only with -b)
    -k              Keep original files after conversion (default: keep)
    -d              Delete original files after successful conversion
    -s              Strip metadata (EXIF, ICC profiles) from output
    -v              Verbose output
    -h              Show this help message

${BOLD}SUPPORTED INPUT FORMATS${RESET}
    jpg, jpeg, png, webp, bmp, tiff, gif

${BOLD}EXAMPLES${RESET}
    # Convert a single PNG to WebP
    $(basename "$0") -i photo.png -f webp

    # Convert with custom quality and output path
    $(basename "$0") -i photo.jpg -f webp -q 85 -o ./out/photo.webp

    # Batch convert a directory of images to WebP
    $(basename "$0") -i ./images/ -f webp -b

    # Batch convert recursively, delete originals, strip metadata
    $(basename "$0") -i ./images/ -f webp -b -r -d -s

    # Convert to JPEG with quality 90
    $(basename "$0") -i photo.png -f jpeg -q 90

${BOLD}DEPENDENCIES${RESET}
    webp   → brew install webp     (required for -f webp)
    ffmpeg → brew install ffmpeg   (required for -f png / -f jpeg)

EOF
}

# ─── Dependency checks ───────────────────────────────────────────────────────
check_deps() {
    local format="$1"
    case "$format" in
        webp)
            command -v cwebp &>/dev/null || die "'cwebp' not found. Install it: brew install webp"
            ;;
        png|jpeg)
            command -v ffmpeg &>/dev/null || die "'ffmpeg' not found. Install it: brew install ffmpeg"
            ;;
    esac
}

# ─── Single file conversion ──────────────────────────────────────────────────
convert_file() {
    local input="$1"
    local format="$2"
    local output="$3"
    local quality="$4"
    local strip_meta="$5"
    local verbose="$6"

    [[ -f "$input" ]] || die "Input file not found: $input"

    # Determine output path if not set
    if [[ -z "$output" ]]; then
        local base
        base="$(dirname "$input")/$(basename "${input%.*}")"
        output="${base}.${format}"
        [[ "$format" == "jpeg" ]] && output="${base}.jpg"
    fi

    # Skip if input and output are the same
    if [[ "$input" == "$output" ]]; then
        warn "Skipping '$input': input and output are the same file."
        return 0
    fi

    [[ "$verbose" == "true" ]] && info "Converting: $input → $output"

    case "$format" in
        webp)
            local cwebp_args=(-q "$quality" "$input" -o "$output")
            [[ "$strip_meta" == "true" ]] && cwebp_args+=(-metadata none)
            if [[ "$verbose" == "true" ]]; then
                cwebp "${cwebp_args[@]}"
            else
                cwebp "${cwebp_args[@]}" &>/dev/null
            fi
            ;;
        png)
            local ffmpeg_args=(-y -i "$input")
            [[ "$strip_meta" == "true" ]] && ffmpeg_args+=(-map_metadata -1)
            ffmpeg_args+=("$output")
            if [[ "$verbose" == "true" ]]; then
                ffmpeg "${ffmpeg_args[@]}"
            else
                ffmpeg "${ffmpeg_args[@]}" &>/dev/null 2>&1
            fi
            ;;
        jpeg)
            local ffmpeg_args=(-y -i "$input" -q:v "$((100 - quality))")
            [[ "$strip_meta" == "true" ]] && ffmpeg_args+=(-map_metadata -1)
            ffmpeg_args+=("$output")
            if [[ "$verbose" == "true" ]]; then
                ffmpeg "${ffmpeg_args[@]}"
            else
                ffmpeg "${ffmpeg_args[@]}" &>/dev/null 2>&1
            fi
            ;;
    esac

    success "$input → $output"
    echo "$output"   # return the output path for the caller
}

# ─── Batch conversion ────────────────────────────────────────────────────────
batch_convert() {
    local dir="$1"
    local format="$2"
    local out_dir="$3"
    local quality="$4"
    local recurse="$5"
    local delete_orig="$6"
    local strip_meta="$7"
    local verbose="$8"

    [[ -d "$dir" ]] || die "Input directory not found: $dir"

    # Build find command
    local find_args=("$dir")
    [[ "$recurse" != "true" ]] && find_args+=(-maxdepth 1)
    find_args+=(-type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
        -o -iname "*.webp" -o -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.gif" \))

    local count=0
    local failed=0

    while IFS= read -r -d '' file; do
        # Determine output path
        local out_file
        if [[ -n "$out_dir" ]]; then
            mkdir -p "$out_dir"
            local rel_path="${file#$dir}"
            local base_name
            base_name="$(basename "${file%.*}")"
            local ext="$format"
            [[ "$format" == "jpeg" ]] && ext="jpg"
            out_file="${out_dir%/}/${base_name}.${ext}"
        else
            out_file=""
        fi

        local result
        if result=$(convert_file "$file" "$format" "$out_file" "$quality" "$strip_meta" "$verbose" 2>&1); then
            (( count++ )) || true
            if [[ "$delete_orig" == "true" && "$file" != "$result" ]]; then
                rm "$file"
                [[ "$verbose" == "true" ]] && info "Deleted original: $file"
            fi
        else
            warn "Failed to convert: $file"
            (( failed++ )) || true
        fi
    done < <(find "${find_args[@]}" -print0)

    echo ""
    info "────────────────────────────────"
    info "Batch complete"
    success "Converted : $count file(s)"
    [[ "$failed" -gt 0 ]] && warn "Failed    : $failed file(s)"
    info "────────────────────────────────"
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
    local input=""
    local format=""
    local output=""
    local quality=80
    local batch=false
    local recurse=false
    local delete_orig=false
    local strip_meta=false
    local verbose=false

    # No arguments → show usage
    [[ $# -eq 0 ]] && { usage; exit 0; }

    while getopts ":i:f:o:q:brdskvh" opt; do
        case "$opt" in
            i) input="$OPTARG" ;;
            f) format="$OPTARG" ;;
            o) output="$OPTARG" ;;
            q) quality="$OPTARG" ;;
            b) batch=true ;;
            r) recurse=true ;;
            d) delete_orig=true ;;
            s) strip_meta=true ;;
            k) ;;   # keep originals is default, flag is a no-op
            v) verbose=true ;;
            h) usage; exit 0 ;;
            :) die "Option -$OPTARG requires an argument." ;;
            \?) die "Unknown option: -$OPTARG. Use -h for help." ;;
        esac
    done

    # Validate required args
    [[ -z "$input" ]]  && die "Input path is required. Use -i <path>"
    [[ -z "$format" ]] && die "Target format is required. Use -f <webp|png|jpeg>"

    # Normalise format
    format="${format,,}"   # lowercase
    [[ "$format" == "jpg" ]] && format="jpeg"

    # Validate format
    case "$format" in
        webp|png|jpeg) ;;
        *) die "Unsupported format '$format'. Choose from: webp, png, jpeg" ;;
    esac

    # Validate quality
    if ! [[ "$quality" =~ ^[0-9]+$ ]] || (( quality < 1 || quality > 100 )); then
        die "Quality must be a number between 1 and 100."
    fi

    check_deps "$format"

    if [[ "$batch" == "true" ]]; then
        batch_convert "$input" "$format" "$output" "$quality" \
            "$recurse" "$delete_orig" "$strip_meta" "$verbose"
    else
        local out_path
        out_path=$(convert_file "$input" "$format" "$output" "$quality" "$strip_meta" "$verbose")
        if [[ "$delete_orig" == "true" && "$input" != "$out_path" ]]; then
            rm "$input"
            [[ "$verbose" == "true" ]] && info "Deleted original: $input"
        fi
    fi
}

main "$@"
