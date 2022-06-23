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
   echo "Runs the ghru mlst nextflow pipeline, see https://gitlab.com/cgps/ghru/pipelines/dsl2/pipelines/mlst"
   echo
   echo "optional arguments:"
   echo "  -h, --help		show this help message and exit"
   echo
   echo "required arguments:"
   echo "  -s species		species"
   echo "  -i input_directory	directory containing the FASTQ files to be assembled"
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
      i) # Input directory
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

VALID_SPECIES=false
for TEST in achromobacter_spp. acinetobacter_baumannii aeromonas_spp. anaplasma_phagocytophilum arcobacter_spp. aspergillus_fumigatus bacillus_cereus bacillus_licheniformis bacillus_subtilis bartonella_bacilliformis bartonella_henselae bartonella_washoensis bordetella_spp. borrelia_spp. brachyspira_hampsonii brachyspira_hyodysenteriae brachyspira_intermedia brachyspira_pilosicoli brachyspira_spp. brucella_spp. burkholderia_cepacia_complex burkholderia_pseudomallei campylobacter_concisus_curvus campylobacter_fetus campylobacter_helveticus campylobacter_hyointestinalis campylobacter_insulaenigrae campylobacter_jejuni campylobacter_lanienae campylobacter_lari campylobacter_sputorum campylobacter_upsaliensis candida_albicans candida_glabrata candida_krusei candida_tropicalis candidatus_liberibacter_solanacearum carnobacterium_maltaromaticum chlamydiales_spp. citrobacter_freundii clonorchis_sinensis clostridioides_difficile clostridium_botulinum clostridium_septicum corynebacterium_diphtheriae cronobacter_spp. dichelobacter_nodosus edwardsiella_spp. enterobacter_cloacae enterococcus_faecalis enterococcus_faecium escherichia_coli flavobacterium_psychrophilum gallibacterium_anatis haemophilus_influenzae haemophilus_parasuis helicobacter_cinaedi helicobacter_pylori helicobacter_suis kingella_kingae klebsiella_aerogenes klebsiella_oxytoca klebsiella_pneumoniae kudoa_septempunctata lactobacillus_salivarius leptospira_spp. listeria_monocytogenes macrococcus_canis macrococcus_caseolyticus mannheimia_haemolytica melissococcus_plutonius moraxella_catarrhalis mycobacteria_spp. mycobacterium_abscessus mycobacterium_massiliense mycoplasma_agalactiae mycoplasma_bovis mycoplasma_flocculare mycoplasma_hominis mycoplasma_hyopneumoniae mycoplasma_hyorhinis mycoplasma_iowae mycoplasma_pneumoniae mycoplasma_synoviae neisseria_spp. orientia_tsutsugamushi ornithobacterium_rhinotracheale paenibacillus_larvae pasteurella_multocida pediococcus_pentosaceus photobacterium_damselae piscirickettsia_salmonis porphyromonas_gingivalis propionibacterium_acnes pseudomonas_aeruginosa pseudomonas_fluorescens pseudomonas_putida rhodococcus_spp. riemerella_anatipestifer salmonella_enterica saprolegnia_parasitica sinorhizobium_spp. staphylococcus_aureus staphylococcus_epidermidis staphylococcus_haemolyticus staphylococcus_hominis staphylococcus_lugdunensis staphylococcus_pseudintermedius stenotrophomonas_maltophilia streptococcus_agalactiae streptococcus_bovis_equinus_complex streptococcus_canis streptococcus_dysgalactiae_equisimilis streptococcus_gallolyticus streptococcus_oralis streptococcus_pneumoniae streptococcus_pyogenes streptococcus_suis streptococcus_thermophilus streptococcus_uberis streptococcus_zooepidemicus streptomyces_spp taylorella_spp. tenacibaculum_spp. treponema_pallidum trichomonas_vaginalis ureaplasma_spp. vibrio_cholerae vibrio_parahaemolyticus vibrio_spp. vibrio_tapetis vibrio_vulnificus wolbachia xylella_fastidiosa yersinia_pseudotuberculosis yersinia_ruckeri 
do
    if [[ ${TEST} == *_spp. ]]
    then
        TEST_GENUS=${TEST%*_spp.}
        SPECIES_GENUS=${SPECIES%*_*}
        if [[ $TEST_GENUS == $SPECIES_GENUS ]]
        then
            VALID_SPECIES=$TEST
        fi
    else
        if [[ $SPECIES == $TEST ]]
        then
            VALID_SPECIES=$TEST
        fi
    fi
done

if [[ $VALID_SPECIES == "false" ]]
then
    cat << EOM
$SPECIES is not valid. Supported MLST schemes are:
achromobacter_spp.
acinetobacter_baumannii
aeromonas_spp.
anaplasma_phagocytophilum
arcobacter_spp.
aspergillus_fumigatus
bacillus_cereus
bacillus_licheniformis
bacillus_subtilis
bartonella_bacilliformis
bartonella_henselae
bartonella_washoensis
bordetella_spp.
borrelia_spp.
brachyspira_hampsonii
brachyspira_hyodysenteriae
brachyspira_intermedia
brachyspira_pilosicoli
brachyspira_spp.
brucella_spp.
burkholderia_cepacia_complex
burkholderia_pseudomallei
campylobacter_concisus_curvus
campylobacter_fetus
campylobacter_helveticus
campylobacter_hyointestinalis
campylobacter_insulaenigrae
campylobacter_jejuni
campylobacter_lanienae
campylobacter_lari
campylobacter_sputorum
campylobacter_upsaliensis
candida_albicans
candida_glabrata
candida_krusei
candida_tropicalis
candidatus_liberibacter_solanacearum
carnobacterium_maltaromaticum
chlamydiales_spp.
citrobacter_freundii
clonorchis_sinensis
clostridioides_difficile
clostridium_botulinum
clostridium_septicum
corynebacterium_diphtheriae
cronobacter_spp.
dichelobacter_nodosus
edwardsiella_spp.
enterobacter_cloacae
enterococcus_faecalis
enterococcus_faecium
escherichia_coli
flavobacterium_psychrophilum
gallibacterium_anatis
haemophilus_influenzae
haemophilus_parasuis
helicobacter_cinaedi
helicobacter_pylori
helicobacter_suis
kingella_kingae
klebsiella_aerogenes
klebsiella_oxytoca
klebsiella_pneumoniae
kudoa_septempunctata
lactobacillus_salivarius
leptospira_spp.
listeria_monocytogenes
macrococcus_canis
macrococcus_caseolyticus
mannheimia_haemolytica
melissococcus_plutonius
moraxella_catarrhalis
mycobacteria_spp.
mycobacterium_abscessus
mycobacterium_massiliense
mycoplasma_agalactiae
mycoplasma_bovis
mycoplasma_flocculare
mycoplasma_hominis
mycoplasma_hyopneumoniae
mycoplasma_hyorhinis
mycoplasma_iowae
mycoplasma_pneumoniae
mycoplasma_synoviae
neisseria_spp.
orientia_tsutsugamushi
ornithobacterium_rhinotracheale
paenibacillus_larvae
pasteurella_multocida
pediococcus_pentosaceus
photobacterium_damselae
piscirickettsia_salmonis
porphyromonas_gingivalis
propionibacterium_acnes
pseudomonas_aeruginosa
pseudomonas_fluorescens
pseudomonas_putida
rhodococcus_spp.
riemerella_anatipestifer
salmonella_enterica
saprolegnia_parasitica
sinorhizobium_spp.
staphylococcus_aureus
staphylococcus_epidermidis
staphylococcus_haemolyticus
staphylococcus_hominis
staphylococcus_lugdunensis
staphylococcus_pseudintermedius
stenotrophomonas_maltophilia
streptococcus_agalactiae
streptococcus_bovis_equinus_complex
streptococcus_canis
streptococcus_dysgalactiae_equisimilis
streptococcus_gallolyticus
streptococcus_oralis
streptococcus_pneumoniae
streptococcus_pyogenes
streptococcus_suis
streptococcus_thermophilus
streptococcus_uberis
streptococcus_zooepidemicus
streptomyces_spp
taylorella_spp.
tenacibaculum_spp.
treponema_pallidum
trichomonas_vaginalis
ureaplasma_spp.
vibrio_cholerae
vibrio_parahaemolyticus
vibrio_spp.
vibrio_tapetis
vibrio_vulnificus
wolbachia
xylella_fastidiosa
yersinia_pseudotuberculosis
yersinia_ruckeri
EOM
exit;
fi

RAND=$(date +%s%N | cut -b10-19)
OUT_DIR=${INPUT_DIR}/ghru-mlst-1.4_${RAND}
WORK_DIR=${OUT_DIR}/work
NEXTFLOW_PIPELINE_DIR='/home/software/nf-pipelines/mlst-1.2'
MLST_SPECIES=$(echo ${VALID_SPECIES} | sed -e 's/^\(.\)/\U\1/' | sed -e 's/_/ /g')

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input data is: "$INPUT_DIR
echo "Output will be written to: "$OUT_DIR

nextflow run \
${NEXTFLOW_PIPELINE_DIR}/main.nf \
--input_dir ${INPUT_DIR} \
--fastq_pattern '*{R,_}{1,2}.f*q.gz' \
--output_dir ${OUT_DIR} \
--read_polishing_depth_cutoff 100 \
--mlst_species "${MLST_SPECIES}" \
-w ${WORK_DIR} \
-with-tower -resume \
-c /home/software/nf_pipeline_scripts/conf/pipelines/ghru_mlst.config

# Clean up on sucess/exit 0
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${WORK_DIR}
fi
