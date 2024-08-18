// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/*library: 
 compilationSequence=[
  macro_lib.dart|package:_macros/src/api.dart|package:macros/macros.dart,
  main.dart],
 macrosAreAvailable,
 neededPrecompilations=[macro_lib.dart=Macro1(new)]
*/

// ignore: unused_import
import 'macro_lib.dart';

void main() {}
