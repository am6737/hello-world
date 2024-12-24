import json
import signal
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

from api.models import HelloWorldResponse


class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        resp = HelloWorldResponse()
        resp.message = "Hello, World!"
        resp.version = "1.0.0"
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(json.dumps(resp.to_dict()).encode("utf-8"))


def run(server_class=HTTPServer, handler_class=SimpleHTTPRequestHandler, port=8080):
    server_address = ("", port)
    httpd = server_class(server_address, handler_class)

    def graceful_shutdown(signal_number, frame):
        print("\nShutting down the server gracefully...")
        httpd.server_close()
        sys.exit(0)

    signal.signal(signal.SIGINT, graceful_shutdown)
    signal.signal(signal.SIGTERM, graceful_shutdown)

    print(f"Starting HTTP server on port {port}...")
    try:
        httpd.serve_forever()
    except Exception as e:
        print(f"An error occurred: {e}")
        httpd.server_close()
        sys.exit(1)


if __name__ == "__main__":
    run()
