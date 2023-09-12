#!/bin/bash

set -o pipefail
# TODO: Re-enable once we have the correct image being used in openshift/release
#set -o errexit

#-----------------------------------------------------------------------------
# Global Variables
#-----------------------------------------------------------------------------
export V_FLAG=-v
export OUTPUT_DIR
OUTPUT_DIR=$(pwd)/out
export LOGS_DIR="${OUTPUT_DIR}"/logs
export GOLANGCI_LINT_BIN="${OUTPUT_DIR}"/golangci-lint
export PYTHON_VENV_DIR="${OUTPUT_DIR}"/venv3
# -- Variables for ACCEPTANCE tests
export TEST_ACCEPTANCE_ARTIFACTS=/tmp/artifacts

# -- Setting up the venv
python3 -m venv "${PYTHON_VENV_DIR}"
"${PYTHON_VENV_DIR}"/bin/pip install --upgrade setuptools
"${PYTHON_VENV_DIR}"/bin/pip install --upgrade pip
# -- Generating a new namespace name
# echo "test-namespace-$(uuidgen | tr '[:upper:]' '[:lower:]' | head -c 8)" > "${OUTPUT_DIR}"/test-namespace
# if [ "$OPENSHIFT_CI" = true ]; then
#     # openshift-ci will not allow to create different namespaces, so will do all in the same namespace.
#     oc project -q > "${OUTPUT_DIR}"/test-namespace
# fi
# TEST_NAMESPACE=$(cat "${OUTPUT_DIR}"/test-namespace)
# export TEST_NAMESPACE
# echo "Assigning value to variable TEST_NAMESPACE=${TEST_NAMESPACE}"

mkdir -p "${LOGS_DIR}"/ACCEPTANCE-tests-logs
mkdir -p "${OUTPUT_DIR}"/ACCEPTANCE-tests-output
touch "${OUTPUT_DIR}"/backups.txt
export TEST_ACCEPTANCE_OUTPUT_DIR="${OUTPUT_DIR}"/ACCEPTANCE
echo "Logs directory created at ${LOGS_DIR}/ACCEPTANCE"

# -- Trigger the test
echo "Acceptance test starting"
"${PYTHON_VENV_DIR}"/bin/pip install -q -r test/acceptance/features/requirements.txt
echo "Running ACCEPTANCE tests in namespace with TEST_NAMESPACE=${TEST_NAMESPACE}"
echo "Logs will be collected in ""${TEST_ACCEPTANCE_OUTPUT_DIR}"
"${PYTHON_VENV_DIR}"/bin/behave --junit --junit-directory "${TEST_ACCEPTANCE_OUTPUT_DIR}" \
                              --no-capture --no-capture-stderr \
                              test/acceptance/features
echo "Logs collected in ""${TEST_ACCEPTANCE_OUTPUT_DIR}"