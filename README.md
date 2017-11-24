# Nonsidereal fixer for ITAC proposals

Quick and dirty script to convert non-sidereal target coordinates to a single
sidereal coordinate pair so that they can be ingested by ITAC. The collapsed
coordinate pair is the mean of the ephemeris coordinates.

## Installation 

1. [Install stack](https://docs.haskellstack.org/en/stable/install_and_upgrade/)
   using a method that suits you. For example, in MacOS you could use
   [homebrew](https://brew.sh/).

   ```sh
   $ brew install stack
   ```

2. Getting the code.

   ```sh
   $ git clone https://github.com/jdnavarro/nonsidereal-fix
   ```
    
3. Making sure stack is set for compilation.

   ```sh
   $ cd nonsidereal-fix
   $ stack setup
   ```

4. Compilation.

   ```sh
   $ stack install
   ```

   The program will be installed by default in `~/.local/bin/non-sidereal`. You can
   add `~/.local/bin/` to your `$PATH` so that it's always available from your
   shell. For example, for bash in MacOS, you would add `export
   PATH=~/.local/bin/:${PATH}` to your `~/.profile`.

   Alternatively, you could also copy the executable to a custom path with `stack
   --local-bin-path <path> install`.

5. Usage.

   ```sh
   $ nonsidereal-fix proposal.xml
   ```

   This will create `proposal-fix.xml` next `proposal.xml`.
