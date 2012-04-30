#! /usr/bin/python

import json
d = json.loads(file('allevents.json').read())
print len(d)

attendees = []
for e in d: attendees.extend(e['attendees'])
print 'total attendees: %i' % len(attendees)
#uniquify
attendees = list(set(attendees))
print 'unique attendees: ' + str(len(attendees))

organizers = []
for e in d: organizers.append(e['organizer'])	
print 'total organizers: ' , len(organizers)
#uniquify
organizers = list(set(organizers))
print 'unique organizers: ', len(organizers)

all = []
all.extend(attendees)
all.extend(organizers)
all = list(set(all))
print 'all: ', len(all)

#for a in all: print a

#print json.dumps(all)
