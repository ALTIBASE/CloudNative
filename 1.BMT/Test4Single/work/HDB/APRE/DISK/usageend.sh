kill `ps -ef | grep $USER | grep top | grep -v grep | awk '{print $2}'`
#cat ./usage_collect | grep altibase | awk '{print " "(sum9+=$9)/NR", " (sum10+=$10)/NR}' | tail -1 >> ./usage_result
cat ./usage_collect | grep altibase | awk '{printf " %.2f, %.2f\n", (sum9+=$9)/NR, (sum10+=$10)/NR}' | tail -1 >> ./usage_result
