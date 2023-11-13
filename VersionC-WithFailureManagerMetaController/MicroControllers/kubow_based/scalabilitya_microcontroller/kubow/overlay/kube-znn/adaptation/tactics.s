module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };

define boolean isStable = M.kubeZnnD.stability == 0;
define boolean sloRed = M.kubeZnnS.slo <= 0.95;

tactic addReplica() {
  int futureReplicas = M.kubeZnnD.desiredReplicas + 1;
  condition {
    sloRed && M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas;
  }
  action {
    M.scaleUp(M.kubeZnnD, 1);
  }
  effect @[35000] {
    futureReplicas == M.kubeZnnD.desiredReplicas;
  }
}

tactic removeReplica() {
  int futureReplicas = M.kubeZnnD.desiredReplicas - 1;
  condition {
    !sloRed && isStable && M.kubeZnnD.minReplicas < M.kubeZnnD.desiredReplicas;
  }
  action {
    M.scaleDown(M.kubeZnnD, 1);
  }
  effect @[35000] {
    futureReplicas == M.kubeZnnD.desiredReplicas;
  }
}

tactic adjustReplicas(){
  int futureReplicas = 1;
  int scalingDown = M.kubeZnnD.desiredReplicas - 1;
  condition {
    M.kubeZnnD.maxReplicas < M.kubeZnnD.desiredReplicas;
  }
  action {
    M.scaleDown(M.kubeZnnD, scalingDown);
  }
  effect @[35000] {
    M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas;
  }

}