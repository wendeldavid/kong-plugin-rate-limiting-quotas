#!/bin/bash

KONG_DATABASE=postgres

export KONG_DATABASE

pongo run --no-cassandra -v -- --coverage

pongo down
