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
	# print target
	pattern = u"value=\"(.*?)\""
	a = re.findall(pattern, target)
	return set(a)

def get(station):
	url = "http://web.metro.taipei/c/stationdetail2010.asp?ID=" + station
	print "=" * 40
	print url
	req = urllib2.Request(url)
	response = urllib2.urlopen(req)
	the_page = response.read()
	# pattern = r'<TD BGCOLOR="#ffffff" CLASS="Default"><font size="-1">(.*?)</font></TD>'
	pattern = r'<div style="float: left;margin: 10px 0 0 3px;font-size: 18px; font-weight: bold;letter-spacing: 0.05em">(.*?)</div>'
	a = re.findall(pattern, the_page)
	print a[0]
	name = a[0]
	pattern = r"<TD valign='center' BGCOLOR=\"#ffffff\" CLASS=\"Default\"><font size=\"-1\">(.*?)</font>&nbsp;"
	a = re.findall(pattern, the_page)
	print a[0]
	address = a[0]
	pattern = r"'googlemap.asp\?Longitude=(.*?)&Latitude=(.*?)'"
	a = re.findall(pattern, the_page)
	print  a[0][0], a[0][1]
	return (name, address, a[0][0], a[0][1])

def main():
	sites = get_options()
	# print sites
	# return
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
