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
      opus_set_vbr_constraint value
      #Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_VBR_CONSTRAINT_REQUEST, :int32, value
    end
    
    def packet_loss_perc=(value)
      opus_set_packet_loss_perc value
      #Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_PACKET_LOSS_PERC, :int32, value
    end

    #Deprecated, use opus_set_bitrate=(value) instead for new projects
    def bitrate=(value)
      @bitrate = value
      opus_set_bitrate value
      #Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_BITRATE_REQUEST, :int32, value
    end

    #Deprecated, use opus_set_signal instead for new projects
    def signal=(value)
      @signal = value
      opus_set_signal value
      #Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_SIGNAL_REQUEST, :int32, value
    end
    
    def set_frame_size frame_size
       @frame_size = frame_size
    end

    def encode(data)
      @buf.put_string 0, data
      len = Opus.opus_encode @encoder, @buf, @frame_size, @out, @size
      @out.read_string len
    end

    # Gets the encoder's complexity configuration.
    # @see OPUS_SET_COMPLEXITY
    # @param[out] x <tt>opus_int32 #</tt>: Returns a value in the range 0-10,
    #                                      inclusive.
    def opus_get_complexity
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_COMPLEXITY_REQUEST
    end
    
    # Gets the encoder's bitrate configuration.
    # @see OPUS_SET_BITRATE
    # @param[out] x <tt>opus_int32 #</tt>: Returns the bitrate in bits per second.
    #                                      The default is determined based on the
    #                                      number of channels and the input
    #                                      sampling rate.
    def opus_get_bitrate
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_BITRATE_REQUEST
    end

    # Configures the encoder's computational complexity.
    # The supported range is 0-10 inclusive with 10 representing the highest complexity.
    # @see OPUS_GET_COMPLEXITY
    # @param[in] x <tt>opus_int32</tt>: Allowed values: 0-10, inclusive.
    def opus_set_complexity(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_COMPLEXITY_REQUEST, :int32, value
    end
    
    # Configures the bitrate in the encoder.
    # Rates from 500 to 512000 bits per second are meaningful, as well as the
    # special values #OPUS_AUTO and #OPUS_BITRATE_MAX.
    # The value #OPUS_BITRATE_MAX can be used to cause the codec to use as much
    # rate as it can, which is useful for controlling the rate by adjusting the
    # output buffer size.
    # @see OPUS_GET_BITRATE
    # @param[in] x <tt>opus_int32</tt>: Bitrate in bits per second. The default
    #                                   is determined based on the number of
    #                                   channels and the input sampling rate.
    def opus_set_bitrate(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_BITRATE_REQUEST, :int32, value
    end
    
    # Enables or disables variable bitrate (VBR) in the encoder.
    # The configured bitrate may not be met exactly because frames must
    # be an integer number of bytes in length.
    # @warning Only the MDCT mode of Opus can provide hard CBR behavior.
    # @see OPUS_GET_VBR
    # @see OPUS_SET_VBR_CONSTRAINT
    # <dl>
    # <dt>0</dt><dd>Hard CBR. For LPC/hybrid modes at very low bit-rate, this can
    #               cause noticeable quality degradation.</dd>
    # <dt>1</dt><dd>VBR (default). The exact type of VBR is controlled by
    #               #OPUS_SET_VBR_CONSTRAINT.</dd>
    # </dl>
    def opus_set_vbr(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_VBR_REQUEST, :int32, value
    end
    
    # Determine if variable bitrate (VBR) is enabled in the encoder.
    # @see OPUS_SET_VBR
    # @see OPUS_GET_VBR_CONSTRAINT
    # @param[out] x <tt>opus_int32 #</tt>: Returns one of the following values:
    # <dl>
    # <dt>0</dt><dd>Hard CBR.</dd>
    # <dt>1</dt><dd>VBR (default). The exact type of VBR may be retrieved via
    #               #OPUS_GET_VBR_CONSTRAINT.</dd>
    # </dl>
    def opus_get_vbr
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_VBR_REQUEST
    end
    
    # Enables or disables constrained VBR in the encoder.
    # This setting is ignored when the encoder is in CBR mode.
    # @warning Only the MDCT mode of Opus currently heeds the constraint.
    #  Speech mode ignores it completely, hybrid mode may fail to obey it
    #  if the LPC layer uses more bitrate than the constraint would have
    #  permitted.
    # @see OPUS_GET_VBR_CONSTRAINT
    # @see OPUS_SET_VBR
    # @param[in] x <tt>opus_int32</tt>: Allowed values:
    # <dl>
    # <dt>0</dt><dd>Unconstrained VBR.</dd>
    # <dt>1</dt><dd>Constrained VBR (default). This creates a maximum of one
    #               frame of buffering delay assuming a transport with a
    #               serialization speed of the nominal bitrate.</dd>
    # </dl>
    def opus_set_vbr_constraint(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_VBR_CONSTRAINT_REQUEST, :int32, value
    end

    # Determine if constrained VBR is enabled in the encoder.
    # @see OPUS_SET_VBR_CONSTRAINT
    # @see OPUS_GET_VBR
    # @param[out] x <tt>opus_int32 #</tt>: Returns one of the following values:
    # <dl>
    # <dt>0</dt><dd>Unconstrained VBR.</dd>
    # <dt>1</dt><dd>Constrained VBR (default).</dd>
    # </dl>
    def opus_get_vbr_constraint
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_VBR_CONSTRAINT_REQUEST
    end
    
    # Configures mono/stereo forcing in the encoder.
    # This can force the encoder to produce packets encoded as either mono or
    # stereo, regardless of the format of the input audio. This is useful when
    # the caller knows that the input signal is currently a mono source embedded
    # in a stereo stream.
    # @see OPUS_GET_FORCE_CHANNELS
    # @param[in] x <tt>opus_int32</tt>: Allowed values:
    # <dl>
    # <dt>#OPUS_AUTO</dt><dd>Not forced (default)</dd>
    # <dt>1</dt>         <dd>Forced mono</dd>
    # <dt>2</dt>         <dd>Forced stereo</dd>
    #* </dl>
    def opus_set_force_cannels(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_FORCE_CHANNELS_REQUEST, :int32, value
    end
    
    # Gets the encoder's forced channel configuration.
    # @see OPUS_SET_FORCE_CHANNELS
    # @param[out] x <tt>opus_int32 #</tt>:
    # <dl>
    # <dt>#OPUS_AUTO</dt><dd>Not forced (default)</dd>
    # <dt>1</dt>         <dd>Forced mono</dd>
    # <dt>2</dt>         <dd>Forced stereo</dd>
    # </dl>
    #define OPUS_GET_FORCE_CHANNELS(x) OPUS_GET_FORCE_CHANNELS_REQUEST, __opus_check_int_ptr(x)
    def opus_get_force_channels
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_FORCE_CHANNELS_REQUEST
    end

    # Configures the maximum bandpass that the encoder will select automatically.
    # Applications should normally use this instead of #OPUS_SET_BANDWIDTH
    # (leaving that set to the default, #OPUS_AUTO). This allows the
    # application to set an upper bound based on the type of input it is
    # providing, but still gives the encoder the freedom to reduce the bandpass
    # when the bitrate becomes too low, for better overall quality.
    # @see OPUS_GET_MAX_BANDWIDTH
    # @param[in] x <tt>opus_int32</tt>: Allowed values:
    # <dl>
    # <dt>OPUS_BANDWIDTH_NARROWBAND</dt>    <dd>4 kHz passband</dd>
    # <dt>OPUS_BANDWIDTH_MEDIUMBAND</dt>    <dd>6 kHz passband</dd>
    # <dt>OPUS_BANDWIDTH_WIDEBAND</dt>      <dd>8 kHz passband</dd>
    # <dt>OPUS_BANDWIDTH_SUPERWIDEBAND</dt><dd>12 kHz passband</dd>
    # <dt>OPUS_BANDWIDTH_FULLBAND</dt>     <dd>20 kHz passband (default)</dd>
    # </dl>
    #define OPUS_SET_MAX_BANDWIDTH(x) OPUS_SET_MAX_BANDWIDTH_REQUEST, __opus_check_int(x)
    def opus_set_max_bandwidth(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_MAX_BANDWIDTH_REQUEST, :int32, value
    end

    # Gets the encoder's configured maximum allowed bandpass.
    # @see OPUS_SET_MAX_BANDWIDTH
    # @param[out] x <tt>opus_int32 #</tt>: Allowed values:
    # <dl>
    # <dt>#OPUS_BANDWIDTH_NARROWBAND</dt>    <dd>4 kHz passband</dd>
    # <dt>#OPUS_BANDWIDTH_MEDIUMBAND</dt>    <dd>6 kHz passband</dd>
    # <dt>#OPUS_BANDWIDTH_WIDEBAND</dt>      <dd>8 kHz passband</dd>
    # <dt>#OPUS_BANDWIDTH_SUPERWIDEBAND</dt><dd>12 kHz passband</dd>
    # <dt>#OPUS_BANDWIDTH_FULLBAND</dt>     <dd>20 kHz passband (default)</dd>
    # </dl>
    #define OPUS_GET_MAX_BANDWIDTH(x) OPUS_GET_MAX_BANDWIDTH_REQUEST, __opus_check_int_ptr(x)
    def opus_get_max_bandwidth
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_MAX_BANDWIDTH_REQUEST
    end

    # Sets the encoder's bandpass to a specific value.
    # This prevents the encoder from automatically selecting the bandpass based
    # on the available bitrate. If an application knows the bandpass of the input
    # audio it is providing, it should normally use #OPUS_SET_MAX_BANDWIDTH
    # instead, which still gives the encoder the freedom to reduce the bandpass
    # when the bitrate becomes too low, for better overall quality.
    # @see OPUS_GET_BANDWIDTH
    # @param[in] x <tt>opus_int32</tt>: Allowed values:
    # <dl>
    # <dt>#OPUS_AUTO</dt>                    <dd>(default)</dd>
    # <dt>#OPUS_BANDWIDTH_NARROWBAND</dt>    <dd>4 kHz passband</dd>
    # <dt>#OPUS_BANDWIDTH_MEDIUMBAND</dt>    <dd>6 kHz passband</dd>
    # <dt>#OPUS_BANDWIDTH_WIDEBAND</dt>      <dd>8 kHz passband</dd>
    # <dt>#OPUS_BANDWIDTH_SUPERWIDEBAND</dt><dd>12 kHz passband</dd>
    # <dt>#OPUS_BANDWIDTH_FULLBAND</dt>     <dd>20 kHz passband</dd>
    # </dl>
    #define OPUS_SET_BANDWIDTH(x) OPUS_SET_BANDWIDTH_REQUEST, __opus_check_int(x)
    def opus_set_bandwidth(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_BANDWIDTH_REQUEST, :int32, value
    end
    
    # Configures the type of signal being encoded.
    # This is a hint which helps the encoder's mode selection.
    # @see OPUS_GET_SIGNAL
    # @param[in] x <tt>opus_int32</tt>: Allowed values:
    # <dl>
    # <dt>#OPUS_AUTO</dt>        <dd>(default)</dd>
    # <dt>#OPUS_SIGNAL_VOICE</dt><dd>Bias thresholds towards choosing LPC or Hybrid modes.</dd>
    # <dt>#OPUS_SIGNAL_MUSIC</dt><dd>Bias thresholds towards choosing MDCT modes.</dd>
    # </dl>
    #define OPUS_SET_SIGNAL(x) OPUS_SET_SIGNAL_REQUEST, __opus_check_int(x)
    def opus_set_signal(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_SIGNAL_REQUEST, :int32, value
    end
    
    # Gets the encoder's configured signal type.
    # @see OPUS_SET_SIGNAL
    # @param[out] x <tt>opus_int32 #</tt>: Returns one of the following values:
    # <dl>
    # <dt>#OPUS_AUTO</dt>        <dd>(default)</dd>
    # <dt>#OPUS_SIGNAL_VOICE</dt><dd>Bias thresholds towards choosing LPC or Hybrid modes.</dd>
    # <dt>#OPUS_SIGNAL_MUSIC</dt><dd>Bias thresholds towards choosing MDCT modes.</dd>
    # </dl>
    #define OPUS_GET_SIGNAL(x) OPUS_GET_SIGNAL_REQUEST, __opus_check_int_ptr(x)
    def opus_get_signal
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_SIGNAL_REQUEST
    end

    # Configures the encoder's intended application.
    # The initial value is a mandatory argument to the encoder_create function.
    # @see OPUS_GET_APPLICATION
    # @param[in] x <tt>opus_int32</tt>: Returns one of the following values:
    # <dl>
    # <dt>#OPUS_APPLICATION_VOIP</dt>
    # <dd>Process signal for improved speech intelligibility.</dd>
    # <dt>#OPUS_APPLICATION_AUDIO</dt>
    # <dd>Favor faithfulness to the original input.</dd>
    # <dt>#OPUS_APPLICATION_RESTRICTED_LOWDELAY</dt>
    # <dd>Configure the minimum possible coding delay by disabling certain modes
    # of operation.</dd>
    # </dl>
    #define OPUS_SET_APPLICATION(x) OPUS_SET_APPLICATION_REQUEST, __opus_check_int(x)
    def opus_set_application(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_APPLICATION_REQUEST, :int32, value
    end
    
    # Gets the encoder's configured application.
    # @see OPUS_SET_APPLICATION
    # @param[out] x <tt>opus_int32 #</tt>: Returns one of the following values:
    # <dl>
    # <dt>#OPUS_APPLICATION_VOIP</dt>
    # <dd>Process signal for improved speech intelligibility.</dd>
    # <dt>#OPUS_APPLICATION_AUDIO</dt>
    # <dd>Favor faithfulness to the original input.</dd>
    # <dt>#OPUS_APPLICATION_RESTRICTED_LOWDELAY</dt>
    # <dd>Configure the minimum possible coding delay by disabling certain modes
    # of operation.</dd>
    # </dl>
    #define OPUS_GET_APPLICATION(x) OPUS_GET_APPLICATION_REQUEST, __opus_check_int_ptr(x)
    def opus_get_application
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_APPLICATION_REQUEST, :int32, value
    end

    # Gets the sampling rate the encoder or decoder was initialized with.
    # This simply returns the <code>Fs</code> value passed to opus_encoder_init()
    # or opus_decoder_init().
    # @param[out] x <tt>opus_int32 #</tt>: Sampling rate of encoder or decoder.
    # 
    #
    #define OPUS_GET_SAMPLE_RATE(x) OPUS_GET_SAMPLE_RATE_REQUEST, __opus_check_int_ptr(x)
    def opus_encoder_get_sample_rate
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_SAMPLE_RATE_REQUEST
    end

    # Gets the total samples of delay added by the entire codec.
    # This can be queried by the encoder and then the provided number of samples can be
    # skipped on from the start of the decoder's output to provide time aligned input
    # and output. From the perspective of a decoding application the real data begins this many
    # samples late.
    #
    # The decoder contribution to this delay is identical for all decoders, but the
    # encoder portion of the delay may vary from implementation to implementation,
    # version to version, or even depend on the encoder's initial configuration.
    # Applications needing delay compensation should call this CTL rather than
    # hard-coding a value.
    # @param[out] x <tt>opus_int32 #</tt>:   Number of lookahead samples
    #define OPUS_GET_LOOKAHEAD(x) OPUS_GET_LOOKAHEAD_REQUEST, __opus_check_int_ptr(x)
    def opus_get_lookahead
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_LOOKAHEAD_REQUEST
    end

    # Configures the encoder's use of inband forward error correction (FEC).
    # @note This is only applicable to the LPC layer
    # @see OPUS_GET_INBAND_FEC
    # @param[in] x <tt>opus_int32</tt>: Allowed values:
    # <dl>
    # <dt>0</dt><dd>Disable inband FEC (default).</dd>
    # <dt>1</dt><dd>Enable inband FEC.</dd>
    # </dl>
    #define OPUS_SET_INBAND_FEC(x) OPUS_SET_INBAND_FEC_REQUEST, __opus_check_int(x)
    def opus_set_inband_fec(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_INBAND_FEC_REQUEST, :int32, value
    end
    
    # Gets encoder's configured use of inband forward error correction.
    # @see OPUS_SET_INBAND_FEC
    # @param[out] x <tt>opus_int32 #</tt>: Returns one of the following values:
    # <dl>
    # <dt>0</dt><dd>Inband FEC disabled (default).</dd>
    # <dt>1</dt><dd>Inband FEC enabled.</dd>
    # </dl>
    #define OPUS_GET_INBAND_FEC(x) OPUS_GET_INBAND_FEC_REQUEST, __opus_check_int_ptr(x)
    def opus_get_inband_fec
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_INBAND_FEC_REQUEST
    end
    
    # Configures the encoder's expected packet loss percentage.
    # Higher values with trigger progressively more loss resistant behavior in the encoder
    # at the expense of quality at a given bitrate in the lossless case, but greater quality
    # under loss.
    # @see OPUS_GET_PACKET_LOSS_PERC
    # @param[in] x <tt>opus_int32</tt>:   Loss percentage in the range 0-100, inclusive (default: 0).
    #define OPUS_SET_PACKET_LOSS_PERC(x) OPUS_SET_PACKET_LOSS_PERC_REQUEST, __opus_check_int(x)
    def opus_set_packet_loss_perc(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_PACKET_LOSS_PERC_REQUEST, :int32, value
    end
    
    # Gets the encoder's configured packet loss percentage.
    # @see OPUS_SET_PACKET_LOSS_PERC
    # @param[out] x <tt>opus_int32 #</tt>: Returns the configured loss percentage
    #                                      in the range 0-100, inclusive (default: 0).
    #define OPUS_GET_PACKET_LOSS_PERC(x) OPUS_GET_PACKET_LOSS_PERC_REQUEST, __opus_check_int_ptr(x)
    def opus_get_packet_loss_perc
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_PACKET_LOSS_PERC_REQUEST
    end

    # Configures the encoder's use of discontinuous transmission (DTX).
    # @note This is only applicable to the LPC layer
    # @see OPUS_GET_DTX
    # @param[in] x <tt>opus_int32</tt>: Allowed values:
    # <dl>
    # <dt>0</dt><dd>Disable DTX (default).</dd>
    # <dt>1</dt><dd>Enabled DTX.</dd>
    # </dl>
    #define OPUS_SET_DTX(x) OPUS_SET_DTX_REQUEST, __opus_check_int(x)
    def opus_set_dtx(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_DTX_REQUEST, :int32, value
    end
    
    # Gets encoder's configured use of discontinuous transmission.
    # @see OPUS_SET_DTX
    # @param[out] x <tt>opus_int32 #</tt>: Returns one of the following values:
    # <dl>
    # <dt>0</dt><dd>DTX disabled (default).</dd>
    # <dt>1</dt><dd>DTX enabled.</dd>
    # </dl>
    #define OPUS_GET_DTX(x) OPUS_GET_DTX_REQUEST, __opus_check_int_ptr(x)
    def opus_get_dtx
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_DTX_REQUEST
    end
    
    # Configures the depth of signal being encoded.
    # This is a hint which helps the encoder identify silence and near-silence.
    # @see OPUS_GET_LSB_DEPTH
    # @param[in] x <tt>opus_int32</tt>: Input precision in bits, between 8 and 24
    #                                   (default: 24).
    #define OPUS_SET_LSB_DEPTH(x) OPUS_SET_LSB_DEPTH_REQUEST, __opus_check_int(x)
    def opus_set_lsb_depth(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_LSB_DEPTH_REQUEST, :int32, value
    end
    
    # Gets the encoder's configured signal depth.
    # @see OPUS_SET_LSB_DEPTH
    # @param[out] x <tt>opus_int32 #</tt>: Input precision in bits, between 8 and
    #                                      24 (default: 24).
    #define OPUS_GET_LSB_DEPTH(x) OPUS_GET_LSB_DEPTH_REQUEST, __opus_check_int_ptr(x)
    def opus_get_lsb_depth
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_LSB_DEPTH_REQUEST
    end

    # Gets the duration (in samples) of the last packet successfully decoded or concealed.
    # @param[out] x <tt>opus_int32 #</tt>: Number of samples (at current sampling rate).
    #define OPUS_GET_LAST_PACKET_DURATION(x) OPUS_GET_LAST_PACKET_DURATION_REQUEST, __opus_check_int_ptr(x)
    def opus_get_last_packet_duration
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_LAST_PACKET_DURATION_REQUEST
    end

    # Configures the encoder's use of variable duration frames.
    # When variable duration is enabled, the encoder is free to use a shorter frame
    # size than the one requested in the opus_encode#() call.
    # It is then the user's responsibility
    # to verify how much audio was encoded by checking the ToC byte of the encoded
    # packet. The part of the audio that was not encoded needs to be resent to the
    # encoder for the next call. Do not use this option unless you <b>really</b>
    # know what you are doing.
    # @see OPUS_GET_EXPERT_VARIABLE_DURATION
    # @param[in] x <tt>opus_int32</tt>: Allowed values:
    # <dl>
    # <dt>OPUS_FRAMESIZE_ARG</dt><dd>Select frame size from the argument (default).</dd>
    # <dt>OPUS_FRAMESIZE_2_5_MS</dt><dd>Use 2.5 ms frames.</dd>
    # <dt>OPUS_FRAMESIZE_5_MS</dt><dd>Use 2.5 ms frames.</dd>
    # <dt>OPUS_FRAMESIZE_10_MS</dt><dd>Use 10 ms frames.</dd>
    # <dt>OPUS_FRAMESIZE_20_MS</dt><dd>Use 20 ms frames.</dd>
    # <dt>OPUS_FRAMESIZE_40_MS</dt><dd>Use 40 ms frames.</dd>
    # <dt>OPUS_FRAMESIZE_60_MS</dt><dd>Use 60 ms frames.</dd>
    # <dt>OPUS_FRAMESIZE_VARIABLE</dt><dd>Optimize the frame size dynamically.</dd>
    # </dl>
    #define OPUS_SET_EXPERT_FRAME_DURATION(x) OPUS_SET_EXPERT_FRAME_DURATION_REQUEST, __opus_check_int(x)
    def opus_set_expert_frame_duration(value)
       Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_EXPERT_FRAME_DURATION_REQUEST, :int32, value
    end
    
    # Gets the encoder's configured use of variable duration frames.
    # @see OPUS_SET_EXPERT_VARIABLE_DURATION
    # @param[out] x <tt>opus_int32 #</tt>: Returns one of the following values:
    # <dl>
    # <dt>OPUS_FRAMESIZE_ARG</dt><dd>Select frame size from the argument (default).</dd>
    # <dt>OPUS_FRAMESIZE_2_5_MS</dt><dd>Use 2.5 ms frames.</dd>
    # <dt>OPUS_FRAMESIZE_5_MS</dt><dd>Use 2.5 ms frames.</dd>
    # <dt>OPUS_FRAMESIZE_10_MS</dt><dd>Use 10 ms frames.</dd>
    # <dt>OPUS_FRAMESIZE_20_MS</dt><dd>Use 20 ms frames.</dd>
    # <dt>OPUS_FRAMESIZE_40_MS</dt><dd>Use 40 ms frames.</dd>
    # <dt>OPUS_FRAMESIZE_60_MS</dt><dd>Use 60 ms frames.</dd>
    # <dt>OPUS_FRAMESIZE_VARIABLE</dt><dd>Optimize the frame size dynamically.</dd>
    # </dl>
    #define OPUS_GET_EXPERT_FRAME_DURATION(x) OPUS_GET_EXPERT_FRAME_DURATION_REQUEST, __opus_check_int_ptr(x)
    def opus_get_expert_frame_duration
       Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_EXPERT_FRAME_DURATION_REQUEST    
    end

    # If set to 1, disables almost all use of prediction, making frames almost completely independent. This reduces quality. (default : 0)
    #define OPUS_SET_PREDICTION_DISABLED(x) OPUS_SET_PREDICTION_DISABLED_REQUEST, __opus_check_int(x)
    def opus_set_prediction_disabled(value)
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_SET_PREDICTION_DISABLED_REQUEST, :int32, value
    end

    # Gets the encoder's configured prediction status.
    #define OPUS_GET_PREDICTION_DISABLED(x) OPUS_GET_PREDICTION_DISABLED_REQUEST, __opus_check_int_ptr(x)
    def opus_get_prediction_disabled
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_PREDICTION_DISABLED_REQUEST  
    end
    
    # Gets the encoder's configured bandpass.
    # @see OPUS_SET_BANDWIDTH
    # @param[out] x <tt>opus_int32 #</tt>: Returns one of the following values:
    # <dl>
    # <dt>#OPUS_AUTO</dt>                    <dd>(default)</dd>
    # <dt>#OPUS_BANDWIDTH_NARROWBAND</dt>    <dd>4 kHz passband</dd>
    # <dt>#OPUS_BANDWIDTH_MEDIUMBAND</dt>    <dd>6 kHz passband</dd>
    # <dt>#OPUS_BANDWIDTH_WIDEBAND</dt>      <dd>8 kHz passband</dd>
    # <dt>#OPUS_BANDWIDTH_SUPERWIDEBAND</dt><dd>12 kHz passband</dd>
    # <dt>#OPUS_BANDWIDTH_FULLBAND</dt>     <dd>20 kHz passband</dd>
    # </dl>
    #define OPUS_GET_BANDWIDTH(x) OPUS_GET_BANDWIDTH_REQUEST, __opus_check_int_ptr(x)
    def opus_encoder_get_bandwidth
      Opus.opus_encoder_ctl @encoder, Opus::Constants::OPUS_GET_BANDWIDTH_REQUEST
    end

  end
end
