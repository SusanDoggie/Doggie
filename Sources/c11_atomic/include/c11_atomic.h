//
//  c11_atomic.h
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

#define _ATOMIC_IS_LOCK_FREE(NAME, x) static inline bool                                                            \
_Atomic##NAME##IsLockFree(const volatile x * address)                                                               \
{                                                                                                                   \
    return atomic_is_lock_free((_Atomic(x)*)address);                                                               \
}

#define _ATOMIC_FIXED_INT_IS_LOCK_FREE(n) _ATOMIC_IS_LOCK_FREE(n, int##n##_t)
#define _ATOMIC_FIXED_UINT_IS_LOCK_FREE(n) _ATOMIC_IS_LOCK_FREE(U##n, uint##n##_t)

_ATOMIC_IS_LOCK_FREE(Bool, bool)
_ATOMIC_FIXED_INT_IS_LOCK_FREE(8)
_ATOMIC_FIXED_INT_IS_LOCK_FREE(16)
_ATOMIC_FIXED_INT_IS_LOCK_FREE(32)
_ATOMIC_FIXED_INT_IS_LOCK_FREE(64)
_ATOMIC_FIXED_UINT_IS_LOCK_FREE(8)
_ATOMIC_FIXED_UINT_IS_LOCK_FREE(16)
_ATOMIC_FIXED_UINT_IS_LOCK_FREE(32)
_ATOMIC_FIXED_UINT_IS_LOCK_FREE(64)
_ATOMIC_IS_LOCK_FREE(Long, long)
_ATOMIC_IS_LOCK_FREE(ULong, unsigned long)
_ATOMIC_IS_LOCK_FREE(Ptr, void*)

static inline bool _AtomicCompareAndSwapWeakPtrBarrier(void* oldValue, void* newValue, volatile void** address) {
    
    return atomic_compare_exchange_weak((_Atomic(void*)*)address, &oldValue, newValue);
}

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

#define _ATOMIC_LOAD_BARRIER(NAME, x) static inline x                                                               \
_AtomicLoad##NAME##Barrier(const volatile x * address)                                                              \
{                                                                                                                   \
    return atomic_load((_Atomic(x)*)address);                                                                       \
}

#define _ATOMIC_LOAD_FIXED_INT_BARRIER(n) _ATOMIC_LOAD_BARRIER(n, int##n##_t)
#define _ATOMIC_LOAD_FIXED_UINT_BARRIER(n) _ATOMIC_LOAD_BARRIER(U##n, uint##n##_t)

_ATOMIC_LOAD_BARRIER(Bool, bool)
_ATOMIC_LOAD_FIXED_INT_BARRIER(8)
_ATOMIC_LOAD_FIXED_INT_BARRIER(16)
_ATOMIC_LOAD_FIXED_INT_BARRIER(32)
_ATOMIC_LOAD_FIXED_INT_BARRIER(64)
_ATOMIC_LOAD_FIXED_UINT_BARRIER(8)
_ATOMIC_LOAD_FIXED_UINT_BARRIER(16)
_ATOMIC_LOAD_FIXED_UINT_BARRIER(32)
_ATOMIC_LOAD_FIXED_UINT_BARRIER(64)
_ATOMIC_LOAD_BARRIER(Long, long)
_ATOMIC_LOAD_BARRIER(ULong, unsigned long)

#define _ATOMIC_STORE_BARRIER(NAME, x) static inline void                                                           \
_AtomicStore##NAME##Barrier(x            newValue,                                                                  \
                            volatile x * address)                                                                   \
{                                                                                                                   \
    atomic_store((_Atomic(x)*)address, newValue);                                                                   \
}

#define _ATOMIC_STORE_FIXED_INT_BARRIER(n) _ATOMIC_STORE_BARRIER(n, int##n##_t)
#define _ATOMIC_STORE_FIXED_UINT_BARRIER(n) _ATOMIC_STORE_BARRIER(U##n, uint##n##_t)

_ATOMIC_STORE_BARRIER(Bool, bool)
_ATOMIC_STORE_FIXED_INT_BARRIER(8)
_ATOMIC_STORE_FIXED_INT_BARRIER(16)
_ATOMIC_STORE_FIXED_INT_BARRIER(32)
_ATOMIC_STORE_FIXED_INT_BARRIER(64)
_ATOMIC_STORE_FIXED_UINT_BARRIER(8)
_ATOMIC_STORE_FIXED_UINT_BARRIER(16)
_ATOMIC_STORE_FIXED_UINT_BARRIER(32)
_ATOMIC_STORE_FIXED_UINT_BARRIER(64)
_ATOMIC_STORE_BARRIER(Long, long)
_ATOMIC_STORE_BARRIER(ULong, unsigned long)

#define _ATOMIC_FETCHADD_BARRIER(NAME, x) static inline x                                                           \
_AtomicFetchAdd##NAME##Barrier(x            arg,                                                                    \
                               volatile x * address)                                                                \
{                                                                                                                   \
    return atomic_fetch_add((_Atomic(x)*)address, arg);                                                             \
}

#define _ATOMIC_FETCHADD_FIXED_INT_BARRIER(n) _ATOMIC_FETCHADD_BARRIER(n, int##n##_t)
#define _ATOMIC_FETCHADD_FIXED_UINT_BARRIER(n) _ATOMIC_FETCHADD_BARRIER(U##n, uint##n##_t)

_ATOMIC_FETCHADD_FIXED_INT_BARRIER(8)
_ATOMIC_FETCHADD_FIXED_INT_BARRIER(16)
_ATOMIC_FETCHADD_FIXED_INT_BARRIER(32)
_ATOMIC_FETCHADD_FIXED_INT_BARRIER(64)
_ATOMIC_FETCHADD_FIXED_UINT_BARRIER(8)
_ATOMIC_FETCHADD_FIXED_UINT_BARRIER(16)
_ATOMIC_FETCHADD_FIXED_UINT_BARRIER(32)
_ATOMIC_FETCHADD_FIXED_UINT_BARRIER(64)
_ATOMIC_FETCHADD_BARRIER(Long, long)
_ATOMIC_FETCHADD_BARRIER(ULong, unsigned long)

#define _ATOMIC_FETCHSUB_BARRIER(NAME, x) static inline x                                                           \
_AtomicFetchSub##NAME##Barrier(x            arg,                                                                    \
                               volatile x * address)                                                                \
{                                                                                                                   \
    return atomic_fetch_sub((_Atomic(x)*)address, arg);                                                             \
}

#define _ATOMIC_FETCHSUB_FIXED_INT_BARRIER(n) _ATOMIC_FETCHSUB_BARRIER(n, int##n##_t)
#define _ATOMIC_FETCHSUB_FIXED_UINT_BARRIER(n) _ATOMIC_FETCHSUB_BARRIER(U##n, uint##n##_t)

_ATOMIC_FETCHSUB_FIXED_INT_BARRIER(8)
_ATOMIC_FETCHSUB_FIXED_INT_BARRIER(16)
_ATOMIC_FETCHSUB_FIXED_INT_BARRIER(32)
_ATOMIC_FETCHSUB_FIXED_INT_BARRIER(64)
_ATOMIC_FETCHSUB_FIXED_UINT_BARRIER(8)
_ATOMIC_FETCHSUB_FIXED_UINT_BARRIER(16)
_ATOMIC_FETCHSUB_FIXED_UINT_BARRIER(32)
_ATOMIC_FETCHSUB_FIXED_UINT_BARRIER(64)
_ATOMIC_FETCHSUB_BARRIER(Long, long)
_ATOMIC_FETCHSUB_BARRIER(ULong, unsigned long)

#define _ATOMIC_FETCHXOR_BARRIER(NAME, x) static inline x                                                           \
_AtomicFetchXor##NAME##Barrier(x            arg,                                                                    \
                               volatile x * address)                                                                \
{                                                                                                                   \
    return atomic_fetch_xor((_Atomic(x)*)address, arg);                                                             \
}

#define _ATOMIC_FETCHXOR_FIXED_INT_BARRIER(n) _ATOMIC_FETCHXOR_BARRIER(n, int##n##_t)
#define _ATOMIC_FETCHXOR_FIXED_UINT_BARRIER(n) _ATOMIC_FETCHXOR_BARRIER(U##n, uint##n##_t)

_ATOMIC_FETCHXOR_FIXED_INT_BARRIER(8)
_ATOMIC_FETCHXOR_FIXED_INT_BARRIER(16)
_ATOMIC_FETCHXOR_FIXED_INT_BARRIER(32)
_ATOMIC_FETCHXOR_FIXED_INT_BARRIER(64)
_ATOMIC_FETCHXOR_FIXED_UINT_BARRIER(8)
_ATOMIC_FETCHXOR_FIXED_UINT_BARRIER(16)
_ATOMIC_FETCHXOR_FIXED_UINT_BARRIER(32)
_ATOMIC_FETCHXOR_FIXED_UINT_BARRIER(64)
_ATOMIC_FETCHXOR_BARRIER(Long, long)
_ATOMIC_FETCHXOR_BARRIER(ULong, unsigned long)

#define _ATOMIC_FETCHAND_BARRIER(NAME, x) static inline x                                                           \
_AtomicFetchAnd##NAME##Barrier(x            arg,                                                                    \
                               volatile x * address)                                                                \
{                                                                                                                   \
    return atomic_fetch_and((_Atomic(x)*)address, arg);                                                             \
}

#define _ATOMIC_FETCHAND_FIXED_INT_BARRIER(n) _ATOMIC_FETCHAND_BARRIER(n, int##n##_t)
#define _ATOMIC_FETCHAND_FIXED_UINT_BARRIER(n) _ATOMIC_FETCHAND_BARRIER(U##n, uint##n##_t)

_ATOMIC_FETCHAND_FIXED_INT_BARRIER(8)
_ATOMIC_FETCHAND_FIXED_INT_BARRIER(16)
_ATOMIC_FETCHAND_FIXED_INT_BARRIER(32)
_ATOMIC_FETCHAND_FIXED_INT_BARRIER(64)
_ATOMIC_FETCHAND_FIXED_UINT_BARRIER(8)
_ATOMIC_FETCHAND_FIXED_UINT_BARRIER(16)
_ATOMIC_FETCHAND_FIXED_UINT_BARRIER(32)
_ATOMIC_FETCHAND_FIXED_UINT_BARRIER(64)
_ATOMIC_FETCHAND_BARRIER(Long, long)
_ATOMIC_FETCHAND_BARRIER(ULong, unsigned long)

#define _ATOMIC_FETCHOR_BARRIER(NAME, x) static inline x                                                            \
_AtomicFetchOr##NAME##Barrier(x            arg,                                                                     \
                              volatile x * address)                                                                 \
{                                                                                                                   \
    return atomic_fetch_or((_Atomic(x)*)address, arg);                                                              \
}

#define _ATOMIC_FETCHOR_FIXED_INT_BARRIER(n) _ATOMIC_FETCHOR_BARRIER(n, int##n##_t)
#define _ATOMIC_FETCHOR_FIXED_UINT_BARRIER(n) _ATOMIC_FETCHOR_BARRIER(U##n, uint##n##_t)

_ATOMIC_FETCHOR_FIXED_INT_BARRIER(8)
_ATOMIC_FETCHOR_FIXED_INT_BARRIER(16)
_ATOMIC_FETCHOR_FIXED_INT_BARRIER(32)
_ATOMIC_FETCHOR_FIXED_INT_BARRIER(64)
_ATOMIC_FETCHOR_FIXED_UINT_BARRIER(8)
_ATOMIC_FETCHOR_FIXED_UINT_BARRIER(16)
_ATOMIC_FETCHOR_FIXED_UINT_BARRIER(32)
_ATOMIC_FETCHOR_FIXED_UINT_BARRIER(64)
_ATOMIC_FETCHOR_BARRIER(Long, long)
_ATOMIC_FETCHOR_BARRIER(ULong, unsigned long)

#endif /* c11_atomic_h */
