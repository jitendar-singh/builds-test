oc label ns default security.openshift.io/scc.podSecurityLabelSync=false pod-security.kubernetes.io/enforce=privileged pod-security.kubernetes.io/audit=privileged pod-security.kubernetes.io/warn=privileged --overwrite

export CONSOLE_URL=$(oc get routes console -n openshift-console -o jsonpath='{.spec.host}')

export TOKEN=$(oc whoami -t)

export API_URL=$(oc whoami --show-server)/openapi/v3/apis/operator.shipwright.io/v1alpha1
# dast_tool_path=./dast_tool
echo "$CONSOLE_URL"
echo "$API_URL"
# mkdir results
api_doc="open-api"

helm install rapidast helm/chart/ --set-file rapidastConfig=cluster_config.yaml

# wait for pod to be completed or error
rapidast_pod=$(oc get pods -n default -l job-name=rapidast-job -o name)
echo "rapidast current pod $rapidast_pod"
oc wait --for=condition=Ready $rapidast_pod --timeout=120s
response=$($?)
echo "response $response"
oc get $rapidast_pod -o 'jsonpath={..status.conditions}'
while [[ $(oc get $rapidast_pod -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == "True" ]]; do
    echo "sleeping 5"
    sleep 5
    
  done
mkdir results/$api_doc
cp ./helm/chart/values.yaml results/$api_doc/values.yaml

oc logs $rapidast_pod -n default >> results/$api_doc/pod_logs.out

./helm/results.sh
  # ${helm_dir}/helm uninstall rapidast 
  # oc delete pvc rapidast-pvc
#done

phase=$(oc get $rapidast_pod -o jsonpath='{.status.phase}')

if [ $phase != "Succeeded" ]; then
    echo "Pod $rapidast_pod failed. Look at pod logs in archives (results/*/pod_logs.out)"
    exit 1
fi