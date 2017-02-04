#https://github.com/LangdalP/GoTimer/blob/master/listener/gamestate_listener.py
import json
import multiprocessing
import SimpleHTTPServer as server
import SocketServer
import urllib2
# Changes to go from 3 to 2
# urllib.request == urllib2 (ez replace)
# http.server == SimpleHTTPServer
# socketserver == SocketServer


class PostHandler(server.SimpleHTTPRequestHandler):

    def __init__(self, *args):
        server.SimpleHTTPRequestHandler.__init__(self, *args)
        

    def do_POST(self):
        if self.path == "/shutdown":
            self.server.should_be_running = False
        else:
            length = int(self.headers["Content-Length"])
            post_body = self.rfile.read(length).decode("utf-8")
            self.process_post_data(post_body)
        self.send_ok_response()

    def process_post_data(self, json_string):
        json_data = json.loads(json_string)
        added_key = json_data.get("added")
        round_key = json_data.get("round")
        map_key = json_data.get("map")
        previously_key = json_data.get("previously")
        
        if added_key:
            added_map_key = added_key.get("map")
            if added_map_key:
                ct = added_map_key.get("team_ct")
                t = added_map_key.get("team_t")

                if ct:#currently how i can tell an ESEA match is live
                    ct_name = ct.get("name")
                    t_name = t.get("name")
                    if ct_name:#match is live
                        self.server.msg_queue.put([0,t_name,ct_name])  
                        
        if map_key:
            map_curr_round = map_key.get("round")
            curr_ct_score = map_key.get("team_ct").get("score")
            curr_t_score = map_key.get("team_t").get("score")

        if round_key:
            round_phase_key = round_key.get("phase")
            if(round_phase_key == "live"):
                self.server.msg_queue.put([1,str(map_curr_round)])
            elif(round_phase_key == "over" and not(previously_key)):
                self.server.msg_queue.put([2, curr_t_score, curr_ct_score, map_curr_round])
        if round_phase_key:
            if (float(curr_ct_score) + float(curr_t_score))/15 == 1:#python 3 defaults to float div
                self.server.msg_queue.put([3, curr_t_score, curr_ct_score,round_phase_key])#halftime...or is it???

    def send_ok_response(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()


class ListenerServer(SocketServer.TCPServer):

    def __init__(self, server_address, req_handler_class, msg_queue):
        self.msg_queue = msg_queue
        self.should_be_running = True
        SocketServer.TCPServer.__init__(
            self, server_address, req_handler_class)

    def serve_forever(self):
        while self.should_be_running:
            self.handle_request()


class ListenerWrapper(multiprocessing.Process):

    def __init__(self, msg_queue):
        multiprocessing.Process.__init__(self)
        self.msg_queue = msg_queue
        self.server = None

    def run(self):
        self.server = ListenerServer(
            ("127.0.0.1", 3000), PostHandler, self.msg_queue)
        self.server.serve_forever()

    def shutdown(self):
        req = urllib2.Request("http://127.0.0.1:3000/shutdown", data=b"")
        urllib2.urlopen(req)