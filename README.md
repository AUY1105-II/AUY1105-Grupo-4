# AUY1105 — Grupo 4

Repositorio de la evaluación (**Infraestructura como código II**): red y cómputo en **AWS** descritos con **Terraform**, revisión automática en **GitHub Actions** y políticas **OPA (Rego)** sobre planes en JSON.

## Objetivos del trabajo

- Declarar una **VPC** (`10.1.0.0/16`) con subredes públicas y privadas en **/24**, NAT y VPN gateway, usando el módulo oficial de Terraform para VPC.
- Añadir un **security group** con **SSH (puerto 22)** solo desde la **CIDR** que indiques en variables (`my_ip`).
- Desplegar una **EC2** `t2.micro` (AMI Ubuntu en **us-east-1**), en subred pública, con el módulo **ec2-instance** compatible con **hashicorp/aws ~> 6**.
- Validar calidad y seguridad en **pull requests** hacia `main` y documentar uso y estructura del repositorio.

## Requisitos previos

- Cuenta **AWS** y credenciales configuradas (perfil `~/.aws/credentials` o variables de entorno que use el provider).
- **Terraform ≥ 1.5** (en CI se usa **1.9.0**).
- Para reproducir localmente los mismos chequeos del pipeline: [TFLint](https://github.com/terraform-linters/tflint), [Checkov](https://www.checkov.io/), [OPA](https://www.openpolicyagent.org/).

La región del provider está fijada en **`us-east-1`** (`providers.tf`).

## Variables

| Variable        | Uso |
|-----------------|-----|
| `project_name`  | Prefijo en nombres de VPC, security group e instancia. |
| `environment`   | Etiqueta de entorno (por ejemplo `dev`, `prod`). |
| `my_ip`         | CIDR desde la que se permite **SSH** al security group (evita `0.0.0.0/0` en entornos reales; las políticas OPA lo rechazan en evaluación de planes). |

Crea un archivo **`terraform.tfvars`** (no lo subas si contiene datos sensibles) con valores acordes a tu red, por ejemplo:

```hcl
project_name = "app"
environment  = "dev"
my_ip        = "203.0.113.10/32"
```

En el repositorio existe **`terraform.tfvars.example`** como referencia de claves; ajústalo y copia el contenido a `terraform.tfvars` si lo usas en local.

## Uso de Terraform (local)

Cada comando sirve para un paso concreto del ciclo de trabajo antes de aplicar infraestructura real.

| Paso | Comando | Para qué sirve |
|------|---------|----------------|
| 1 | `terraform init` | Descarga **providers** y **módulos** (VPC y EC2 desde el registry) y prepara el directorio `.terraform/`. Sin esto, `validate` y `plan` no funcionan. |
| 2 | `terraform fmt -recursive` | Formatea los `.tf` con el estilo estándar de Terraform. En CI se usa `fmt -check` (falla si algo no está formateado). |
| 3 | `terraform validate` | Comprueba que la sintaxis y los tipos sean válidos **para el provider y la versión de Terraform** cargados tras `init` (no llama a AWS). |
| 4 | `terraform plan` | Calcula el **plan** de cambios contra tu cuenta AWS (requiere credenciales). Revísalo antes de `apply`. |
| 5 | `terraform apply` | Aplica el plan y crea o modifica recursos. Úsalo solo cuando el plan sea el esperado. |

Opcional, mismas herramientas que en el pipeline:

- **`tflint --init`** y **`tflint`**: reglas de estilo y buenas prácticas sobre Terraform.
- **`checkov -d . --framework terraform ...`**: análisis de seguridad sobre los archivos `.tf` (los flags exactos coinciden con el workflow).

## Políticas OPA (Rego)

En **`policies/`** hay reglas pensadas para evaluar un **plan en JSON** (`terraform show -json tfplan`) y pruebas unitarias con **`opa test`**.

| Archivo | Rol |
|---------|-----|
| `deny_public_ssh.rego` | Niega reglas de ingreso **SSH** abiertas a **`0.0.0.0/0`** en `aws_security_group`, `aws_vpc_security_group_ingress_rule` y `aws_security_group_rule`. |
| `only_t2_micro.rego`   | Niega instancias **`aws_instance`** cuyo `instance_type` no sea **`t2.micro`**. |
| `policy_test.rego`     | Casos de prueba (`opa test`) que comprueban que las políticas permiten o deniegan escenarios esperados. |

| Comando | Para qué sirve |
|---------|----------------|
| `opa test policies/` | Ejecuta las pruebas **Rego** del paquete `main` sin necesidad de AWS. Es el mismo paso que en GitHub Actions. |

Evaluar políticas contra un **plan real**:

```bash
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
# Luego puedes pasar tfplan.json a OPA/Conftest según la consigna de la evaluación.
```

## Estructura del código Terraform

| Archivo | Contenido relevante |
|---------|----------------------|
| `providers.tf` | Bloque `terraform` con **Terraform ≥ 1.5** y provider **hashicorp/aws ~> 6.0**; bloque `provider "aws"` con región **us-east-1**. |
| `variables.tf` | `project_name`, `environment`, `my_ip`. |
| `main.tf` | Módulo **VPC** (`terraform-aws-modules/vpc/aws`, `~> 5.0`): CIDR `10.1.0.0/16`, 3 AZs, subredes públicas/privadas **/24**, NAT y VPN gateway. **Security group** con SSH desde `my_ip`. Módulo **EC2** (`terraform-aws-modules/ec2-instance/aws`, `~> 6.1`): `t2.micro`, AMI Ubuntu, `key_name`, subred pública y el security group anterior. |
| `outputs.tf` | Salidas mínimas tras `apply`: **`ec2_public_ip`**, **`ec2_instance_name`** y **`vpc_name`**. |

## GitHub Actions

El workflow **`.github/workflows/iac-pr.yml`** se dispara en **pull request** hacia la rama **`main`**. Cada paso automatiza una revisión distinta:

| Orden | Paso | Explicación breve |
|-------|------|-------------------|
| 1 | **Checkout** | Clona el repositorio en el runner para ejecutar el resto de comandos. |
| 2 | **Configurar Terraform** (`setup-terraform`, versión **1.9.0**) | Instala el binario de Terraform con la versión fijada para que `fmt`, `init` y `validate` sean reproducibles. |
| 3 | **`terraform fmt -check -recursive`** | Falla el job si algún archivo `.tf` no cumple el formato oficial (misma convención que `terraform fmt`). |
| 4 | **`terraform init -backend=false -input=false`** | Inicializa módulos y providers **sin configurar backend remoto** (adecuado para validar solo el código en CI). |
| 5 | **TFLint** (instalación, `tflint --init`, `tflint`) | Análisis estático adicional sobre la configuración Terraform. |
| 6 | **Checkov** | Escaneo de seguridad sobre el marco **terraform** del directorio actual; se excluye la carpeta **`policies/`** del análisis Terraform y se omiten comprobaciones concretas (`CKV_TF_1`, `CKV_AWS_24`, `CKV_AWS_382`, `CKV2_AWS_5`) alineadas al alcance del proyecto. |
| 7 | **`terraform validate`** | Valida la configuración ya inicializada (coherencia con el **AWS provider 6.x** y los módulos descargados). |
| 8 | **OPA** (instalación) y **`opa test policies/`** | Ejecuta las pruebas de las políticas **Rego** (requisito de políticas como código con tests automatizados). |
