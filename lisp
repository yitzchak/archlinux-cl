#!/usr/bin/bash

IMPL=sbcl

CMD=(sbcl)

while getopts 'i:e:l:qn' opt; do
      case "$opt" in
      i)
        IMPL="$OPTARG"
        case "$IMPL" in
        acl)
                CMD=(alisp -L "/root/quicklisp/setup.lisp")
                ;;
        cmucl)
                CMD=(cmucl -batch)
                ;;
        *)
                CMD=("$IMPL")
                ;;
        esac
        ;;
      e)
        case "$IMPL" in
        acl)
                CMD+=(-e "$OPTARG")
                ;;
        clisp)
                CMD+=(-x "$OPTARG")
                ;;
        cmucl|mkcl)
                CMD+=(-eval "$OPTARG")
                ;;
        *)
                CMD+=(--eval "$OPTARG")
                ;;
        esac
        ;;
      l)
        case "$IMPL" in
        acl)
                CMD+=(-L "$OPTARG")
                ;;
        clisp)
                CMD+=(-i "$OPTARG")
                ;;
        cmucl|mkcl)
                CMD+=(-load "$OPTARG")
                ;;
        *)
                CMD+=(--load "$OPTARG")
                ;;
        esac
        ;;
      q)
        case "$IMPL" in
        abcl|ecl)
                CMD+=(--eval "(ext:quit)")
                ;;
        acl)
                CMD+=(-e "(excl:exit)")
                ;;
        clisp)
                CMD+=(-x "(quit)")
                ;;
        cmucl)
                CMD+=(-eval "(quit)")
                ;;
        mkcl)
                CMD+=(-eval "(mkcl:quit)")
                ;;
        *)
                CMD+=(--quit)
                ;;
        esac
        ;;
      n)
        case "$IMPL" in
        clasp|ecl)
                CMD+=(--norc)
                ;;
        acl)
                CMD+=(-q)
                ;;
        ccl)
                CMD+=(--no-init)
                ;;
        clisp|mkcl)
                CMD+=(-norc)
                ;;
        cmucl)
                CMD+=(-noinit)
                ;;
        *)
                CMD+=(--no-userinit)
                ;;
        esac
        ;;
      esac
done

shift $(($OPTIND - 1))

if [ -n "$@" ]; then
    case "$IMPL" in
        clasp|cmucl|ecl|mkcl)
            CMD+=(-- "$@")
            ;;
        *)
            CMD+=("$@")
            ;;
    esac
fi

"${CMD[@]}"
