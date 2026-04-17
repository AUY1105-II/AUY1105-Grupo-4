# Registro de Cambios (Changelog)

Todas las novedades significativas de este proyecto se documentarán en este archivo.

## 17-04-2026

### Añadido
- Directorio `policies/` con políticas en Rego: `deny_public_ssh.rego` (SSH no expuesto a `0.0.0.0/0`) y `only_t2_micro.rego` (solo tipo de instancia `t2.micro`).
- Tests unitarios automatizados en `policy_test.rego` para validación de políticas OPA en CI/CD.
- Exclusión explícita de `*.tfvars` en `.gitignore` para mitigar riesgo de fuga de secretos.
- Plantilla segura `terraform.tfvars.example` (reemplazando archivo local con IPs expuestas).
- Incorporación de archivo `outputs.tf` para la obtención de datos básicos de infraestructura creada.

### Cambiado
- **IaC/Cloud:** Actualización del módulo `ec2-instance` a `~> 6.1` para garantizar compatibilidad nativa con AWS Provider v6.
- **IaC/Cloud:** Fijación de dependencias (VPC a `~> 5.0`, Terraform a `>= 1.5.0`) asegurando el pilar de Fiabilidad del Well-Architected Framework.
- **DevSecOps:** Delegación de supresiones de falsos positivos de Checkov (`--skip-check`) directamente a nivel de pipeline en `.github/workflows/iac-pr.yaml`.
- **Código:** Estandarización canónica de sintaxis en todos los archivos `.tf` mediante `terraform fmt`.
- **Validaciones:** Se añaden capturas de validaciones locales y en Github Actions en `README.md`.

### Arreglado
- **GitOps:** Restauración crítica del estado de la infraestructura (`main.tf`, `providers.tf`) en rama `feat/eva1`, revirtiendo orden de eliminación accidental proveniente de `main`.
- **CI/CD:** Resolución de error de indentación YAML que rompía la ejecución secuencial en GitHub Actions.
- **Terraform:** Resolución de fallos de validación por atributos deprecados (`cpu_core_count`, `cpu_threads_per_core`) sincronizando la versión del módulo EC2 con la del Provider.
- **Estandarización:** Se modifica plantilla de `README.md` para una correcta lectura.

---

## 15-04-26

### Añadido

- Creación de archivos iniciales:
    - CHANGELOG.md
    - main.tf
    - providers.tf
    - README.md
    - variables.tf

- Incorporación de pruebas mediante pipeline en archivo iac-pr.yml

### Cambios

-Modificación de archivos:
-Estructura de archivo README.md

### Eliminación

- Eliminación de archivos en rama main, por carga de erronea en rama principal.