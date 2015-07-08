/*
 * Copyright 2015 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package com.google.j2cl.transpiler.integration.breakstatement;

/**
 * Test for for break statement.
 */
public class Main {
  public static void main(String... args) {
    int i = 0;

    for (; i < 100; i++) {
      if (i == 50) {
        break;
      }
    }

    assert i == 50;

    while (true) {
      i++;

      if (i == 100) {
        break;
      }
    }

    assert i == 100;

    int count = 0;

    for (int j = 0; j < 100; j++) {
      for (int k = 0; k < 10; k++) {
        if (count == 100) {
          break;
        }

        count++;
      }
    }

    assert count == 100;

    for (; ; ) {
      count++;
      break;
    }

    assert count == 101;
  }
}
