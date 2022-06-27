#!/usr/bin/env python3

"""This is simple bitbucket repositories downloader 2022

Note! - You need to create app password since bitbucket is not suported regular password
authentication

Script will download all available repositories in current folder

TODO: make pagination.
"""
import os
import requests
import json


API_URL = "https://api.bitbucket.org/2.0/user/permissions/repositories?pagelen=100"
GIT_USERNAME="__bitbucket_username__"
GIT_PASSWORD="__bitbucket_app__password__"


# get repositories pull
response = requests.get(API_URL, auth=(GIT_USERNAME, GIT_PASSWORD))


# get repositories urls
if response.status_code > 200:
    raise ValueError("Some thing went wrong")


repositories = []

for item in response.json()["values"]:
    _link = item["repository"]["links"]["html"]["href"]
    link = _link.replace("https://", f"https://{GIT_USERNAME}:{GIT_PASSWORD}@")
    os.system(f"git clone {link}")
