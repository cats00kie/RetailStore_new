# RetailStore

E-commerce de microservicios con pipeline DevOps completo sobre AWS ECS Fargate. Incluye catálogo de productos, carrito, checkout, gestión de órdenes y panel de administración.

---

## Tabla de Contenidos

- [Inicio rápido (local)](#inicio-rápido-local)
- [Arquitectura de microservicios](#arquitectura-de-microservicios)
- [Tecnologías por servicio](#tecnologías-por-servicio)
- [Variables de entorno](#variables-de-entorno)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Pipelines CI/CD](#pipelines-cicd)
- [Despliegue en AWS](#despliegue-en-aws)
- [Observabilidad](#observabilidad)
- [Testing](#testing)
- [Estrategia de ramas](#estrategia-de-ramas)

---

## Inicio rápido (local)

**Requisitos:**
- [Docker](https://docs.docker.com/get-docker/) 24+
- [Docker Compose](https://docs.docker.com/compose/install/) v2.20+

```bash
docker compose up --build
```

| Servicio | URL                   |
|----------|-----------------------|
| Tienda   | http://localhost:8080 |
| Admin    | http://localhost:8081 |

Credenciales del admin: `admin` / `admin`

```bash
# Detener los servicios
docker compose down

# Resetear base de datos
docker compose down -v

# Reconstruir un servicio específico
docker compose up --build <servicio>

# Ver logs
docker compose logs -f <servicio>
```

---

## Arquitectura de microservicios

```
          ┌──────────────────────────────────────────────────┐
          │               Usuario / Navegador                │
          └────────────────────────┬─────────────────────────┘
                                   │ HTTP
          ┌────────────────────────▼─────────────────────────┐
          │                   UI  :8080                      │
          │            Node.js 22 / Express                  │
          └───────┬──────────┬──────────┬────────────┬───────┘
                  │          │          │            │  HTTP (proxy)
        ┌─────────▼────┐ ┌───▼─────┐ ┌──▼────────┐ ┌▼──────────┐
        │   Catalog    │ │  Cart   │ │ Checkout  │ │  Orders   │
        │    :8080     │ │  :8080  │ │  :8080    │ │  :8080    │
        │  Go / Gin    │ │ Python  │ │ NestJS/TS │ │ Go / Gin  │
        └──────┬───────┘ └────┬────┘ └─────┬─────┘ └─────┬─────┘
               │              │            │  HTTP        │
               │              │            └─────────────►│
               │              │     ┌───────────────┐     │
               │              │     │    Redis 7    │◄────┤
               │              │     └───────────────┘     │
               └──────────────┴───────────────────────────┘
                                          │
        ┌─────────────────────────────────▼──────────────────────┐
        │                      PostgreSQL 16                     │
        │          catalogdb     │    cartdb    │    orders      │
        └────────────────────────────────────────────────────────┘

          ┌──────────────────────────────────────────────────┐
          │                  Admin  :8081                    │
          │            Node.js 22 / Express                  │
          └────────────────────────┬─────────────────────────┘
                                   │ SQL directo
          ┌────────────────────────▼─────────────────────────┐
          │                  PostgreSQL 16                   │
          └──────────────────────────────────────────────────┘
```

### Flujo de comunicación

| Origen     | Destino    | Protocolo | Descripción                              |
|------------|------------|-----------|------------------------------------------|
| UI         | Catalog    | HTTP REST | Listar y consultar productos             |
| UI         | Cart       | HTTP REST | Agregar, quitar y consultar carrito      |
| UI         | Checkout   | HTTP REST | Iniciar y confirmar el proceso de pago   |
| UI         | Orders     | HTTP REST | Consultar historial de órdenes           |
| Checkout   | Orders     | HTTP REST | Crear orden al confirmar checkout        |
| Checkout   | Redis      | TCP       | Persistencia de sesión de checkout       |
| Catalog    | PostgreSQL | TCP       | Base de datos `catalogdb`                |
| Cart       | PostgreSQL | TCP       | Base de datos `cartdb`                   |
| Orders     | PostgreSQL | TCP       | Base de datos `orders`                   |
| Admin      | PostgreSQL | TCP       | Acceso directo a todas las bases         |

---

## Tecnologías por servicio

| Servicio     | Lenguaje       | Framework        | Runtime         | Persistencia      | Puerto externo |
|--------------|----------------|------------------|-----------------|-------------------|----------------|
| **ui**       | TypeScript     | Express          | Node.js 22      | —                 | 8080           |
| **catalog**  | Go 1.24        | Gin + GORM       | Alpine Linux    | PostgreSQL        | —              |
| **cart**     | Python 3.12    | FastAPI          | Python slim     | PostgreSQL        | —              |
| **checkout** | TypeScript     | NestJS           | Node.js 22      | Redis             | —              |
| **orders**   | Go 1.24        | Gin + GORM       | Alpine Linux    | PostgreSQL        | —              |
| **admin**    | TypeScript     | Express          | Node.js 22      | PostgreSQL        | 8081           |
| **db**       | —              | PostgreSQL 16    | —               | —                 | —              |
| **redis**    | —              | Redis 7          | Alpine Linux    | —                 | —              |

### Dependencias clave

| Servicio     | Dependencias destacadas                                               |
|--------------|-----------------------------------------------------------------------|
| **catalog**  | `gin-gonic/gin`, `gorm`, `go-gorm/postgres`, OpenTelemetry           |
| **cart**     | `FastAPI`, `Uvicorn`, `Pydantic`, `psycopg2`, Prometheus client       |
| **checkout** | `NestJS`, `ioredis`, `class-validator`, OpenTelemetry                 |
| **orders**   | `gin-gonic/gin`, `gorm`, `go-gorm/postgres`, Prometheus              |
| **ui**       | `express`, `http-proxy-middleware`                                    |
| **admin**    | `express`, `pg`, `jsonwebtoken`, `cookie-parser`                      |

---

## Variables de entorno

### UI
| Variable                        | Descripción                  | Default               |
|---------------------------------|------------------------------|-----------------------|
| `RETAIL_UI_ENDPOINTS_CATALOG`   | URL del servicio catalog     | `http://catalog:8080` |
| `RETAIL_UI_ENDPOINTS_CARTS`     | URL del servicio cart        | `http://carts:8080`   |
| `RETAIL_UI_ENDPOINTS_CHECKOUT`  | URL del servicio checkout    | `http://checkout:8080`|
| `RETAIL_UI_ENDPOINTS_ORDERS`    | URL del servicio orders      | `http://orders:8080`  |

### Catalog / Orders / Cart
| Variable                               | Descripción           | Default          |
|----------------------------------------|-----------------------|------------------|
| `RETAIL_CATALOG_PERSISTENCE_PROVIDER`  | Tipo de persistencia  | `postgres`       |
| `RETAIL_CATALOG_PERSISTENCE_ENDPOINT`  | Host:Puerto de la DB  | `db:5432`        |
| `DB_PASSWORD`                          | Contraseña PostgreSQL | `retailpassword` |

### Checkout
| Variable                                   | Descripción              | Default               |
|--------------------------------------------|--------------------------|------------------------|
| `RETAIL_CHECKOUT_PERSISTENCE_PROVIDER`     | Tipo de persistencia     | `redis`               |
| `RETAIL_CHECKOUT_PERSISTENCE_REDIS_URL`    | URL de Redis             | `redis://redis:6379`  |
| `RETAIL_CHECKOUT_ENDPOINTS_ORDERS`         | URL del servicio orders  | `http://orders:8080`  |

### Admin
| Variable            | Descripción                | Default                   |
|---------------------|----------------------------|---------------------------|
| `ADMIN_USERNAME`    | Usuario administrador      | `admin`                   |
| `ADMIN_PASSWORD`    | Contraseña administrador   | `admin`                   |
| `ADMIN_JWT_SECRET`  | Secreto para tokens JWT    | `change-me-in-production` |

---

## Estructura del repositorio

---

## Estructura del repositorio

```
RetailStore/
├── .github/
│   └── workflows/
│       ├── ci.yml          # Pipeline de integración continua
│       ├── cd.yml          # Pipeline de despliegue continuo
│       └── infra.yml       # Pipeline de infraestructura (Terraform)
├── infra/
│   ├── modules/
│   │   ├── networking/     # VPC, subnets, IGW, NAT Gateway
│   │   ├── ecr/            # Repositorios de imágenes Docker
│   │   ├── ecs/            # Cluster ECS Fargate
│   │   ├── ecs_service/    # Task Definition + Service + ALB
│   │   ├── rds/            # Instancias RDS PostgreSQL
│   │   ├── cloudwatch/     # Dashboard, alarmas y SNS
│   │   └── lambda/         # Función Lambda + Subscription Filter
│   └── environments/
│       ├── dev/            # terraform.tfvars del ambiente DEV
│       ├── test/           # terraform.tfvars del ambiente TEST
│       └── prod/           # terraform.tfvars del ambiente PROD
├── src/
│   ├── admin/              # TypeScript / Express — panel de administración
│   ├── cart/               # Python / FastAPI — carrito de compras
│   ├── catalog/            # Go / Gin — catálogo de productos
│   ├── checkout/           # TypeScript / NestJS — proceso de pago
│   ├── orders/             # Go / Gin — gestión de órdenes
│   └── ui/                 # TypeScript / Express — frontend
├── tests/
│   └── RetailStore.postman_collection.json
├── docker-compose.yml
└── init-db.sql
```

---

## Pipelines CI/CD

Hay tres pipelines independientes, cada uno con su responsabilidad.

### CI (`ci.yml`)

Se ejecuta en cada push y pull request a `develop`, `test` y `main`. Primero detecta qué microservicio cambió (usando `dorny/paths-filter`) para no correr análisis innecesarios.

| Job | Descripción |
|-----|-------------|
| `changes` | Detecta qué servicios fueron modificados |
| `go-lint` | `golangci-lint` + `go vet` — catalog y orders |
| `python-lint` | `flake8` — cart |
| `ts-lint` / `ts-build` | ESLint + compilación TypeScript — ui, admin, checkout |
| `gitleaks` | Detección de secrets hardcodeados |
| `dependency-check` | `go mod`, `pip-audit`, `npm audit` |
| `build-images` | Build de las 6 imágenes Docker (sin publicar) |
| `trivy-scan` | Escaneo de vulnerabilidades; resultados SARIF a GitHub Security |
| `newman-tests` | `docker compose up` + colección Postman vía Newman |
| `ci-status` | Quality gate: falla el pipeline si algún job previo falló |

Solo si `ci-status` pasa, se dispara el pipeline CD.

Para correr el linter de TypeScript localmente:

```bash
cd src/ui      && npm run lint
cd src/admin   && npm run lint
cd src/checkout && npm run lint
```

### CD (`cd.yml`)

Se dispara automáticamente por `workflow_run` cuando el CI pasa en `develop`, `test` o `main`. También puede ejecutarse manualmente desde la UI de GitHub Actions.

| Rama | Ambiente AWS |
|------|-------------|
| `develop` | DEV |
| `test` | TEST |
| `main` | PROD |

Etapas: **Guard** (verifica que CI pasó y resuelve el ambiente) → **Build & Push** (construye las 6 imágenes y las publica en ECR con tag `{sha}` y `latest`) → **Deploy** (actualiza cada ECS Service con la nueva imagen y espera estabilización).

### Infra (`infra.yml`)

Se ejecuta cuando hay cambios en `infra/environments/` o `infra/modules/`. Mapea la rama al ambiente correspondiente y corre `init → validate → plan → apply`. En pull requests solo comenta el plan; el `apply` ocurre únicamente en push.

---

## Despliegue en AWS

### Prerrequisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [AWS CLI](https://aws.amazon.com/cli/) configurado con credenciales de AWS Academy
- Bucket S3 para el estado remoto de Terraform: `obligatorio-devops-tfstate`

### GitHub Secrets requeridos

Estos secrets deben estar configurados en el repositorio antes de ejecutar los pipelines:

| Secret | Descripción |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | Credenciales AWS Academy |
| `AWS_SECRET_ACCESS_KEY` | Credenciales AWS Academy |
| `AWS_SESSION_TOKEN` | Token de sesión AWS Academy |
| `ORDERS_DB_PASSWORD` | Contraseña de la instancia RDS de orders |
| `CATALOG_DB_PASSWORD` | Contraseña de la instancia RDS de catalog |

### Despliegue manual de infraestructura

```bash
cd infra/environments/dev

terraform init \
  -backend-config="bucket=obligatorio-devops-tfstate" \
  -backend-config="key=dev/terraform.tfstate" \
  -backend-config="region=us-east-1"

terraform plan \
  -var="orders_db_password=<PASSWORD>" \
  -var="catalog_db_password=<PASSWORD>"

terraform apply \
  -var="orders_db_password=<PASSWORD>" \
  -var="catalog_db_password=<PASSWORD>"
```

Repetir en `environments/test` y `environments/prod` según corresponda.

### Recursos que se crean por ambiente

| Módulo | Recursos |
|--------|----------|
| `networking` | VPC, 2 subnets públicas, 2 subnets privadas, IGW, 1 NAT Gateway |
| `ecr` | 6 repositorios ECR (uno por microservicio) |
| `ecs` | 1 cluster ECS Fargate |
| `ecs_service` | 6 Task Definitions + 6 ECS Services + 6 ALBs |
| `rds` | 2 instancias RDS PostgreSQL 16 (orders y catalog) |
| `cloudwatch` | 1 dashboard, 5 alarmas, 1 SNS topic |
| `lambda` | 1 función Lambda + 5 CloudWatch Log Subscription Filters |

### Configuración de notificaciones por email

Para recibir alertas de CloudWatch por email, completar `alarm_email` en el `terraform.tfvars` del ambiente:

```hcl
alarm_email = "tu@email.com"
```

Después del `apply`, AWS enviará un correo de confirmación de suscripción SNS que debe aceptarse para activar las notificaciones.

---

## Observabilidad

El módulo `cloudwatch` despliega un dashboard y cinco alarmas sobre el servicio UI (punto de entrada con ALB):

| Alarma | Condición |
|--------|-----------|
| `ecs-cpu-high` | CPU > 80% por 2 períodos de 5 min |
| `ecs-memory-high` | Memoria > 80% por 2 períodos de 5 min |
| `alb-5xx-errors` | Errores 5XX > 10 en 5 min |
| `alb-unhealthy-hosts` | Hosts sin salud >= 1 |
| `alb-response-time` | Latencia > 2 segundos |

Complementariamente, una función Lambda analiza los logs de los 5 microservicios principales buscando palabras clave de error (`ERROR`, `FATAL`, `PANIC`, `EXCEPTION`, `CRITICAL`) y publica alertas en el mismo SNS topic cuando las detecta.

Cada microservicio escribe sus logs en `/ecs/retail-{servicio}-{env}` con retención de 7 días.

---

## Testing

Las pruebas funcionales se ejecutan automáticamente en el pipeline CI mediante Newman (Postman CLI). La colección está en `tests/RetailStore.postman_collection.json` y cubre los endpoints principales de todos los servicios.

Para correr las pruebas localmente:

```bash
# Levantar la aplicación
docker compose up -d --build

# Esperar que los servicios estén listos e instalar Newman
npm install -g newman

# Ejecutar la colección
newman run tests/RetailStore.postman_collection.json
```

---

## Estrategia de ramas

**Código de aplicación** — Git Flow simplificado:

| Rama | Propósito |
|------|-----------|
| `main` | Producción estable |
| `test` | Ambiente de testing/staging |
| `develop` | Integración continua (DEV) |
| `feature/*` | Nuevas funcionalidades |
| `fix/*` | Corrección de bugs |

Flujo estándar: `feature/*` → PR → `develop` → (CI pasa) → merge a `test` → merge a `main`.

**Código de infraestructura** — Feature Branch: cada cambio en `infra/` se desarrolla en una rama dedicada y se integra con PR. El pipeline Infra aplica los cambios automáticamente al hacer merge.
