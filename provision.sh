#!/bin/sh

if [ -z $2 ]
then
    >&2 echo "Usage: $0 FROM TO"
    exit 1
fi

FROM=$1
TO=$2
# Number of missing variables
MISSING_COUNT=0

# reset TO file
echo "" > $TO

# Load required environment variables from the FROM file
while read -r line || [ -n "$line" ]; do
    # get the variable name
    VAR=`echo "$line" | grep -Eo "^[^#][^=]+=" | cut -d = -f 1`
    # If not a variable definition ...
    if [ -z "$VAR" ]
    then
        # skip to the next line
        continue
    fi

    # get the default value
    DEFAULT_VALUE=`echo "$line" | grep -Eo "=.*" | cut -c 2-`
    # get the current defined value
    ENV_VALUE=`eval "echo \\\$$VAR"`

    # Compute the value
    VALUE="$ENV_VALUE"
    if [ -z "$VALUE" ]
    then
        VALUE="$DEFAULT_VALUE"
    fi

    if [ -z "$VALUE" ]
    then
        MISSING_COUNT=$(expr "$MISSING_COUNT" + 1)
        >&2 echo "$VAR missing"
    fi

    # add to TO file
    echo "$VAR=$VALUE" >> $TO
done < "$FROM"

if [ 0 -ne $MISSING_COUNT ]
then
    >&2 echo "$MISSING_COUNT variable(s) are missing"
    exit 1
fi
