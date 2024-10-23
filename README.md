# Automated build for atop container


## Introduction

This is an automated build pipeline for the [atop](https://github.com/Atoptool/atop) that you can use to diagnose performance issues. This container can be used to debug processes and performance issues on Kubernetes worker nodes, for example.


## How to run this container on a Kubernetes host

### `kubectl debug node`

You could use this by running a interactive pod for debugging purposes. In that case run:

```bash
kubectl debug -it node/<nodename> --image=ghcr.io/michaeltrip/atop-container:latest
```

This will start a privileged pod on the node. You can run atop from here.

### `DaemonSet`

You can also create a `DaemonSet` that will run on all nodes. Take a look at the example below:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: atop-container
  labels:
    app: atop-container
spec:
  selector:
    matchLabels:
      app: atop-container
  template:
    metadata:
      labels:
        app: atop-container
    spec:
      containers:
      - name: atop-container
        image: ghcr.io/michaeltrip/atop-container:latest
        securityContext:
          privileged: true
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
          requests:
            memory: "64Mi"
            cpu: "250m"
      hostNetwork: true
      hostPID: true
      tolerations:
      - effect: NoSchedule
        operator: Exists
      restartPolicy: Always
```

And apply with:

```bash
kubectl apply -f daemonset.yaml
```

After that, you can execute directly on the daemonset running on your node with `kubectl exec -it <podname> -- /bin/bash` and start atop from there.


