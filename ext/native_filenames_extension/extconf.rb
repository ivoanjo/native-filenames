# native-filenames: Ruby gem for finding out where native methods are defined
# Copyright (c) 2025 Ivo Anjo <ivo@ivoanjo.me>
#
# This file is part of native-filenames.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

if ["jruby", "truffleruby"].include?(RUBY_ENGINE)
  raise \
    "\n#{"-" * 80}\nSorry! This gem is unsupported on #{RUBY_ENGINE}. Since it relies on a lot of guts of MRI Ruby, " \
    "it's impossible to make a direct port.\n" \
    "Perhaps a #{RUBY_ENGINE} equivalent could be created -- help is welcome! :)\n#{"-" * 80}"
end

require "mkmf"

append_cflags("-std=gnu99")
append_cflags("-Wno-declaration-after-statement")
append_cflags("-Wno-compound-token-split-by-macro")
append_cflags("-Werror-implicit-function-declaration")
append_cflags("-Wunused-parameter")
append_cflags("-Wold-style-definition")
append_cflags("-Wall")
append_cflags("-Wextra")
append_cflags("-Werror") if ENV["ENABLE_WERROR"] == "true"

# Used to get native filenames (dladdr1 is preferred, so we only check for the other if not available)
# Note it's possible none are available
if have_header("dlfcn.h")
  (have_struct_member("struct link_map", "l_name", "link.h") && have_func("dladdr1")) || have_func("dladdr")
else
  have_header("windows.h")
end

create_header
create_makefile "native_filenames_extension"
