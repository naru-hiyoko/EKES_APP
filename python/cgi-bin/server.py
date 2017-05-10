#!/Volumes/MacintoshHD3/Homebrew//bin/python3
import cgi
import json
import sys

print('Content-type: application/json; charset=UTF-8\n\n')
#print('Content-type: text/html; charset=UTF-8\n\n')

form = cgi.FieldStorage()

msg = '\nこんにちは\n僕は太一\nよろしくね\n\n'
x = 4.0
y = 0.0
z = 0.0




#text = form['text'].value
#_time = form['time'].value

if 'image' in form:
    image = form['image'].value
    with open('sample.jpg', 'wb') as f:
        f.write(image)
    msg = "\n 写真を撮影\nさせてもらった\nぜ\n\n"

if 'speechText' in form:
    text = form['speechText'].value
    text = text.decode('utf-8')
    if '誰' in text:
        msg = "太一だよ"

content = { 'msg': msg,
            'x': x,
            'y': y,
            'z': z}
        
print(json.dumps(content))



