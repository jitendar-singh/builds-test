Feature: Assert Shipwright Installation

    Assert the installation of Shipwright and its dependencies in the Kubernetes cluster.

    Scenario: Asserting Shipwright Installation
        Given the Kubernetes cluster is available
        Then we assert if the following controllers are deployed and "READY" in the specified namespace
            | controller                 | namespace             | is_ready |
            | tekton-pipelines-controller| openshift-pipelines   | True     |
            | tekton-pipelines-webhook   | openshift-pipelines   | True     |
            | shipwright-build-controller| shipwright-build      | True     |
        Then the following crds belong to "shipwright.io/v1alpha1" API version:
            | crds                                 | scope      |
            | buildruns.shipwright.io              | Namespaced |
            | builds.shipwright.io                 | Namespaced |
            | buildstrategies.shipwright.io        | Namespaced |
            | clusterbuildstrategies.shipwright.io | Cluster    |
        # And the following "clusterbuildstrategies.shipwright.io" objects are present:
        #     | name            |
        #     | buildah         |
        #     | buildkit        |
        #     | buildpacks-v3   |
        #     | kaniko          |
        #     | ko              |
        #     | source-to-image |