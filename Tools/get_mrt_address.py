#!/usr/bin/env python
# encoding: utf-8

import urllib
import urllib2
import re

def get_options():
	url = 'http://web.trtc.com.tw/c/TicketALLresult.asp'
	req = urllib2.Request(url)
	response = urllib2.urlopen(req)
	the_page = response.read()
	target = ""
	for line in the_page.split("\n"):
		if "optgroup" in line:
			target = line
			break
	pattern = u"value='(.*?)'"
	a = re.findall(pattern, target)
	return set(a)

def get(station):
	url = "http://web.trtc.com.tw/c/stationdetail2010.asp?ID=" + station
	req = urllib2.Request(url)
	response = urllib2.urlopen(req)
	the_page = response.read()
	pattern = r'<TD BGCOLOR="#ffffff" CLASS="Default"><font size="-1">(.*?)</font></TD>'
	a = re.findall(pattern, the_page)
	name = a[0]
	pattern = r"<TD valign='center' BGCOLOR=\"#ffffff\" CLASS=\"Default\"><font size=\"-1\">(.*?)</font>&nbsp;"
	a = re.findall(pattern, the_page)
	address = a[0]
	pattern = r"'googlemap.asp\?Longitude=(.*?)&Latitude=(.*?)'"
	a = re.findall(pattern, the_page)
	return (name, address, a[0][0], a[0][1])

def main():
	sites = get_options()
	address = []
	for site in sites:
		result = get(site)
		address.append(result)
	with open("address.txt", "w") as f:
		txt = ""
		for row in address:
			txt += ",".join(row) + "\n"
		f.write(txt)


if __name__ == "__main__":
    main()
