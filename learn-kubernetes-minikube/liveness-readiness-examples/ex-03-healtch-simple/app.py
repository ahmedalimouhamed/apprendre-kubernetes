from http.server import BaseHTTPRequestHandler, HTTPServer
import json, time, os

is_healthy = True
is_ready = False


class HealthHandler(BaseHTTPRequestHandler):
    def do_get(self):
        global is_healthy, is_ready

        if self.path == "/path":
            self.send_responce(200)
            self.send_header('Content-Type', 'text/html')
            self.end_headers()
            self.write.write(b"<h1>Hello kubernetes</h1>")
        elif self.path == "/health":
            if is_healthy:
                self.send_response(200)
                self.wfile.write(b"OK")
            else:
                self.send_response(500)
                self.wfile.write(b"Unhealthy")
        elif self.path == "/ready":
            if is_ready:
                self.send_response(200)
                self.wfile.write(b"READY")
            else:
                self.send_response(503)
                self.wfile.write(b"Not ready")
        elif self.path == "/toggle/health":
            is_healthy = not is_healthy
            self.send_response(200)
            self.wfile.write(b"Health toggled to : {is_healthy}".encode())
        elif self.path == "/toggle/ready":
            is_ready = not is_ready
            self.send_response(200)
            self.wfile.write(b"Ready toggled to : {is_ready}".encode())
        else:
            self.send_response(404)
            self.wfile.write(b"Not found")

print("Démarage de l'application...")
time.sleep(5)
print("Application démarrée")

is_ready = True

server = HTTPServer(("", 8080), HealthHandler)
print("Server started on port 8080")
server.serve_forever()

