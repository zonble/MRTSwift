#!/usr/bin/env python
# encoding: utf-8

import urllib
import urllib2
import re

def get_options():
	url = 'http://www.metro.taipei/ct.asp?xItem=78479152&CtNode=70089&mp=122035'
	req = urllib2.Request(url)
	response = urllib2.urlopen(req)
	the_page = response.read()
	target = ""
	for line in the_page.split("\n"):
		if "optgroup" in line:
			target = line
			break
	pattern = u"value=\"(.*?)\""
	a = re.findall(pattern, target)
	return set(a)

def get(station):
	url = "http://web.metro.taipei/c/TicketALLresult.asp"
	data = urllib.urlencode({'s2elect': station, 'submit': '確定'})
	req = urllib2.Request(url, data)
	response = urllib2.urlopen(req)
	the_page = response.read()
	target = ""
	for line in the_page.split("\n"):
		if "<tr><td align='center' width='20%'>" in line:
			target = line
			break
	target = target.strip()
	target = target.split("</tr>")
	rows = []
	for s in target:
		s = s.decode('utf8')
		pattern = u"<font(.*?)>(.*?)</font>"
		a = re.findall(pattern, s)
		if len(a):
			row = [x[1].strip() for x in a if x[1] != u'→']
			row[0] = row[0].split(' ')[1]
			row[1] = row[1].split(' ')[1]
			rows.append(row)
	return rows

def main():
	print "get options"
	sites = get_options()
	print set(sites)
	print "get content"
	all_rows = []
	for site in sites:
		try:
			print site
			rows = get(site)
			all_rows.extend(rows)
		except Exception as e:
			print e

	with open("price.txt", "w") as f:
		txt = ""
		for row in all_rows:
			txt += ",".join(row) + "\n"
		f.write(txt.encode("utf-8"))

	with open("price.sql", "w") as f:
		txt = "create table data (from_station, to_station, oneway, easycard, reduced_fare, time);\n"
		for row in all_rows:
			row[0] = "\"%s\"" % row[0]
			row[1] = "\"%s\"" % row[1]
			txt += "insert into data values(" + ",".join(row) + ");\n"
		txt += "create index from_station_index on data (from_station);\n"
		txt += "create index to_station_index on data (to_station);\n"
		f.write(txt.encode("utf-8"))

if __name__ == "__main__":
    main()
