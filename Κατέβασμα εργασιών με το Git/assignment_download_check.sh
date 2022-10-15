#!/bin/bash
# Άσκηση 2 - Κατέβασμα εργασιών με το Git

# Δημιουργώ προσωρινούς φακέλους όπου μπορούν να αποθηκευτούν τα
#   αρχεία που δημιουργούνται και δεν απαιτούνται να υπάρχουν
#   στον ίδιο φάκελο με το script. Η μεταβλητή NOW_TIME αποθηκεύει τον αριθμό των δευτερολέπτων
#   που έχουν περάσει από 1970-01-01 00:00:00 UTC, ως τρόπο να αποφευχθεί να χρησιμοποιηθεί παραπάνω από μία
#   φορές ο ίδιος κατάλογος με διαφορετικά ορίσματα σε διαφορετικές εκτελέσεις του script.
#
# Επίσης, δημιουργώ συντομεύσεις για τον φάκελο με τα προσωρινά αρχεία και
#   με εκείνον που (θα) περιέχει τα περιεχόμενα του συμπιεσμένου αρχείου
#   που δίνεται.
NOW_TIME=`date "+%s"`
TMP_DIR=`echo "/tmp/script2_tmp_files_""$NOW_TIME""/"`
TAR_DIR=`echo "$TMP_DIR""unzipped_tar/"`
mkdir -p $TAR_DIR

# Αποσυμπίεση αρχείου.
tar xf "$1" -C $TAR_DIR

# Ανιχνεύω όλα τα αρχεία .txt εντός του δοθέντος συμπιεσμένου αρχείου
#   και απομονώνω το κάθε ένα σε array.
TXT_FILES=(`find $TAR_DIR -name "*.txt"`)

# Μετακινώ το τρέχον directory στον φάκελο assignments
    mkdir -p assignments
    cd ./assignments
    
# Επεξεργασία κάθε αρχείου για cloning του repository που περιέχει
for txt in "${TXT_FILES[@]}"; do  
    # Απομόνωση της πρώτης διεύθυνσης αποθετηρίου από το αρχείο.
    repo_addr=`cat $txt | sed "/^#.*/d" | grep "^https" -m 1 | sed "s/.*\(https.*\.git\).*/\1/"`
    
    # Έλεγχος για το αν υπάρχει στο τρέχον αρχείο γραμμή με διεύθυνση ενός αποθετηρίου git σε https μορφή:
    if [ `echo $repo_addr | wc -c` -ne 1 ]; then
            
        # Cloning του αποθετηρίου της διεύθυνσης
        git clone -q $repo_addr 2> /tmp/script2_sh_errors
        if [ $? -eq 0 ]; then
            echo "$repo_addr": Cloning OK
        else
            echo "$repo_addr": Cloning FAILED >&2 
        fi

    fi
    # Διαφορετικά, το αρχείο αυτό αγνοείται.
done

# Για κάθε repository που κλωνοποιήθηκε, έλεγχος δομής και μέτρηση αριθμού καταλόγων και αρχείων που περιέχει.
LIST_OF_REPOS=(`ls -d */ | sed "s|\(.*\)/.*|\1|"`)

for dr in "${LIST_OF_REPOS[@]}"; do  
    # Μετακίνηση στον φάκελο του αποθετηρίου
    cd ./"$dr"/
    
    echo "$dr":
    
    DIR_N=`find ./* -type d | wc -l`
    echo "Number of directories:" "$DIR_N"
    TXT_N=`find ./ -name "*.txt" | wc -l`
    echo "Number of txt files:" "$TXT_N"
    FILE_N=`find ./ -not -path "*/\.git*" -name "*" -type f | wc -l`
    OTHER_FILE_N=$(( $FILE_N - $TXT_N ))
    echo "Number of other files:" "$OTHER_FILE_N"
    
    OK_FILE_STR=$'./\n./more\n./more/dataC.txt\n./more/dataB.txt\n./dataA.txt'
    
    THIS_FILE_STR=`find ./ -not -path "*/\.git*"`
    
    if [ "$THIS_FILE_STR" = "$OK_FILE_STR" ]; then
        echo "Directory structure is OK."
    else
        echo "Directory structure is NOT OK." >&2
    fi
    
    # Μετακίνηση πίσω στον φάκελο με τα αποθετήρια
    cd ..
done
