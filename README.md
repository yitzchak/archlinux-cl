# archlinux-cl

Arch Linux Docker image with Common Lisp implementations. Current
implementations are:

* [ABCL](https://armedbear.common-lisp.dev/)
* [CCL](https://ccl.clozure.com/)
* [CLASP](https://github.com/clasp-developers/clasp)
* [CLISP](https://gitlab.com/gnu-clisp/clisp)
* [CMUCL](https://gitlab.common-lisp.net/cmucl/cmucl)
* [ECL](https://ecl.common-lisp.dev/)
* [MKCL](https://github.com/jcbeaudoin/MKCL)
* [SBCL](http://sbcl.org)

The image tag is `ghcr.io/yitzchak/archlinux-cl:latest`

## GitHub Workflows

The image can be used to test Common Lisp systems using GitHub workflows. To aid with this there are three scripts which setup the envionment or aid with calling the specific Lisp implementation. 

The first is `make-rc` which ensures that that are RC files for all the provided Lisp implementations in the home directory. This is needed because GitHub makes a new directory when the container starts and sets the environment variable `HOME` to it. 

The second is `asdf-add` which adds the current folder to the ASDF registery. This avoids the difficulty of attempting to clone the repository into `~/quicklisp/local-projects`.

The final script is `lisp` which executes a specified Lisp implementation using the appropriate eval and load flags. It accepts the following arguments:
* `-i <name>` — use the Lisp implementation <name>. This should be the first argument.
* `-e <form>` — evaluate the <form>
* `-l <file>` — load the <file>
* `-q` — quit

A simple example of a workflow file is given below that tests a system named `fubar` which has the tests located in a system named `fubar/test`

```yaml
name: test

on:
  workflow_dispatch:
  push:
    branches: [ main ]
  pull_request:

jobs:
  test:
    name: Test
    defaults:
      run:
        shell: bash -l {0}
    strategy:
      matrix:
        lisp:
        - abcl
        - ccl
        - clasp
        - clisp
        - cmucl
        - ecl
        - mkcl
        - sbcl
      fail-fast: false
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/yitzchak/archlinux-cl:latest
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3
    - name: Setup Lisp Environment
      run: |
        make-rc
        asdf-add
    - name: Run Tests
      run: |
        lisp -i ${{ matrix.lisp }} -e "(ql:quickload :fubar/test)" -e "(asdf:test-system :fubar)"
```
