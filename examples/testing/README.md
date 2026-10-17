# Separate C and C++ test projects

These are independent native-host examples. Framework sources are project-local,
not global packages. CMake fetches pinned Unity/GoogleTest revisions on the first
configure unless an existing checkout is supplied through `UNITY_SOURCE_DIR` or
`GTEST_SOURCE_DIR`. Those cache variables name source checkouts, not install
prefixes. Use a Debug build for CodeLLDB.

## C: Unity

```sh
cmake -S examples/testing/unity -B examples/testing/unity/build -DCMAKE_BUILD_TYPE=Debug
cmake --build examples/testing/unity/build
ctest --test-dir examples/testing/unity/build --output-on-failure --no-tests=error -R '^unity_'
```

Open `unity/tests/test_add.c` and use `:OverseerRun`. Select Configure, Build,
then Run Unity tests. Defaults use the nearest CMake project and its `build/`
directory. The run task matches CTest names beginning with `unity_`; adapt the
filter for your project. No matching tests is an error. Framework assertions and
all tests within a runner appear in the task output; this is not a Neotest adapter.
The example has a handwritten runner, so Ruby/Ceedling is not needed.

For debugging, launch `unity/build/unity_tests` with the shared CodeLLDB profile.
Firmware cross-builds and on-device test execution need their own toolchain and
debug-server configuration; these tasks do not flash hardware.

## C++: GoogleTest

```sh
cmake -S examples/testing/gtest -B examples/testing/gtest/build -DCMAKE_BUILD_TYPE=Debug
cmake --build examples/testing/gtest/build
ctest --test-dir examples/testing/gtest/build --output-on-failure --no-tests=error
```

Open `gtest/tests/add_test.cpp`, then `Space T<CR>` to open the Neotest summary.
Mark the file or test directory with `m`, then press `C` or run `:ConfigureGtest`
in that summary buffer. Select `gtest/build/calculator_tests` (use its absolute
path). The adapter remembers that mapping.

Use `Space Tt` for the nearest test, `Space Tf` for the file, and `Space Td` to
debug a test through CodeLLDB. Rebuild after changing source: the adapter does not
compile automatically. Default discovery recognizes `test_*.cpp`/`*_test.cpp`
and corresponding supported C++ extensions; it does not claim `.c` Unity files.
`TEST` and `TEST_F` are supported; `TEST_P` parameterized execution is not.

## Verify the Neovim configuration

From the configuration repository root, run `bash scripts/check_c_testing.sh`.
It copies these examples to a temporary directory, builds/runs both, verifies
failure reporting and empty Unity selections, discovers/runs GoogleTest tests
through Neotest, and hits a CodeLLDB test breakpoint. It executes fixture code.
Plugins, the C++ Tree-sitter parser, native compilers, CMake/CTest, and CodeLLDB
must already be installed. First configuration downloads dependencies unless
`NVIM_TEST_UNITY_SOURCE` and `NVIM_TEST_GTEST_SOURCE` point to existing source
checkouts. All test build output and adapter mappings use temporary directories.
