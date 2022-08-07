#Create Kubernetes provider

provider "kubernetes" {
  config_path = "~/.kube/config"
}

#create a namespace for the kubernetes deployment
resource "kubernetes_namespace" "products" {
  metadata {
    name = "products"
  }
}

#create kubernetes secret for the postgres db
resource "kubernetes_secret" "products_db" {
  metadata {
    name      = "postgresdb"
    namespace = kubernetes_namespace.products.metadata.0.name
  }

  data = {
    DATABASE_URL = var.database_url
  }

  type = "Opaque"
}


#Create a deployment (a deployment defines how we want our pods to run from number of replicas, to the name, etc.)

resource "kubernetes_deployment" "products_deployment" {
  metadata {
    name      = "products" # Define the name of the deployment
    namespace = "products" #the namespace that this deployment is associated with
  }

  spec {
    replicas = 1 #specify the number of pods 

    selector {
      match_labels = {
        app = "products_api" #Define the selector
      }
    }

    template {
      metadata {
        labels = {
          app = "products_api"
        }
      }

      spec {
        container {                                #Define the container details
          image = "scottyfullstack/basic-rest-api" #image of the container (used dockerhub, pulled api container there)
          name  = "products"
          port {
            container_port = 8000
          }
          env {
            name = "DATABASE_URL"
          }
          env_from {

            secret_ref {

              name = kubernetes_secret.products_db.metadata.0.name
            }

          }
        }
        volume {
            name="${kubernetes_secret.products_db.metadata.0.name}"
            secret {
              secret_name = "${kubernetes_secret.products_db.metadata.0.name}"
            }

        }
      }
    }
  }
}
#create a kubernetes service (service is what traffic we want to flow to our pods. what do you want your pods "exposed" to traffic wise)

resource "kubernetes_service" "products_service" {
  metadata {
    name      = "products-service"
    namespace = kubernetes_namespace.products.metadata.0.name
  }
  spec {
    selector = {
      app = "${kubernetes_deployment.products_deployment.spec.0.template.0.metadata.0.labels.app}"
    }
    type = "NodePort"
    port {
      port        = 8000
      target_port = 8000
    }
  }
}