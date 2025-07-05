// native-filenames: Ruby gem for finding out where native methods are defined
// Copyright (c) 2025 Ivo Anjo <ivo@ivoanjo.me>
//
// This file is part of native-filenames.
//
// MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include "direct-bind.h"

#include "extconf.h" // This is needed for the HAVE_DLADDR and friends below

static VALUE get_native_filename(void *func);

VALUE filename_for(__attribute__((unused)) VALUE _self, VALUE klass, VALUE method) {
  direct_bind_cfunc_result result = direct_bind_get_cfunc(klass, SYM2ID(method), true);
  void *func = result.func;
  return get_native_filename(func);
}

void Init_native_filenames_extension(void) {
  VALUE native_filenames_module = rb_define_module("NativeFilenames");

  direct_bind_initialize(native_filenames_module, true);
  rb_define_singleton_method(native_filenames_module, "filename_for", filename_for, 2);
}

#if (defined(HAVE_DLADDR1) && HAVE_DLADDR1) || (defined(HAVE_DLADDR) && HAVE_DLADDR)
  #ifndef _GNU_SOURCE
    #define _GNU_SOURCE
  #endif
  #include <dlfcn.h>
  #if defined(HAVE_DLADDR1) && HAVE_DLADDR1
    #include <link.h>
  #endif

  static VALUE get_native_filename(void *func) {
    Dl_info info;
    const char *native_filename = NULL;
      #if defined(HAVE_DLADDR1) && HAVE_DLADDR1
      struct link_map *extra_info = NULL;
      if (dladdr1(func, &info, (void **) &extra_info, RTLD_DL_LINKMAP) != 0 && extra_info != NULL) {
        native_filename = extra_info->l_name != NULL ? extra_info->l_name : info.dli_fname;
      }
    #elif defined(HAVE_DLADDR) && HAVE_DLADDR
      if (dladdr(func, &info) != 0) {
        native_filename = info.dli_fname;
      }
    #endif
    return (native_filename != NULL && native_filename[0] != '\0') ? rb_utf8_str_new_cstr(native_filename) : Qnil;
  }
#elif defined(HAVE_WINDOWS_H) && HAVE_WINDOWS_H
  #include <windows.h>

  static VALUE get_native_filename(void *func) {
    const int max_path = 1024;
    char native_filename[max_path];
    HMODULE hMod = NULL;
    return (
      GetModuleHandleEx(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, (LPCSTR) func, &hMod) &&
      GetModuleFileNameA(hMod, native_filename, max_path) &&
      native_filename[0] != '\0'
    ) ? rb_utf8_str_new_cstr(native_filename) : Qnil;
  }
#else
  static VALUE get_native_filename(__attribute__((unused)) void *_func) {
    rb_raise(rb_eRuntimeError, "native-filenames failed: not supported on current OS. Please report to https://github.com/ivoanjo/native-filenames");
  }
#endif
