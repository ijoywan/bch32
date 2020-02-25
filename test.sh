#!/bin/bash

export GOPATH=$(pwd)

go test -v -cover bch32
