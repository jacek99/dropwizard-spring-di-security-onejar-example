class AppConfig:
    def __init__(self,app_port,admin_port,host="127.0.0.1"):
        self.app_port = app_port
        self.admin_port = admin_port
        self.host = host
        self.app_url_prefix = "http://127.0.0.1:%s" % app_port
        self.admin_url_prefix = "http://127.0.0.1:%s" % admin_port
        #self.app_url_prefix = "http://172.16.1.84:%s" % app_port
        #self.admin_url_prefix = "http://172.16.1.84:%s" % admin_port