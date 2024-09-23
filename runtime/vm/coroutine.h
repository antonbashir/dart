// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef RUNTIME_VM_FIBER_H_
#define RUNTIME_VM_FIBER_H_

#include "vm/tagged_pointer.h"

#if defined(SHOULD_NOT_INCLUDE_RUNTIME)
#error "Should not include runtime"
#endif

namespace dart {
class CoroutineLink {
 public:
  DART_FORCE_INLINE
  bool IsEmpty() const { return previous_ == next_ && next_ == this; }

  DART_FORCE_INLINE
  void Initialize() { previous_ = next_ = this; }

  DART_FORCE_INLINE
  CoroutineLink* First() const { return next_; }

  DART_FORCE_INLINE
  CoroutineLink* Next() const { return next_; }

  DART_FORCE_INLINE
  CoroutinePtr Value() const { return value_; }

  DART_FORCE_INLINE
  void SetValue(CoroutinePtr value) { value_ = value; }

  DART_FORCE_INLINE
  static void Remove(CoroutineLink* item) {
    item->previous_->next_ = item->next_;
    item->next_->previous_ = item->previous_;
    item->next_ = item;
    item->previous_ = item;
  }

  DART_FORCE_INLINE
  static void AddHead(CoroutineLink* to, CoroutineLink* item) {
    item->previous_ = to;
    item->next_ = to->next_;
    item->previous_->next_ = item;
    item->next_->previous_ = item;
  }

  DART_FORCE_INLINE
  static void StealHead(CoroutineLink* to, CoroutineLink* item) {
    item->previous_->next_ = item->next_;
    item->next_->previous_ = item->previous_;
    item->previous_ = to;
    item->next_ = to->next_;
    item->previous_->next_ = to;
    item->next_->previous_ = to;
  }

  DART_FORCE_INLINE
  void ForEach(std::function<void(CoroutinePtr)> action) {
    for (auto item = First(); item != this; item = Next())
      action(item->Value());
  }

 private:
  CoroutineLink* next_;
  CoroutineLink* previous_;
  CoroutinePtr value_;
};

}  // namespace dart

#endif  // RUNTIME_VM_FIBER_H_
