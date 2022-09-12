#!/bin/bash

# Translate C++ files
for i in $(find ./ -name '*.cpp')
do
    echo "found" $i
    IFS=$'\n' # Ignore newline characters
    # Comments beginning with a double slash
    awk '/\/\//' $i > $i.comments
    sed -i 's/.*\/\//\/\//' $i.comments

    while read single_comment;
    do
        # Translate when comment-out contains double-byte characters
        if LANG=C grep -q -n -v '^[[:cntrl:][:print:]]*$' <<< "$single_comment" ; then
            raw_escape=$(echo $single_comment | sed -e 's/[]\/$*.^[]/\\&/g' | sed -e 's/"/\"/g' | sed -e "s/'/\'/g")
            en_escape=$(echo $(trans -brief -no-warn -no-ansi zh-CN:en $raw_escape))
            sed -i -z "s/$raw_escape/$en_escape/g" $i
            echo -e $raw_escape "\n<<translated>>\n" $en_escape "\n-----"
        fi
    done < $i.comments # Translate all comment-outs

    # Comments surrounded by slash asterisks
    tmp=$(grep -zoP "\/\*[\s\S]*?\*\/" $i | sed 's!*//*!\*/_NR_!g' | sed 's!_NR_!\n!g')
    echo "$tmp" > $i.comments2
    while read single_comment;
    do
        # Translate when comment-out contains double-byte characters
        if LANG=C grep -q -n -v '^[[:cntrl:][:print:]]*$' <<< "$single_comment" ; then
            raw_escape=$(echo "$single_comment" | sed -e 's/[]\/$*.^[]/\\&/g' | sed 's/"/\"/g' | sed "s/'/\'/g")
            en_escape=$(echo $(trans -brief -no-warn -no-ansi zh-CN:en "$raw_escape"))
            sed -i -z "s/$raw_escape/$en_escape/g" $i
            echo -e "$raw_escape" "\n<<translated>>\n" "$en_escape" "\n-----"
        fi
    done < $i.comments2 # Translate all comment-outs

    rm $i.comments
    rm $i.comments2
done
