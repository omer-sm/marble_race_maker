ffmpeg -y -f concat -safe 0 -i outputs/timeline.txt -af "aresample=async=1,atrim=start=0.05" -c:a libmp3lame -b:a 128k outputs/vocals_test2.mp3
