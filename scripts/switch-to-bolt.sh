#!/usr/bin/env bash
rm /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/bolt /etc/nginx/sites-enabled/bolt
service nginx restart