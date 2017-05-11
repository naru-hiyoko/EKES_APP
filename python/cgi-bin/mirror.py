#!/Volumes/MacintoshHD3/Homebrew//bin/python3
import cgi
import json
import sys
from os.path import join

print('Content-type: text/html; charset=UTF-8\n\n')

storage = cgi.FieldStorage()

DEBUG = True

with open('/dev/ttys002', 'a') as f:
#with open('/dev/null', 'a') as f:
    id = storage.getvalue('id', "")
    id = "" if id == "" else id.decode('utf-8')
    image = storage.getvalue("image", None)
    _json = storage.getvalue("json", None)

    if image != None:
        with open(join('./data/img', id + '.jpg'), 'wb') as f2:
            f2.write(image)

    if _json != None:
        with open(join('./data/json', id + '.json'), 'wb') as f2:
            f2.write(_json)
            

    """ check if works. """
    if DEBUG:
        with open(join('./data/json', id + '.json'), 'r') as f2:
            content = json.load(f2)
            f.write('\n')
            """ username """
            f.write(content['username'] + '\n')
            """ unique id """
            f.write(content['id'] + '\n')
            for datum in content['data']:
                f.write(str(datum))
                f.write('\n')
