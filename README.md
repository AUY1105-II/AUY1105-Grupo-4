# AUY1105 Grupo 4

Repositorio del **Parcial 1** (AUY1105 — Infraestructura como código II): infraestructura en **Terraform** sobre **AWS**, pipeline de calidad y seguridad con **GitHub Actions**, y **políticas OPA (Rego)** alineadas a la evaluación.

## Objetivos

- Definir en código una VPC con subredes `/24`, grupos de seguridad y una instancia **EC2 Ubuntu 24.04 LTS** `t2.micro`.
- Automatizar revisión en **pull requests** hacia `main`: **TFLint** → **Checkov** → **`terraform validate`** → **`opa test`** sobre las políticas.
- Documentar el proyecto y los cambios (`README`, `CHANGELOG`) y facilitar revisiones con plantilla de PR.

## Requisitos previos

- Cuenta AWS y credenciales configuradas (perfil o variables de entorno estándar del provider).
- Terraform **≥ 1.5** (recomendado **1.9** como en CI).
- Opcional en local: [TFLint](https://github.com/terraform-linters/tflint), [Checkov](https://www.checkov.io/), [OPA](https://www.openpolicyagent.org/).

## Uso rápido

1. Copia variables de ejemplo y ajusta región y CIDR SSH permitido (**no** uses `0.0.0.0/0`; las políticas OPA y la rúbrica lo penalizan).

   ```bash
   cp terraform.tfvars.example.example terraform.tfvars.example
   ```

2. Inicializa y valida:

   ```bash
   terraform init
   terraform fmt -recursive
   terraform validate
   ```

3. Revisa el plan antes de aplicar:

   ```bash
   terraform plan
   ```

4. Políticas OPA (pruebas incluidas):

   ```bash
   opa test policies/
   ```

Para evaluar las políticas contra un **plan real** en JSON (flujo típico con Conftest u OPA):

```bash
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
# Con conftest (opcional): conftest test tfplan.json -p policies/
```

## Definición del código Terraform

| Área | Descripción |
|------|-------------|
| `providers.tf` | Configuración del provider y etiquetas por defecto. |
| `variables.tf` | `project_name`, `environment`, `aws_region`, `allowed_ssh_cidr`. |
| `main.tf` | VPC `10.1.0.0/16`, 3 subredes públicas y 3 privadas en `/24`, NAT, security group con **solo SSH** desde `allowed_ssh_cidr`, EC2 **Ubuntu 24.04** `t2.micro` con IMDSv2 obligatorio. |
| `outputs.tf` | IDs principales de red y cómputo. |
| `policies/` | Reglas **Rego** para: (1) prohibir SSH desde `0.0.0.0/0` y (2) permitir solo `t2.micro`. |

## GitHub Actions

El workflow `.github/workflows/iac-pr.yml` se ejecuta **únicamente** en **pull request** hacia **`main`**, en este orden:

1. **TFLint** — análisis estático.
2. **Checkov** — seguridad sobre archivos Terraform (se excluye `policies/` del escaneo Terraform).
3. **`terraform validate`** — validación de configuración.
4. **`opa test policies/`** — comprobación automatizada de las políticas (IL2.3).