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

#include "module.h"
#include "exception.h"
#include "function.h"
#include "gc.h"
#include "malloc.h"
#include "object.h"
#include "parser.h"
#include "runtime.h"
#include "string.h"

/* 'name' is freed */
JSModuleDef *js_new_module_def(JSContext *ctx, JSAtom name)
{
  JSModuleDef *m;
  m = js_mallocz(ctx, sizeof(*m));
  if (!m) {
    JS_FreeAtom(ctx, name);
    return NULL;
  }
  m->header.ref_count = 1;
  m->module_name = name;
  m->module_ns = JS_UNDEFINED;
  m->func_obj = JS_UNDEFINED;
  m->eval_exception = JS_UNDEFINED;
  m->meta_obj = JS_UNDEFINED;
  list_add_tail(&m->link, &ctx->loaded_modules);
  return m;
}

void js_mark_module_def(JSRuntime *rt, JSModuleDef *m,
                               JS_MarkFunc *mark_func)
{
  int i;

  for(i = 0; i < m->export_entries_count; i++) {
    JSExportEntry *me = &m->export_entries[i];
    if (me->export_type == JS_EXPORT_TYPE_LOCAL &&
        me->u.local.var_ref) {
      mark_func(rt, &me->u.local.var_ref->header);
    }
  }

  JS_MarkValue(rt, m->module_ns, mark_func);
  JS_MarkValue(rt, m->func_obj, mark_func);
  JS_MarkValue(rt, m->eval_exception, mark_func);
  JS_MarkValue(rt, m->meta_obj, mark_func);
}

void js_free_module_def(JSContext *ctx, JSModuleDef *m)
{
  int i;

  JS_FreeAtom(ctx, m->module_name);

  for(i = 0; i < m->req_module_entries_count; i++) {
    JSReqModuleEntry *rme = &m->req_module_entries[i];
    JS_FreeAtom(ctx, rme->module_name);
  }
  js_free(ctx, m->req_module_entries);

  for(i = 0; i < m->export_entries_count; i++) {
    JSExportEntry *me = &m->export_entries[i];
    if (me->export_type == JS_EXPORT_TYPE_LOCAL)
      free_var_ref(ctx->rt, me->u.local.var_ref);
    JS_FreeAtom(ctx, me->export_name);
    JS_FreeAtom(ctx, me->local_name);
  }
  js_free(ctx, m->export_entries);

  js_free(ctx, m->star_export_entries);

  for(i = 0; i < m->import_entries_count; i++) {
    JSImportEntry *mi = &m->import_entries[i];
    JS_FreeAtom(ctx, mi->import_name);
  }
  js_free(ctx, m->import_entries);

  JS_FreeValue(ctx, m->module_ns);
  JS_FreeValue(ctx, m->func_obj);
  JS_FreeValue(ctx, m->eval_exception);
  JS_FreeValue(ctx, m->meta_obj);
  list_del(&m->link);
  js_free(ctx, m);
}

int add_req_module_entry(JSContext *ctx, JSModuleDef *m,
                                JSAtom module_name)
{
  JSReqModuleEntry *rme;
  int i;

  /* no need to add the module request if it is already present */
  for(i = 0; i < m->req_module_entries_count; i++) {
    rme = &m->req_module_entries[i];
    if (rme->module_name == module_name)
      return i;
  }

  if (js_resize_array(ctx, (void **)&m->req_module_entries,
                      sizeof(JSReqModuleEntry),
                      &m->req_module_entries_size,
                      m->req_module_entries_count + 1))
    return -1;
  rme = &m->req_module_entries[m->req_module_entries_count++];
  rme->module_name = JS_DupAtom(ctx, module_name);
  rme->module = NULL;
  return i;
}

JSExportEntry *find_export_entry(JSContext *ctx, JSModuleDef *m,
                                        JSAtom export_name)
{
  JSExportEntry *me;
  int i;
  for(i = 0; i < m->export_entries_count; i++) {
    me = &m->export_entries[i];
    if (me->export_name == export_name)
      return me;
  }
  return NULL;
}

/* create a C module */
JSModuleDef *JS_NewCModule(JSContext *ctx, const char *name_str,
                           JSModuleInitFunc *func)
{
  JSModuleDef *m;
  JSAtom name;
  name = JS_NewAtom(ctx, name_str);
  if (name == JS_ATOM_NULL)
    return NULL;
  m = js_new_module_def(ctx, name);
  m->init_func = func;
  return m;
}

int JS_AddModuleExport(JSContext *ctx, JSModuleDef *m, const char *export_name)
{
  JSExportEntry *me;
  JSAtom name;
  name = JS_NewAtom(ctx, export_name);
  if (name == JS_ATOM_NULL)
    return -1;
  me = add_export_entry2(ctx, NULL, m, JS_ATOM_NULL, name,
                         JS_EXPORT_TYPE_LOCAL);
  JS_FreeAtom(ctx, name);
  if (!me)
    return -1;
  else
    return 0;
}

int JS_SetModuleExport(JSContext *ctx, JSModuleDef *m, const char *export_name,
                       JSValue val)
{
  JSExportEntry *me;
  JSAtom name;
  name = JS_NewAtom(ctx, export_name);
  if (name == JS_ATOM_NULL)
    goto fail;
  me = find_export_entry(ctx, m, name);
  JS_FreeAtom(ctx, name);
  if (!me)
    goto fail;
  set_value(ctx, me->u.local.var_ref->pvalue, val);
  return 0;
fail:
  JS_FreeValue(ctx, val);
  return -1;
}

void JS_SetModuleLoaderFunc(JSRuntime *rt,
                            JSModuleNormalizeFunc *module_normalize,
                            JSModuleLoaderFunc *module_loader, void *opaque)
{
  rt->module_normalize_func = module_normalize;
  rt->module_loader_func = module_loader;
  rt->module_loader_opaque = opaque;
}

/* default module filename normalizer */
char *js_default_module_normalize_name(JSContext *ctx,
                                              const char *base_name,
                                              const char *name)
{
  char *filename, *p;
  const char *r;
  int len;

  if (name[0] != '.') {
    /* if no initial dot, the module name is not modified */
    return js_strdup(ctx, name);
  }

  p = strrchr(base_name, '/');
  if (p)
    len = p - base_name;
  else
    len = 0;

  filename = js_malloc(ctx, len + strlen(name) + 1 + 1);
  if (!filename)
    return NULL;
  memcpy(filename, base_name, len);
  filename[len] = '\0';

  /* we only normalize the leading '..' or '.' */
  r = name;
  for(;;) {
    if (r[0] == '.' && r[1] == '/') {
      r += 2;
    } else if (r[0] == '.' && r[1] == '.' && r[2] == '/') {
      /* remove the last path element of filename, except if "."
         or ".." */
      if (filename[0] == '\0')
        break;
      p = strrchr(filename, '/');
      if (!p)
        p = filename;
      else
        p++;
      if (!strcmp(p, ".") || !strcmp(p, ".."))
        break;
      if (p > filename)
        p--;
      *p = '\0';
      r += 3;
    } else {
      break;
    }
  }
  if (filename[0] != '\0')
    strcat(filename, "/");
  strcat(filename, r);
  //    printf("normalize: %s %s -> %s\n", base_name, name, filename);
  return filename;
}

JSModuleDef *js_find_loaded_module(JSContext *ctx, JSAtom name)
{
  struct list_head *el;
  JSModuleDef *m;

  /* first look at the loaded modules */
  list_for_each(el, &ctx->loaded_modules) {
    m = list_entry(el, JSModuleDef, link);
    if (m->module_name == name)
      return m;
  }
  return NULL;
}

/* return NULL in case of exception (e.g. module could not be loaded) */
JSModuleDef *js_host_resolve_imported_module(JSContext *ctx,
                                                    const char *base_cname,
                                                    const char *cname1)
{
  JSRuntime *rt = ctx->rt;
  JSModuleDef *m;
  char *cname;
  JSAtom module_name;

  if (!rt->module_normalize_func) {
    cname = js_default_module_normalize_name(ctx, base_cname, cname1);
  } else {
    cname = rt->module_normalize_func(ctx, base_cname, cname1,
                                      rt->module_loader_opaque);
  }
  if (!cname)
    return NULL;

  module_name = JS_NewAtom(ctx, cname);
  if (module_name == JS_ATOM_NULL) {
    js_free(ctx, cname);
    return NULL;
  }

  /* first look at the loaded modules */
  m = js_find_loaded_module(ctx, module_name);
  if (m) {
    js_free(ctx, cname);
    JS_FreeAtom(ctx, module_name);
    return m;
  }

  JS_FreeAtom(ctx, module_name);

  /* load the module */
  if (!rt->module_loader_func) {
    /* XXX: use a syntax error ? */
    JS_ThrowReferenceError(ctx, "could not load module '%s'",
                           cname);
    js_free(ctx, cname);
    return NULL;
  }

  m = rt->module_loader_func(ctx, cname, rt->module_loader_opaque);
  js_free(ctx, cname);
  return m;
}

JSModuleDef *js_host_resolve_imported_module_atom(JSContext *ctx,
                                                         JSAtom base_module_name,
                                                         JSAtom module_name1)
{
  const char *base_cname, *cname;
  JSModuleDef *m;

  base_cname = JS_AtomToCString(ctx, base_module_name);
  if (!base_cname)
    return NULL;
  cname = JS_AtomToCString(ctx, module_name1);
  if (!cname) {
    JS_FreeCString(ctx, base_cname);
    return NULL;
  }
  m = js_host_resolve_imported_module(ctx, base_cname, cname);
  JS_FreeCString(ctx, base_cname);
  JS_FreeCString(ctx, cname);
  return m;
}

static int find_resolve_entry(JSResolveState *s,
                              JSModuleDef *m, JSAtom name)
{
  int i;
  for(i = 0; i < s->count; i++) {
    JSResolveEntry *re = &s->array[i];
    if (re->module == m && re->name == name)
      return i;
  }
  return -1;
}

static int add_resolve_entry(JSContext *ctx, JSResolveState *s,
                             JSModuleDef *m, JSAtom name)
{
  JSResolveEntry *re;

  if (js_resize_array(ctx, (void **)&s->array,
                      sizeof(JSResolveEntry),
                      &s->size, s->count + 1))
    return -1;
  re = &s->array[s->count++];
  re->module = m;
  re->name = JS_DupAtom(ctx, name);
  return 0;
}

typedef enum JSResolveResultEnum {
  JS_RESOLVE_RES_EXCEPTION = -1, /* memory alloc error */
  JS_RESOLVE_RES_FOUND = 0,
  JS_RESOLVE_RES_NOT_FOUND,
  JS_RESOLVE_RES_CIRCULAR,
  JS_RESOLVE_RES_AMBIGUOUS,
} JSResolveResultEnum;

static JSResolveResultEnum js_resolve_export1(JSContext *ctx,
                                              JSModuleDef **pmodule,
                                              JSExportEntry **pme,
                                              JSModuleDef *m,
                                              JSAtom export_name,
                                              JSResolveState *s)
{
  JSExportEntry *me;

  *pmodule = NULL;
  *pme = NULL;
  if (find_resolve_entry(s, m, export_name) >= 0)
    return JS_RESOLVE_RES_CIRCULAR;
  if (add_resolve_entry(ctx, s, m, export_name) < 0)
    return JS_RESOLVE_RES_EXCEPTION;
  me = find_export_entry(ctx, m, export_name);
  if (me) {
    if (me->export_type == JS_EXPORT_TYPE_LOCAL) {
      /* local export */
      *pmodule = m;
      *pme = me;
      return JS_RESOLVE_RES_FOUND;
    } else {
      /* indirect export */
      JSModuleDef *m1;
      m1 = m->req_module_entries[me->u.req_module_idx].module;
      if (me->local_name == JS_ATOM__star_) {
        /* export ns from */
        *pmodule = m;
        *pme = me;
        return JS_RESOLVE_RES_FOUND;
      } else {
        return js_resolve_export1(ctx, pmodule, pme, m1,
                                  me->local_name, s);
      }
    }
  } else {
    if (export_name != JS_ATOM_default) {
      /* not found in direct or indirect exports: try star exports */
      int i;

      for(i = 0; i < m->star_export_entries_count; i++) {
        JSStarExportEntry *se = &m->star_export_entries[i];
        JSModuleDef *m1, *res_m;
        JSExportEntry *res_me;
        JSResolveResultEnum ret;

        m1 = m->req_module_entries[se->req_module_idx].module;
        ret = js_resolve_export1(ctx, &res_m, &res_me, m1,
                                 export_name, s);
        if (ret == JS_RESOLVE_RES_AMBIGUOUS ||
            ret == JS_RESOLVE_RES_EXCEPTION) {
          return ret;
        } else if (ret == JS_RESOLVE_RES_FOUND) {
          if (*pme != NULL) {
            if (*pmodule != res_m ||
                res_me->local_name != (*pme)->local_name) {
              *pmodule = NULL;
              *pme = NULL;
              return JS_RESOLVE_RES_AMBIGUOUS;
            }
          } else {
            *pmodule = res_m;
            *pme = res_me;
          }
        }
      }
      if (*pme != NULL)
        return JS_RESOLVE_RES_FOUND;
    }
    return JS_RESOLVE_RES_NOT_FOUND;
  }
}

/* If the return value is JS_RESOLVE_RES_FOUND, return the module
  (*pmodule) and the corresponding local export entry
  (*pme). Otherwise return (NULL, NULL) */
static JSResolveResultEnum js_resolve_export(JSContext *ctx,
                                             JSModuleDef **pmodule,
                                             JSExportEntry **pme,
                                             JSModuleDef *m,
                                             JSAtom export_name)
{
  JSResolveState ss, *s = &ss;
  int i;
  JSResolveResultEnum ret;

  s->array = NULL;
  s->size = 0;
  s->count = 0;

  ret = js_resolve_export1(ctx, pmodule, pme, m, export_name, s);

  for(i = 0; i < s->count; i++)
    JS_FreeAtom(ctx, s->array[i].name);
  js_free(ctx, s->array);

  return ret;
}

static void js_resolve_export_throw_error(JSContext *ctx,
                                          JSResolveResultEnum res,
                                          JSModuleDef *m, JSAtom export_name)
{
  char buf1[ATOM_GET_STR_BUF_SIZE];
  char buf2[ATOM_GET_STR_BUF_SIZE];
  switch(res) {
    case JS_RESOLVE_RES_EXCEPTION:
      break;
    default:
    case JS_RESOLVE_RES_NOT_FOUND:
      JS_ThrowSyntaxError(ctx, "Could not find export '%s' in module '%s'",
                          JS_AtomGetStr(ctx, buf1, sizeof(buf1), export_name),
                          JS_AtomGetStr(ctx, buf2, sizeof(buf2), m->module_name));
      break;
    case JS_RESOLVE_RES_CIRCULAR:
      JS_ThrowSyntaxError(ctx, "circular reference when looking for export '%s' in module '%s'",
                          JS_AtomGetStr(ctx, buf1, sizeof(buf1), export_name),
                          JS_AtomGetStr(ctx, buf2, sizeof(buf2), m->module_name));
      break;
    case JS_RESOLVE_RES_AMBIGUOUS:
      JS_ThrowSyntaxError(ctx, "export '%s' in module '%s' is ambiguous",
                          JS_AtomGetStr(ctx, buf1, sizeof(buf1), export_name),
                          JS_AtomGetStr(ctx, buf2, sizeof(buf2), m->module_name));
      break;
  }
}


typedef enum {
  EXPORTED_NAME_AMBIGUOUS,
  EXPORTED_NAME_NORMAL,
  EXPORTED_NAME_NS,
} ExportedNameEntryEnum;

typedef struct ExportedNameEntry {
  JSAtom export_name;
  ExportedNameEntryEnum export_type;
  union {
    JSExportEntry *me; /* using when the list is built */
    JSVarRef *var_ref; /* EXPORTED_NAME_NORMAL */
    JSModuleDef *module; /* for EXPORTED_NAME_NS */
  } u;
} ExportedNameEntry;

typedef struct GetExportNamesState {
  JSModuleDef **modules;
  int modules_size;
  int modules_count;

  ExportedNameEntry *exported_names;
  int exported_names_size;
  int exported_names_count;
} GetExportNamesState;

static int find_exported_name(GetExportNamesState *s, JSAtom name)
{
  int i;
  for(i = 0; i < s->exported_names_count; i++) {
    if (s->exported_names[i].export_name == name)
      return i;
  }
  return -1;
}

static __exception int get_exported_names(JSContext *ctx,
                                          GetExportNamesState *s,
                                          JSModuleDef *m, BOOL from_star)
{
  ExportedNameEntry *en;
  int i, j;

  /* check circular reference */
  for(i = 0; i < s->modules_count; i++) {
    if (s->modules[i] == m)
      return 0;
  }
  if (js_resize_array(ctx, (void **)&s->modules, sizeof(s->modules[0]),
                      &s->modules_size, s->modules_count + 1))
    return -1;
  s->modules[s->modules_count++] = m;

  for(i = 0; i < m->export_entries_count; i++) {
    JSExportEntry *me = &m->export_entries[i];
    if (from_star && me->export_name == JS_ATOM_default)
      continue;
    j = find_exported_name(s, me->export_name);
    if (j < 0) {
      if (js_resize_array(ctx, (void **)&s->exported_names, sizeof(s->exported_names[0]),
                          &s->exported_names_size,
                          s->exported_names_count + 1))
        return -1;
      en = &s->exported_names[s->exported_names_count++];
      en->export_name = me->export_name;
      /* avoid a second lookup for simple module exports */
      if (from_star || me->export_type != JS_EXPORT_TYPE_LOCAL)
        en->u.me = NULL;
      else
        en->u.me = me;
    } else {
      en = &s->exported_names[j];
      en->u.me = NULL;
    }
  }
  for(i = 0; i < m->star_export_entries_count; i++) {
    JSStarExportEntry *se = &m->star_export_entries[i];
    JSModuleDef *m1;
    m1 = m->req_module_entries[se->req_module_idx].module;
    if (get_exported_names(ctx, s, m1, TRUE))
      return -1;
  }
  return 0;
}

/* Unfortunately, the spec gives a different behavior from GetOwnProperty ! */
static int js_module_ns_has(JSContext *ctx, JSValueConst obj, JSAtom atom)
{
  return (find_own_property1(JS_VALUE_GET_OBJ(obj), atom) != NULL);
}

static const JSClassExoticMethods js_module_ns_exotic_methods = {
    .has_property = js_module_ns_has,
};

static int exported_names_cmp(const void *p1, const void *p2, void *opaque)
{
  JSContext *ctx = opaque;
  const ExportedNameEntry *me1 = p1;
  const ExportedNameEntry *me2 = p2;
  JSValue str1, str2;
  int ret;

  /* XXX: should avoid allocation memory in atom comparison */
  str1 = JS_AtomToString(ctx, me1->export_name);
  str2 = JS_AtomToString(ctx, me2->export_name);
  if (JS_IsException(str1) || JS_IsException(str2)) {
    /* XXX: raise an error ? */
    ret = 0;
  } else {
    ret = js_string_compare(ctx, JS_VALUE_GET_STRING(str1),
                            JS_VALUE_GET_STRING(str2));
  }
  JS_FreeValue(ctx, str1);
  JS_FreeValue(ctx, str2);
  return ret;
}

static JSValue js_get_module_ns(JSContext *ctx, JSModuleDef *m);

JSValue js_module_ns_autoinit(JSContext *ctx, JSObject *p, JSAtom atom,
                                     void *opaque)
{
  JSModuleDef *m = opaque;
  return js_get_module_ns(ctx, m);
}

static JSValue js_build_module_ns(JSContext *ctx, JSModuleDef *m)
{
  JSValue obj;
  JSObject *p;
  GetExportNamesState s_s, *s = &s_s;
  int i, ret;
  JSProperty *pr;

  obj = JS_NewObjectClass(ctx, JS_CLASS_MODULE_NS);
  if (JS_IsException(obj))
    return obj;
  p = JS_VALUE_GET_OBJ(obj);

  memset(s, 0, sizeof(*s));
  ret = get_exported_names(ctx, s, m, FALSE);
  js_free(ctx, s->modules);
  if (ret)
    goto fail;

  /* Resolve the exported names. The ambiguous exports are removed */
  for(i = 0; i < s->exported_names_count; i++) {
    ExportedNameEntry *en = &s->exported_names[i];
    JSResolveResultEnum res;
    JSExportEntry *res_me;
    JSModuleDef *res_m;

    if (en->u.me) {
      res_me = en->u.me; /* fast case: no resolution needed */
      res_m = m;
      res = JS_RESOLVE_RES_FOUND;
    } else {
      res = js_resolve_export(ctx, &res_m, &res_me, m,
                              en->export_name);
    }
    if (res != JS_RESOLVE_RES_FOUND) {
      if (res != JS_RESOLVE_RES_AMBIGUOUS) {
        js_resolve_export_throw_error(ctx, res, m, en->export_name);
        goto fail;
      }
      en->export_type = EXPORTED_NAME_AMBIGUOUS;
    } else {
      if (res_me->local_name == JS_ATOM__star_) {
        en->export_type = EXPORTED_NAME_NS;
        en->u.module = res_m->req_module_entries[res_me->u.req_module_idx].module;
      } else {
        en->export_type = EXPORTED_NAME_NORMAL;
        if (res_me->u.local.var_ref) {
          en->u.var_ref = res_me->u.local.var_ref;
        } else {
          JSObject *p1 = JS_VALUE_GET_OBJ(res_m->func_obj);
          p1 = JS_VALUE_GET_OBJ(res_m->func_obj);
          en->u.var_ref = p1->u.func.var_refs[res_me->u.local.var_idx];
        }
      }
    }
  }

  /* sort the exported names */
  rqsort(s->exported_names, s->exported_names_count,
         sizeof(s->exported_names[0]), exported_names_cmp, ctx);

  for(i = 0; i < s->exported_names_count; i++) {
    ExportedNameEntry *en = &s->exported_names[i];
    switch(en->export_type) {
      case EXPORTED_NAME_NORMAL:
      {
        JSVarRef *var_ref = en->u.var_ref;
        pr = add_property(ctx, p, en->export_name,
                          JS_PROP_ENUMERABLE | JS_PROP_WRITABLE |
                              JS_PROP_VARREF);
        if (!pr)
          goto fail;
        var_ref->header.ref_count++;
        pr->u.var_ref = var_ref;
      }
      break;
      case EXPORTED_NAME_NS:
        /* the exported namespace must be created on demand */
        if (JS_DefineAutoInitProperty(ctx, obj,
                                      en->export_name,
                                      JS_AUTOINIT_ID_MODULE_NS,
                                      en->u.module, JS_PROP_ENUMERABLE | JS_PROP_WRITABLE) < 0)
          goto fail;
        break;
      default:
        break;
    }
  }

  js_free(ctx, s->exported_names);

  JS_DefinePropertyValue(ctx, obj, JS_ATOM_Symbol_toStringTag,
                         JS_AtomToString(ctx, JS_ATOM_Module),
                         0);

  p->extensible = FALSE;
  return obj;
fail:
  js_free(ctx, s->exported_names);
  JS_FreeValue(ctx, obj);
  return JS_EXCEPTION;
}

static JSValue js_get_module_ns(JSContext *ctx, JSModuleDef *m)
{
  if (JS_IsUndefined(m->module_ns)) {
    JSValue val;
    val = js_build_module_ns(ctx, m);
    if (JS_IsException(val))
      return JS_EXCEPTION;
    m->module_ns = val;
  }
  return JS_DupValue(ctx, m->module_ns);
}

/* Load all the required modules for module 'm' */
int js_resolve_module(JSContext *ctx, JSModuleDef *m)
{
  int i;
  JSModuleDef *m1;

  if (m->resolved)
    return 0;
#ifdef DUMP_MODULE_RESOLVE
  {
    char buf1[ATOM_GET_STR_BUF_SIZE];
    printf("resolving module '%s':\n", JS_AtomGetStr(ctx, buf1, sizeof(buf1), m->module_name));
  }
#endif
  m->resolved = TRUE;
  /* resolve each requested module */
  for(i = 0; i < m->req_module_entries_count; i++) {
    JSReqModuleEntry *rme = &m->req_module_entries[i];
    m1 = js_host_resolve_imported_module_atom(ctx, m->module_name,
                                              rme->module_name);
    if (!m1)
      return -1;
    rme->module = m1;
    /* already done in js_host_resolve_imported_module() except if
       the module was loaded with JS_EvalBinary() */
    if (js_resolve_module(ctx, m1) < 0)
      return -1;
  }
  return 0;
}

static JSVarRef *js_create_module_var(JSContext *ctx, BOOL is_lexical)
{
  JSVarRef *var_ref;
  var_ref = js_malloc(ctx, sizeof(JSVarRef));
  if (!var_ref)
    return NULL;
  var_ref->header.ref_count = 1;
  if (is_lexical)
    var_ref->value = JS_UNINITIALIZED;
  else
    var_ref->value = JS_UNDEFINED;
  var_ref->pvalue = &var_ref->value;
  var_ref->is_detached = TRUE;
  add_gc_object(ctx->rt, &var_ref->header, JS_GC_OBJ_TYPE_VAR_REF);
  return var_ref;
}

/* Create the <eval> function associated with the module */
static int js_create_module_bytecode_function(JSContext *ctx, JSModuleDef *m)
{
  JSFunctionBytecode *b;
  int i;
  JSVarRef **var_refs;
  JSValue func_obj, bfunc;
  JSObject *p;

  bfunc = m->func_obj;
  func_obj = JS_NewObjectProtoClass(ctx, ctx->function_proto,
                                    JS_CLASS_BYTECODE_FUNCTION);

  if (JS_IsException(func_obj))
    return -1;
  b = JS_VALUE_GET_PTR(bfunc);

  p = JS_VALUE_GET_OBJ(func_obj);
  p->u.func.function_bytecode = b;
  b->header.ref_count++;
  p->u.func.home_object = NULL;
  p->u.func.var_refs = NULL;
  if (b->closure_var_count) {
    var_refs = js_mallocz(ctx, sizeof(var_refs[0]) * b->closure_var_count);
    if (!var_refs)
      goto fail;
    p->u.func.var_refs = var_refs;

    /* create the global variables. The other variables are
       imported from other modules */
    for(i = 0; i < b->closure_var_count; i++) {
      JSClosureVar *cv = &b->closure_var[i];
      JSVarRef *var_ref;
      if (cv->is_local) {
        var_ref = js_create_module_var(ctx, cv->is_lexical);
        if (!var_ref)
          goto fail;
#ifdef DUMP_MODULE_RESOLVE
        printf("local %d: %p\n", i, var_ref);
#endif
        var_refs[i] = var_ref;
      }
    }
  }
  m->func_obj = func_obj;
  JS_FreeValue(ctx, bfunc);
  return 0;
fail:
  JS_FreeValue(ctx, func_obj);
  return -1;
}

/* must be done before js_link_module() because of cyclic references */
int js_create_module_function(JSContext *ctx, JSModuleDef *m)
{
  BOOL is_c_module;
  int i;
  JSVarRef *var_ref;

  if (m->func_created)
    return 0;

  is_c_module = (m->init_func != NULL);

  if (is_c_module) {
    /* initialize the exported variables */
    for(i = 0; i < m->export_entries_count; i++) {
      JSExportEntry *me = &m->export_entries[i];
      if (me->export_type == JS_EXPORT_TYPE_LOCAL) {
        var_ref = js_create_module_var(ctx, FALSE);
        if (!var_ref)
          return -1;
        me->u.local.var_ref = var_ref;
      }
    }
  } else {
    if (js_create_module_bytecode_function(ctx, m))
      return -1;
  }
  m->func_created = TRUE;

  /* do it on the dependencies */

  for(i = 0; i < m->req_module_entries_count; i++) {
    JSReqModuleEntry *rme = &m->req_module_entries[i];
    if (js_create_module_function(ctx, rme->module) < 0)
      return -1;
  }

  return 0;
}


/* Prepare a module to be executed by resolving all the imported
   variables. */
int js_link_module(JSContext *ctx, JSModuleDef *m)
{
  int i;
  JSImportEntry *mi;
  JSModuleDef *m1;
  JSVarRef **var_refs, *var_ref;
  JSObject *p;
  BOOL is_c_module;
  JSValue ret_val;

  if (m->instantiated)
    return 0;
  m->instantiated = TRUE;

#ifdef DUMP_MODULE_RESOLVE
  {
    char buf1[ATOM_GET_STR_BUF_SIZE];
    printf("start instantiating module '%s':\n", JS_AtomGetStr(ctx, buf1, sizeof(buf1), m->module_name));
  }
#endif

  for(i = 0; i < m->req_module_entries_count; i++) {
    JSReqModuleEntry *rme = &m->req_module_entries[i];
    if (js_link_module(ctx, rme->module) < 0)
      goto fail;
  }

#ifdef DUMP_MODULE_RESOLVE
  {
    char buf1[ATOM_GET_STR_BUF_SIZE];
    printf("instantiating module '%s':\n", JS_AtomGetStr(ctx, buf1, sizeof(buf1), m->module_name));
  }
#endif
  /* check the indirect exports */
  for(i = 0; i < m->export_entries_count; i++) {
    JSExportEntry *me = &m->export_entries[i];
    if (me->export_type == JS_EXPORT_TYPE_INDIRECT &&
        me->local_name != JS_ATOM__star_) {
      JSResolveResultEnum ret;
      JSExportEntry *res_me;
      JSModuleDef *res_m, *m1;
      m1 = m->req_module_entries[me->u.req_module_idx].module;
      ret = js_resolve_export(ctx, &res_m, &res_me, m1, me->local_name);
      if (ret != JS_RESOLVE_RES_FOUND) {
        js_resolve_export_throw_error(ctx, ret, m, me->export_name);
        goto fail;
      }
    }
  }

#ifdef DUMP_MODULE_RESOLVE
  {
    printf("exported bindings:\n");
    for(i = 0; i < m->export_entries_count; i++) {
      JSExportEntry *me = &m->export_entries[i];
      printf(" name="); print_atom(ctx, me->export_name);
      printf(" local="); print_atom(ctx, me->local_name);
      printf(" type=%d idx=%d\n", me->export_type, me->u.local.var_idx);
    }
  }
#endif

  is_c_module = (m->init_func != NULL);

  if (!is_c_module) {
    p = JS_VALUE_GET_OBJ(m->func_obj);
    var_refs = p->u.func.var_refs;

    for(i = 0; i < m->import_entries_count; i++) {
      mi = &m->import_entries[i];
#ifdef DUMP_MODULE_RESOLVE
      printf("import var_idx=%d name=", mi->var_idx);
      print_atom(ctx, mi->import_name);
      printf(": ");
#endif
      m1 = m->req_module_entries[mi->req_module_idx].module;
      if (mi->import_name == JS_ATOM__star_) {
        JSValue val;
        /* name space import */
        val = js_get_module_ns(ctx, m1);
        if (JS_IsException(val))
          goto fail;
        set_value(ctx, &var_refs[mi->var_idx]->value, val);
#ifdef DUMP_MODULE_RESOLVE
        printf("namespace\n");
#endif
      } else {
        JSResolveResultEnum ret;
        JSExportEntry *res_me;
        JSModuleDef *res_m;
        JSObject *p1;

        ret = js_resolve_export(ctx, &res_m,
                                &res_me, m1, mi->import_name);
        if (ret != JS_RESOLVE_RES_FOUND) {
          js_resolve_export_throw_error(ctx, ret, m1, mi->import_name);
          goto fail;
        }
        if (res_me->local_name == JS_ATOM__star_) {
          JSValue val;
          JSModuleDef *m2;
          /* name space import from */
          m2 = res_m->req_module_entries[res_me->u.req_module_idx].module;
          val = js_get_module_ns(ctx, m2);
          if (JS_IsException(val))
            goto fail;
          var_ref = js_create_module_var(ctx, TRUE);
          if (!var_ref) {
            JS_FreeValue(ctx, val);
            goto fail;
          }
          set_value(ctx, &var_ref->value, val);
          var_refs[mi->var_idx] = var_ref;
#ifdef DUMP_MODULE_RESOLVE
          printf("namespace from\n");
#endif
        } else {
          var_ref = res_me->u.local.var_ref;
          if (!var_ref) {
            p1 = JS_VALUE_GET_OBJ(res_m->func_obj);
            var_ref = p1->u.func.var_refs[res_me->u.local.var_idx];
          }
          var_ref->header.ref_count++;
          var_refs[mi->var_idx] = var_ref;
#ifdef DUMP_MODULE_RESOLVE
          printf("local export (var_ref=%p)\n", var_ref);
#endif
        }
      }
    }

    /* keep the exported variables in the module export entries (they
       are used when the eval function is deleted and cannot be
       initialized before in case imports are exported) */
    for(i = 0; i < m->export_entries_count; i++) {
      JSExportEntry *me = &m->export_entries[i];
      if (me->export_type == JS_EXPORT_TYPE_LOCAL) {
        var_ref = var_refs[me->u.local.var_idx];
        var_ref->header.ref_count++;
        me->u.local.var_ref = var_ref;
      }
    }

    /* initialize the global variables */
    ret_val = JS_Call(ctx, m->func_obj, JS_TRUE, 0, NULL);
    if (JS_IsException(ret_val))
      goto fail;
    JS_FreeValue(ctx, ret_val);
  }

#ifdef DUMP_MODULE_RESOLVE
  printf("done instantiate\n");
#endif
  return 0;
fail:
  return -1;
}

/* return JS_ATOM_NULL if the name cannot be found. Only works with
   not striped bytecode functions. */
JSAtom JS_GetScriptOrModuleName(JSContext *ctx, int n_stack_levels)
{
  JSStackFrame *sf;
  JSFunctionBytecode *b;
  JSObject *p;
  /* XXX: currently we just use the filename of the englobing
     function. It does not work for eval(). Need to add a
     ScriptOrModule info in JSFunctionBytecode */
  sf = ctx->rt->current_stack_frame;
  if (!sf)
    return JS_ATOM_NULL;
  while (n_stack_levels-- > 0) {
    sf = sf->prev_frame;
    if (!sf)
      return JS_ATOM_NULL;
  }
  if (JS_VALUE_GET_TAG(sf->cur_func) != JS_TAG_OBJECT)
    return JS_ATOM_NULL;
  p = JS_VALUE_GET_OBJ(sf->cur_func);
  if (!js_class_has_bytecode(p->class_id))
    return JS_ATOM_NULL;
  b = p->u.func.function_bytecode;
  if (!b->has_debug)
    return JS_ATOM_NULL;
  return JS_DupAtom(ctx, b->debug.filename);
}

JSAtom JS_GetModuleName(JSContext *ctx, JSModuleDef *m)
{
  return JS_DupAtom(ctx, m->module_name);
}

JSValue JS_GetImportMeta(JSContext *ctx, JSModuleDef *m)
{
  JSValue obj;
  /* allocate meta_obj only if requested to save memory */
  obj = m->meta_obj;
  if (JS_IsUndefined(obj)) {
    obj = JS_NewObjectProto(ctx, JS_NULL);
    if (JS_IsException(obj))
      return JS_EXCEPTION;
    m->meta_obj = obj;
  }
  return JS_DupValue(ctx, obj);
}

JSValue js_import_meta(JSContext *ctx)
{
  JSAtom filename;
  JSModuleDef *m;

  filename = JS_GetScriptOrModuleName(ctx, 0);
  if (filename == JS_ATOM_NULL)
    goto fail;

  /* XXX: inefficient, need to add a module or script pointer in
     JSFunctionBytecode */
  m = js_find_loaded_module(ctx, filename);
  JS_FreeAtom(ctx, filename);
  if (!m) {
  fail:
    JS_ThrowTypeError(ctx, "import.meta not supported in this context");
    return JS_EXCEPTION;
  }
  return JS_GetImportMeta(ctx, m);
}

/* used by os.Worker() and import() */
JSModuleDef *JS_RunModule(JSContext *ctx, const char *basename,
                          const char *filename)
{
  JSModuleDef *m;
  JSValue ret, func_obj;

  m = js_host_resolve_imported_module(ctx, basename, filename);
  if (!m)
    return NULL;

  if (js_resolve_module(ctx, m) < 0) {
    js_free_modules(ctx, JS_FREE_MODULE_NOT_RESOLVED);
    return NULL;
  }

  /* Evaluate the module code */
  func_obj = JS_DupValue(ctx, JS_MKPTR(JS_TAG_MODULE, m));
  ret = JS_EvalFunction(ctx, func_obj);
  if (JS_IsException(ret))
    return NULL;
  JS_FreeValue(ctx, ret);
  return m;
}

static JSValue js_dynamic_import_job(JSContext *ctx,
                                     int argc, JSValueConst *argv)
{
  JSValueConst *resolving_funcs = argv;
  JSValueConst basename_val = argv[2];
  JSValueConst specifier = argv[3];
  JSModuleDef *m;
  const char *basename = NULL, *filename;
  JSValue ret, err, ns;

  if (!JS_IsString(basename_val)) {
    JS_ThrowTypeError(ctx, "no function filename for import()");
    goto exception;
  }
  basename = JS_ToCString(ctx, basename_val);
  if (!basename)
    goto exception;

  filename = JS_ToCString(ctx, specifier);
  if (!filename)
    goto exception;

  m = JS_RunModule(ctx, basename, filename);
  JS_FreeCString(ctx, filename);
  if (!m)
    goto exception;

  /* return the module namespace */
  ns = js_get_module_ns(ctx, m);
  if (JS_IsException(ns))
    goto exception;

  ret = JS_Call(ctx, resolving_funcs[0], JS_UNDEFINED,
                1, (JSValueConst *)&ns);
  JS_FreeValue(ctx, ret); /* XXX: what to do if exception ? */
  JS_FreeValue(ctx, ns);
  JS_FreeCString(ctx, basename);
  return JS_UNDEFINED;
exception:

  err = JS_GetException(ctx);
  ret = JS_Call(ctx, resolving_funcs[1], JS_UNDEFINED,
                1, (JSValueConst *)&err);
  JS_FreeValue(ctx, ret); /* XXX: what to do if exception ? */
  JS_FreeValue(ctx, err);
  JS_FreeCString(ctx, basename);
  return JS_UNDEFINED;
}

JSValue js_dynamic_import(JSContext *ctx, JSValueConst specifier)
{
  JSAtom basename;
  JSValue promise, resolving_funcs[2], basename_val;
  JSValueConst args[4];

  basename = JS_GetScriptOrModuleName(ctx, 0);
  if (basename == JS_ATOM_NULL)
    basename_val = JS_NULL;
  else
    basename_val = JS_AtomToValue(ctx, basename);
  JS_FreeAtom(ctx, basename);
  if (JS_IsException(basename_val))
    return basename_val;

  promise = JS_NewPromiseCapability(ctx, resolving_funcs);
  if (JS_IsException(promise)) {
    JS_FreeValue(ctx, basename_val);
    return promise;
  }

  args[0] = resolving_funcs[0];
  args[1] = resolving_funcs[1];
  args[2] = basename_val;
  args[3] = specifier;

  JS_EnqueueJob(ctx, js_dynamic_import_job, 4, args);

  JS_FreeValue(ctx, basename_val);
  JS_FreeValue(ctx, resolving_funcs[0]);
  JS_FreeValue(ctx, resolving_funcs[1]);
  return promise;
}

/* Run the <eval> function of the module and of all its requested
   modules. */
JSValue js_evaluate_module(JSContext *ctx, JSModuleDef *m)
{
  JSModuleDef *m1;
  int i;
  JSValue ret_val;

  if (m->eval_mark)
    return JS_UNDEFINED; /* avoid cycles */

  if (m->evaluated) {
    /* if the module was already evaluated, rethrow the exception
       it raised */
    if (m->eval_has_exception) {
      return JS_Throw(ctx, JS_DupValue(ctx, m->eval_exception));
    } else {
      return JS_UNDEFINED;
    }
  }

  m->eval_mark = TRUE;

  for(i = 0; i < m->req_module_entries_count; i++) {
    JSReqModuleEntry *rme = &m->req_module_entries[i];
    m1 = rme->module;
    if (!m1->eval_mark) {
      ret_val = js_evaluate_module(ctx, m1);
      if (JS_IsException(ret_val)) {
        m->eval_mark = FALSE;
        return ret_val;
      }
      JS_FreeValue(ctx, ret_val);
    }
  }

  if (m->init_func) {
    /* C module init */
    if (m->init_func(ctx, m) < 0)
      ret_val = JS_EXCEPTION;
    else
      ret_val = JS_UNDEFINED;
  } else {
    ret_val = JS_CallFree(ctx, m->func_obj, JS_UNDEFINED, 0, NULL);
    m->func_obj = JS_UNDEFINED;
  }
  if (JS_IsException(ret_val)) {
    /* save the thrown exception value */
    m->eval_has_exception = TRUE;
    m->eval_exception = JS_DupValue(ctx, ctx->rt->current_exception);
  }
  m->eval_mark = FALSE;
  m->evaluated = TRUE;
  return ret_val;
}

int JS_ResolveModule(JSContext *ctx, JSValueConst obj)
{
  if (JS_VALUE_GET_TAG(obj) == JS_TAG_MODULE) {
    JSModuleDef *m = JS_VALUE_GET_PTR(obj);
    if (js_resolve_module(ctx, m) < 0) {
      js_free_modules(ctx, JS_FREE_MODULE_NOT_RESOLVED);
      return -1;
    }
  }
  return 0;
}
