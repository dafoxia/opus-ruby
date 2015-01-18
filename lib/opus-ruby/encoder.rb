module Opus
  class Encoder
    attr_reader :sample_rate, :frame_size, :channels,
                :vbr_rate, :bitrate, :signal

    def initialize(sample_rate, frame_size, channels, size)
      @sample_rate = sample_rate
      @frame_size = frame_size
      @channels = channels
      @size = size
      @buf = FFI::MemoryPointer.new :char, @size + 1
      @out = FFI::MemoryPointer.new :char, @size + 1
      @encoder = Opus.opus_encoder_create sample_rate, channels, Constants::OPUS_APPLICATION_AUDIO, nil
    end

    def destroy
      @buf.free
      @out.free
      Opus.opus_encoder_destroy @encoder
    end

    def reset
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_RESET_STATE, :pointer, nil
    end

    def vbr_rate=(value)
      @vbr_rate = value
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_VBR_REQUEST, :int32, value
    end

    def bitrate=(value)
      @bitrate = value
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_BITRATE_REQUEST, :int32, value
    end

    def signal=(value)
      @signal = value
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_SIGNAL_REQUEST, :int32, value
    end

    def encode(data)
      @buf.put_string 0, data
      len = Opus.opus_encode @encoder, @buf, @frame_size, @out, @size
      @out.read_string len
    end
  end
end
