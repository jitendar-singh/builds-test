# @mark.steps
# ----------------------------------------------------------------------------
# STEPS:
# ----------------------------------------------------------------------------
import subprocess
import kubernetes
import ipaddress
import os
import re
import polling2
import parse
import binascii
import yaml
import json
import time

from behave import given, register_type, then, when, step
from namespace import Namespace
from openshift import Openshift
from command import Command
from environment import ctx
from subscription_install_mode import InstallMode
from hamcrest import assert_that, equal_to
from util import scenario_id, substitute_scenario_id, get_env


openshift = Openshift()
cmd = Command()

@given(u'the Kubernetes cluster is available')
def assert_cluster_connection(context):
    output, code = cmd.run(f'oc get ns default -o jsonpath="{{.metadata.name}}"')
    assert code == 0, f"Checking connection to OS cluster by getting the 'default' project failed: {output}"

@then(u'we assert if the following controllers are deployed and "READY" in the specified namespace')
def asert_controllers(context):
    model = getattr(context, "model", None)
    if not model:
        context.model = Openshift()
    for row in context.table:
        res = context.model.get_deployment_status(row["controller"], row["namespace"])
        assert_that(row["is_ready"],equal_to(res.strip()))

@then(u'the following crds belong to "shipwright.io/v1alpha1" API version')
def assert_reources(context):
    model = getattr(context, "model", None)
    jq_expression = '.spec.scope'
    if not model:
        context.model = Openshift()
    for row in context.table:
        res = context.model.get_resource_info_by_jq("crd", row["crds"], jq_expression)
        assert_that(row["scope"],equal_to(res.strip()))


@then(u'the following "clusterbuildstrategies.shipwright.io" objects are present')
def step_impl(context):
    raise NotImplementedError(u'STEP: Then the following "clusterbuildstrategies.shipwright.io" objects are present')