#!/bin/bash


# monkz, deskz, metakz
approach=$1
# Initial execution
i=$2
# 20 executions, 30 executions, 40 executions
executionNumber=$3
# 6 minutes, 7 minutes, 9 minutes
loadTime=$4
#timeout to rerun in minutes
timeout=$5

until [ $i -gt $executionNumber ]
do
	echo "Generating $i times."

    echo "$(date +"%D %T") - Generating $i times. " >> ./tracker.log

    minikube delete
    minikube start --cpus=5 --memory=8192 --vm-driver hyperv --kubernetes-version=v1.16.10

    

    kubectl create secret docker-registry regcred --docker-username=******* --docker-password=******** --docker-email=********* -n default
    
    echo "Running approach" $approach

    if [ $approach = monkz ]; then
        echo "Runnning Mon-KZ"
        ### MON KZ
        kubectl apply -f ./VersionC-WithFailureManagerMetaController/MetaController/priorityObjectsK8s/
        kubectl apply -k ./tools/monitoring/
        kubectl apply -k ./VersionA-Monolithic/TargetSystem/kube-znn/overlay/default/
        kubectl apply -f ./tools/nginxc-ingress/
        kubectl apply -k ./VersionA-Monolithic/kubow/overlay/kube-znn
        kubectl apply -f ./VersionC-WithFailureManagerMetaController/MicroControllers/tailored_based/k8s/

    elif [ $approach = deskz ]; then
        echo "Runnning Des-KZ"

        ### Des KZ
        kubectl apply -f ./VersionC-WithFailureManagerMetaController/MetaController/priorityObjectsK8s/
        kubectl apply -k ./tools/monitoring/
        kubectl apply -k ./VersionB-Microcontrollers/TargetSystem/kube-znn/overlay/default/
        kubectl apply -f ./tools/nginxc-ingress/
        kubectl apply -k ./VersionB-Microcontrollers/fidelitya_microcontroller/kubow/overlay/kube-znn/
        kubectl apply -k ./VersionB-Microcontrollers/scalabilitya_microcontroller/kubow/overlay/kube-znn/
        kubectl apply -k ./VersionB-Microcontrollers/fidelityb_microcontroller/kubow/overlay/kube-znn/
        kubectl apply -k ./VersionB-Microcontrollers/scalabilityb_microcontroller/kubow/overlay/kube-znn/
        kubectl apply -f ./VersionC-WithFailureManagerMetaController/MicroControllers/tailored_based/k8s/

    elif [ $approach = metakz ]; then
        echo "Runnning Meta-KZ"
        ### Meta KZ
        kubectl apply -f ./VersionC-WithFailureManagerMetaController/MetaController/priorityObjectsK8s/
        kubectl apply -k ./tools/monitoring/
        kubectl apply -k ./VersionC-WithFailureManagerMetaController/TargetSystem/kube-znn/overlay/default/
        kubectl apply -f ./tools/nginxc-ingress/
        kubectl apply -k ./VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/fidelitya_microcontroller/kubow/overlay/kube-znn/
        kubectl apply -k ./VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/scalabilitya_microcontroller/kubow/overlay/kube-znn/
        kubectl apply -k ./VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/fidelityb_microcontroller/kubow/overlay/kube-znn/
        kubectl apply -k ./VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/scalabilityb_microcontroller/kubow/overlay/kube-znn/
        kubectl apply -f ./VersionC-WithFailureManagerMetaController/MicroControllers/tailored_based/k8s/
        kubectl apply -k ./VersionC-WithFailureManagerMetaController/MetaController/kubow/overlay/controller_targetsystem/

    else
        echo "Invalid option for approach"
        exit
    fi

    echo "$(date +"%D %T") - Deployments performed." >> ./tracker.log
    
    watingPods=2

    while [ $watingPods -gt 1 ]; do
        watingPods=$(kubectl get pods | grep -c -v Running)

        echo "Waiting to run k6."
        :
    done

    echo "$(date +"%D %T") - K6 deployed." >> ./tracker.log

    echo "Deployment k6."

    kubectl apply -k ./tools/k6/

    watingPods=0
    while [ $watingPods = 0 ]; do
        watingPods=$(kubectl get pods | grep k6 | grep -c Running)
        echo "Waiting to run logs."
        :
    done

    echo "$(date +"%D %T") - K6 running -- Initial data." >> ./tracker.log
    # Replicas + Image (deployment)
    kubectl describe deployment kube-znn | grep 'cmendes/znn\|desire' >> ./tracker.log 
    
    # counting LOAD
    end=$((SECONDS+(${loadTime}*60)))
    while [ $SECONDS -lt $end ]; do
        kubectl describe deployment kube-znn | grep 'cmendes/znn\|desire'
        :
    done

    echo "$(date +"%D %T") - K6 finishing -- Peak data." >> ./tracker.log 
    # Replicas + Image (deployment) 
    kubectl describe deployment kube-znn | grep 'cmendes/znn\|desire' >> ./tracker.log 

    peakPods=$(kubectl get pods | grep znn | grep -c Running)
    # if peak is corrupted
    if [ $peakPods -lt 3 ]; then
        rm ./tracker.log
        echo "$(date +"%D %T") - Corrupted, restarting execution of ${i}."
        continue
    fi

    # counting UNLOAD
    end=$((SECONDS+(${loadTime}*60)))
    while [ $SECONDS -lt $end ]; do
        kubectl describe deployment kube-znn | grep 'cmendes/znn\|desire'
        :
    done

    echo "$(date +"%D %T") - K6 finised after unload -- Final data." >> ./tracker.log 
    # Replicas + Image (deployment) 
    kubectl describe deployment kube-znn | grep 'cmendes/znn\|desire' >> ./tracker.log 

    endtimeout=$((SECONDS+(${timeout}*60)))

    watingPodsRestauration=3
    while [ $watingPodsRestauration -gt 2 ]; do
        watingPodsRestauration=$(kubectl get pods | grep znn | grep -c Running)
        echo "Wating to finish (restauration replicas). Current number of replicas: "$watingPodsRestauration

        kubectl describe deployment kube-znn | grep 'cmendes/znn\|desire'

        # timeout to restart this execution
        if [ $endtimeout -lt $SECONDS ]; then
            echo "$(date +"%D %T") - exiting restaurating of replicas."
            break
        fi
        :
    done

    # timeout to restart this execution
    if [ $endtimeout -lt $SECONDS ]; then
        rm ./tracker.log
        echo "$(date +"%D %T") - restarting execution of ${i}."
        continue
    fi

    currentImage=000
    while ! [[ $currentImage -eq 800 || $currentImage -eq 200 ]]; do
        currentImage=$(kubectl describe deployment kube-znn | grep 'cmendes/znn' | awk '{print  $2}' | cut -b 13-15)
        echo "Wating to finish (restauration image). Current imagem: "$currentImage

        kubectl describe deployment kube-znn | grep 'cmendes/znn\|desire'
        
        # timeout to restart this execution
        if [ $endtimeout -lt $SECONDS ]; then
            echo "$(date +"%D %T") - exiting restaurating of images."
            break
        fi
        :
    done

    # timeout to restart this execution
    if [ $endtimeout -lt $SECONDS ]; then
        rm ./tracker.log
        echo "$(date +"%D %T") - restarting execution of ${i}."
        continue
    fi

    echo "$(date +"%D %T") - Restauration has finished." >> ./tracker.log
    # Replicas + Image (deployment) 
    kubectl describe deployment kube-znn | grep 'cmendes/znn\|desire' >> ./tracker.log 

    folderName=$approach-$i-$(date +"%H%M%S")
    mkdir $folderName

    # move all txt files to foldername
    find ./*.log -exec mv {} $folderName/ \;

    minikube delete
	i=$(( i+1 ))
done