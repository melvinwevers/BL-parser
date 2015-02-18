
PARENT_ID=$$

if [ -z "$3" ]; then
    echo " USAGE: $0 FORMAT INPUT_DIR OUTPUT_DIR [NR_OF_PROCESSES [EXT]]"
    echo
    echo "   Convert all .xml files in INPUT_DIR to OUTPUT_DIR"
    echo "   Files are assumed to be in a certain FORMAT"
    echo
    echo "   If you have multiple cores at your disposal, you can specify how many threads"
    echo "   to use in parallel"
    echo
    echo "   If OUTPUT_DIR does not exist it will be created"     
    echo "   If a different file extension than '.json' is to be used, provide this as"
    echo "   4th argument"
    echo

    exit
fi

FORMAT=$1
INPUT_DIR=$2
OUTPUT_DIR=$3
NR_OF_PROCESSES=${4:-1}
EXT=${5:-json}

if [ ! -d $OUTPUT_DIR ]; then
    echo "Creating directory $OUTPUT_DIR"
    mkdir $OUTPUT_DIR
fi

for FILE in $(ls $INPUT_DIR | grep -i xml); do
    INPUT_FILE=$INPUT_DIR/$FILE
    OUTPUT_FILE=$OUTPUT_DIR/$FILE.$EXT

    echo "Converting $INPUT_FILE -> $OUTPUT_FILE" 
    perl xmlParser.pl $FORMAT $INPUT_FILE > $OUTPUT_FILE &

    NUM_CHILDREN=$(pgrep -P $PARENT_ID | wc -l)
    while [ $NUM_CHILDREN -ge $NR_OF_PROCESSES ]; do
        sleep 1
        NUM_CHILDREN=$(($(pgrep -P $PARENT_ID | wc -l) - 1))
    done
done

wait