#!/bin/bash
# Άσκηση 1 - Έλεγχος ενημέρωσης ιστοσελίδων

# Ορισμός συνάρτησης που δέχεται ως πρώτη παράμετρο μία ιστοσελίδα και επιτελεί το έργο του
#   ελέγχου για την ενημερώτητα αυτής.
check_website(){
    HS_RECORD=`grep "$1" $HSF` # Η γραμμή του αρχείου με το όνομα και τα παλιά δεδομένα της σελίδας
    
    WEBSITE_CONTENTS=`curl -s $1` 
    
    # Έλεγχος για το άν είναι δυνατή η ανάγνωση των περιεχομένων μιας ιστοσελίδας.
    # Αν η curl εκτελέστηκε και επέστρεψε 0, τότε είναι.
    if [ $? -eq 0 ]; then
            WBS_NEW_HST=`echo $WEBSITE_CONTENTS | md5sum | sed "s/\(.*\)  -.*/\1/"`
    else
            # Όταν δεν είναι δυνατή η ανάγνωση, αντί για το md5sum, έχω το string "[FAILED]" ως νέο ιστορικό σελίδας.
            WBS_NEW_HST='[FAILED]'
            echo $1 "FAILED"
    fi
        
    # Αν δεν υπάρχει αναφορά της σελίδας στο ιστορικό και απέτυχε η ανάγνωση της, την αγνοώ.
    # Διαφορετικά
    if [ \( `echo "$HS_RECORD" | wc -c` -eq 1 \) -a \( "$WBS_NEW_HST" != '[FAILED]' \) ]; then
        echo $1 "INIT"
        echo $1","$WBS_NEW_HST >> $HSF
    else
        WBS_OLD_HST=`echo $HS_RECORD | cut -f 2 -d "," | tr -d '[:space:]'`
        if [ \( "$WBS_OLD_HST" != "$WBS_NEW_HST" \) -a \( "$WBS_NEW_HST" != '[FAILED]' \) ]; then
            echo $1
        fi
        sed -i "s|$1,.*|$1,$WBS_NEW_HST|g" "$HSF"
    fi
}

# Διαγράφω τα σχόλια από την είσοδο και εισάγω του συνδέσμους των ιστοσελίδων σε array.
WEBSITES=(`sed "/^#.*$/d" $1 | sed "/^$/d"`);

# Το όνομα του αρχείου με το "ιστορικό" της προηγούμενης έκδοσης κάθε σελίδας.
HSF=".history.txt";

# Αν δεν υπάρχει ήδη, δημιοws=υργώ το αρχείο ιστορικού
if [ `ls -l | grep ".history.txt" | wc -l` -eq 0 ]; then
    touch $HSF || echo "Πρόβλημα με την δημιουργία αρχείου!";
fi

for ws in "${WEBSITES[@]}"; do  
    check_website "$ws";
done
