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

declare template="$BPKG_PACKAGE_ROOT/_template"
declare latest=""

let should_force_generate=0

for opt in "$@"; do
  case "$opt" in
    -f|--force)
      should_force_generate=1
      ;;

    -h|--help)
      usage
      return 0
      ;;
  esac
done

for tag in $(bpkg run list-bpkg-tags); do
  if [ -z "$latest" ]; then
    bpkg_info "Latest tag is '$tag'"
    latest="$tag"
  fi

  export tag
  export latest

  ## create a directory with tag as name and store script as `index.html`
  declare dirname="$BPKG_PACKAGE_ROOT/$tag"
  declare output="$dirname/index.html"

  if ! test -f "$output" || (( should_force_generate == 1 )); then
    ## clean up existing
    bpkg_warn "Purging '$output'"
    mkdir -p "$dirname"
    rm -rf "$output"

    ## output from template
    cat < "$template" | mush > "$output"

    ## ensure it is executable
    chmod +x "$output"
    bpkg_info "Generated '$tag'"
  fi
done

if [ -n "$latest" ]; then
  ## create a directory with tag as name and store script as `index.html`
  declare dirname="${BPKG_PACKAGE_ROOT:-.}/$tag"
  declare output="$dirname/index.html"

  bpkg_warn "Copying latest ('$latest') to root as 'index.html'"
  cp -f "$output" "$BPKG_PACKAGE_ROOT/index.html"
fi
