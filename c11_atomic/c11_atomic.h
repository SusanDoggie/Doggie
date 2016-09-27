//
//  c11_atomic.h
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#ifndef c11_atomic_h
#define c11_atomic_h

#include <stdint.h>
#include <stdbool.h>
#include <stdatomic.h>

#define _ATOMIC_CAS_BARRIER(NAME, x) static inline bool                                                             \
_AtomicCompareAndSwap##NAME##Barrier(x            oldValue,                                                         \
                                     x            newValue,                                                         \
                                     volatile x * address)                                                          \
{                                                                                                                   \
    return atomic_compare_exchange_strong((_Atomic(x)*)address, &oldValue, newValue);                               \
}

#define _ATOMIC_CAS_FIXED_INT_BARRIER(n) _ATOMIC_CAS_BARRIER(n, int##n##_t)
#define _ATOMIC_CAS_FIXED_UINT_BARRIER(n) _ATOMIC_CAS_BARRIER(U##n, uint##n##_t)

_ATOMIC_CAS_BARRIER(Bool, bool)
_ATOMIC_CAS_FIXED_INT_BARRIER(8)
_ATOMIC_CAS_FIXED_INT_BARRIER(16)
_ATOMIC_CAS_FIXED_INT_BARRIER(32)
_ATOMIC_CAS_FIXED_INT_BARRIER(64)
_ATOMIC_CAS_FIXED_UINT_BARRIER(8)
_ATOMIC_CAS_FIXED_UINT_BARRIER(16)
_ATOMIC_CAS_FIXED_UINT_BARRIER(32)
_ATOMIC_CAS_FIXED_UINT_BARRIER(64)
_ATOMIC_CAS_BARRIER(Long, long)
_ATOMIC_CAS_BARRIER(ULong, unsigned long)
_ATOMIC_CAS_BARRIER(Ptr, void*)

#define _ATOMIC_EXCHANGE_BARRIER(NAME, x) static inline x                                                           \
_AtomicExchange##NAME##Barrier(x            newValue,                                                               \
                               volatile x * address)                                                                \
{                                                                                                                   \
    return atomic_exchange((_Atomic(x)*)address, newValue);                                                         \
}

#define _ATOMIC_EXCHANGE_FIXED_INT_BARRIER(n) _ATOMIC_EXCHANGE_BARRIER(n, int##n##_t)
#define _ATOMIC_EXCHANGE_FIXED_UINT_BARRIER(n) _ATOMIC_EXCHANGE_BARRIER(U##n, uint##n##_t)

_ATOMIC_EXCHANGE_BARRIER(Bool, bool)
_ATOMIC_EXCHANGE_FIXED_INT_BARRIER(8)
_ATOMIC_EXCHANGE_FIXED_INT_BARRIER(16)
_ATOMIC_EXCHANGE_FIXED_INT_BARRIER(32)
_ATOMIC_EXCHANGE_FIXED_INT_BARRIER(64)
_ATOMIC_EXCHANGE_FIXED_UINT_BARRIER(8)
_ATOMIC_EXCHANGE_FIXED_UINT_BARRIER(16)
_ATOMIC_EXCHANGE_FIXED_UINT_BARRIER(32)
_ATOMIC_EXCHANGE_FIXED_UINT_BARRIER(64)
_ATOMIC_EXCHANGE_BARRIER(Long, long)
_ATOMIC_EXCHANGE_BARRIER(ULong, unsigned long)
_ATOMIC_EXCHANGE_BARRIER(Ptr, void*)

#endif /* c11_atomic_h */
