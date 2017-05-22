#!/usr/bin/env bash
rm /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/october /etc/nginx/sites-enabled/october
service nginx restart