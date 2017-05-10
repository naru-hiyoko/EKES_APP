#!/Volumes/MacintoshHD3/Homebrew//bin/python3

import os
import cgi
import json
import sys


_out = open('/dev/ttys000', 'a')

print('Content-type: application/json; charset=UTF-8\n\n')

form = cgi.FieldStorage()

msg = '\nテスト\nメッセージ\n\n'
x = 3.0
y = 0.0
z = 0.0



_out.write('response message: \n ------------- \n')

if 'speechText' in form:
    text = form['speechText'].value
    text = text.decode('utf-8')
else:
    text = "NO response!!"


_out.write(text + '\n')
_out.write('-------------\n')
_out.write('plz type in!\n')

_in = open('./pipe')
msg = ""
for line in _in.readlines():
    msg += line
msg += "\n\n"
        
content = { 'msg': msg,
            'x': x,
            'y': y,
            'z': z}
        
print(json.dumps(content))
        
_in.close()
_out.close()
