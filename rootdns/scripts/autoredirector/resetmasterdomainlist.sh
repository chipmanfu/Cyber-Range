#!/bin/bash
# Written by Chip McElvain 168COS
# simply removes the comment "#" in front of any domains that are commented out
# Just makes all the possible domains in the list available again.  Only do this
# after the exercise/training is over.
sed -i 's/#//' masterdomainlist.txt
