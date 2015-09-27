#!/usr/bin/fish

# just to make a output less ugly
set script_name (basename (status -f))

# run git pull origi on all folders
for d in *;
    if test -d $d
        echo -n -s (set_color green) "[$script_name]" (set_color normal)
        echo " Running git pull in: $d..."

        cd ./$d;
        git pull origin;
        cd ..;
    end
end
