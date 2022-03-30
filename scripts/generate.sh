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

for tag in $(bpkg run list-bpkg-tags); do
  if [ -z "$latest" ]; then
    latest="$tag"
  fi

  ## create a directory with tag as name and store script as `index.html`
  declare dirname="$BPKG_PACKAGE_ROOT/$tag"
  declare output="$dirname/index.html"

  if ! test -f "$output" || (( should_force_generate == 1 )); then
    ## clean up existing
    bpkg_warn "Purging '$output'"
    mkdir -p "$dirname"
    rm -rf "$output"

    export tag
    export latest

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
  declare dirname="${BPKG_PACKAGE_ROOT:-.}/$latest"
  declare output="$dirname/index.html"

  if ! test -f "$output" || (( should_force_generate == 1 )); then
    bpkg_warn "Copying latest ('$latest') to root as 'index.html'"
    cp -f "$output" "$BPKG_PACKAGE_ROOT/index.html"
  fi
fi
