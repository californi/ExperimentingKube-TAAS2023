#minikube delete
#minikube start --cpus=5 --memory=8192 --vm-driver hyperv --kubernetes-version=v1.16.10
 
#kubectl create secret docker-registry regcred --docker-username=******* --docker-password=***** --docker-email=******* -n default

### MON KZ
#kubectl apply -f ./VersionC-WithFailureManagerMetaController/MetaController/priorityObjectsK8s/
#kubectl apply -k ./tools/monitoring/
#kubectl apply -k ./VersionA-Monolithic/TargetSystem/kube-znn/overlay/default/
#kubectl apply -f ./tools/nginxc-ingress/
#kubectl apply -k ./VersionA-Monolithic/kubow/overlay/kube-znn
#kubectl apply -f ./VersionC-WithFailureManagerMetaController/MicroControllers/tailored_based/k8s/

### DES KZ
kubectl apply -f ./VersionC-WithFailureManagerMetaController/MetaController/priorityObjectsK8s/
kubectl apply -k ./tools/monitoring/
kubectl apply -k ./VersionB-Microcontrollers/TargetSystem/kube-znn/overlay/default/
kubectl apply -f ./tools/nginxc-ingress/
kubectl apply -k ./VersionB-Microcontrollers/fidelitya_microcontroller/kubow/overlay/kube-znn/
kubectl apply -k ./VersionB-Microcontrollers/scalabilitya_microcontroller/kubow/overlay/kube-znn/
kubectl apply -k ./VersionB-Microcontrollers/fidelityb_microcontroller/kubow/overlay/kube-znn/
kubectl apply -k ./VersionB-Microcontrollers/scalabilityb_microcontroller/kubow/overlay/kube-znn/
kubectl apply -f ./VersionC-WithFailureManagerMetaController/MicroControllers/tailored_based/k8s/

### META KZ
#kubectl apply -f ./VersionC-WithFailureManagerMetaController/MetaController/priorityObjectsK8s/
#kubectl apply -k ./tools/monitoring/
#kubectl apply -k ./VersionC-WithFailureManagerMetaController/TargetSystem/kube-znn/overlay/default/
#kubectl apply -f ./tools/nginxc-ingress/
#kubectl apply -k ./VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/fidelitya_microcontroller/kubow/overlay/kube-znn/
#kubectl apply -k ./VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/scalabilitya_microcontroller/kubow/overlay/kube-znn/
#kubectl apply -k ./VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/fidelityb_microcontroller/kubow/overlay/kube-znn/
#kubectl apply -k ./VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/scalabilityb_microcontroller/kubow/overlay/kube-znn/
#kubectl apply -f ./VersionC-WithFailureManagerMetaController/MicroControllers/tailored_based/k8s/
#kubectl apply -k ./VersionC-WithFailureManagerMetaController/MetaController/kubow/overlay/controller_targetsystem/

