__author__ = 'jacekf'

from behave import *
from nose.tools import *
from difflib import Differ, unified_diff
import httplib2, json, sys, difflib, urllib, urlparse, string, codecs

from urllib import urlencode
import httplib, base64, string, unicodedata

SKIP = '_'

###################################################################
# GIVEN
###################################################################

@given('"{name}:{password}" sends {method} "{url}"')
def given_i_post_to_url(context, name, password,method, url):
    """
    Used for setting up test data
    """
    for row in context.table:
        args = []
        for key in row.headings:
            val = row[key]
            if unicode(val) is not unicode(SKIP):
                args.append("%s=%s" % (key,val))

        # convert it to an HTML format form, to be compatible with existing methods
        form = "&".join(args)
        when_i_post_put_to_url_with_params(context,name,password,method,url,form)
        # validate was successful
        if str(method) == "POST":
            then_i_expect_http_code(context,201)
        else:
            then_i_expect_http_code(context,200)


###################################################################
# WHEN
###################################################################
@when('"{name}:{password}" sends {method} "{url}" with "{params}"')
def when_i_post_put_to_url_with_params(context, name, password,method, url, params = SKIP, admin = False, content_type = "application/x-www-form-urlencoded"):
    full_url = "%s%s" % (context.app_config.app_url_prefix,url) if admin is False else "%s%s" % (context.app_config.admin_url_prefix,url)
    h = httplib2.Http()
    h.add_credentials(name,password)
    # convert string params to dictionary
    form_params = {}
    if params is not SKIP:
        form_params = dict(urlparse.parse_qsl(params))

    # handle both
    content = params.encode("utf-8")

    if content_type is "application/x-www-form-urlencoded":
        content = urllib.urlencode(form_params)

    if method in {"PUT","POST","PATCH"}:
        context.http_headers["content-type"] = content_type

    # encode http headers
    context.http_headers = dict((k.encode('ascii') if isinstance(k, unicode) else k,
                                 v.encode('ascii') if isinstance(v, unicode) else v)
        for k,v in context.http_headers.items())

    context.resp, context.content = h.request(full_url.encode("utf-8"), method.encode("utf-8"), content, headers=context.http_headers)
    context.http_headers = {}

@when('"{name}:{password}" sends {method} "{url}" with {file_type} file "{file_path}"')
def when_i_send_file(context,name,password,method,url,file_type,file_path):
    content = None

    with codecs.open(file_path, encoding='utf-8') as f:
        content = f.read()

    content_type = "text/plain; charset=utf-8"
    if file_type in ("CSV","csv"):
        content_type = "text/csv; charset=utf-8"

    when_i_post_put_to_url_with_params(context, name, password,method, url, params = content, content_type = content_type)

@when('"{name}:{password}" sends {method} "{url}" with {type}')
def when_i_send_text(context,name,password,method,url,type):
    content = context.text

    content_type = "text/plain; charset=utf-8"
    if type in ("JSON","json"):
        content_type = "application/json; charset=utf-8"

    when_i_post_put_to_url_with_params(context, name, password,method, url, params = content, content_type = content_type)


@when('"{name}:{password}" sends {method} "{url}"')
def when_i_send_to_app_port(context,name,password,method,url):
    when_i_post_put_to_url_with_params(context, name, password,method, url)

@when('"{name}:{password}" sends {method} "{url}" on admin port')
def when_i_send_to_admin_port(context,name,password,method,url):
    when_i_post_put_to_url_with_params(context, name, password,method, url, admin= True)

@when('I set HTTP header "{header_name}" to "{header_value}"')
def when_i_set_http_header(context,header_name,header_value):
    context.http_headers[header_name] = header_value


###################################################################
# THEN
###################################################################
@then('I expect HTTP code {code}')
def then_i_expect_http_code(context,code):
    error_message = u"Expected HTTP code %s != %s\nResponse:\n%s\n%s" % (code, context.resp.status, context.resp, context.content.decode('utf-8'))
    assert_equals(int(code),context.resp.status, error_message)

@then('I expect JSON equivalent to')
def and_i_expect_json_equivalent_to(context):
    """This method looks only at the field names that are specified in the expected JSON. All other field names are removed for comparison purposes.
        This shields the JSON from changes over time, when new fields are being added
    """

    actual_json = json.loads(context.content)
    exp_json = json.loads(context.text)

    # remove fields that are not explicitly listed in the expected JSON
    # to allow APIs to add new fields without breaking existing tests
    # remove the additional fields from the received JSON
    expected_fields = get_unique_fields(exp_json, set())
    received_fields = get_unique_fields(actual_json, set())
    delta_fields = received_fields - expected_fields

    original_json = json.dumps(actual_json, sort_keys=True, indent=4)

    remove_property_list_from_object_recursively(actual_json, delta_fields)

    expected_json_sorted = json.dumps(exp_json, sort_keys=True, indent=4)
    actual_json_sorted = json.dumps(actual_json, sort_keys=True, indent=4)

    # prepare potential error message
    assert_json(expected_json_sorted,actual_json_sorted,original_json)

@then('I expect HTTP header "{header}" equals "{value}"')
def then_i_expect_http_header_value(context,header,value):
    if str(value) != str(SKIP):
        actual_header = context.resp[header]
        assert_equals(value,actual_header)

@then('I expect HTTP content equals "{content}"')
def then_i_expect_http_content_equals(context,content):
    if str(content) is not SKIP:
        assert_equals(content,context.content)

@then('I expect HTTP content contains "{content}"')
def then_i_expect_http_content_contains(context,content):
    error_message = "Content '%s' not found\nResponse:\n%s\n%s" % (content,context.resp,context.content)
    if str(content) is not SKIP:
        assert_true(content in context.content,error_message)

###################################################################
# UTILITY METHODS
###################################################################

#This removes recursively from the object parameter all the properties contained in the propertiesToRemove list
def remove_property_list_from_object_recursively(object, propertiesToRemove):
    if type(object).__name__ == 'list':
        for subObject in object:
            remove_property_list_from_object_recursively(subObject, propertiesToRemove)
    elif type(object).__name__ == 'dict':
    #This is in case a property contains another object
        for key in object.keys():
            remove_property_list_from_object_recursively(object[key], propertiesToRemove)

        for property in propertiesToRemove:
            remove_property_from_object(object, property)


def get_unique_fields(list_or_dict, fieldset):
    "Traverses an entire JSON documents and returns a tuple of all the unique field names, no matter how deep"
    if type(list_or_dict).__name__ == 'list':
        for subObject in list_or_dict:
            get_unique_fields(subObject, fieldset)
    elif type(list_or_dict).__name__ == 'dict':
    #This is in case a property contains another list_or_dict
        for key in list_or_dict.keys():
            fieldset.add(key)
            get_unique_fields(list_or_dict[key], fieldset)
    return fieldset

#This will remove the propertyToRemove property from the list_or_dict parameter
def remove_property_from_object(object, propertyToRemove):
    try:
        if(object[propertyToRemove] != None):
            del object[propertyToRemove]
    except Exception:
        return

def diff(expected, actual):
    expected = expected.splitlines(1)
    actual = actual.splitlines(1)
    diff = unified_diff(expected, actual)
    return ''.join(diff)

def assert_json(expected, actual, full_actual_json=None):
    # allow passing FULL JSON before delta fields were removed
    if full_actual_json == None:
        full_actual_json = actual
    try:
        assert_equals(expected, actual)
    except AssertionError, e:
        raise AssertionError("Expected JSON:\n%s\n*** actual ****\n%s\n*** diff on expected fields only ****\n%s" % (
            expected, full_actual_json, diff(expected, actual)))
