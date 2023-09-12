SHELL = /usr/bin/env bash -o pipefail
SHELLFLAGS = -ec

.PHONY: acceptance
acceptance:
	@echo "Testing the test framework on openshift"
	@./hack/test-setup.sh