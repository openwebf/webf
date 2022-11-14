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

#ifndef QUICKJS_PARSER_H
#define QUICKJS_PARSER_H

#include "quickjs/cutils.h"
#include "quickjs/list.h"
#include "types.h"

/* JS parser */

enum {
  TOK_NUMBER = -128,
  TOK_STRING,
  TOK_TEMPLATE,
  TOK_IDENT,
  TOK_REGEXP,
  /* warning: order matters (see js_parse_assign_expr) */
  TOK_MUL_ASSIGN,
  TOK_DIV_ASSIGN,
  TOK_MOD_ASSIGN,
  TOK_PLUS_ASSIGN,
  TOK_MINUS_ASSIGN,
  TOK_SHL_ASSIGN,
  TOK_SAR_ASSIGN,
  TOK_SHR_ASSIGN,
  TOK_AND_ASSIGN,
  TOK_XOR_ASSIGN,
  TOK_OR_ASSIGN,
#ifdef CONFIG_BIGNUM
  TOK_MATH_POW_ASSIGN,
#endif
  TOK_POW_ASSIGN,
  TOK_LAND_ASSIGN,
  TOK_LOR_ASSIGN,
  TOK_DOUBLE_QUESTION_MARK_ASSIGN,
  TOK_DEC,
  TOK_INC,
  TOK_SHL,
  TOK_SAR,
  TOK_SHR,
  TOK_LT,
  TOK_LTE,
  TOK_GT,
  TOK_GTE,
  TOK_EQ,
  TOK_STRICT_EQ,
  TOK_NEQ,
  TOK_STRICT_NEQ,
  TOK_LAND,
  TOK_LOR,
#ifdef CONFIG_BIGNUM
  TOK_MATH_POW,
#endif
  TOK_POW,
  TOK_ARROW,
  TOK_ELLIPSIS,
  TOK_DOUBLE_QUESTION_MARK,
  TOK_QUESTION_MARK_DOT,
  TOK_ERROR,
  TOK_PRIVATE_NAME,
  TOK_EOF,
  /* keywords: WARNING: same order as atoms */
  TOK_NULL, /* must be first */
  TOK_FALSE,
  TOK_TRUE,
  TOK_IF,
  TOK_ELSE,
  TOK_RETURN,
  TOK_VAR,
  TOK_THIS,
  TOK_DELETE,
  TOK_VOID,
  TOK_TYPEOF,
  TOK_NEW,
  TOK_IN,
  TOK_INSTANCEOF,
  TOK_DO,
  TOK_WHILE,
  TOK_FOR,
  TOK_BREAK,
  TOK_CONTINUE,
  TOK_SWITCH,
  TOK_CASE,
  TOK_DEFAULT,
  TOK_THROW,
  TOK_TRY,
  TOK_CATCH,
  TOK_FINALLY,
  TOK_FUNCTION,
  TOK_DEBUGGER,
  TOK_WITH,
  /* FutureReservedWord */
  TOK_CLASS,
  TOK_CONST,
  TOK_ENUM,
  TOK_EXPORT,
  TOK_EXTENDS,
  TOK_IMPORT,
  TOK_SUPER,
  /* FutureReservedWords when parsing strict mode code */
  TOK_IMPLEMENTS,
  TOK_INTERFACE,
  TOK_LET,
  TOK_PACKAGE,
  TOK_PRIVATE,
  TOK_PROTECTED,
  TOK_PUBLIC,
  TOK_STATIC,
  TOK_YIELD,
  TOK_AWAIT, /* must be last */
  TOK_OF,    /* only used for js_parse_skip_parens_token() */
};

#define TOK_FIRST_KEYWORD TOK_NULL
#define TOK_LAST_KEYWORD TOK_AWAIT

/* unicode code points */
#define CP_NBSP 0x00a0
#define CP_BOM 0xfeff

#define CP_LS 0x2028
#define CP_PS 0x2029

typedef struct BlockEnv {
  struct BlockEnv* prev;
  JSAtom label_name; /* JS_ATOM_NULL if none */
  int label_break;   /* -1 if none */
  int label_cont;    /* -1 if none */
  int drop_count;    /* number of stack elements to drop */
  int label_finally; /* -1 if none */
  int scope_level;
  int has_iterator;
} BlockEnv;

typedef struct JSGlobalVar {
  int cpool_idx;          /* if >= 0, index in the constant pool for hoisted
                                               function defintion*/
  uint8_t force_init : 1; /* force initialization to undefined */
  uint8_t is_lexical : 1; /* global let/const definition */
  uint8_t is_const : 1;   /* const definition */
  int scope_level;        /* scope of definition */
  JSAtom var_name;        /* variable name */
} JSGlobalVar;

typedef struct RelocEntry {
  struct RelocEntry* next;
  uint32_t addr; /* address to patch */
  int size;      /* address size: 1, 2 or 4 bytes */
} RelocEntry;

typedef struct JumpSlot {
  int op;
  int size;
  int pos;
  int label;
} JumpSlot;

typedef struct LabelSlot {
  int ref_count;
  int pos;  /* phase 1 address, -1 means not resolved yet */
  int pos2; /* phase 2 address, -1 means not resolved yet */
  int addr; /* phase 3 address, -1 means not resolved yet */
  RelocEntry* first_reloc;
} LabelSlot;

typedef struct LineNumberSlot {
  uint32_t pc;
  int line_num;
} LineNumberSlot;

typedef struct ColumnNumberSlot {
  uint32_t pc;
  int column_num;
} ColumnNumberSlot;

typedef enum JSParseFunctionEnum {
  JS_PARSE_FUNC_STATEMENT,
  JS_PARSE_FUNC_VAR,
  JS_PARSE_FUNC_EXPR,
  JS_PARSE_FUNC_ARROW,
  JS_PARSE_FUNC_GETTER,
  JS_PARSE_FUNC_SETTER,
  JS_PARSE_FUNC_METHOD,
  JS_PARSE_FUNC_CLASS_CONSTRUCTOR,
  JS_PARSE_FUNC_DERIVED_CLASS_CONSTRUCTOR,
} JSParseFunctionEnum;

typedef enum JSParseExportEnum {
  JS_PARSE_EXPORT_NONE,
  JS_PARSE_EXPORT_NAMED,
  JS_PARSE_EXPORT_DEFAULT,
} JSParseExportEnum;

typedef struct JSFunctionDef {
  JSContext* ctx;
  struct JSFunctionDef* parent;
  int parent_cpool_idx;        /* index in the constant pool of the parent
                                                or -1 if none */
  int parent_scope_level;      /* scope level in parent at point of definition */
  struct list_head child_list; /* list of JSFunctionDef.link */
  struct list_head link;

  BOOL is_eval;         /* TRUE if eval code */
  int eval_type;        /* only valid if is_eval = TRUE */
  BOOL is_global_var;   /* TRUE if variables are not defined locally:
                               eval global, eval module or non strict eval */
  BOOL is_func_expr;    /* TRUE if function expression */
  BOOL has_home_object; /* TRUE if the home object is available */
  BOOL has_prototype;   /* true if a prototype field is necessary */
  BOOL has_simple_parameter_list;
  BOOL has_parameter_expressions; /* if true, an argument scope is created */
  BOOL has_use_strict;            /* to reject directive in special cases */
  BOOL has_eval_call;             /* true if the function contains a call to eval() */
  BOOL has_arguments_binding;     /* true if the 'arguments' binding is
                                             available in the function */
  BOOL has_this_binding;          /* true if the 'this' and new.target binding are
                                                       available in the function */
  BOOL new_target_allowed;        /* true if the 'new.target' does not
                                                   throw a syntax error */
  BOOL super_call_allowed;        /* true if super() is allowed */
  BOOL super_allowed;             /* true if super. or super[] is allowed */
  BOOL arguments_allowed;         /* true if the 'arguments' identifier is allowed */
  BOOL is_derived_class_constructor;
  BOOL in_function_body;
  BOOL backtrace_barrier;
  JSFunctionKindEnum func_kind : 8;
  JSParseFunctionEnum func_type : 8;
  uint8_t js_mode;  /* bitmap of JS_MODE_x */
  JSAtom func_name; /* JS_ATOM_NULL if no name */

  JSVarDef* vars;
  int var_size; /* allocated size for vars[] */
  int var_count;
  JSVarDef* args;
  int arg_size;  /* allocated size for args[] */
  int arg_count; /* number of arguments */
  int defined_arg_count;
  int var_object_idx;           /* -1 if none */
  int arg_var_object_idx;       /* -1 if none (var object for the argument scope) */
  int arguments_var_idx;        /* -1 if none */
  int arguments_arg_idx;        /* argument variable definition in argument scope,
                                                 -1 if none */
  int func_var_idx;             /* variable containing the current function (-1
                                                           if none, only used if is_func_expr is true) */
  int eval_ret_idx;             /* variable containing the return value of the eval, -1 if none */
  int this_var_idx;             /* variable containg the 'this' value, -1 if none */
  int new_target_var_idx;       /* variable containg the 'new.target' value, -1 if none */
  int this_active_func_var_idx; /* variable containg the 'this.active_func' value, -1 if none */
  int home_object_var_idx;
  BOOL need_home_object;

  int scope_level; /* index into fd->scopes if the current lexical scope */
  int scope_first; /* index into vd->vars of first lexically scoped variable */
  int scope_size;  /* allocated size of fd->scopes array */
  int scope_count; /* number of entries used in the fd->scopes array */
  JSVarScope* scopes;
  JSVarScope def_scope_array[4];
  int body_scope; /* scope of the body of the function or eval */

  int global_var_count;
  int global_var_size;
  JSGlobalVar* global_vars;

  DynBuf byte_code;
  int last_opcode_pos; /* -1 if no last opcode */
  int last_opcode_line_num;
  BOOL use_short_opcodes; /* true if short opcodes are used in byte_code */

  LabelSlot* label_slots;
  int label_size; /* allocated size for label_slots[] */
  int label_count;
  BlockEnv* top_break; /* break/continue label stack */

  /* constant pool (strings, functions, numbers) */
  JSValue* cpool;
  int cpool_count;
  int cpool_size;

  /* list of variables in the closure */
  int closure_var_count;
  int closure_var_size;
  JSClosureVar* closure_var;

  JumpSlot* jump_slots;
  int jump_size;
  int jump_count;

  LineNumberSlot* line_number_slots;
  int line_number_size;
  int line_number_count;
  int line_number_last;
  int line_number_last_pc;

  ColumnNumberSlot* column_number_slots;
  int column_number_size;
  int column_number_count;
  int column_number_last_pc;
  int column_number_last;

  /* pc2line table */
  JSAtom filename;
  int line_num;
  int column_num;
  DynBuf pc2line;
  DynBuf pc2column;

  char* source; /* raw source, utf-8 encoded */
  int source_len;

  JSModuleDef* module; /* != NULL when parsing a module */
} JSFunctionDef;

typedef struct JSToken {
  int val;
  int line_num;  /* line number of token start */
  int column_num; /* colum number of token start */
  const uint8_t *ptr;
  union {
    struct {
      JSValue str;
      int sep;
    } str;
    struct {
      JSValue val;
#ifdef CONFIG_BIGNUM
      slimb_t exponent; /* may be != 0 only if val is a float */
#endif
    } num;
    struct {
      JSAtom atom;
      BOOL has_escape;
      BOOL is_reserved;
    } ident;
    struct {
      JSValue body;
      JSValue flags;
    } regexp;
  } u;
} JSToken;

typedef struct JSParseState {
  JSContext *ctx;
  int last_line_num;  /* line number of last token */
  int line_num;       /* line number of current offset */
  const uint8_t *column_ptr;
  const uint8_t *column_last_ptr;
  int column_num_count;
  const char *filename;
  JSToken token;
  BOOL got_lf; /* true if got line feed before the current token */
  const uint8_t *last_ptr;
  const uint8_t *buf_ptr;
  const uint8_t *buf_end;

  /* current function code */
  JSFunctionDef *cur_func;
  BOOL is_module; /* parsing a module */
  BOOL allow_html_comments;
  BOOL ext_json; /* true if accepting JSON superset */
} JSParseState;

typedef struct JSOpCode {
#ifdef DUMP_BYTECODE
  const char *name;
#endif
  uint8_t size; /* in bytes */
  /* the opcodes remove n_pop items from the top of the stack, then
     pushes n_push items */
  uint8_t n_pop;
  uint8_t n_push;
  uint8_t fmt;
} JSOpCode;

static const JSOpCode opcode_info[OP_COUNT + (OP_TEMP_END - OP_TEMP_START)] = {
#define FMT(f)
#ifdef DUMP_BYTECODE
#define DEF(id, size, n_pop, n_push, f) { #id, size, n_pop, n_push, OP_FMT_ ## f },
#else
#define DEF(id, size, n_pop, n_push, f) { size, n_pop, n_push, OP_FMT_ ## f },
#endif
#include "quickjs/quickjs-opcode.h"
#undef DEF
#undef FMT
};

#if SHORT_OPCODES
/* After the final compilation pass, short opcodes are used. Their
   opcodes overlap with the temporary opcodes which cannot appear in
   the final bytecode. Their description is after the temporary
   opcodes in opcode_info[]. */
#define short_opcode_info(op)           \
    opcode_info[(op) >= OP_TEMP_START ? \
                (op) + (OP_TEMP_END - OP_TEMP_START) : (op)]
#else
#define short_opcode_info(op) opcode_info[op]
#endif

__exception int json_next_token(JSParseState *s);
void free_token(JSParseState *s, JSToken *token);

JSExportEntry* add_export_entry2(JSContext* ctx, JSParseState* s, JSModuleDef* m, JSAtom local_name, JSAtom export_name, JSExportTypeEnum export_type);
JSFunctionDef* js_new_function_def(JSContext* ctx, JSFunctionDef* parent, BOOL is_eval, BOOL is_func_expr, const char* filename, int line_num, int column_num);
void js_parse_init(JSContext* ctx, JSParseState* s, const char* input, size_t input_len, const char* filename);
int __attribute__((format(printf, 2, 3))) js_parse_error(JSParseState *s, const char *fmt, ...);
void skip_shebang(JSParseState* s);

JSValue js_module_ns_autoinit(JSContext* ctx, JSObject* p, JSAtom atom, void* opaque);
void js_free_module_def(JSContext* ctx, JSModuleDef* m);
JSValue js_import_meta(JSContext* ctx);

/* 'input' must be zero terminated i.e. input[input_len] = '\0'. */
JSValue __JS_EvalInternal(JSContext *ctx, JSValueConst this_obj,
                                 const char *input, size_t input_len,
                                 const char *filename, int flags, int scope_idx);

#endif