extends AudioStreamPlayer

"""
	AudioStreamPlayer with ADSR
"""

var releasing = false
var instrument = null
var velocity = 0
var pitch_bend = 0
var mix_rate = 0
var using_timer = 0.0
var timer = 0.0
var current_volume = 0
var maximum_volume_db = -8.0
var minimum_volume_db = -108.0
var pan = 0.5
var ads_state = [
	{ "time": 0, "volume": 1.0 },
	{ "time": 0.2, "volume": 0.95 },
	# { "time": 0.2, "jump_to": 0.0 },	# not implemented
]
var release_state = [
	{ "time": 0, "volume": 0.8 },
	{ "time": 0.01, "volume": 0.0 },
	# { "time": 0.2, "jump_to": 0.0 },	# not implemented
]

func _ready( ):
	self.stop( )

func set_instrument( instrument ):
	self.instrument = instrument
	self.mix_rate = instrument.mix_rate
	self.stream = instrument.stream.duplicate( )
	self.ads_state = instrument.ads_state
	self.release_state = instrument.release_state

func play( from_position=0.0 ):
	self.releasing = false
	self.timer = 0.0
	self.using_timer = 0.0
	self.current_volume = self.ads_state[0].volume
	self.stream.mix_rate = round( self.mix_rate * ( 1.0 + self.pitch_bend * 0.5 ) )
	.play( from_position )
	self._update_volume( )

func start_release( ):
	self.releasing = true
	self.current_volume = self.release_state[0].volume
	self.timer = 0.0
	self._update_volume( )

func set_pitch_bend( pb ):
	self.pitch_bend = pb
	var pos = self.get_playback_position( )
	self.stream.mix_rate = round( self.mix_rate * ( 1.0 + self.pitch_bend * 0.5 ) )
	.play( pos )

func _process( delta ):
	if not self.playing:
		return

	self.timer += delta
	self.using_timer += delta
	# self.transform.origin.x = self.pan * self.get_viewport( ).size.x

	# ADSR
	var use_state = null
	if self.releasing:
		use_state = self.release_state
	else:
		use_state = self.ads_state

	var all_states = use_state.size( )
	var last_state = all_states - 1
	if use_state[last_state].time <= self.timer:
		self.current_volume = use_state[last_state].volume
		if self.releasing:
			self.stop( )
	else:
		for state_number in range( 1, all_states ):
			var state = use_state[state_number]
			if self.timer < state.time:
				var pre_state = use_state[state_number-1]
				var s = ( state.time - self.timer ) / ( state.time - pre_state.time )
				var t = 1.0 - s
				self.current_volume = pre_state.volume * s + state.volume * t
				break

	self._update_volume( )

func _update_volume( ):
	var s = self.current_volume
	var t = 1.0 - s
	self.volume_db = s * self.maximum_volume_db + t * self.minimum_volume_db
