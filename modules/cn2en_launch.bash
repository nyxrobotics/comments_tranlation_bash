#!/bin/bash

# Translate launch files
for i in $(find ./ -name '*.launch')
do
    firstline=$(head -n 1 $i)
    if grep -q -n -v '<?xml' <<< $firstline ; then
        echo "Add xml definition"
        sed -i '1s/^/<?xml version="1.0" encoding="UTF-8"?>\n/' $i
    fi
    > $i.comments # Find the commented-out section in the file.
    sed -i "s/<!-- -\*- mode: XML -\*- -->//g" $i
    sed -i "s/<!-- \+/<!-- /g;s/ \+-->/ -->/g" $i
    awk '/<!--/,/-->/' $i > $i.comments
    sed -i "s/[\r\n]\+//g" $i.comments
    sed -i "s/<!--/\n<!--/g;s/-->/-->\n/g" $i.comments
    # awk -i inplace '/<!--/,/-->/' $i.comments
    awk '/<!--/,/-->/' $i.comments > tmp && mv tmp $i.comments
    while read single_comment;
    do
        # Translate when comment-out contains double-byte characters
        if LANG=C grep -q -n -v '^[[:cntrl:][:print:]]*$' <<< "$single_comment" ; then
            raw_escape=$(echo "$single_comment" | sed -e 's/[]\/$*.^[]/\\&/g')
            en_escape=$(echo $(trans -brief -no-warn -no-ansi zh-CN:en "$raw_escape"))
            sed -i -z "s/$raw_escape/$en_escape/g" $i
            echo -e $raw_escape "\n<<translated>>\n" ${en_escape^} "\n-----"
        fi
    done < $i.comments # Translate all comment-outs
    rm $i.comments
done
