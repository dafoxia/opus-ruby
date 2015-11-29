require 'ffi'
require 'opus-ruby/version'
require 'opus-ruby/encoder'
require 'opus-ruby/decoder'

module Opus
  extend FFI::Library

  ffi_lib 'opus'

  module Constants
    OPUS_OK                               = 0
    OPUS_BAD_ARG                          = -1
    OPUS_BUFFER_TOO_SMALL                 = -2
    OPUS_INTERNAL_ERROR                   = -3
    OPUS_INVALID_PACKET                   = -4
    OPUS_UNIMPLEMENTED                    = -5
    OPUS_INVALID_STATE                    = -6
    OPUS_ALLOC_FAIL                       = -7
    
    
    OPUS_AUTO                             = -1000 # Auto/default setting @hideinitializer
    OPUS_BITRATE_MAX                      = -1    # Maximum bitrate @hideinitializer

    
    OPUS_BANDWIDTH_NARROWBAND             = 1101 # < 4 kHz bandpass @hideinitializer
    OPUS_BANDWIDTH_MEDIUMBAND             = 1102 # < 6 kHz bandpass @hideinitializer
    OPUS_BANDWIDTH_WIDEBAND               = 1103 # < 8 kHz bandpass @hideinitializer
    OPUS_BANDWIDTH_SUPERWIDEBAND          = 1104 # <12 kHz bandpass @hideinitializer
    OPUS_BANDWIDTH_FULLBAND               = 1105 # <20 kHz bandpass @hideinitializer
    
    OPUS_APPLICATION_VOIP                 = 2048
    OPUS_APPLICATION_AUDIO                = 2049
    OPUS_APPLICATION_RESTRICTED_LOWDELAY  = 2051
    
    OPUS_SIGNAL_VOICE                     = 3001
    OPUS_SIGNAL_MUSIC                     = 3002
    
    # WE SHOULD NOT USE NUMBERS (could change) (Begin) ------------------------------------------------------------------------
    OPUS_SET_APPLICATION_REQUEST          = 4000
    OPUS_GET_APPLICATION_REQUEST          = 4001
    OPUS_SET_BITRATE_REQUEST              = 4002
    OPUS_GET_BITRATE_REQUEST              = 4003
    OPUS_SET_MAX_BANDWIDTH_REQUEST        = 4004
    OPUS_GET_MAX_BANDWIDTH_REQUEST        = 4005
    OPUS_SET_VBR_REQUEST                  = 4006
    OPUS_GET_VBR_REQUEST                  = 4007
    OPUS_SET_BANDWIDTH_REQUEST            = 4008
    OPUS_GET_BANDWIDTH_REQUEST            = 4009
    OPUS_SET_COMPLEXITY_REQUEST           = 4010
    OPUS_GET_COMPLEXITY_REQUEST           = 4011
    OPUS_SET_INBAND_FEC_REQUEST           = 4012
    OPUS_GET_INBAND_FEC_REQUEST           = 4013
    OPUS_SET_PACKET_LOSS_PERC_REQUEST     = 4014
    OPUS_GET_PACKET_LOSS_PERC_REQUEST     = 4015
    OPUS_SET_DTX_REQUEST                  = 4016
    OPUS_GET_DTX_REQUEST                  = 4017
    
    
    OPUS_SET_VBR_CONSTRAINT_REQUEST       = 4020
    OPUS_GET_VBR_CONSTRAINT_REQUEST       = 4021
    OPUS_SET_FORCE_CHANNELS_REQUEST       = 4022
    OPUS_GET_FORCE_CHANNELS_REQUEST       = 4023
    OPUS_SET_SIGNAL_REQUEST               = 4024
    OPUS_GET_SIGNAL_REQUEST               = 4025
    
    OPUS_GET_LOOKAHEAD_REQUEST            = 4027
    OPUS_RESET_STATE                      = 4028 
    OPUS_GET_SAMPLE_RATE_REQUEST          = 4029

    OPUS_GET_FINAL_RANGE_REQUEST          = 4031

    OPUS_GET_PITCH_REQUEST                = 4033
    OPUS_SET_GAIN_REQUEST                 = 4034
    OPUS_GET_GAIN_REQUEST                 = 4045 # Should have been 4035
    OPUS_SET_LSB_DEPTH_REQUEST            = 4036
    OPUS_GET_LSB_DEPTH_REQUEST            = 4037

    OPUS_GET_LAST_PACKET_DURATION_REQUEST = 4039
    OPUS_SET_EXPERT_FRAME_DURATION_REQUEST= 4040
    OPUS_GET_EXPERT_FRAME_DURATION_REQUEST= 4041
    OPUS_SET_PREDICTION_DISABLED_REQUEST  = 4042
    OPUS_GET_PREDICTION_DISABLED_REQUEST  = 4043
    # WE SHOULD NOT USE NUMBERS (could change) (End) --------------------------------------------------------------------------
    
    
    OPUS_FRAMESIZE_ARG                    = 5000 # Select frame size from the argument (default) 
    OPUS_FRAMESIZE_2_5_MS                 = 5001 # Use 2.5 ms frames 
    OPUS_FRAMESIZE_5_MS                   = 5002 # Use 5 ms frames
    OPUS_FRAMESIZE_10_MS                  = 5003 # Use 10 ms frames 
    OPUS_FRAMESIZE_20_MS                  = 5004 # Use 20 ms frames 
    OPUS_FRAMESIZE_40_MS                  = 5005 # Use 40 ms frames 
    OPUS_FRAMESIZE_60_MS                  = 5006 # Use 60 ms frames 

  end 

  attach_function :opus_encoder_get_size, [:int], :int
  attach_function :opus_encoder_create, [:int32, :int, :int, :pointer], :pointer
  attach_function :opus_encoder_init, [:pointer, :int32, :int, :int], :int
  attach_function :opus_encode, [:pointer, :pointer, :int, :pointer, :int32], :int32
  attach_function :opus_encode_float, [:pointer, :pointer, :int, :pointer, :int32], :int32
  attach_function :opus_encoder_destroy, [:pointer], :void
  attach_function :opus_encoder_ctl, [:pointer, :int, :varargs], :int

  attach_function :opus_decoder_get_size, [:int], :int
  attach_function :opus_decoder_create, [:int32, :int, :pointer], :pointer
  attach_function :opus_decoder_init, [:pointer, :int32, :int], :int
  attach_function :opus_decode, [:pointer, :pointer, :int32, :pointer, :int, :int], :int
  attach_function :opus_decode_float, [:pointer, :pointer, :int32, :pointer, :int, :int], :int
  attach_function :opus_decoder_ctl, [:pointer, :int, :varargs], :int
  attach_function :opus_decoder_destroy, [:pointer], :void
  # attach_function :opus_packet_get_samples_per_frame, [:pointer, :int32], :int
end
