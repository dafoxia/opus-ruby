#################################################################################
# The MIT License (MIT)                                                         #
#                                                                               #
# Copyright (c) 2014, Aaron Herting 'qwertos' <aaron@herting.cc>                #
# Copyright (c) 2015, dafoxia <dafoxia@mail.austria.com>                        #
# Heavily based on code (c) GitHub User 'perrym5' and code found in the         #
# libopus public documentation.                                                 #
#                                                                               #
# Permission is hereby granted, free of charge, to any person obtaining a copy  #
# of this software and associated documentation files (the "Software"), to deal #
# in the Software without restriction, including without limitation the rights  #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     #
# copies of the Software, and to permit persons to whom the Software is         #
# furnished to do so, subject to the following conditions:                      #
#                                                                               #
# The above copyright notice and this permission notice shall be included in    #
# all copies or substantial portions of the Software.                           #
#                                                                               #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN     #
# THE SOFTWARE.                                                                 #
#################################################################################



module Opus
  class Decoder
    attr_reader :sample_rate, :frame_size, :channels, :lasterror

    def initialize(sample_rate, frame_size, channels)
      @sample_rate = sample_rate
      @frame_size = frame_size
      @channels = channels
      @lasterror = 0

      @decoder = Opus.opus_decoder_create sample_rate, channels, nil
    end

    def destroy
      Opus.opus_decoder_destroy @decoder
    end

    def reset
      Opus.opus_decoder_ctl @decoder, Opus::Constants::OPUS_RESET_STATE, :pointer, nil
    end

    def decode(data)
      len = data.size

      packet = FFI::MemoryPointer.new :char, len + 1
      packet.put_string 0, data

      max_size = @frame_size * @channels * 2 # Was getting buffer_too_small errors without the 2
      decoded = FFI::MemoryPointer.new :short, max_size + 1

      frame_size = Opus.opus_decode @decoder, packet, len, decoded, max_size, 0
      if frame_size < 0
        @lasterror = frame_size
        frame_size = 0
      end
      decoded.read_string frame_size * 2
    end

    def decode_missed
      Opus.opus_decode @decoder, nil, 0, nil, 0, 0
    end

    # <b>DEPRECATED:</b> Please use <tt>lasterror</tt> instead.
    def get_lasterror_code
      warn "[DEPRECATION] `get_lasterror_code` is deprecated.  Please use `lasterror` instead."
      @lasterror
    end

    def get_lasterror_string
      case @lasterror
        when  0 then "OK"
        when -1 then "BAD ARG"
        when -2 then "BUFFER TOO SMALL"
        when -3 then "INTERNAL ERROR"
        when -4	then "INVALID PACKET"
        when -5 then "UNIMPLEMENTED"
        when -6 then "INVALID STATE"
        when -7	then "ALLOC FAIL"
        else "UNKNOWN ERROR / ERROR NOT DEFINED (should never happen)"
      end
    end
    
    
  end
end

