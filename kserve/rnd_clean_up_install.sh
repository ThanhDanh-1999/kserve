set -eo pipefail
############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "KServe quick install script."
   echo
   echo "Syntax: [-s|-r]"
   echo "options:"
   echo "s Serverless Mode."
   echo "r RawDeployment Mode."
   echo
}

deploymentMode=serverless
while getopts ":hsr" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      r) # skip knative install
         deploymentMode=kubernetes;;
      s) # install knative
         deploymentMode=serverless;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

export ISTIO_VERSION=1.17.2
export KNATIVE_SERVING_VERSION=knative-v1.10.1
export KNATIVE_ISTIO_VERSION=knative-v1.10.0
export KSERVE_VERSION=v0.11.0
export CERT_MANAGER_VERSION=v1.9.1
export SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"

cleanup(){
  rm -rf istio-${ISTIO_VERSION}
  rm -rf deploy-config-patch.yaml
}
trap cleanup EXIT

get_kube_version(){
    kubectl version --short=true 2>/dev/null || kubectl version | awk -F '.' '/Server Version/ {print $2}'
}

if [ $(get_kube_version) -lt 24 ];
then
   echo "😱 install requires at least Kubernetes 1.24";
   exit 1;
fi

curl -L https://istio.io/downloadIstio | sh -
cd istio-${ISTIO_VERSION}

bin/istioctl uninstall --purge -y;

echo "😀 Successfully deleted Istio"

# # Install Knative
# if [ $deploymentMode = serverless ]; then
#    kubectl delete --filename https://github.com/knative/serving/releases/download/${KNATIVE_SERVING_VERSION}/serving-crds.yaml
#    kubectl delete --filename https://github.com/knative/serving/releases/download/${KNATIVE_SERVING_VERSION}/serving-core.yaml
#    kubectl delete --filename https://github.com/knative/net-istio/releases/download/${KNATIVE_ISTIO_VERSION}/release.yaml
#    echo "😀 Successfully deleted Knative"
# fi

# # Install Cert Manager is exist v1.9.1

# # Install KServe
# KSERVE_CONFIG=kserve.yaml
# MAJOR_VERSION=$(echo ${KSERVE_VERSION:1} | cut -d "." -f1)
# MINOR_VERSION=$(echo ${KSERVE_VERSION} | cut -d "." -f2)
# if [ ${MAJOR_VERSION} -eq 0 ] && [ ${MINOR_VERSION} -le 6 ]; then KSERVE_CONFIG=kfserving.yaml; fi

# # Retry inorder to handle that it may take a minute or so for the TLS assets required for the webhook to function to be provisioned
# kubectl delete -f https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/${KSERVE_CONFIG}

# if [ ${MAJOR_VERSION} -eq 0 ] && [ ${MINOR_VERSION} -le 11 ]; then
#     kubectl delete -f https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/kserve-runtimes.yaml
# else
#     kubectl delete -f https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/kserve-cluster-resources.yaml
# fi

# echo "😀 Successfully deleted KServe"
