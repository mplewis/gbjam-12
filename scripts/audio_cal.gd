extends Node

# Audio offset, customized to the user. Set in the audio calibration screen.
var audio_offset := 0.0

## Determined by experimentation.
## There is some constant difference between the offset from the calibration scene
## (which seems to be very close to real life!) and in the actual game, here.
const MAGIC_NUMBER_MIDI_DELAY := 0.16


## When you are spawning notes, spawn them this many seconds early.
func total_audio_offset() -> float:
	return audio_offset
