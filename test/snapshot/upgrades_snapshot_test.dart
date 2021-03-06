// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library pub_tests;

import 'package:path/path.dart' as p;
import 'package:scheduled_test/scheduled_test.dart';

import '../descriptor.dart' as d;
import '../test_pub.dart';

main() {
  integration("upgrades a snapshot when its package is upgraded", () {
    servePackages((builder) {
      builder.serve("foo", "1.2.3", contents: [
        d.dir("bin", [
          d.file("hello.dart", "void main() => print('hello!');")
        ])
      ]);
    });

    d.appDir({"foo": "any"}).create();

    pubGet(output: contains("Precompiled foo:hello."));

    d.dir(p.join(appPath, '.pub', 'bin', 'foo'), [
      d.matcherFile('hello.dart.snapshot', contains('hello!'))
    ]).validate();

    servePackages((builder) {
      builder.serve("foo", "1.2.4", contents: [
        d.dir("bin", [
          d.file("hello.dart", "void main() => print('hello 2!');")
        ])
      ]);
    });

    pubUpgrade(output: contains("Precompiled foo:hello."));

    d.dir(p.join(appPath, '.pub', 'bin', 'foo'), [
      d.matcherFile('hello.dart.snapshot', contains('hello 2!'))
    ]).validate();

    var process = pubRun(args: ['foo:hello']);
    process.stdout.expect("hello 2!");
    process.shouldExit();
  });
}
