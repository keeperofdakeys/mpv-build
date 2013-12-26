#!/bin/sh

do_make()
{
  DIR=$1
  shift
  make -C $DIR $@
}

do_waf()
{
  DIR=$1
  shift
  (cd $DIR && ./waf $@)
}

do_ffmpeg()
{
  scripts/ffmpeg-config
  do_make ffmpeg install $@
}

do_libass()
{
  scripts/libass-config
  do_make libass install $@
}

do_fribidi()
{
  scripts/fribidi-config
  do_make fribidi install $@
}

do_mpv()
{
  do_ffmpeg $@
  do_libass $@
  scripts/mpv-config
  do_waf mpv build $@
}

BUILDOPTS=""
OPTS=$(getopt -o j: -- "$@")
eval set -- "$OPTS"

while [ $# -gt 0 ]; do
  case "$1" in
    -j)
      shift
      BUILDOPTS="-j $1"
      ;;
    --)
      if [ $# = 1 ]; then
        set -- -- mpv
      fi
      ;;
    ffmpeg)
      do_ffmpeg $BUILDOPTS
      ;;
    libass)
      do_libass $BUILDOPTS
      ;;
    mpv)
      do_mpv $BUILDOPTS
      ;;
    fribidi)
      do_fribidi
      ;;
    install)
      do_waf mpv install
      ;;
    uninstall)
      do_waf mpv uninstall
      ;;
    clean)
      rm -rf ffmpeg_build build_libs
      do_make libass distclean
      do_waf mpv clean
      ;;
    *)
      echo >&2 "$0 mpv"
      echo >&2 "$0 install"
      echo >&2 "$0 uninstall"
      exit 0
      ;;
  esac
  shift
done
