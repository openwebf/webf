/*
 * QuickJS Javascript Engine
 *
 * Copyright (c) 2017-2021 Fabrice Bellard
 * Copyright (c) 2017-2021 Charlie Gordon
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef QUICKJS_EXCEPTION_H
#define QUICKJS_EXCEPTION_H

#include "quickjs/cutils.h"
#include "quickjs/quickjs.h"
#include "types.h"

#define JS_DEFINE_CLASS_HAS_HERITAGE (1 << 0)

/* %s is replaced by 'atom'. The macro is used so that gcc can check
    the format string. */
#define JS_ThrowTypeErrorAtom(ctx, fmt, atom) __JS_ThrowTypeErrorAtom(ctx, atom, fmt, "")
#define JS_ThrowSyntaxErrorAtom(ctx, fmt, atom) __JS_ThrowSyntaxErrorAtom(ctx, atom, fmt, "")

JSValue __attribute__((format(printf, 2, 3))) JS_ThrowInternalError(JSContext* ctx, const char* fmt, ...);
JSValue JS_ThrowError2(JSContext* ctx, JSErrorEnum error_num, const char* fmt, va_list ap, BOOL add_backtrace);
JSValue JS_ThrowError(JSContext* ctx, JSErrorEnum error_num, const char* fmt, va_list ap);

int __attribute__((format(printf, 3, 4))) JS_ThrowTypeErrorOrFalse(JSContext* ctx, int flags, const char* fmt, ...);
JSValue __attribute__((format(printf, 3, 4))) __JS_ThrowTypeErrorAtom(JSContext* ctx, JSAtom atom, const char* fmt, ...);
JSValue __attribute__((format(printf, 3, 4))) __JS_ThrowSyntaxErrorAtom(JSContext* ctx, JSAtom atom, const char* fmt, ...);

JSValue JS_ThrowTypeErrorPrivateNotFound(JSContext* ctx, JSAtom atom);

int JS_ThrowTypeErrorReadOnly(JSContext* ctx, int flags, JSAtom atom);
JSValue JS_ThrowOutOfMemory(JSContext* ctx);
JSValue JS_ThrowTypeErrorRevokedProxy(JSContext* ctx);
JSValue JS_ThrowStackOverflow(JSContext* ctx);
JSValue JS_ThrowTypeErrorNotAnObject(JSContext* ctx);
JSValue JS_ThrowTypeErrorNotASymbol(JSContext* ctx);
JSValue JS_ThrowReferenceErrorNotDefined(JSContext* ctx, JSAtom name);
JSValue JS_ThrowReferenceErrorUninitialized(JSContext* ctx, JSAtom name);
JSValue JS_ThrowReferenceErrorUninitialized2(JSContext* ctx, JSFunctionBytecode* b, int idx, BOOL is_ref);
JSValue JS_ThrowTypeErrorInvalidClass(JSContext* ctx, int class_id);

void JS_SetUncatchableError(JSContext* ctx, JSValueConst val, BOOL flag);

/* used to avoid catching interrupt exceptions */
BOOL JS_IsUncatchableError(JSContext* ctx, JSValueConst val);

JSValue JS_Throw(JSContext* ctx, JSValue obj);
JSValue JS_GetException(JSContext* ctx);
JS_BOOL JS_IsError(JSContext* ctx, JSValueConst val);
void JS_ResetUncatchableError(JSContext* ctx);
JSValue JS_NewError(JSContext* ctx);
JSValue __js_printf_like(2, 3) JS_ThrowSyntaxError(JSContext* ctx, const char* fmt, ...);
JSValue __js_printf_like(2, 3) JS_ThrowTypeError(JSContext* ctx, const char* fmt, ...);
JSValue __js_printf_like(2, 3) JS_ThrowReferenceError(JSContext* ctx, const char* fmt, ...);
JSValue __js_printf_like(2, 3) JS_ThrowRangeError(JSContext* ctx, const char* fmt, ...);
JSValue __js_printf_like(2, 3) JS_ThrowInternalError(JSContext* ctx, const char* fmt, ...);
JSValue JS_ThrowOutOfMemory(JSContext* ctx);

#endif