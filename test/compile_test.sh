#!/usr/bin/env bash
# Adapted from:
#   https://github.com/Hoverbear/heroku-buildpack-rust/blob/master/test/compile_test.sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

PROJECT="rust-buildpack-test"

setup()
{
  mkdir -p $BUILD_DIR/src

  cat > $BUILD_DIR/Cargo.toml <<EOF
  [package]
  name = "$PROJECT"
  version = "0.1.0"
  authors = ["Andrew Hobden <andrew@hoverbear.org>"]

  [dependencies]
  rand = "*"
EOF

  cat > $BUILD_DIR/src/main.rs <<EOF
  extern crate rand;

  fn main() {
      let number = rand::random::<u64>();
      println!("Hello world! Some random number is {}", number);
  }

  #[test]
  fn it_works() {
      assert(true);
  }
EOF

  echo 'VERSION=1.8.0' > $BUILD_DIR/RustConfig
}

cleanup()
{
    rm -rf $BUILD_DIR
    rm -rf $CACHE_DIR
    rm -rf /tmp/multirust-repo

    unset RUST_VERSION
}

testDefault()
{
    setup

    compile

    assertCaptured "-----> Downloading Rust install script for 1.8.0 from"
    assertCaptured "-----> Installing Rust binaries..."
    assertCaptured "-----> No cached crates detected."
    assertCaptured "-----> Compiling application..."
    assertCaptured "-----> Caching build artifacts..."

    compile

    assertCaptured "-----> Using Rust version 1.8.0."
    assertCaptured "-----> Detected cached crates. Restoring..."

    cleanup
}
