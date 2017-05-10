#!/Volumes/MacintoshHD3/Homebrew//bin/python3
import cgi
import json
import sys
from os.path import join

print('Content-type: text/html; charset=UTF-8\n\n')

storage = cgi.FieldStorage()

DEBUG = False

#with open('/dev/ttys003', 'a') as f:
with open('/dev/null', 'a') as f:
    id = storage["id"].value.decode('utf-8')
    image = storage["image"].value
    _json = storage["json"].value.decode('utf-8')
    
    with open(join('./data/img', id + '.jpg'), 'wb') as f2:
        f2.write(image)
    
    with open(join('./data/json', id + '.json'), 'w') as f2:
        f2.write(_json)


    """ check if works. """
    if DEBUG:
        with open(join('./data/json', id + '.json'), 'r') as f2:
            content = json.load(f2)
            f.write(text)
