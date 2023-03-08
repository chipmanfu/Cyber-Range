#!/bin/bash

cp /configmod/ports.conf /etc/apache2/ports.conf
cp /configmod/default.conf /etc/apache2/sites-enabled/default.conf
a2enmod ssl
