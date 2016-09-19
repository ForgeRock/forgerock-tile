#!/usr/bin/env python

import argparse
import unittest
import json
import subprocess
import os
import urllib2

parser = argparse.ArgumentParser()
parser.add_argument('repo_dir')
parser.add_argument('app_domain')
args = parser.parse_args()

mock_openam_app = "mock-openam"
test_app = "forgerock-test-app"
service_instance_name = "openam-test-instance"

def create_url(app_name):
    return "http://" + app_name + "." + args.app_domain

def create_service(service_name):
    subprocess.check_call(["cf", "create-service", "openam-oauth2", "shared", service_name])

def bind_service(service_name):
    subprocess.check_call(["cf", "bind-service", test_app, service_name])

def unbind_service(service_name):
    subprocess.check_call(["cf", "unbind-service", test_app, service_name])

def remove_service(service_name):
    unbind_service(service_name)
    subprocess.check_call(["cf", "delete-service", "-f", service_name])

def get_test_app_environment():
    subprocess.check_call(["cf", "restage", test_app])
    return json.load(urllib2.urlopen(create_url(test_app) + "/services"))

def get_mock_openam_requests():
    return json.load(urllib2.urlopen(create_url(mock_openam_app) + "/reqs"))

class IntegrationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        subprocess.check_call(["cf", "push", mock_openam_app, "-p", os.path.join(args.repo_dir, "ci", "mock-openam")])
        subprocess.check_call(["cf", "push", test_app, "-p", os.path.join(args.repo_dir, "ci", "test-app")])

    @classmethod
    def tearDownClass(cls):
        subprocess.call(["cf", "delete", "-f", mock_openam_app])
        subprocess.call(["cf", "delete", "-f", test_app])

    def setUp(self):
        get_mock_openam_requests()  # Clears the set of requests as a side effect
        create_service(service_instance_name)

    def tearDown(self):
        remove_service(service_instance_name)

    def test_marketplace_shows_openam_service(self):
        output = subprocess.check_output(["cf", "marketplace"])
        self.assertTrue(output.find("openam-oauth2") != -1)

    def test_bind_provides_appropriate_environment_variables(self):
        bind_service(service_instance_name)
        env = get_test_app_environment()
        requests = get_mock_openam_requests()

        create_agent_request = filter(lambda x: x["path"] == "/openam/json/test-realm/agents" and x["method"] == "POST", requests)[0]

        self.assertEqual(env["openam-oauth2"][0]["credentials"]["uri"], create_url(mock_openam_app) + "/openam/oauth2/test-realm/")
        self.assertEqual(env["openam-oauth2"][0]["credentials"]["username"], create_agent_request["body"]["username"])
        self.assertEqual(env["openam-oauth2"][0]["credentials"]["password"], create_agent_request["body"]["userpassword"])

    def test_bind_creates_oauth2_client_with_correct_parameters(self):
        bind_service(service_instance_name)
        requests = get_mock_openam_requests()
        create_agent_request = filter(lambda x: x["path"] == "/openam/json/test-realm/agents" and x["method"] == "POST", requests)[0]
        self.assertEqual(create_agent_request["body"]["com.forgerock.openam.oauth2provider.scopes"], ["[0]=scope1", "[1]=scope2"])

    def test_unbind_deletes_oauth2_client(self):
        bind_service(service_instance_name)
        env = get_test_app_environment()
        username = env["openam-oauth2"][0]["credentials"]["username"]
        unbind_service(service_instance_name)
        requests = get_mock_openam_requests()
        delete_agent_requests = filter(lambda x: x["path"] == "/openam/json/test-realm/agents/" + username and x["method"] == "DELETE", requests)
        self.assertEqual(len(delete_agent_requests), 1)

    def test_correct_openam_credentials_are_used(self):
        bind_service(service_instance_name)
        requests = get_mock_openam_requests()
        auth_requests = filter(lambda x: x["path"] == "/openam/json/test-realm/authenticate" and x["method"] == "POST", requests)
        print auth_requests[0]
        self.assertTrue(len(auth_requests) > 0)
        self.assertEqual(auth_requests[0]["headers"]["x-openam-username"], "mock-username")
        self.assertEqual(auth_requests[0]["headers"]["x-openam-password"], "mock-password")


unittest.main(argv=('',))
