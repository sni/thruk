#!/bin/bash

# This script is intended to print details of a post request to the CGI.
# It should be invoked with a POST request to the CGI.
# This should be added as a custom service/host action to the Thruk.
# See the documentation for custom service/host actions more information.

echo "Showing fields of the POST request:"
env | grep 'POST_'