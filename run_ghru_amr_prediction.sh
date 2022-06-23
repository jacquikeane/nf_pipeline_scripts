#!/bin/bash

export NXF_ANSI_LOG=false
export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

function help
{
   # Display Help
   script=$(basename $0)
   echo 
   echo "usage: "$script" [-h] -s species -i input_directory"
   echo
   echo "Runs the ghru amr prediction nextflow pipeline, see https://gitlab.com/cgps/ghru/pipelines/dsl2/pipelines/amr_prediction"
   echo
   echo "optional arguments:"
   echo "  -h, --help           show this help message and exit"
   echo
   echo "required arguments:"
   echo "  -s species		species"
   echo "  -i input_directory   directory containing the FASTQ files"
   echo
   echo "To run this pipeline with alternative parameters, copy this script and make changes to nextflow run as required"
   echo
}

# Check number of input parameters 

NAG=$#

if [ $NAG -ne 1 ] && [ $NAG -ne 4 ] && [ $NAG -ne 5 ]
then
  help
  echo "!!! Please provide the correct number of input arguments"
  echo
  exit;
fi

# Get the options
while getopts "hs:i:" option; do
   case $option in
      h) # display help
         help
         exit;;
      s) # Species
         SPECIES=$OPTARG;;
      i) #  Input directory
         INPUT_DIR=$OPTARG;;
     \?) # Invalid option
         help
         echo "!!!Error: Invalid arguments"
         exit;;
   esac
done


# Check the input directory exists

if [ ! -d $INPUT_DIR ]
then
  help
  echo "!!! The directory $INPUT_DIR does not exist"
  echo
  exit;
fi

RAND=$(date +%s%N | cut -b10-19)
OUT_DIR=${INPUT_DIR}/amr_prediction-1.1_${RAND}
WORK_DIR=${OUT_DIR}/work
NEXTFLOW_PIPELINE_DIR='/home/software/nf-pipelines/amr_prediction-1.1'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input data is: "$INPUT_DIR
echo "Output will be written to: "$OUT_DIR

ARIBA_POINTFINDER_SPECIES=""
for TEST in campylobacter enterococcus_faecalis enterococcus_faecium escherichia_coli helicobacter_pylori klebsiella mycobacterium_tuberculosis neisseria_gonorrhoeae salmonella staphylococcus_aureus
do
    if [[ $SPECIES == $TEST* ]]
    then
        ARIBA_POINTFINDER_SPECIES=$TEST
    fi
done

if [[ $ARIBA_POINTFINDER_SPECIES != "" ]]
then
    nextflow run \
    ${NEXTFLOW_PIPELINE_DIR}/main.nf \
    --input_dir ${INPUT_DIR} \
    --fastq_pattern '*{R,_}{1,2}.f*q.gz' \
    --output_dir ${OUT_DIR} \
    --read_polishing_adapter_file ${NEXFLOW_PIPELINE_DIR}/adapters.fas \
    --read_polishing_depth_cutoff 100 \
    --species ${ARIBA_POINTFINDER_SPECIES} \
    -w ${WORK_DIR} \
    -with-tower -resume \
    -c /home/software/nf_pipeline_scripts/conf/pipelines/ghru_amr_prediction.config
else
    nextflow run \
    ${NEXTFLOW_PIPELINE_DIR}/main.nf \
    --input_dir ${INPUT_DIR} \
    --fastq_pattern '*{R,_}{1,2}.f*q.gz' \
    --output_dir ${OUT_DIR} \
    --read_polishing_adapter_file ${NEXFLOW_PIPELINE_DIR}/adapters.fas \
    --read_polishing_depth_cutoff 100 \
    -w ${WORK_DIR} \
    -with-tower -resume \
    -c /home/software/nf_pipeline_scripts/conf/bakersrv1.config,/home/software/nf_pipeline_scripts/conf/pipelines/ghru_amr_prediction.config
 fi

# Clean up on sucess/exit 0
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${WORK_DIR}
fi
