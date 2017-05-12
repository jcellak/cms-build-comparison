#!/usr/bin/env bash
rm /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress
service nginx restart