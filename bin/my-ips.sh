#!/usr/bin/env bash
ip -o addr | awk '!/^[0-9]*: ?lo|link\// {gsub("/", " "); print $2" "$4}'

