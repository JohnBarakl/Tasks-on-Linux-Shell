#!/bin/bash

# Δημιουργώ προσωρινούς φακέλους όπου μπορούν να αποθηκευτούν τα
#   ενδιάμεσα αρχεία που δημιουργούνται και δεν απαιτούνται να υπάρχουν
#   στον ίδιο φάκελο με το script.
mkdir -p /tmp/script2_tmp_files/unzipped_tar/

# Δημιουργώ συντομεύσεις για τον φάκελο με τα προσωρινά αρχεία και
#   με εκείνον που (θα) περιέχει τα περιεχόμενα του συμπιεσμένου αρχείου
#   που δίνεται.
TAR_DIR="/tmp/script2_tmp_files/unzipped_tar/"
TMP_DIR="/tmp/script2_tmp_files"

# Αποσυμπίεση αρχείου.
tar xf $1 -C $TAR_DIR

# Ανιχνεύω όλα τα αρχεία .txt εντός του δοθέντος συμπιεσμένου αρχείου
#   και απομονώνω το κάθε ένα σε array.
TXT_FILES=`find $TAR_DIR -name "*.txt"`

# Μετακινώ το τρέχον directory στον φάκελο assignments
    mkdir assignments
    cd assignments
    
# Επεξεργασία κάθε αρχείου για cloning του repository που περιέχει
for txt in "${TXT_FILES[@]}"; do  
    # Απομόνωση της γραμμής
    repo_addr=`cat $txt | sed "s/^#.*//" | grep "^https" -m 1 | sed "s/.*\(https.*\.git\).*/\1/"`
    
    # Έλεγχος για το αν υπάρχει γραμμή με διεύθυνση ενός αποθετηρίου git σε https μορφή:
    if [ `echo $repo_addr | wc -c` -ne 1 ]; then
            
        # Cloning του αποθετηρίου της διεύθυνσης
        git clone -q $repo_addr
        if [ $? -eq 0 ]; then
            echo "$repo_addr": Cloning OK
        else
            echo "$repo_addr": Cloning FAILED >&2 
        fi

    fi
    # Διαφορετικά, το αρχείο αυτό αγνοείται.
done


