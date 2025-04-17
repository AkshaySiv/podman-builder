# 🐳 Podman-in-Pod: Secure DinD Replacement for Jenkins Agents on Kubernetes

This project provides a **lightweight, secure alternative to Docker-in-Docker (DinD)** using **Podman**, designed specifically for **Jenkins JNLP agent pods** running in Kubernetes.

## 🚀 Overview

A container image that:
- Runs **Podman** as a background service inside a minimal container.
- Exposes the Podman socket over **`tcp://0.0.0.0:2375`** for Docker-compatible CLI and tools.
- Replaces insecure DinD setups in **Kubernetes CI/CD pipelines**, especially Jenkins worker pods.
- Is based on **Red Hat UBI 8 Minimal**, optimized for enterprise use.

---

## ✅ Use Case: Jenkins + Kubernetes (JNLP Agent)

- Jenkins master dynamically spins up worker pods using the Kubernetes plugin.
- This Podman-based image acts as a **build runtime** container in the pod.
- Supports container build and image operations via Docker-compatible commands.

