extends "midi/MidiPlayer.gd"

const Tetromino = preload("res://Tetrominos/Tetromino.gd")

const LINE_CLEAR_CHANNELS = [2, 6]

var muted_events = []

func _ready():
	mute_channels(LINE_CLEAR_CHANNELS)

func _init_channel( ):
	._init_channel()
	for channel in max_channel:
		self.muted_events.append({})

func resume():
	play(position)

func _process_track_event_note_off( channel, event ):
	muted_events[channel.number].erase(event.note)
	._process_track_event_note_off( channel, event )
	
func _process_track_event_note_on( channel, event ):
	if self.channel_mute[channel.number]:
		muted_events[channel.number][event.note] = event
	._process_track_event_note_on( channel, event )

func mute_channels(channels):
	for channel_id in channels:
		channel_mute[channel_id] = true
		
func unmute_channels(channels):
	for channel_id in channels:
		channel_mute[channel_id] = false
		for note in muted_events[channel_id]:
			_process_track_event_note_on(channel_status[channel_id], muted_events[channel_id][note])

func _on_Main_piece_locked(lines, t_spin):
	if lines or t_spin:
		if lines == Tetromino.NB_MINOES:
			for channel in LINE_CLEAR_CHANNELS:
				channel_status[channel].vomume = 127
			$LineCLearTimer.wait_time = 0.86
		else:
			for channel in LINE_CLEAR_CHANNELS:
				channel_status[channel].vomume = 100
			$LineCLearTimer.wait_time = 0.43
		unmute_channels(LINE_CLEAR_CHANNELS)
		$LineCLearTimer.start()

func _on_LineCLearTimer_timeout():
	mute_channels(LINE_CLEAR_CHANNELS)