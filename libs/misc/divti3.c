//===-- divti3.c - Implement __divti3 -------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements __divti3 for the compiler_rt library.
//
//===----------------------------------------------------------------------===//

#include "int_lib.h"

#ifdef CRT_HAS_128BIT

// Returns: a / b

#define fixint_t ti_int
#define fixuint_t tu_int
#define COMPUTE_UDIV(a, b) __udivmodti4((a), (b), (tu_int *)0)
#include "int_div_impl.inc"

COMPILER_RT_ABI ti_int __divti3(ti_int a, ti_int b) { return __divXi3(a, b); }

#endif // CRT_HAS_128BIT