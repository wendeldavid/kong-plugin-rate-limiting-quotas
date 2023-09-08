#!/bin/bash

KONG_DATABASE=postgres

export KONG_DATABASE

rm -f luacov.report.out
rm -f luacov.stats.out

pongo run -v -- --coverage

pongo down
