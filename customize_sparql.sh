#!/bin/bash

user=$1
pw=$2
isql 1111 $user $pw < ./sparql_io.sql

