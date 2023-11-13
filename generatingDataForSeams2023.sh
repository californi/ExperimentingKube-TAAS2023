
#!/bin/bash

i=1
until [ $i -gt 30 ]
do
	echo "Generating $i times."

    echo "$(date +"%D %T") - Generating $i times. " >> ./tracker.log

    minikube delete
    minikube start --cpus=5 --memory=8192 --vm-driver hyperv --kubernetes-version=v1.16.10

    echo "Running approach B: "	

    kubectl create secret docker-registry regcred --docker-username=****** --docker-password=******* --docker-email=*********** -n default
    
    ### MON KZ - testado e funcionando
    #kubectl apply -f ./VersionC-WithFailureManagerMetaController/MetaController/priorityObjectsK8s/
    #kubectl apply -k ./tools/monitoring/
    #kubectl apply -k ./VersionA-Monolithic/TargetSystem/kube-znn/overlay/default/
    #kubectl apply -f ./tools/nginxc-ingress/
    #kubectl apply -k ./VersionA-Monolithic/kubow/overlay/kube-znn
    #kubectl apply -f ./VersionC-WithFailureManagerMetaController/MicroControllers/tailored_based/k8s/


    ### Des KZ - testado e funcionando
    kubectl apply -f ./VersionC-WithFailureManagerMetaController/MetaController/priorityObjectsK8s/
    kubectl apply -k ./tools/monitoring/
    kubectl apply -k ./VersionB-Microcontrollers/TargetSystem/kube-znn/overlay/default/
    kubectl apply -f ./tools/nginxc-ingress/
    kubectl apply -k ./VersionB-Microcontrollers/fidelitya_microcontroller/kubow/overlay/kube-znn/
    kubectl apply -k ./VersionB-Microcontrollers/scalabilitya_microcontroller/kubow/overlay/kube-znn/
    kubectl apply -k ./VersionB-Microcontrollers/fidelityb_microcontroller/kubow/overlay/kube-znn/
    kubectl apply -k ./VersionB-Microcontrollers/scalabilityb_microcontroller/kubow/overlay/kube-znn/
    kubectl apply -f ./VersionC-WithFailureManagerMetaController/MicroControllers/tailored_based/k8s/

    ### Meta KZ
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

    echo "$(date +"%D %T") - Deployments realizados." >> ./tracker.log
    

    watingPods=2

    while [ $watingPods -gt 1 ]; do
        watingPods=$(kubectl get pods | grep -c -v Running)

        echo "Waiting to run k6."
        :
    done

    echo "$(date +"%D %T") - K6 implantado." >> ./tracker.log

    echo "Deployment k6."

    kubectl apply -k ./tools/k6/

    watingPods=0
    while [ $watingPods = 0 ]; do
        watingPods=$(kubectl get pods | grep k6 | grep -c Running)
        echo "Waiting to run logs."
        :
    done

    echo "$(date +"%D %T") - K6 rodando." >> ./tracker.log

    python ./test/apptrackingupdatesznn/app2.py

    python ./test/apptrackingupdatesznn/generateSummary.py > summary-trace-znn.log     

    echo "$(date +"%D %T") - Terminadas carga e descarga." >> ./tracker.log

    watingPodsRestauration=3
    while [ $watingPodsRestauration -gt 2 ]; do
        watingPodsRestauration=$(kubectl get pods | grep znn | grep -c Running)
        echo "Wating to finish (restauration)."
        :
    done

    echo "$(date +"%D %T") - Restauracao realizada." >> ./tracker.log

    folderName=generateLogs$(date +"%H%M%S")
    mkdir $folderName

    # move all txt files to foldername
    find ./*.log -exec mv {} $folderName/ \;

    minikube delete
	i=$(( i+1 ))
done