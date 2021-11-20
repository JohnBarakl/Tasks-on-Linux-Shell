#!/bin/bash
# Άσκηση 1 - Έλεγχος ενημέρωσης ιστοσελίδων

# Διαγράφω τα σχόλια από την είσοδο και εισάγω του συνδέσμους των ιστοσελίδων σε array.
WEBSITES=(`sed "/^#.*$/d" $1`)

# Το όνομα του αρχείου με το "ιστορικό" της προηγούμενης έκδοσης κάθε σελίδας.
HSF=".history.txt"

# Αν δεν υπάρχει ήδη, δημιουργώ το αρχείο ιστορικού
if [ `ls -l | grep ".history.txt" | wc -l` -eq 0 ]; then
    touch $HSF || echo "Πρόβλημα με την δημιουργία αρχείου!"
fi

for ws in $WEBSITES; do
    HS_RECORD=`grep "$ws" $HSF` # Η γραμμή του αρχείου με το όνομα και τα παλιά δεδομένα της σελίδας
    
    WEBSITE_CONTENTS=`curl -s $ws` 
    
    # Έλεγχος για το άν είναι δυνατή η ανάγνωση των περιεχομένων μιας ιστοσελίδας.
    # Αν η curl εκτελέστηκε και επέστρεψε 0, τότε είναι.
    if [ $? -eq 0 ]; then
            WBS_NEW_HST=`echo $WEBSITE_CONTENTS | md5sum`
    else
            # Όταν δεν είναι δυνατή η ανάγνωση, αντί για το md5sum, έχω το string "[FAILED]" ως νέο ιστορικό σελίδας.
            WBS_NEW_HST='[FAILED]'
            echo $ws "FAILED"
    fi
    
    echo "here"
        
    # Αν δεν υπάρχει αναφορά της σελίδας στο ιστορικό και απέτυχε η ανάγνωση της, την αγνοώ.
    # Διαφορετικά
    if [ `wc -l $HS_RECORD` -eq 0 -a WBS_NEW_HST != '[FAILED]' ]; then
        echo $ws "INIT"
        echo $ws","WBS_NEW_HST >> $HSF
    else
        WBS_OLD_HST=`cut -f 2 -d "," $HS_RECORD`
        if [ WBS_OLD_HST != WBS_NEW_HST -a WBS_NEW_HST != '[FAILED]' ]; then
            echo $ws
        fi
        sed -i "s/\(.*\),.*/\1,$WBS_NEW_HST/"
    fi
    
    
done


old=`cut -f 2 -d ',' $HS_RECORD`
