module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };
import lib "tactics.s";

define boolean sloRed = M.kubeZnnS.slo <= 0.95;
define boolean sloGreen = M.kubeZnnS.slo >= 0.99;

define boolean canAddReplica = M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas;
define boolean canRemoveReplica = M.kubeZnnD.minReplicas < M.kubeZnnD.desiredReplicas;

define boolean mismatchingReplicas = M.kubeZnnD.desiredReplicas > M.kubeZnnD.maxReplicas;

define boolean NoFailureRate = M.failureManagerS.cpufailure == 0.0;
define boolean LowFailureRate = M.failureManagerS.cpufailure > 0.0 && M.failureManagerS.cpufailure <= 0.5;
define boolean HighFailureRate = M.failureManagerS.cpufailure > 0.5;

strategy deactivateScalabilityA [ LowFailureRate || HighFailureRate ] {  
  t0: (LowFailureRate || HighFailureRate) -> removeHighScalability() @[65000 /*ms*/] {
    t0a: (success) -> done;
  }   
  t1: (default) -> TNULL;
}

strategy activateScalabilityA [ NoFailureRate ] {  
  t0: (NoFailureRate) -> addHighScalability() @[65000 /*ms*/] {
    t0a: (success) -> done;
  }      
  t1: (default) -> TNULL;
}

/*
 * ----
 */
strategy ImproveSlo [ canAddReplica && sloRed ] {
  t0: (sloRed && canAddReplica) -> addReplica() @[45000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (default) -> TNULL;
}

/*
 * ----
 */
strategy ReduceCost [ sloGreen ] {
  t0: (sloGreen && canRemoveReplica) -> removeReplica() @[45000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (default) -> TNULL;
}

strategy AdjustDefaultReplicas [ mismatchingReplicas ] {
  t0: (mismatchingReplicas) -> adjustReplicas() @[65000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (default) -> TNULL;
}