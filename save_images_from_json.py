import urllib.request
import json
req = urllib.request.Request('--example--json--url--')

r = urllib.request.urlopen(req).read()
items = json.loads(r.decode('utf-8'))

# Loop through array
for item in items['items']:
    # get file name
    file_name = item['assetUrl'].rsplit('/', 1)[-1]
    # save image with file_name
    urllib.request.urlretrieve(item['assetUrl'], file_name)
