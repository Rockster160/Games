from http.server import SimpleHTTPRequestHandler, HTTPServer
import os

class MyRequestHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        print("Requested path:", self.path)
        if self.path.startswith("/worlds/"):
            script_path = os.path.join(os.getcwd(), "mc_maps", self.path[1:])
            print("Script path:", script_path)
            if os.path.exists(script_path):
                directory_name = os.path.basename(os.path.dirname(script_path))
                file_name = os.path.basename(script_path).split(".")[0]
                page_title = f"{file_name} ({directory_name})"
                index_path = os.path.join(os.getcwd(), "mc_maps", "layout", "index.html")
                print("Index path:", index_path)
                if os.path.exists(index_path):
                    with open(script_path, "r") as file:
                        script_content = file.read()
                    with open(index_path, "r") as index_file:
                        index_content = index_file.read()
                    index_content = index_content.replace('<div id="script-placeholder"></div>', f'<script>{script_content}</script>')
                    index_content = index_content.replace('<title></title>', f'<title>{page_title}</title>')
                    self.send_response(200)
                    self.send_header("Content-type", "text/html")
                    self.end_headers()
                    self.wfile.write(index_content.encode())
                else:
                    print("Index file does not exist")
                    self.send_response(404)
                    self.end_headers()
            else:
                print("Script file does not exist")
                self.send_response(404)
                self.end_headers()
        else:
            super().do_GET()

if __name__ == "__main__":
    PORT = 8000
    server_address = ('', PORT)
    httpd = HTTPServer(server_address, MyRequestHandler)
    print(f"Server running on port {PORT}")
    httpd.serve_forever()
