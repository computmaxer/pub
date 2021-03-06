// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS d.file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE d.file.

import 'package:path/path.dart' as path;
import 'package:pub/src/io.dart';

import '../descriptor.dart' as d;
import '../test_pub.dart';

main() {
  integration("uses what's in the lockfile regardless of the pubspec", () {
    d.dir("foo", [
      d.libDir("foo"),
      d.libPubspec("foo", "1.0.0")
    ]).create();

    d.dir(appPath, [
      d.appPubspec({
        "foo": {"path": path.join(sandboxDir, "foo")}
      })
    ]).create();

    pubGet();

    // Add a dependency on "bar" and remove "foo", but don't run "pub get".
    d.dir(appPath, [
      d.appPubspec({
        "bar": "any"
      })
    ]).create();

    // Note: Using canonicalize here because pub gets the path to the
    // entrypoint package from the working directory, which has had symlinks
    // resolve. On Mac, "/tmp" is actually a symlink to "/private/tmp", so we
    // need to accomodate that.
    schedulePub(args: ["list-package-dirs", "--format=json"],
        outputJson: {
          "packages": {
            "foo": path.join(sandboxDir, "foo", "lib"),
            "myapp": canonicalize(path.join(sandboxDir, appPath, "lib"))
          },
          "input_files": [
            canonicalize(path.join(sandboxDir, appPath, "pubspec.lock")),
            canonicalize(path.join(sandboxDir, appPath, "pubspec.yaml"))
          ]
        });
  });
}