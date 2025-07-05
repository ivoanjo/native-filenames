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

# frozen_string_literal: true

require "native-filenames"
require "direct_bind/rspec_helper"

RSpec.describe NativeFilenames do
  describe ".filename_for" do
    context "for a native method in the standard library" do
      # Note: It's possible to build Ruby without a libruby, or in other weird configurations
      it do
        expect(NativeFilenames.filename_for(Array, :each)).to(
          include("/libruby.so.")
          .or(match(/\/libruby([.]\d?){0,3}\.dylib/)
          .or(match(/ruby\d+\.dll/)
          .or(end_with("/ruby"))))
        )
      end
    end

    context "for a native method in a third-party library" do
      require "bigdecimal"

      it do
        expect(NativeFilenames.filename_for(BigDecimal.singleton_class, :save_rounding_mode)).to(
          end_with("bigdecimal.so")
          .or(end_with("/bigdecimal.bundle"))
        )
      end
    end

    context "for a native method in the current gem" do
      it do
        expect(NativeFilenames.filename_for(NativeFilenames.singleton_class, :filename_for)).to( # ;)
          end_with("native_filenames_extension.so")
          .or(end_with("/native_filenames_extension.bundle"))
        )
      end
    end

    context "for a method that is not native" do
      it do
        expect { NativeFilenames.filename_for(RSpec.singleton_class, :describe) }.to raise_error(RuntimeError, /not a cfunc/)
      end
    end
  end

  it "uses the correct direct-bind gem version" do
    DirectBind::RSpecHelper.expect_direct_bind_version_to_be_up_to_date_in(NativeFilenames)
  end
end
