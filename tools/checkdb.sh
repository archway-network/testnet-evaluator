#!/bin/bash

# This script checks the database for missed blocks
# It has to be executed inside postgresql container

# POSTGRES_USER=root
# POSTGRES_PORT=5432
# POSTGRES_DB=cosmologger
# POSTGRES_HOST=postgres
# POSTGRES_PASSWORD=password

# echo ${POSTGRES_PASSWORD} | psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -c "SELECT * FROM blocks LIMIT 2" -t

LIST_OF_ERR=""

#------------------------#

function main(){

    echo -e "\nChecking for missed blocks in the database...\n"

    local LAST_BLOCK=$(psql -d ${POSTGRES_DB} -c "SELECT MAX(height) FROM blocks" -tq | xargs)

    echo -e "\n\nLast block in the database: ${LAST_BLOCK}\n"

    find_missing_blocks 1 $LAST_BLOCK

    echo -e "\n\nList of Failed blocks: \n\n${LIST_OF_ERR}\n\n"
}

#------------------------#

function find_missing_blocks(){
    local START=$1
    local END=$2

    local TOTAL_BLOCKS=$(psql -d ${POSTGRES_DB} -c "SELECT COUNT(*) FROM blocks WHERE height >= ${START} AND height <= ${END}" -tq | xargs)
    local EXPECTED_BLOCKS=$((END-START+1))

    if [ $TOTAL_BLOCKS != $EXPECTED_BLOCKS ]; then
        
        if [ $START == $END ]; then
            echo -e "\n\nBlock: ${START} is missing"
            LIST_OF_ERR="${LIST_OF_ERR}${START}, "
        else
            # Call it recursively
            local MIDDLE=$(((START+END)/2))

            find_missing_blocks $START $MIDDLE
            find_missing_blocks $((MIDDLE+1)) $END
        fi
    fi
}

#------------------------#

main

#------------------------#

# Linear slow approach
# BLOCK=1
# LIST_OF_ERR=""
# while : ; do

#     LAST_BLOCK=$(psql -d ${POSTGRES_DB} -c "SELECT MAX(height) FROM blocks" -tq | xargs)

#     if [ $BLOCK == $LAST_BLOCK ]; then
#         echo -e "\n\nAll done :)"
#         break
#     fi

#     OUT=$(psql -d ${POSTGRES_DB} -c "SELECT COUNT(*) FROM blocks WHERE height = ${BLOCK}" -tq | xargs)

#     if [ $OUT == "0" ]; then
#         echo -e "\nBlock: ${BLOCK} is missing"
#         LIST_OF_ERR="${LIST_OF_ERR}${BLOCK}, "
#     fi

#     ((BLOCK++))

#     if [ $((BLOCK%50)) == 0 ]; then
#         printf "\r\tProcessing block ${BLOCK}"
#     fi

# done

# echo -e "\n\nList of Failed blocks: \n\n${LIST_OF_ERR}"