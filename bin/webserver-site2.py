#!/usr/bin/env python

import http.server
import socketserver

class CustomHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.path = 'status-site2.txt'
        return http.server.SimpleHTTPRequestHandler.do_GET(self)
PORT = 9000

handler = CustomHttpRequestHandler
server=socketserver.TCPServer(("", PORT), handler)
print("Server started at port 9000. Press CTRL+C to close the server.")
try:
	server.serve_forever()
except KeyboardInterrupt:
	server.server_close()
	print("Server Closed")
 
 