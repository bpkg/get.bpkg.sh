#!/usr/bin/env bash
# shellcheck disable=SC1090

source "$(which bpkg-env)" || exit 1
source "$(which bpkg-utils)" || exit 1

if [ -z "$BPKG_PACKAGE_ROOT" ]; then
  bpkg_error "'BPKG_PACKAGE_ROOT' is not defined"
  exit 1
fi

if ! test -d "$BPKG_PACKAGE_ROOT"; then
  bpkg_error "'BPKG_PACKAGE_ROOT' does not exist"
  exit 1
fi

declare should_force_generate=0
declare template="$BPKG_PACKAGE_ROOT/_template"
declare latest=""

for opt in "$@"; do
  case "$opt" in
    -f|--force)
      should_force_generate=1
      ;;

    -h|--help)
      echo "usage: generate.sh [-f|--force]"
      echo "   or: bpkg run generate [-f|--force]"
      exit 0
      ;;
  esac
done

list_tags () {
  local page=1
  while true; do
    # shellcheck disable=SC2207
    local tags=($(bpkg run list-bpkg-tags "$page"))

    (( page++ ))

    if (( ${#tags[@]} == 0 )); then
      break
    fi

    for tag in "${tags[@]}"; do
      echo "$tag"
    done
  done
  return $?
}


# shellcheck disable=SC2207
declare -a tags=($(list_tags))

declare tagshtml=""
tagshtml+="<h2>### <a name=\"tags\" href=\"#tags\">TAGS</a></h2>"
tagshtml+="<ul>"
for tag in "${tags[@]}"; do
  tagshtml+="<li>"
  tagshtml+="<a href="/$tag">$tag</a>"
  tagshtml+="</li>"
done
tagshtml+="</ul>"

echo "$tagshtml"

export tagshtml

for tag in "${tags[@]}"; do
  if [ -z "$latest" ]; then
    latest="$tag"
  fi

  ## create a directory with tag as name and store script as `index.html`
  declare dirname="$BPKG_PACKAGE_ROOT/$tag"
  declare output="$dirname/index.html"

  if ! test -f "$output" || (( should_force_generate == 1 )); then
    mkdir -p "$dirname"

    if test -f "$output"; then
      ## clean up existing
      bpkg_warn "Purging '$output'"
      rm -rf "$output"
    fi

    export tag
    export latest
    export tagpath="/$tag"

    ## output from template
    cat < "$template" | mush > "$output"

    ## ensure it is executable
    chmod +x "$output"
    bpkg_info "Generated '$tag'"
  fi
done

if [ -n "$latest" ]; then
  bpkg_info "Latest tag is '$latest'"

  ## create a directory with tag as name and store script as `index.html`
  declare dirname="$BPKG_PACKAGE_ROOT"
  declare output="$dirname/index.html"

  if ! test -f "$output" || (( should_force_generate == 1 )); then
    if test -f "$output"; then
      ## clean up existing
      bpkg_warn "Purging '$output'"
      rm -rf "$output"
    fi

    export tag="$latest"
    export latest
    export tagpath=""

    ## output from template
    cat < "$template" | mush > "$output"

    ## ensure it is executable
    chmod +x "$output"
    bpkg_info "Generated '$tag'"
  fi

  if ! test -f "$BPKG_PACKAGE_ROOT/latest" || (( should_force_generate == 1 )); then
    declare dirname="$BPKG_PACKAGE_ROOT/latest"
    declare output="$dirname/index.html"

    if test -f "$output"; then
      ## clean up existing
      bpkg_warn "Purging '$output'"
      rm -rf "$output"
    fi

    export tag="$latest"
    export latest
    export tagpath="/latest"

    ## output from template
    cat < "$template" | mush > "$output"
    ## ensure it is executable
    chmod +x "$output"
    bpkg_info "Generated 'latest'"
  fi
fi
