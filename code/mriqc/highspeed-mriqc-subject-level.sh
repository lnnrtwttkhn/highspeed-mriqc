#!/usr/bin/bash
# ==============================================================================
# SCRIPT INFORMATION:
# ==============================================================================
# SCRIPT: CREATE PARTICIPANT-LEVEL MRIQC REPORTS FOR A BIDS-STRUCTURED DATASET
# PROJECT: HIGHSPEED
# WRITTEN BY LENNART WITTKUHN, 2018 - 2020
# CONTACT: WITTKUHN AT MPIB HYPHEN BERLIN DOT MPG DOT DE
# MAX PLANCK RESEARCH GROUP NEUROCODE
# MAX PLANCK INSTITUTE FOR HUMAN DEVELOPMENT (MPIB)
# MAX PLANCK UCL CENTRE FOR COMPUTATIONAL PSYCHIATRY AND AGEING RESEARCH
# LENTZEALLEE 94, 14195 BERLIN, GERMANY
# ACKNOWLEDGEMENTS: THANKS TO ALEXANDER SKOWRON AND NIR MONETA @ MPIB FOR HELP
# ==============================================================================
# DEFINE ALL PATHS:
# ==============================================================================
# path to the base directory:
PATH_BASE="${HOME}"
# path to the project root directory
PATH_ROOT="${PATH_BASE}/highspeed"
# define the name of the project:
PROJECT_NAME="highspeed-mriqc"
# define the path to the project folder:
PATH_PROJECT="${PATH_ROOT}/${PROJECT_NAME}"
# define the name of the current task:
TASK_NAME="mriqc"
# define the path to the script main directory:
PATH_CODE="${PATH_PROJECT}/code"
# cd into the directory of the current task:
cd "${PATH_CODE}"
# define the path to the singularity container:
PATH_CONTAINER="${PATH_PROJECT}/tools/${TASK_NAME}/${TASK_NAME}_0.15.2rc1.sif"
# define the path for the templateflow cache
PATH_TEMPLATEFLOW="${PATH_BASE}/.cache/templateflow"
# path to the data directory (in bids format):
PATH_INPUT="${PATH_PROJECT}/bids"
# path to the output directory:
PATH_OUTPUT=${PATH_PROJECT}
# path to the working directory:
PATH_WORK=${PATH_PROJECT}/work
# path to the log directory:
PATH_LOG=${PATH_PROJECT}/logs/$(date '+%Y%m%d_%H%M%S')
# path to the text file with all subject ids:
PATH_SUB_LIST="${PATH_CODE}/highspeed-participant-list.txt"
# ==============================================================================
# CREATE RELEVANT DIRECTORIES:
# ==============================================================================
# create output directory:
if [ ! -d ${PATH_OUTPUT} ]
then
	mkdir -p ${PATH_OUTPUT}
fi
# create working directory:
if [ ! -d ${PATH_WORK} ]
then
	mkdir -p ${PATH_WORK}
fi
# create directory for log files:
if [ ! -d ${PATH_LOG} ]
then
	mkdir -p ${PATH_LOG}
else
	# remove old log files inside the log container:
	rm -r ${PATH_LOG}/*
fi
# ==============================================================================
# DEFINE PARAMETERS:
# ==============================================================================
# maximum number of cpus per process:
N_CPUS=5
# memory demand in *GB*
MEM_GB=9
# read subject ids from the list of the text file:
SUB_LIST=$(cat ${PATH_SUB_LIST} | tr '\n' ' ')
# declare an array with sessions you want to run:
declare -a SESSIONS=("01" "02")
#for SUB in ${SUB_LIST}; do
# ==============================================================================
# RUN MRIQC:
# ==============================================================================
# initilize a subject counter:
SUB_COUNT=0
for SUB in ${SUB_LIST}; do
	# update the subject counter:
	let SUB_COUNT=SUB_COUNT+1
	# create the subject number with zero-padding:
	SUB_PAD=$(printf "%02d\n" ${SUB_COUNT})
	# loop over all sessions:
	for SES in ${SESSIONS[@]}; do
		# create a new job file:
		echo "#!/bin/bash" > job
		# name of the job
		echo "#SBATCH --job-name mriqc_sub-${SUB_PAD}_ses-${SES}" >> job
		# add partition to job
		echo "#SBATCH --partition gpu" >> job
		# set the expected maximum running time for the job:
		echo "#SBATCH --time 24:00:00" >> job
		# determine how much RAM your operation needs:
		echo "#SBATCH --mem ${MEM_GB}GB" >> job
		# email notification on abort/end, use 'n' for no notification:
		echo "#SBATCH --mail-type NONE" >> job
		# write log to log folder:
		echo "#SBATCH --output ${PATH_LOG}/slurm-%j.out" >> job
		# request multiple cpus:
		echo "#SBATCH --cpus-per-task ${N_CPUS}" >> job
		# export template flow environment variable:
		echo "export SINGULARITYENV_TEMPLATEFLOW_HOME=/templateflow" >> job
		# define the main command:
		echo "singularity run -B ${PATH_INPUT}:/input:ro \
		-B ${PATH_OUTPUT}:/output:rw -B ${PATH_WORK}:/work:rw \
		-B ${PATH_TEMPLATEFLOW}:/templateflow:rw \
		${PATH_CONTAINER} /input/ /output/ participant --participant-label ${SUB_PAD} \
		--session-id ${SES} -w /work/ --verbose-reports --write-graph \
		--n_cpus ${N_CPUS} --mem_gb ${MEM_GB} --no-sub" >> job
		# submit job to cluster queue and remove it to avoid confusion:
		sbatch job
		rm -f job
	done
done
