#!/usr/bin/python3
import sys

import urllib
import mutagen
import urllib.request
import mutagen.mp3



def GetSoundDurationFromURL(url):
	filename, headers = urllib.request.urlretrieve(url)
	audio = mutagen.mp3.MP3(filename)
	return audio.info.length



sound_duration = GetSoundDurationFromURL("http://audio.atelier801.com/" + sys.argv[1] + ".mp3")
print(sound_duration)
