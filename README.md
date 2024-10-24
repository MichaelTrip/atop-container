# Automated build for atop container


## Introduction

This is an automated build pipeline for the [atop](https://github.com/Atoptool/atop) that you can use to diagnose performance issues. This container can be used to debug processes and performance issues on Kubernetes worker nodes, for example.


## How to run this container on a Kubernetes host

### Run a pod on your node

You could use this by running a pod on a specific node. This can be done by using the following yaml file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: atop-container
  labels:
    app: atop-container
spec:
  containers:
  - name: atop
    image: ghcr.io/michaeltrip/atop-container:latest
    command: ["sh", "-c", "sleep infinity"]
    securityContext:
      privileged: true
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
    volumeMounts:
    - mountPath: /sys
      name: sys
      readOnly: true
    - mountPath: /var/run
      name: varrun
      readOnly: false
    - mountPath: /var/log
      name: varlog
      readOnly: false
    - mountPath: /proc
      name: proc
      readOnly: true
  hostNetwork: true
  hostPID: true
  volumes:
  - name: sys
    hostPath:
      path: /sys
  - name: varrun
    hostPath:
      path: /var/run
  - name: varlog
    hostPath:
      path: /var/log
  - name: proc
    hostPath:
      path: /proc
  restartPolicy: Never
  nodeSelector:
    kubernetes.io/hostname: "<nodename>"
  ```

This will run a privileged pod with a sleep infinity. From there you can exec into the pod:

```bash
kubectl exec -it <podname> -- /bin/bash
```


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
      - name: atop
        image: ghcr.io/michaeltrip/atop-container:latest
        command: ["sh", "-c", "sleep infinity"]
        securityContext:
          privileged: true
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        volumeMounts:
        - mountPath: /sys
          name: sys
          readOnly: true
        - mountPath: /var/run
          name: varrun
          readOnly: false
        - mountPath: /var/log
          name: varlog
          readOnly: false
        - mountPath: /proc
          name: proc
          readOnly: true
      hostNetwork: true
      hostNetwork: true
      hostPID: true
      volumes:
      - name: sys
        hostPath:
          path: /sys
      - name: varrun
        hostPath:
          path: /var/run
      - name: varlog
        hostPath:
          path: /var/log
      - name: proc
        hostPath:
          path: /proc
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

## Persistency of atop log files

If you want the atop logfiles to persist, you have to mount `/var/log/atop` to a persistent volume.


