#!/bin/bash
perl -ne 'BEGIN{$ax=0;$ay=0}@F=split(/\t/,$_);$ax+=$F[0];$ay+=$F[1];print "$ax\t$ay\n";' hackaday.txt  > lines.txt
