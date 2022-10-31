ARR=0
set -A array           # Move it BEFORE the while
cat /home/ansiadm/handover/vars_co999/hosts.yaml | while read LINE
do
    arr[$ARR]=$LINE    # NO spaces
    echo $LINE
    echo ${arr[$ARR]}
    ARR=$(($ARR+1))
done
echo "Number of Lines: $ARR"
