from behave import *
import httplib2, time
from nose.tools import *

from yaml import load
from steps import AppConfig

def before_all(context):

    # parse the YAML file to get all the soft-coded connection info
    with open("../../../../myapp.yml") as f:
        config = load(f.read())
        # prepare std app config object that steps.py expects
        context.app_config = AppConfig(config["http"]["port"],config["http"]["adminPort"])

def before_scenario(context,scenario):
    # clear out all the caches
    full_url = "%s%s" % (context.app_config.admin_url_prefix,"/tasks/clearData")
    h = httplib2.Http()
    h.add_credentials("ops","password")
    resp, _ = h.request(full_url.encode("utf-8"), "POST".encode("utf-8"))
    assert_equals(200,resp.status)

    # init HTTP headers
    context.http_headers = {}



