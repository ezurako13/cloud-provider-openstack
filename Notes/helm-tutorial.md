# Interactive Helm Chart Tutorial
*Estimated time: 30 minutes*

## Prerequisites
- Kubernetes cluster (can be local like minikube or kind)
- Helm CLI installed
- Basic understanding of YAML
- kubectl configured

## 1. Understanding Helm Charts (5 minutes)

### What is a Helm Chart?
A Helm chart is a package format for Kubernetes applications. Think of it as a bundle containing:
- Kubernetes manifest templates
- Default values
- Chart metadata
- Optional dependencies

### Basic Structure
```
mychart/
  ├── Chart.yaml          # Chart metadata
  ├── values.yaml         # Default configuration values
  ├── templates/          # Template files
  │   ├── deployment.yaml
  │   ├── service.yaml
  │   └── _helpers.tpl    # Template helpers
  └── charts/             # Dependencies (optional)
```

## 2. Hands-on: Creating Your First Chart (5 minutes)

🔨 **Exercise 1: Create a new chart**
```bash
# Create a new directory for your chart
mkdir first-chart
cd first-chart

# Create the basic chart structure
mkdir templates
touch Chart.yaml values.yaml
touch templates/deployment.yaml templates/service.yaml
```

Now, let's populate Chart.yaml:
```yaml
apiVersion: v2
name: first-chart
description: My first Helm chart
version: 0.1.0
appVersion: "1.0.0"
```

## 3. Understanding Values and Templates (10 minutes)

### values.yaml
This file defines default values that can be overridden. Let's create a simple one:

```yaml
# values.yaml
replicaCount: 1
image:
  repository: nginx
  tag: "1.21.1"
service:
  type: ClusterIP
  port: 80
```

🔨 **Exercise 2: Create deployment template**
Create `templates/deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: 80
```

🔨 **Exercise 3: Create service template**
Create `templates/service.yaml`:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-service
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: 80
  selector:
    app: {{ .Release.Name }}
```

## 4. Template Functions and Pipelines (5 minutes)

Helm uses Go templating. Here are some common functions:

- `quote`: Wraps a string in quotes
- `default`: Sets a default value
- `upper`: Converts to uppercase
- `nindent`: Indents text with newline

🔨 **Exercise 4: Add some template functions**
Update your deployment.yaml to include:
```yaml
metadata:
  name: {{ .Release.Name }}-deployment
  labels:
    app.kubernetes.io/name: {{ .Chart.Name | upper }}
    app.kubernetes.io/instance: {{ .Release.Name | quote }}
```

## 5. Testing and Debugging (5 minutes)

### Test your templates:
```bash
# Test template rendering
helm template .

# Check for potential issues
helm lint .

# Do a dry run
helm install --dry-run --debug my-release .
```

🔨 **Exercise 5: Debug your chart**
1. Run the commands above
2. Fix any issues you find
3. Verify the output looks correct

## Final Challenge
Now that you've learned the basics, create a chart for a simple web application with:
1. A deployment with 2 replicas
2. A service exposing port 80
3. A configurable image tag
4. Resource limits

## Tips for Success
- Always use version control for your charts
- Document your values.yaml
- Test thoroughly before deployment
- Use helm lint frequently

## Common Pitfalls to Avoid
1. Not quoting string values in templates
2. Forgetting to update Chart.yaml version
3. Not handling optional values properly
4. Missing dependencies in requirements.yaml

## Next Steps
- Learn about Helm hooks
- Explore chart dependencies
- Study chart best practices
- Create charts with multiple resources

Congratulations! You now know how to create a basic Helm chart. Try deploying it to your cluster with:
```bash
helm install my-release .
```
