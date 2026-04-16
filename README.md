# AUY1105 Grupo 4

Repositorio del **Parcial 1** (AUY1105 — Infraestructura como código II): infraestructura en **Terraform** sobre **AWS**, pipeline de calidad y seguridad con **GitHub Actions**, y **políticas OPA (Rego)** alineadas a la evaluación.

## Objetivos

- Definir en código una VPC con subredes `/24`, grupos de seguridad y una instancia **EC2 Ubuntu 24.04 LTS** `t2.micro`.
- Automatizar revisión en **pull requests** hacia `main`: **TFLint** → **Checkov** → **`terraform validate`** → **`opa test`** sobre las políticas.
- Documentar el proyecto y los cambios (`README`, `CHANGELOG`) y facilitar revisiones con plantilla de PR.