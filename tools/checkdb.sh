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

    echo -e "\nChecking for missed blocks in the database..."

    local LAST_BLOCK=$(psql -d ${POSTGRES_DB} -c "SELECT MAX(height) FROM blocks" -tq | xargs)

    if [ -z "${LAST_BLOCK}" ]; then
        echo "No blocks in the database"
        LAST_BLOCK=0
    fi

    echo -e "Last block in the database: ${LAST_BLOCK}\n"

    find_missing_blocks 1 $LAST_BLOCK

    
    if [ "${LIST_OF_ERR}" == "" ]; then
        echo -e "\nNo missed blocks found\n"
    else
        echo -e "\nMissed blocks found:"
        echo -e "\n${LIST_OF_ERR}\n\n"
    fi

}

#------------------------#

function find_missing_blocks(){
    local START=$1
    local END=$2

    local TOTAL_BLOCKS=$(psql -d ${POSTGRES_DB} -c "SELECT COUNT(*) FROM blocks WHERE height >= ${START} AND height <= ${END}" -tq | xargs)
    local EXPECTED_BLOCKS=$((END-START+1))

    if [ $TOTAL_BLOCKS != $EXPECTED_BLOCKS ]; then
        
        if [ $START == $END ]; then
            echo -e "Block: ${START} is missing"
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