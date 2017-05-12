#!/usr/bin/env bash
rm /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/drupal /etc/nginx/sites-enabled/drupal
service nginx restart