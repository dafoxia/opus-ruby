module Opus
  class Encoder
    attr_reader :sample_rate, :frame_size, :channels,
                :vbr_rate, :vbr_constraint, :bitrate, :signal

    def initialize(sample_rate, frame_size, channels, size)
      @vbr_constraint= 0
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
    
    def vbr_contstraint=(value)
      @vbr_constraint = value
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_VBR_CONSTRAINT_REQUEST, :int32, value
    end
    
    def packet_loss_perc=(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_PACKET_LOSS_PERC, :int32, value
    end

    def bitrate=(value)
      @bitrate = value
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_BITRATE_REQUEST, :int32, value
    end

    def signal=(value)
      @signal = value
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_SIGNAL_REQUEST, :int32, value
    end
    
    def set_frame_size frame_size
       @frame_size = frame_size
    end

    def encode(data)
      @buf.put_string 0, data
      len = Opus.opus_encode @encoder, @buf, @frame_size, @out, @size
      @out.read_string len
    end
  end
end
