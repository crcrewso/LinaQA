#!/bin/bash
if [ -z "$1" ]
   then
      python /home/alanphys/Programs/LinaQA/LinaQA/LinaQA.pyw
   else
      python /home/alanphys/Programs/LinaQA/LinaQA/LinaQA.pyw "$1"
fi
