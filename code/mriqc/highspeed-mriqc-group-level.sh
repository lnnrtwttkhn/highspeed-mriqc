#!/usr/bin/bash
# ==============================================================================
# SCRIPT INFORMATION:
# ==============================================================================
# SCRIPT: CREATE GROUP-LEVEL MRIQC REPORTS FOR A BIDS-STRUCTURED DATASET
# ONLY RUN AFTER ALL PARTICIPANT-LEVEL REPORTS ARE FINISHED!
# PROJECT: HIGHSPEED
# WRITTEN BY LENNART WITTKUHN, 2018 - 2020
# CONTACT: WITTKUHN AT MPIB HYPHEN BERLIN DOT MPG DOT DE
# MAX PLANCK RESEARCH GROUP NEUROCODE
# MAX PLANCK INSTITUTE FOR HUMAN DEVELOPMENT (MPIB)
# MAX PLANCK UCL CENTRE FOR COMPUTATIONAL PSYCHIATRY AND AGEING RESEARCH
# LENTZEALLEE 94, 14195 BERLIN, GERMANY
# ACKNOWLEDGEMENT: THANKS TO ALEXANDER SKOWRON AND NIR MONETA @ MPIB FOR HELP
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
PATH_LOG=${PATH_PROJECT}/logs
# ==============================================================================
# CREATE RELEVANT DIRECTORIES:
# ==============================================================================
# create working directory:
if [ ! -d ${PATH_WORK} ]
then
	mkdir -p ${PATH_WORK}
fi
# create directory for log files:
if [ ! -d ${PATH_LOG} ]
then
	mkdir -p ${PATH_LOG}
fi
# ==============================================================================
# RUN MRIQC TO CREATE THE GROUP REPORTS:
# ==============================================================================
# create group reports for the functional data:
singularity run -B ${PATH_INPUT}:/input:ro \
-B ${PATH_OUTPUT}:/output:rw -B ${PATH_WORK}:/work:rw \
-B ${PATH_TEMPLATEFLOW}:/templateflow:rw \
${PATH_CONTAINER} /input/ /output/ group --no-sub
