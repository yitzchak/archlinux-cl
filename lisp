#!/usr/bin/bash

IMPL=sbcl

CMD=(sbcl)

while getopts 'i:e:l:qn' opt; do
      case "$opt" in
      i)
        IMPL="$OPTARG"
        case "$IMPL" in
        acl)
                CMD=(alisp)
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
                CMD+=(-e "(load \"$OPTARG\")")
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
                CMD+=(-eval "(ext:quit)")
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

"${CMD[@]}"
