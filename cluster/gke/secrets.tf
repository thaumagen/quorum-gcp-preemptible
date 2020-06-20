# Do these as a single map keyed resource so they can be indexed by secret id
resource "google_secret_manager_secret" "qnode" {
  project = var.project
  provider           = google-beta
  for_each = toset([
    "qnode-0-key", "qnode-0-enode",
    "qnode-1-key", "qnode-1-enode",
    "qnode-2-key", "qnode-2-enode" ])
  secret_id = each.key
  replication {
    automatic = true
  }
}

# google_secret_manager_secret.qnode["qnode-0-enode"]: Refreshing state... [id=projects/quorumpreempt/secrets/qnode-0-enode]
resource "google_secret_manager_secret_iam_member" "qnode-key" {
  project = var.project
  count = var.max_quorum_nodes
  provider           = google-beta
  secret_id = google_secret_manager_secret.qnode["qnode-${count.index}-key"].secret_id
  role = "roles/secretmanager.secretAccessor"
  member = module.quorum-node.gcp_service_account_fqn
}

resource "google_secret_manager_secret_iam_member" "qnode-enode" {
  project = var.project
  count = var.max_quorum_nodes
  provider           = google-beta
  secret_id = google_secret_manager_secret.qnode["qnode-${count.index}-enode"].secret_id
  role = "roles/secretmanager.secretAccessor"
  member = module.quorum-node.gcp_service_account_fqn
}
