#!/bin/bash

# Ensure that we get the default var_N by
# first deleting any previous settings
rm -f current_settings.sh
source settings.sh

function quick_setup {
    local n=$1 ; shift
    while [ $# -gt 0 ]; do
	if [ $(var_N $1) -ne $n ]; then
	    echo "Updating number of dimensions for: $(var_name $1) to $n"
	    echo "# Updating number of dimensions for: $(var_name $1) to $n" >> current_settings.sh
	fi
	echo "$1) _ps $n ;;" >> current_settings.sh
	shift
    done
}
	 	
function _help {
    echo "Helper routine for compilation setup"
    echo " Call by:"
    echo "   $0 <options>"
    echo ""
    echo " Several options are allowed to control how many dimensions that will"
    echo " be accesible in type(var) and type(dict)."
    echo " currently you cannot ask for more than 7 dimensions without"
    echo " changing this file and settings.inc"
    echo ""
    echo " The following options control how the dimensions are allocated:"
    for v in -s -d -c -z -b -h -i -l ; do
	echo "   $v <num> : allows 0-<num> dimensions of $(var_name ${v:1})"
    done
    echo "   -A <num> : short for all the above options simultaneously"
    echo "   -R <num> : short for -s <num> -d <num>"
    echo "   -C <num> : short for -c <num> -z <num>"
    echo "   -I <num> : short for -h <num> -i <num> -l <num>"
    echo " The above options can be combined with the last option taking precedence."
    echo ""
    echo "Example"
    echo " Allowing all variables to have 2 dimensions but the"
    echo " double precision reals to have 3 can be done with:"
    echo "  $0 -A 2 -d 3"
    echo ""
}

[ $# -eq 0 ] && _help && exit

{
echo "function var_N {"
echo "local var=\"\$1\""
echo "case \$var in"
} > current_settings.sh

while [ $# -gt 0 ]; do
    opt=$1 ; shift
    case $opt in
	--*)
	    opt=${opt:1} ;;
	-*)
	    ;;
	*)
	    echo "Error, could not recognize option"
	    _help ; exit
	    ;;
    esac
    case $opt in 
        -h)
	    if [ $# -eq 0 ]; then
		# This will capture if only -h is supplied
		_help 
		exit
	    fi
	    n=${opt:1}
	    quick_setup $1 $n
	    shift ;;
	-s|-d|-c|-z|-b|-i|-l)
	    n=${opt:1}
	    quick_setup $1 $n
	    shift ;;
	-A)
	    quick_setup $1 s d c z b h i l
	    shift ;;
	-R)
	    quick_setup $1 s d
	    shift ;;
	-C)
	    quick_setup $1 c z
	    shift ;;
	-I)
	    quick_setup $1 h i l
	    shift ;;
	-help)
	    _help ; exit ;;
	*)
	    ;;
    esac
done

# In a 
for v in VAR V a s d c z b h i l ; do
    quick_setup $(var_N $v) $v
done
{
echo "esac"
echo "}"
} >> current_settings.sh

